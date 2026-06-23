import 'package:flutter/material.dart';

class AttendanceCalculatorScreen extends StatefulWidget {
  const AttendanceCalculatorScreen({super.key});

  @override
  State<AttendanceCalculatorScreen> createState() =>
      _AttendanceCalculatorScreenState();
}

class _AttendanceCalculatorScreenState
    extends State<AttendanceCalculatorScreen> {

  final totalController = TextEditingController();
  final attendedController = TextEditingController();

  double result = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Calculator")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: totalController),
            TextField(controller: attendedController),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  result =
                      (int.parse(attendedController.text) /
                              int.parse(totalController.text)) *
                          100;
                });
              },
              child: const Text("Calculate"),
            ),
            Text("${result.toStringAsFixed(2)}%"),
          ],
        ),
      ),
    );
  }
}