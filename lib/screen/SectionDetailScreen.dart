import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class SectionDetailScreen extends StatefulWidget {
  final String sectionId;
  final String sectionName;

  SectionDetailScreen({required this.sectionId, required this.sectionName});

  @override
  _SectionDetailScreenState createState() => _SectionDetailScreenState();
}

class _SectionDetailScreenState extends State<SectionDetailScreen> {
  List<Map<String, dynamic>> menuItems = [];
  List<Map<String, dynamic>> orderItems = [];
  List<Map<String, dynamic>> mergedItems = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    startPolling();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startPolling() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchData());
  }

  Future<void> fetchData() async {
    await fetchMenuData();
    await fetchOrderData();
    mergeData();
  }

  Future<void> fetchMenuData() async {
    final response = await http.get(Uri.parse('http://192.168.56.1:4000/admin/branch/general-menu-list'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Map<String, dynamic>> items = (data['data'] as List)
          .map((item) => {'id': item['id'], 'name': item['name']})
          .toList();
      setState(() {
        menuItems = items;
      });
    } else {
      throw Exception('Failed to load menu data');
    }
  }

  Future<void> fetchOrderData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.56.1:4000/user/order/orderItemsBySection/${widget.sectionId}/2/pending'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> items = (data['data'] as List)
            .map((item) => {
                  'order_id': item['fn_order_id'],
                  'customer_id': item['fn_customer_id'],
                  'item_id': item['fn_item_id'],
                  'section_id': item['fn_section_id'],
                  'item_status': item['fn_item_status'],
                  'quantity': item['fn_quantity'],
                })
            .toList();
        setState(() {
          orderItems = items;
        });
      } else {
        print('Failed to load order data - Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void mergeData() {
    final List<Map<String, dynamic>> tempMergedItems = [];

    for (var orderItem in orderItems) {
      final menuItem = menuItems.firstWhere((menuItem) => menuItem['id'] == orderItem['item_id'], orElse: () => {});
      if (menuItem.isNotEmpty) {
        tempMergedItems.add({
          'order_id': orderItem['order_id'],
          'customer_id': orderItem['customer_id'],
          'item_id': orderItem['item_id'],
          'section_id': orderItem['section_id'],
          'item_status': orderItem['item_status'],
          'item_name': menuItem['name'],
          'quantity': orderItem['quantity'],
        });
      }
    }

    setState(() {
      mergedItems = tempMergedItems;
    });
  }

  Future<void> changeOrderItemStatus(String orderId, String customerId, String itemId, String newStatus) async {
    final url = Uri.parse('http://192.168.56.1:4000/admin/menu/changeOrderItemStatus');
    final response = await http.patch(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'orderId': orderId,
        'customerId': customerId,
        'itemId': itemId,
        'newStatus': newStatus,
      }),
    );

    if (response.statusCode == 200) {
      print('Status updated successfully');
      fetchData(); // Refresh data after update
    } else {
      print('Failed to update status - Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section Detail', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Section ID: ${widget.sectionId}',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            Text(
              'Section Name: ${widget.sectionName}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[800]),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: mergedItems.length,
                itemBuilder: (context, index) {
                  final item = mergedItems[index];
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListTile(
                        title: Text(
                          item['item_name'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order ID: ${item['order_id']}', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                            Text('Quantity: ${item['quantity']}', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                          ],
                        ),
                        trailing: TextButton(
                          onPressed: () {
                            changeOrderItemStatus(
                              item['order_id'].toString(),
                              item['customer_id'].toString(),
                              item['item_id'].toString(),
                              'confirmed',
                            );
                          },
                          child: Text(
                            item['item_status'],
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red[400]),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
