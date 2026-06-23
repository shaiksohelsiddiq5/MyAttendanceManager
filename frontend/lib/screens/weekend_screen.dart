import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../services/api_service.dart';

class WeekendScreen extends StatefulWidget {
  const WeekendScreen({super.key});

  @override
  State<WeekendScreen> createState() => _WeekendScreenState();
}

class _WeekendScreenState extends State<WeekendScreen> {
  List holidays = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHolidays();
  }

  Future<void> _loadHolidays() async {
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> customWeekends = [];
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

    String getHolidayName(DateTime date) {
      final dateStrKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final match = holidays.firstWhere(
        (h) => (h['date']?.toString() ?? '') == dateStrKey || (h['date']?.toString() ?? '').startsWith(dateStrKey),
        orElse: () => null,
      );
      return match != null ? (match['name']?.toString() ?? 'Holiday') : 'Weekend';
    }

    // Scan next 180 days
    final scannedDate = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < 180; i++) {
      final date = scannedDate.add(Duration(days: i));
      
      // If today is NOT a holiday, check if taking it off makes a long break (>= 4 days)
      if (!isHoliday(date)) {
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

          final label = "${date.day}/${date.month}/${date.year}";
          final rangeLabel = "${start.day}/${start.month} to ${end.day}/${end.month}";
          
          final weekdaysNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
          final weekdayStr = weekdaysNames[date.weekday - 1];

          customWeekends.add({
            "title": "Take $weekdayStr Off ($consecutive-Day Break)",
            "date": "Leave Date: $label",
            "days": consecutive,
            "sequence": "Take $label off to bridge holidays → break from $rangeLabel!",
            "color": const Color(0xFFFFB547),
          });
        }
      } else {
        // It IS a holiday. Check if it's Monday or Friday to suggest 3-Day weekend
        if (date.weekday == DateTime.monday) {
          final hName = getHolidayName(date);
          final label = "${date.day}/${date.month}/${date.year}";
          customWeekends.add({
            "title": "Official 3-Day Weekend",
            "date": label,
            "days": 3,
            "sequence": "Holiday ($hName) on Monday → Saturday & Sunday off",
            "color": const Color(0xFF20C997),
          });
        } else if (date.weekday == DateTime.friday) {
          final hName = getHolidayName(date);
          final label = "${date.day}/${date.month}/${date.year}";
          customWeekends.add({
            "title": "Official 3-Day Weekend",
            "date": label,
            "days": 3,
            "sequence": "Holiday ($hName) on Friday → Saturday & Sunday off",
            "color": const Color(0xFF20C997),
          });
        }
      }
    }

    // Deduplicate customWeekends
    final List<Map<String, dynamic>> uniqueWeekends = [];
    final seen = <String>{};
    for (final cw in customWeekends) {
      final key = "${cw['title']}_${cw['sequence']}";
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueWeekends.add(cw);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),
      appBar: AppBar(title: const Text('Long weekend finder')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Upcoming breaks & recommendations',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                if (uniqueWeekends.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text("No upcoming breaks found in the calendar.")),
                    ),
                  )
                else
                  ...uniqueWeekends.map((cw) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _WeekendCard(
                          title: cw['title'],
                          date: cw['date'],
                          days: cw['days'],
                          sequence: cw['sequence'],
                          color: cw['color'],
                        ),
                      )),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFFFB547),
                    ),
                    title: const Text('Calendar integration active'),
                    subtitle: Text(
                      uniqueWeekends.isNotEmpty
                          ? 'Successfully scanned calendar holidays to identify ${uniqueWeekends.length} long breaks.'
                          : 'No calendar holidays loaded. Go to settings to reload your calendar.',
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _WeekendCard extends StatelessWidget {
  const _WeekendCard({
    required this.title,
    required this.date,
    required this.days,
    required this.sequence,
    required this.color,
  });
  final String title;
  final String date;
  final int days;
  final String sequence;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$days\ndays',
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(date, style: TextStyle(color: color)),
                  const SizedBox(height: 5),
                  Text(
                    sequence,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: .6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
