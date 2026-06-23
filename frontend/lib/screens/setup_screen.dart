import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../services/api_service.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final branchController = TextEditingController();
  final yearController = TextEditingController();
  final attendanceController = TextEditingController();
  final targetController = TextEditingController();
  final totalClassesController = TextEditingController();

  DateTime _calculationDate = (DateTime.now().isAfter(DateTime(2025, 7, 5)) && DateTime.now().isBefore(DateTime(2026, 4, 18)))
      ? DateTime.now()
      : DateTime(2026, 3, 2);
  bool _calculatingClasses = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    branchController.text = await StorageService.getBranch();
    yearController.text = await StorageService.getYear();
    attendanceController.text = await StorageService.getAttendance();
    targetController.text = await StorageService.getTarget();

    final total = await StorageService.getTotalClasses();
    if (total == 0) {
      await _calculateClasses();
    } else {
      totalClassesController.text = total.toString();
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _calculateClasses() async {
    if (mounted) setState(() => _calculatingClasses = true);
    try {
      final rollNo = await StorageService.getRollNo();
      if (rollNo.isEmpty) return;

      final dateStr = "${_calculationDate.year}-${_calculationDate.month.toString().padLeft(2, '0')}-${_calculationDate.day.toString().padLeft(2, '0')}";
      final response = await http.get(Uri.parse("${ApiService.baseUrl}/api/calculate-classes/$rollNo/$dateStr"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final count = data['totalClasses'] as int;
          totalClassesController.text = count.toString();
        }
      }
    } catch (e) {
      debugPrint("Error calculating classes: $e");
    } finally {
      if (mounted) {
        setState(() => _calculatingClasses = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "⚙️ First Time Setup",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Customize your branch, target, and onboarding date to automatically estimate classes conducted so far.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: branchController,
                    decoration: const InputDecoration(
                      labelText: "Branch (CSE, ECE...)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: yearController,
                    decoration: const InputDecoration(
                      labelText: "Year (1st, 2nd, 3rd...)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Calculation Date Selector Card
                SizedBox(
                  width: 320,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Onboarding Date",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${_calculationDate.day}/${_calculationDate.month}/${_calculationDate.year}",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                            label: const Text("Select Date"),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _calculationDate,
                                firstDate: DateTime(2025, 7, 5),
                                lastDate: DateTime(2026, 4, 18),
                              );
                              if (picked != null) {
                                setState(() {
                                  _calculationDate = picked;
                                });
                                await _calculateClasses();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: totalClassesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Classes conducted so far",
                      suffixIcon: _calculatingClasses
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: attendanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Current Attendance %",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Target Attendance %",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: () async {
                    final current = double.tryParse(attendanceController.text);
                    final targetVal = double.tryParse(targetController.text);
                    final totalVal = int.tryParse(totalClassesController.text);

                    if (branchController.text.trim().isEmpty ||
                        yearController.text.trim().isEmpty ||
                        current == null ||
                        current < 0 ||
                        current > 100 ||
                        targetVal == null ||
                        targetVal <= 0 ||
                        targetVal > 100 ||
                        totalVal == null ||
                        totalVal <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter valid setup details'),
                        ),
                      );
                      return;
                    }

                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    final rollNo = await StorageService.getRollNo();
                    final attended = (totalVal * current / 100).round();

                    try {
                      final response = await http.post(
                        Uri.parse("${ApiService.baseUrl}/api/setup"),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "rollNo": rollNo,
                          "branch": branchController.text,
                          "year": yearController.text,
                          "attendance": attendanceController.text,
                          "target": targetController.text,
                          "attendedClasses": attended,
                          "totalClasses": totalVal,
                        }),
                      );
                      if (response.statusCode != 200) {
                        throw Exception(
                          jsonDecode(response.body)['message'] ?? 'Setup sync failed',
                        );
                      }

                      await StorageService.saveSetup(
                        branchController.text,
                        yearController.text,
                        attendanceController.text,
                        targetController.text,
                      );

                      await StorageService.saveAttendanceCounts(
                        attended,
                        totalVal,
                      );

                      navigator.pushReplacementNamed("/dashboard");
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Server Sync Failed: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Continue to Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    branchController.dispose();
    yearController.dispose();
    attendanceController.dispose();
    targetController.dispose();
    totalClassesController.dispose();
    super.dispose();
  }
}
