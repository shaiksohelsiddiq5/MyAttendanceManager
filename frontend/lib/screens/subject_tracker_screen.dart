import 'package:flutter/material.dart';

class SubjectTrackerScreen extends StatelessWidget {
  const SubjectTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final subjects = [
      {
        "name": "Java",
        "attendance": "82%"
      },
      {
        "name": "DBMS",
        "attendance": "78%"
      },
      {
        "name": "Operating Systems",
        "attendance": "85%"
      },
      {
        "name": "Computer Networks",
        "attendance": "80%"
      },
      {
        "name": "React",
        "attendance": "88%"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text(
          "Subject Tracker",
        ),
      ),

      body: ListView.builder(
        itemCount: subjects.length,

        itemBuilder: (context, index) {

          return Card(
            margin: const EdgeInsets.all(10),

            child: ListTile(
              leading: const Icon(
                Icons.book,
              ),

              title: Text(
                subjects[index]["name"]!,
              ),

              trailing: Text(
                subjects[index]["attendance"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}