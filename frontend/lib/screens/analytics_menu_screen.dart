import 'package:flutter/material.dart';

class AnalyticsMenuScreen extends StatelessWidget {
  const AnalyticsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
      ),
      body: ListView(
        children: [

          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text(
              "Attendance Analytics",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/attendance-analytics",
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text(
              "Semester Progress",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/semester-progress",
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.summarize),
            title: const Text(
              "Semester Summary",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/semester-summary",
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.book),
            title: const Text(
              "Subject Tracker",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/subject-tracker",
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text(
              "Subject Analytics",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/subject-analytics",
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(
              "Student Stats",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/student-stats",
              );
            },
          ),
        ],
      ),
    );
  }
}