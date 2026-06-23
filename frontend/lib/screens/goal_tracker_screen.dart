import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class GoalTrackerScreen extends StatefulWidget {
  const GoalTrackerScreen({super.key});

  @override
  State<GoalTrackerScreen> createState() =>
      _GoalTrackerScreenState();
}

class _GoalTrackerScreenState
    extends State<GoalTrackerScreen> {

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

    double goal =
        double.tryParse(target) ?? 100;

    double progress =
        goal == 0 ? 0 : current / goal;

    if (progress > 1) {
      progress = 1;
    }

    String status;

    if (current >= goal) {
      status = "🏆 Goal Achieved";
    } else {
      status = "🎯 Goal In Progress";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text(
          "Goal Tracker",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(
          children: [

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.percent,
                ),
                title: const Text(
                  "Current Attendance",
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

            const SizedBox(height: 25),

            const Text(
              "Goal Progress",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(
              value: progress,
              minHeight: 15,
            ),

            const SizedBox(height: 15),

            Text(
              "${(progress * 100).toStringAsFixed(0)}% Completed",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 25),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}