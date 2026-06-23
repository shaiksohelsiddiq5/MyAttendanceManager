import 'package:flutter/material.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text(
          "AI Assistant",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: const [

            Card(
              child: ListTile(
                leading: Icon(Icons.smart_toy),
                title: Text("Attendance Advice"),
                subtitle: Text(
                  "Attend 3 more classes to reach your target.",
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: Icon(Icons.event),
                title: Text("Leave Suggestion"),
                subtitle: Text(
                  "Take leave near holidays for long weekends.",
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: Icon(Icons.quiz),
                title: Text("Exam Suggestion"),
                subtitle: Text(
                  "Start preparing for upcoming exams.",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}