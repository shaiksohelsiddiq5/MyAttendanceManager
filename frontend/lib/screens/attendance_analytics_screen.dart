import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AttendanceAnalyticsScreen extends StatefulWidget {
  const AttendanceAnalyticsScreen({super.key});

  @override
  State<AttendanceAnalyticsScreen> createState() =>
      _AttendanceAnalyticsScreenState();
}

class _AttendanceAnalyticsScreenState
    extends State<AttendanceAnalyticsScreen> {

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

    double difference =
        goal - current;

    int safeBunks = 0;

    if (current >= 90) {
      safeBunks = 8;
    } else if (current >= 85) {
      safeBunks = 5;
    } else if (current >= 80) {
      safeBunks = 2;
    }

    int recoveryNeeded =
        difference > 0
            ? (difference * 2).ceil()
            : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text(
          "Attendance Analytics",
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          const Text(
            "📈 Attendance Analytics",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
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

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.compare_arrows,
              ),
              title: const Text(
                "Difference",
              ),
              trailing: Text(
                "${difference.toStringAsFixed(1)}%",
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.free_breakfast,
              ),
              title: const Text(
                "Safe Bunks",
              ),
              trailing: Text(
                "$safeBunks",
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.trending_up,
              ),
              title: const Text(
                "Classes Needed",
              ),
              trailing: Text(
                "$recoveryNeeded",
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Attendance Progress",
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
            value: goal / 100,
            minHeight: 15,
          ),

          const SizedBox(height: 10),

          Text(
            "Target: $target%",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}