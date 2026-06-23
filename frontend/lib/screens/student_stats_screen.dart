import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class StudentStatsScreen extends StatefulWidget {
  const StudentStatsScreen({super.key});

  @override
  State<StudentStatsScreen> createState() =>
      _StudentStatsScreenState();
}

class _StudentStatsScreenState
    extends State<StudentStatsScreen> {

  String name = "";
  String attendance = "";
  String target = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    name =
        await StorageService.getName();

    attendance =
        await StorageService.getAttendance();

    target =
        await StorageService.getTarget();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    double current =
        double.tryParse(attendance) ?? 0;

    String performance;

    if (current >= 90) {
      performance = "Excellent";
    } else if (current >= 80) {
      performance = "Good";
    } else if (current >= 75) {
      performance = "Average";
    } else {
      performance = "Needs Improvement";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text(
          "Student Statistics",
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Student"),
              trailing: Text(name),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.percent),
              title: const Text("Attendance"),
              trailing: Text("$attendance%"),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.flag),
              title: const Text("Target"),
              trailing: Text("$target%"),
            ),
          ),

          const Card(
            child: ListTile(
              leading: Icon(Icons.event),
              title: Text("Holidays"),
              trailing: Text("12"),
            ),
          ),

          const Card(
            child: ListTile(
              leading: Icon(Icons.quiz),
              title: Text("Upcoming Exams"),
              trailing: Text("5"),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Performance"),
              trailing: Text(performance),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Overall Performance",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          LinearProgressIndicator(
            value: current / 100,
            minHeight: 15,
          ),

          const SizedBox(height: 10),

          Text(
            "$attendance%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}