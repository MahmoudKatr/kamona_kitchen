import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AllSectionList extends StatefulWidget {
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
    final response = await http.get(Uri.parse('http://192.168.56.1:4000/admin/menu/sectionsList'));
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
        title: Text('All Section List'),
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
                        section['section_name'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Define the action when the list tile is tapped
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
