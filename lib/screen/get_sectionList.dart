import 'package:flutter/material.dart';

class AllSectionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // This hides the back button
        title: Text('All Section List'),
        centerTitle: true, // This centers the title text
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centers the content vertically
          children: [
            Text('Welcome to All Section List!'),
          ],
        ),
      ),
    );
  }
}
