import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../services/api_service.dart';

class ExamCountdownScreen extends StatefulWidget {
  const ExamCountdownScreen({super.key});

  @override
  State<ExamCountdownScreen> createState() => _ExamCountdownScreenState();
}

class _ExamCountdownScreenState extends State<ExamCountdownScreen> {
  List exams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    try {
      final rollNo = await StorageService.getRollNo();
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/exams/$rollNo"),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            exams = jsonDecode(response.body) as List;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load exams');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),
      appBar: AppBar(
        title: const Text("Exam Countdown"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : exams.isEmpty
              ? const Center(
                  child: Text(
                    "No Exams Found",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    final dateStr = exam['date']?.toString() ?? '';
                    final subject = exam['subject']?.toString() ?? 'Exam';

                    DateTime? examDate;
                    try {
                      examDate = DateTime.parse(dateStr);
                    } catch (_) {
                      // Fallback for custom formatted dates
                    }

                    String daysLeft = "N/A";
                    if (examDate != null) {
                      final today = DateTime.now();
                      // Set hours/minutes to midnight for standard days calculation
                      final start = DateTime(today.year, today.month, today.day);
                      final end = DateTime(examDate.year, examDate.month, examDate.day);
                      final diff = end.difference(start).inDays;
                      if (diff == 0) {
                        daysLeft = "Today!";
                      } else if (diff < 0) {
                        daysLeft = "Completed";
                      } else {
                        daysLeft = "$diff Days";
                      }
                    } else {
                      daysLeft = dateStr;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.timer),
                        title: Text(subject),
                        trailing: Text(
                          daysLeft,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: daysLeft.contains("Days")
                                ? const Color(0xFFFFB547)
                                : Colors.greenAccent,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}