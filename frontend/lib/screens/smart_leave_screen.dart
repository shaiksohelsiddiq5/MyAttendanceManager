import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../services/api_service.dart';

class SmartLeaveScreen extends StatefulWidget {
  const SmartLeaveScreen({super.key});

  @override
  State<SmartLeaveScreen> createState() => _SmartLeaveScreenState();
}

class _SmartLeaveScreenState extends State<SmartLeaveScreen> {
  int attended = 0;
  int total = 0;
  double target = 75;
  List holidays = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    attended = await StorageService.getAttendedClasses();
    total = await StorageService.getTotalClasses();
    target = double.tryParse(await StorageService.getTarget()) ?? 75;

    try {
      final rollNo = await StorageService.getRollNo();
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

  int get safeLeaves {
    if (target <= 0 || total == 0) return 0;
    return ((attended * 100 / target) - total).floor().clamp(0, 999);
  }

  @override
  Widget build(BuildContext context) {
    final now = (DateTime.now().isAfter(DateTime(2025, 7, 5)) && DateTime.now().isBefore(DateTime(2026, 4, 18)))
        ? DateTime.now()
        : DateTime(2026, 3, 2);
    final List<Map<String, dynamic>> bridgeSuggestions = [];

    final holidayDates = <String>{};
    for (final h in holidays) {
      final dStr = h['date']?.toString() ?? '';
      if (dStr.isNotEmpty) {
        final parsed = DateTime.tryParse(dStr);
        if (parsed != null) {
          final dateStrKey = "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
          holidayDates.add(dateStrKey);
        }
      }
    }

    bool isHoliday(DateTime date) {
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        return true;
      }
      final dateStrKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      return holidayDates.contains(dateStrKey);
    }

    // Scan next 90 days for bridge opportunities
    final scannedDate = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < 90; i++) {
      final date = scannedDate.add(Duration(days: i));
      if (isHoliday(date)) continue;

      final label = "${date.day}/${date.month}/${date.year}";
      final weekdaysNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
      final weekdayStr = weekdaysNames[date.weekday - 1];

      // 1. Saturday & Monday are holidays -> Take Friday leave
      if (date.weekday == DateTime.friday &&
          isHoliday(date.add(const Duration(days: 1))) && // Saturday
          isHoliday(date.add(const Duration(days: 3)))) { // Monday
        bridgeSuggestions.add({
          "title": "Holiday Sandwich: Friday",
          "date": label,
          "days": 4,
          "sequence": "Take Friday leave since Saturday & Monday are holidays.",
          "isSafe": safeLeaves >= 1,
        });
        continue;
      }

      // 2. Sandwiched day (Yesterday is holiday and tomorrow is holiday) -> Middle of holiday
      if (isHoliday(date.subtract(const Duration(days: 1))) &&
          isHoliday(date.add(const Duration(days: 1)))) {
        final yesterday = date.subtract(const Duration(days: 1));
        final tomorrow = date.add(const Duration(days: 1));
        final yesterdayWeekday = weekdaysNames[yesterday.weekday - 1];
        final tomorrowWeekday = weekdaysNames[tomorrow.weekday - 1];
        bridgeSuggestions.add({
          "title": "Sandwiched Leave: $weekdayStr",
          "date": label,
          "days": 3,
          "sequence": "Middle of holiday: take $weekdayStr leave ($label) since $yesterdayWeekday and $tomorrowWeekday are holidays.",
          "isSafe": safeLeaves >= 1,
        });
        continue;
      }

      int consecutive = 1;
      
      DateTime prev = date.subtract(const Duration(days: 1));
      while (isHoliday(prev)) {
        consecutive++;
        prev = prev.subtract(const Duration(days: 1));
      }
      
      DateTime next = date.add(const Duration(days: 1));
      while (isHoliday(next)) {
        consecutive++;
        next = next.add(const Duration(days: 1));
      }

      if (consecutive >= 4) {
        DateTime start = date;
        DateTime boundaryPrev = date.subtract(const Duration(days: 1));
        while (isHoliday(boundaryPrev)) {
          start = boundaryPrev;
          boundaryPrev = boundaryPrev.subtract(const Duration(days: 1));
        }

        DateTime end = date;
        DateTime boundaryNext = date.add(const Duration(days: 1));
        while (isHoliday(boundaryNext)) {
          end = boundaryNext;
          boundaryNext = boundaryNext.add(const Duration(days: 1));
        }

        final rangeLabel = "${start.day}/${start.month} to ${end.day}/${end.month}";

        bridgeSuggestions.add({
          "title": "Bridge Leave: $weekdayStr",
          "date": label,
          "days": consecutive,
          "sequence": "Bridge $label to create a $consecutive-day break ($rangeLabel)",
          "isSafe": safeLeaves >= 1,
        });
      }
    }

    // Deduplicate and prioritize sandwich leaves
    final List<Map<String, dynamic>> uniqueSuggestions = [];
    final seen = <String>{};
    for (final s in bridgeSuggestions) {
      if (!seen.contains(s['date'])) {
        seen.add(s['date']);
        uniqueSuggestions.add(s);
      }
    }

    uniqueSuggestions.sort((a, b) {
      final aIsSandwich = a['title'].toString().contains('Sandwich') || a['title'].toString().contains('Sandwiched');
      final bIsSandwich = b['title'].toString().contains('Sandwich') || b['title'].toString().contains('Sandwiched');
      if (aIsSandwich && !bIsSandwich) return -1;
      if (!aIsSandwich && bIsSandwich) return 1;
      return 0; // Keep chronological order if both are same or neither is sandwich
    });

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),
      appBar: AppBar(title: const Text('Smart leave suggestions')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Hero card for safe absences
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB547).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.event_available_rounded,
                        color: Color(0xFFFFB547),
                        size: 56,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$safeLeaves safe class ${safeLeaves == 1 ? 'absence' : 'absences'}',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Your estimated buffer before falling below ${target.toStringAsFixed(0)}%.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 22),
                
                const Text(
                  'Smart sandwich leave planner',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                if (uniqueSuggestions.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Center(child: Text("No sandwich leave options in the next 90 days.")),
                    ),
                  )
                else
                  ...uniqueSuggestions.take(5).map((s) {
                    final isSafe = s['isSafe'] as bool;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSafe ? const Color(0xFF20C997).withValues(alpha: 0.15) : const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                          child: Icon(
                            isSafe ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                            color: isSafe ? const Color(0xFF20C997) : const Color(0xFFFF6B6B),
                          ),
                        ),
                        title: Text(s['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(s['sequence']),
                            const SizedBox(height: 4),
                            Text(
                              isSafe ? "✓ Safe to take leave!" : "⚠ Risk: low attendance buffer",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSafe ? const Color(0xFF20C997) : const Color(0xFFFF6B6B),
                                fontSize: 12,
                              ),
                            )
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB547).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${s['days']}d break",
                            style: const TextStyle(color: Color(0xFFFFB547), fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ),
                    );
                  }),
                
                const SizedBox(height: 16),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.info_outline_rounded),
                    title: Text('Timetable & Day Absences'),
                    subtitle: Text(
                      'One day can contain multiple classes. Tapping present/absent on the dashboard checklist automatically updates your safe absences buffer.',
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
