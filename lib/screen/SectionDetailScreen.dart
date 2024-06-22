import 'package:flutter/material.dart';

class SectionDetailScreen extends StatelessWidget {
  final String sectionId;
  final String sectionName;

  SectionDetailScreen({required this.sectionId, required this.sectionName});

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
              'Section ID: $sectionId',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Section Name: $sectionName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
