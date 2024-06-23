import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SectionDetailScreen extends StatefulWidget {
  final String sectionId;
  final String sectionName;

  SectionDetailScreen({required this.sectionId, required this.sectionName});

  @override
  _SectionDetailScreenState createState() => _SectionDetailScreenState();
}

class _SectionDetailScreenState extends State<SectionDetailScreen> {
  List<Map<String, dynamic>> menuItems = [];

  @override
  void initState() {
    super.initState();
    fetchMenuData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Section ID: ${widget.sectionId}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Section Name: ${widget.sectionName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}