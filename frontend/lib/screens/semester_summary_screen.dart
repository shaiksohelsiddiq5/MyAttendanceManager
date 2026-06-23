import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SemesterSummaryScreen extends StatefulWidget {
  const SemesterSummaryScreen({super.key});

  @override
  State<SemesterSummaryScreen> createState() =>
      _SemesterSummaryScreenState();
}

class _SemesterSummaryScreenState
    extends State<SemesterSummaryScreen> {

  String attendance = "";
  String target = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

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
          "Semester Summary",
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          const Text(
            "📋 Semester Report",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.percent,
              ),
              title: const Text(
                "Attendance Summary",
              ),
              trailing: Text(
                "$attendance%",
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.flag,
              ),
              title: const Text(
                "Target Attendance",
              ),
              trailing: Text(
                "$target%",
              ),
            ),
          ),

          const Card(
            child: ListTile(
              leading: Icon(
                Icons.event,
              ),
              title: Text(
                "Holidays Used",
              ),
              trailing: Text(
                "12",
              ),
            ),
          ),

          const Card(
            child: ListTile(
              leading: Icon(
                Icons.quiz,
              ),
              title: Text(
                "Exams Completed",
              ),
              trailing: Text(
                "5",
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.emoji_events,
              ),
              title: const Text(
                "Semester Performance",
              ),
              trailing: Text(
                performance,
              ),
            ),
          ),

          const SizedBox(height: 25),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [

                  const Text(
                    "🏆 Overall Result",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    performance,
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}