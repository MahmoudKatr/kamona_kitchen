import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class SectionDetailScreen extends StatefulWidget {
  final String sectionId;
  final String sectionName;
  final int branchNumber; // Add this line


  SectionDetailScreen({required this.sectionId, required this.sectionName,required this.branchNumber});

  @override
  _SectionDetailScreenState createState() => _SectionDetailScreenState();
}

class _SectionDetailScreenState extends State<SectionDetailScreen> {
  List<Map<String, dynamic>> menuItems = [];
  List<Map<String, dynamic>> orderItems = [];
  List<Map<String, dynamic>> confirmedOrderItems = [];
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
    timer = Timer.periodic(Duration(seconds: 20), (Timer t) => fetchData());
  }

  Future<void> fetchData() async {
    await fetchMenuData();
    await fetchOrderData();
    await fetchConfirmedOrderData();
    mergeData();
  }

  Future<void> fetchMenuData() async {
    try {
      final response = await http.get(
          Uri.parse('https://54.235.40.102.nip.io/admin/branch/general-menu-list'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> items = (data['data'] as List)
            .map((item) => {'id': item['id'], 'name': item['name']})
            .toList();
        if (mounted) {
          setState(() {
            menuItems = items;
          });
        }
      } else {
        throw Exception('Failed to load menu data');
      }
    } catch (e) {
      print('Error fetching menu data: $e');
      if (mounted) {
        setState(() {
          menuItems = [];
        });
      }
    }
  }

  Future<void> fetchOrderData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://54.235.40.102.nip.io/user/order/orderItemsBySection/${widget.sectionId}/${widget.branchNumber}/pending'));

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
                  'button_text': 'CONFIRMED', // New field
                  'new_status': 'confirmed',  // New field
                })
            .toList();
        if (mounted) {
          setState(() {
            orderItems = items;
          });
        }
      } else {
        print(
            'Failed to load order data - Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        if (mounted) {
          setState(() {
            orderItems = [];
          });
        }
      }
    } catch (e) {
      print('Error fetching order data: $e');
      if (mounted) {
        setState(() {
          orderItems = [];
        });
      }
    }
  }

  Future<void> fetchConfirmedOrderData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://54.235.40.102.nip.io/user/order/orderItemsBySection/${widget.sectionId}/${widget.branchNumber}/confirmed'));

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
                  'button_text': 'COMPLETED', // New field
                  'new_status': 'completed', // New field
                })
            .toList();
        if (mounted) {
          setState(() {
            confirmedOrderItems = items;
          });
        }
      } else {
        print(
            'Failed to load confirmed order data - Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        if (mounted) {
          setState(() {
            confirmedOrderItems = [];
          });
        }
      }
    } catch (e) {
      print('Error fetching confirmed order data: $e');
      if (mounted) {
        setState(() {
          confirmedOrderItems = [];
        });
      }
    }
  }

  void mergeData() {
    final List<Map<String, dynamic>> tempMergedItems = [];

    for (var orderItem in orderItems) {
      final menuItem = menuItems.firstWhere(
          (menuItem) => menuItem['id'] == orderItem['item_id'],
          orElse: () => {});
      if (menuItem.isNotEmpty) {
        tempMergedItems.add({
          'order_id': orderItem['order_id'],
          'customer_id': orderItem['customer_id'],
          'item_id': orderItem['item_id'],
          'section_id': orderItem['section_id'],
          'item_status': orderItem['item_status'],
          'item_name': menuItem['name'],
          'quantity': orderItem['quantity'],
          'button_text': orderItem['button_text'], // Pass button text
          'new_status': orderItem['new_status'],   // Pass new status
        });
      }
    }

    for (var confirmedItem in confirmedOrderItems) {
      final menuItem = menuItems.firstWhere(
          (menuItem) => menuItem['id'] == confirmedItem['item_id'],
          orElse: () => {});
      if (menuItem.isNotEmpty) {
        tempMergedItems.add({
          'order_id': confirmedItem['order_id'],
          'customer_id': confirmedItem['customer_id'],
          'item_id': confirmedItem['item_id'],
          'section_id': confirmedItem['section_id'],
          'item_status': confirmedItem['item_status'],
          'item_name': menuItem['name'],
          'quantity': confirmedItem['quantity'],
          'button_text': confirmedItem['button_text'], // Pass button text
          'new_status': confirmedItem['new_status'],   // Pass new status
        });
      }
    }

    if (mounted) {
      setState(() {
        mergedItems = tempMergedItems;
      });
    }
  }

  Future<void> changeOrderItemStatus(String orderId, String customerId,
      String itemId, String newStatus) async {
    final url =
        Uri.parse('https://54.235.40.102.nip.io/admin/menu/changeOrderItemStatus');
    try {
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
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section Detail',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800]),
            ),
            SizedBox(height: 20),
                        Text(
              'Branch: ${widget.branchNumber}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800]),
            ),
            SizedBox(height: 20),
            Expanded(
              child: mergedItems.isEmpty
                  ? Center(
                      child: Text(
                        'No orders available',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: mergedItems.length,
                      itemBuilder: (context, index) {
                        final item = mergedItems[index];
                        final quantity = item['quantity'] ?? 0; // Default to 0 if quantity is null
                        final buttonColor = item['new_status'] == 'confirmed'
                            ? Colors.orange
                            : item['new_status'] == 'completed'
                                ? Colors.green
                                : Colors.grey; // Default color

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
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Order ID: ${item['order_id']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600])),
                                  Text('Quantity: $quantity',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600])),
                                ],
                              ),
                              trailing: TextButton(
                                onPressed: () {
                                  changeOrderItemStatus(
                                    item['order_id'].toString(),
                                    item['customer_id'].toString(),
                                    item['item_id'].toString(),
                                    item['new_status'],
                                  );
                                },
                                child: Text(
                                  item['button_text'],
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: buttonColor),
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
