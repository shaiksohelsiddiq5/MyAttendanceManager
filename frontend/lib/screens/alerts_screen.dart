import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() =>
      _AlertsScreenState();
}

class _AlertsScreenState
    extends State<AlertsScreen> {

  List alerts = [];

  @override
  void initState() {
    super.initState();

    alerts = [
      {
        "subject": "Java",
        "days": "5 Days Left",
      },
      {
        "subject": "DBMS",
        "days": "10 Days Left",
      },
      {
        "subject": "React",
        "days": "15 Days Left",
      },
      {
        "subject": "Node.js",
        "days": "20 Days Left",
      },
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text(
          "Exam Alerts",
        ),
        backgroundColor: Colors.black,
      ),

      body: ListView.builder(
        itemCount: alerts.length,

        itemBuilder: (context, index) {

          return Card(
            margin:
                const EdgeInsets.all(10),

            child: ListTile(
              leading: const Icon(
                Icons.notifications_active,
                color: Colors.red,
              ),

              title: Text(
                alerts[index]["subject"]
                    .toString(),
              ),

              subtitle: Text(
                alerts[index]["days"]
                    .toString(),
              ),
            ),
          );
        },
      ),
    );
  }
}