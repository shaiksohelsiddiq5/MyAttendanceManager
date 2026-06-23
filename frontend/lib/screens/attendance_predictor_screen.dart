import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AttendancePredictorScreen extends StatefulWidget {
  const AttendancePredictorScreen({super.key});

  @override
  State<AttendancePredictorScreen> createState() =>
      _AttendancePredictorScreenState();
}

class _AttendancePredictorScreenState
    extends State<AttendancePredictorScreen> {

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
        double.tryParse(target) ?? 0;

    double predicted =
        current + 5;

    if (predicted > 100) {
      predicted = 100;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text(
          "Attendance Predictor",
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
                  Icons.trending_up,
                ),
                title: const Text(
                  "Predicted Attendance",
                ),
                trailing: Text(
                  "${predicted.toStringAsFixed(1)}%",
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

            const SizedBox(height: 30),

            const Text(
              "Attendance Growth",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
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
              "Current: $attendance%",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(
              value: predicted / 100,
              minHeight: 15,
            ),

            const SizedBox(height: 10),

            Text(
              "Predicted: ${predicted.toStringAsFixed(1)}%",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  predicted >= goal
                      ? "✅ You are likely to achieve your target attendance."
                      : "⚠️ Attend more classes to reach your target.",
                  style: const TextStyle(
                    fontSize: 16,
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