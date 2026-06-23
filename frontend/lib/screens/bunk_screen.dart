import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../services/api_service.dart';

class BunkScreen extends StatefulWidget {
  const BunkScreen({super.key});

  @override
  State<BunkScreen> createState() => _BunkScreenState();
}

class _BunkScreenState extends State<BunkScreen> {
  int attended = 0;
  int total = 0;
  double target = 75;

  DateTime _selectedDate = (DateTime.now().isAfter(DateTime(2025, 7, 5)) && DateTime.now().isBefore(DateTime(2026, 4, 18)))
      ? DateTime.now()
      : DateTime(2026, 3, 2);
  List _todaySessions = [];
  List _attendanceRecords = [];
  final Set<String> _simulatedBunks = {}; // Set of "Subject_Period"
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rollNo = await StorageService.getRollNo();
      if (rollNo.isEmpty) return;

      target = double.tryParse(await StorageService.getTarget()) ?? 75;

      final weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
      final weekdayName = weekdays[_selectedDate.weekday - 1];

      // 1. Fetch timetable sessions
      final timetableRes = await http.get(Uri.parse("${ApiService.baseUrl}/api/timetable/$rollNo"));
      List sessions = [];
      if (timetableRes.statusCode == 200) {
        final data = jsonDecode(timetableRes.body);
        if (data['success'] == true && data['sessions'] != null) {
          sessions = (data['sessions'] as List)
              .where((s) => s['day']?.toString().toLowerCase() == weekdayName.toLowerCase())
              .toList();
          sessions.sort((a, b) => (a['period']?.toString() ?? '').compareTo(b['period']?.toString() ?? ''));
        }
      }

      // 2. Fetch subject wise attendance data
      final attRes = await http.get(Uri.parse("${ApiService.baseUrl}/attendance/$rollNo"));
      List attData = [];
      if (attRes.statusCode == 200) {
        attData = jsonDecode(attRes.body) as List;
      }

      attended = await StorageService.getAttendedClasses();
      total = await StorageService.getTotalClasses();

      if (mounted) {
        setState(() {
          _todaySessions = sessions;
          _attendanceRecords = attData;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading bunk data: $e");
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025, 7, 5),
      lastDate: DateTime(2026, 4, 18),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _loading = true;
        _simulatedBunks.clear();
      });
      await _load();
    }
  }

  Widget _buildSmartSuggestionsCard() {
    if (_todaySessions.isEmpty) return const SizedBox.shrink();

    final bunkablePeriods = [];
    final nonBunkablePeriods = [];

    for (final session in _todaySessions) {
      final subject = session['subject']?.toString() ?? 'Class';
      final period = session['period']?.toString() ?? '1';

      final record = _attendanceRecords.firstWhere(
        (r) => r['subject']?.toString().toLowerCase() == subject.toLowerCase(),
        orElse: () => null,
      );
      int subPresent = record != null ? (record['present'] as num? ?? 0).toInt() : 15;
      int subTotal = record != null ? (record['total'] as num? ?? 0).toInt() : 20;

      double subSimPct = (subTotal + 1) == 0 ? 0.0 : (subPresent / (subTotal + 1)) * 100;
      final isBunkable = subSimPct >= target;

      if (isBunkable) {
        bunkablePeriods.add("Period $period ($subject) - ${subSimPct.toStringAsFixed(1)}%");
      } else {
        nonBunkablePeriods.add("Period $period ($subject) - ${subSimPct.toStringAsFixed(1)}%");
      }
    }

    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.lightbulb_rounded, color: Color(0xFFFFB547)),
                SizedBox(width: 8),
                Text(
                  "Smart Bunk Suggestions",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFFB547)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (bunkablePeriods.isNotEmpty) ...[
              const Text(
                "Safe to bunk today:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF20C997)),
              ),
              const SizedBox(height: 4),
              ...bunkablePeriods.map((p) => Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 14, color: Color(0xFF20C997)),
                    const SizedBox(width: 6),
                    Text(p, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              )),
              const SizedBox(height: 8),
            ],
            if (nonBunkablePeriods.isNotEmpty) ...[
              const Text(
                "Do NOT bunk (attendance too low):",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFF6B6B)),
              ),
              const SizedBox(height: 4),
              ...nonBunkablePeriods.map((p) => Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.close, size: 14, color: Color(0xFFFF6B6B)),
                    const SizedBox(width: 6),
                    Text(p, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = total == 0 ? 0.0 : attended * 100 / total;
    final totalMissed = _simulatedBunks.length;
    final predicted = (total + totalMissed) == 0 ? 0.0 : attended * 100 / (total + totalMissed);
    final safe = predicted >= target;

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),
      appBar: AppBar(title: const Text('Bunk predictor')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Top Result Hero Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        Icon(
                          safe ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                          size: 72,
                          color: safe ? const Color(0xFF20C997) : const Color(0xFFFF6B6B),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          safe
                              ? (totalMissed == 0
                                  ? 'Safe to miss selected classes'
                                  : 'Safe to miss $totalMissed ${totalMissed == 1 ? 'class' : 'classes'}')
                              : 'Better attend today',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your overall attendance would become ${predicted.toStringAsFixed(1)}% against a ${target.toStringAsFixed(0)}% target.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Date Picker Card
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today_rounded, color: Color(0xFF9B91FF)),
                    title: const Text('Bunk Target Date Selector', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Simulating classes for: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                    trailing: TextButton(
                      onPressed: _pickDate,
                      child: const Text("Change Date"),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildSmartSuggestionsCard(),

                const Text(
                  'Select classes you want to bunk:',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),

                if (_todaySessions.isEmpty)
                  Card(
                    color: const Color(0xFF13233D),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          "No classes scheduled for this day (${_selectedDate.weekday == 7 ? 'Sunday' : 'Holiday / Off-day'})",
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15),
                        ),
                      ),
                    ),
                  )
                else
                  ..._todaySessions.map((session) {
                    final subject = session['subject']?.toString() ?? 'Class';
                    final period = session['period']?.toString() ?? '1';
                    final startTime = session['startTime']?.toString() ?? '';
                    final endTime = session['endTime']?.toString() ?? '';
                    final room = session['room']?.toString() ?? 'N/A';

                    final key = "${subject}_$period";
                    final isTicked = _simulatedBunks.contains(key);

                    // Count how many classes of this subject are simulated to be bunked
                    final tickedForSubject = _simulatedBunks.where((k) => k.startsWith("${subject}_")).length;

                    // Get subject specific record
                    final record = _attendanceRecords.firstWhere(
                      (r) => r['subject']?.toString().toLowerCase() == subject.toLowerCase(),
                      orElse: () => null,
                    );
                    int subPresent = record != null ? (record['present'] as num? ?? 0).toInt() : 15;
                    int subTotal = record != null ? (record['total'] as num? ?? 0).toInt() : 20;

                    // Calculate simulated subject percentage
                    double subSimPct = (subTotal + tickedForSubject) == 0
                        ? 0.0
                        : (subPresent / (subTotal + tickedForSubject)) * 100;
                    
                    // Bunkable if simulated subject percentage is >= target
                    final isSubjectBunkable = subSimPct >= target;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Period $period",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "$startTime - $endTime",
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subject,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Room: $room",
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSubjectBunkable
                                          ? const Color(0xFF20C997).withValues(alpha: 0.12)
                                          : const Color(0xFFFF6B6B).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isSubjectBunkable ? const Color(0xFF20C997) : const Color(0xFFFF6B6B),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      "Attendance: ${subSimPct.toStringAsFixed(1)}% (${isSubjectBunkable ? 'Bunkable' : 'Not Bunkable'})",
                                      style: TextStyle(
                                        color: isSubjectBunkable ? const Color(0xFF20C997) : const Color(0xFFFF6B6B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: isTicked,
                              activeColor: const Color(0xFF9B91FF),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _simulatedBunks.add(key);
                                  } else {
                                    _simulatedBunks.remove(key);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 20),

                // Statistics Card
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Current attendance'),
                        trailing: Text('${current.toStringAsFixed(1)}%'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('After bunking simulated classes'),
                        trailing: Text(
                          '${predicted.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: safe ? const Color(0xFF20C997) : const Color(0xFFFF6B6B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Recorded classes'),
                        trailing: Text('$attended / $total'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Classes simulated to bunk'),
                        trailing: Text('$totalMissed'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Prediction assumes every ticked class is marked absent.',
                  style: TextStyle(color: Colors.white.withValues(alpha: .55)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}
