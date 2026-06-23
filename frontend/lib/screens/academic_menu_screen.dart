import 'package:flutter/material.dart';

class AcademicMenuScreen extends StatelessWidget {
  const AcademicMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Academic"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text(
              "Academic Calendar Upload",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/calendar-upload",
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text(
              "Academic Calendar Viewer",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/academic-calendar-viewer",
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text(
              "Timetable Upload",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/timetable-upload",
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text(
              "Timetable Viewer",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/timetable-viewer",
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.event),
            title: const Text(
              "Holidays",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/holidays",
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.school),
            title: const Text(
              "Exams",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/exams",
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text(
              "Exam Countdown",
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/exam-countdown",
              );
            },
          ),
        ],
      ),
    );
  }
}