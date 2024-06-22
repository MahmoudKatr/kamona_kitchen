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
  late Map<String, dynamic> sectionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSectionData();
  }

  Future<void> fetchSectionData() async {
    final response = await http.get(Uri.parse('http://192.168.56.1:4000/admin/branch/sections/${widget.sectionId}'));

    if (response.statusCode == 200) {
      setState(() {
        sectionData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load section data');
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
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Section ID: ${widget.sectionId}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Section Name: ${sectionData['sectionName']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
