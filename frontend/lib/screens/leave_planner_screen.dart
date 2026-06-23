import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../services/api_service.dart';

class LeavePlannerScreen extends StatefulWidget {
  const LeavePlannerScreen({super.key});

  @override
  State<LeavePlannerScreen> createState() => _LeavePlannerScreenState();
}

class _LeavePlannerScreenState extends State<LeavePlannerScreen> {
  String attendance = "";
  List holidays = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    attendance = await StorageService.getAttendance();
    final rollNo = await StorageService.getRollNo();
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/holidays/$rollNo"),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            holidays = jsonDecode(response.body) as List;
          });
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double current = double.tryParse(attendance) ?? 0;
    int leaves;

    if (current >= 90) {
      leaves = 8;
    } else if (current >= 85) {
      leaves = 5;
    } else if (current >= 75) {
      leaves = 2;
    } else {
      leaves = 0;
    }

    // Filter valid holidays to build suggestions
    final suggestions = holidays.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),
      appBar: AppBar(
        title: const Text("Leave Planner"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.percent),
                      title: const Text("Current Attendance"),
                      trailing: Text("$attendance%"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.beach_access),
                      title: const Text("Recommended Leaves"),
                      trailing: Text("$leaves"),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Suggested Leave Plan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: suggestions.isEmpty
                        ? const Center(
                            child: Text(
                              "No holidays found in academic calendar.",
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              final h = suggestions[index];
                              final name = h['name']?.toString() ?? 'Holiday';
                              final dateStr = h['date']?.toString() ?? '';
                              
                              DateTime? hDate;
                              try {
                                hDate = DateTime.parse(dateStr);
                              } catch (_) {}

                              String advice = "Create a long weekend break.";
                              if (hDate != null) {
                                if (hDate.weekday == DateTime.tuesday) {
                                  advice = "Take Monday off to create a 4-day weekend.";
                                } else if (hDate.weekday == DateTime.thursday) {
                                  advice = "Take Friday off to create a 4-day weekend.";
                                } else if (hDate.weekday == DateTime.wednesday) {
                                  advice = "Mid-week break. Take 2 days to get a 5-day holiday.";
                                }
                              }

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(Icons.event),
                                  title: Text(name),
                                  subtitle: Text(advice),
                                  trailing: Text(dateStr),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}