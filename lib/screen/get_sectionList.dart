import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kamona_kitchen/screen/SectionDetailScreen.dart';
import 'dart:convert';

class AllSectionList extends StatefulWidget {
  final int branchNumber;

  AllSectionList({required this.branchNumber}); // Update constructor to accept userNumber

  @override
  _AllSectionListState createState() => _AllSectionListState();
}

class _AllSectionListState extends State<AllSectionList> {
  List<dynamic> sections = [];

  @override
  void initState() {
    super.initState();
    fetchSections();
  }

Future<void> fetchSections() async {
  final response = await http.get(Uri.parse('https://54.235.40.102.nip.io/admin/branch/sections/${widget.branchNumber}'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    setState(() {
      sections = data['data']['sections'];
    });
  } else {
    throw Exception('Failed to load sections');
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Text('All Section List (Branch ${widget.branchNumber})'), // Display branch number
      centerTitle: true,
    ),
    body: sections.isEmpty
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(Icons.list),
                    title: Text(
                      section['name'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SectionDetailScreen(
                            sectionId: section['id'].toString(),  // Convert to string here
                            sectionName: section['name'],
                            branchNumber: widget.branchNumber
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
  );
}}
