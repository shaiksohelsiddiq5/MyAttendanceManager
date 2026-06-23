import 'package:flutter/material.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text(
          "Attendance History",
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(15),

        children: const [

          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text("January"),
              trailing: Text("78%"),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text("February"),
              trailing: Text("80%"),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text("March"),
              trailing: Text("82%"),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text("April"),
              trailing: Text("84%"),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text("May"),
              trailing: Text("86%"),
            ),
          ),
        ],
      ),
    );
  }
}