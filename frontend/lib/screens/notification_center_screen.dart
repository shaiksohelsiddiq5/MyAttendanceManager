import 'package:flutter/material.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text(
          "Notification Center",
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(15),

        children: const [

          Card(
            child: ListTile(
              leading: Icon(
                Icons.warning,
                color: Colors.red,
              ),
              title: Text(
                "Attendance Alert",
              ),
              subtitle: Text(
                "Your attendance is below target.",
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(
                Icons.event,
                color: Colors.green,
              ),
              title: Text(
                "Holiday Alert",
              ),
              subtitle: Text(
                "Independence Day holiday is coming.",
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(
                Icons.quiz,
                color: Colors.orange,
              ),
              title: Text(
                "Exam Alert",
              ),
              subtitle: Text(
                "Java Exam starts in 5 days.",
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(
                Icons.flag,
                color: Colors.blue,
              ),
              title: Text(
                "Goal Alert",
              ),
              subtitle: Text(
                "Need 3% more attendance to reach target.",
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(
                Icons.smart_toy,
                color: Colors.purple,
              ),
              title: Text(
                "AI Recommendation",
              ),
              subtitle: Text(
                "You can safely take 2 leaves this month.",
              ),
            ),
          ),
        ],
      ),
    );
  }
}