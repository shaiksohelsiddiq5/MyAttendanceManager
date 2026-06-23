import 'package:flutter/material.dart';

class LeaveMenuScreen extends StatelessWidget {
  const LeaveMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Planner"),
      ),
      body: ListView(
        children: [

          ListTile(
            leading: const Icon(Icons.event_available),
            title: const Text(
              "Leave Planner",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/leave-planner",
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text(
              "Smart Leave",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/smart-leave",
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.question_mark),
            title: const Text(
              "Can I Bunk Today?",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/bunk",
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text(
              "Attendance Recovery",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/recovery",
              );
            },
          ),


          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text(
              "Goal Tracker",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/goal-tracker",
              );
            },
          ),
        ],
      ),
    );
  }
}