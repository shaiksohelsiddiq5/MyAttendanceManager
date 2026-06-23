import 'package:flutter/material.dart';

class SemesterProgressScreen extends StatelessWidget {
  const SemesterProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {

    const totalDays = 120;
    const completedDays = 72;

    double progress =
        completedDays / totalDays;

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text(
          "Semester Progress",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            const Text(
              "Semester Progress",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            LinearProgressIndicator(
              value: progress,
              minHeight: 15,
            ),

            const SizedBox(height: 20),

            const Text(
              "72 / 120 Days Completed",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "${(progress * 100).toStringAsFixed(0)}% Completed",
              style: const TextStyle(
                color: Colors.green,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}