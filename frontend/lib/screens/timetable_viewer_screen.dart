import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/timetable_upload_service.dart';

class TimetableViewerScreen extends StatefulWidget {
  const TimetableViewerScreen({super.key});

  @override
  State<TimetableViewerScreen> createState() => _TimetableViewerScreenState();
}

class _TimetableViewerScreenState extends State<TimetableViewerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

  List<dynamic> _sessions = [];
  bool _isLoading = true;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    try {
      final rollNo = await StorageService.getRollNo();
      final sessions = await TimetableUploadService.getTimetable(rollNo);
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getSessionsForDay(String day) {
    return _sessions.where((s) {
      final sDay = s['day']?.toString().toLowerCase() ?? '';
      return sDay == day.toLowerCase();
    }).toList()
      ..sort((a, b) {
        final aTime = a['startTime']?.toString() ?? '';
        final bTime = b['startTime']?.toString() ?? '';
        return aTime.compareTo(bTime);
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),
      appBar: AppBar(
        title: const Text("Timetable Viewer"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Text(
                    "Error: $_error",
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: _days.map((day) {
                    final daySessions = _getSessionsForDay(day);
                    if (daySessions.isEmpty) {
                      return const Center(
                        child: Text(
                          "No Classes Scheduled",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: daySessions.length,
                      itemBuilder: (context, index) {
                        final s = daySessions[index];
                        final subject = s['subject']?.toString() ?? 'Subject';
                        final period = s['period']?.toString() ?? '';
                        final start = s['startTime']?.toString() ?? '';
                        final end = s['endTime']?.toString() ?? '';
                        final room = s['room']?.toString() ?? '';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7C6CFF)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    period.isNotEmpty ? "P$period" : "Class",
                                    style: const TextStyle(
                                      color: Color(0xFF7C6CFF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subject,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$start - $end",
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (room.isNotEmpty) ...[
                                  const Icon(Icons.location_on_outlined,
                                      size: 18, color: Colors.greenAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    room,
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
    );
  }
}