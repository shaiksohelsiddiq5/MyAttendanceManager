import 'package:flutter/material.dart';

class SubjectAnalyticsScreen extends StatelessWidget {
  const SubjectAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text(
          "Subject Analytics",
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(15),

        children: const [

          Card(
            child: ListTile(
              leading: Icon(Icons.book),
              title: Text("Java"),
              trailing: Text("82%"),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.book),
              title: Text("DBMS"),
              trailing: Text("78%"),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.book),
              title: Text("Operating Systems"),
              trailing: Text("85%"),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.book),
              title: Text("Computer Networks"),
              trailing: Text("88%"),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.book),
              title: Text("React"),
              trailing: Text("90%"),
            ),
          ),
        ],
      ),
    );
  }
}