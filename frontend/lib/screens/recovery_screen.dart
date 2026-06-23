import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../services/api_service.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  int attended = 0;
  int total = 0;
  double target = 75;
  List _subjectAttendance = [];
  bool _loadingSubjects = true;

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
      if (rollNo.isNotEmpty) {
        final res = await http.get(Uri.parse("${ApiService.baseUrl}/attendance/$rollNo"));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as List;
          if (mounted) {
            setState(() {
              _subjectAttendance = data;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading subject recovery: $e");
    } finally {
      if (mounted) {
        setState(() {
          _loadingSubjects = false;
        });
      }
    }
  }

  int get classesNeeded {
    if (total == 0 || target >= 100) return 0;
    final current = attended * 100 / total;
    if (current >= target) return 0;
    return ((target * total - 100 * attended) / (100 - target)).ceil();
  }

  List<Widget> _buildSubjectRecoveryList() {
    final processed = _subjectAttendance.map((item) {
      final subject = item['subject']?.toString() ?? 'Unknown';
      final present = (item['present'] as num? ?? 0).toInt();
      final tot = (item['total'] as num? ?? 0).toInt();
      final currentPct = tot == 0 ? 0.0 : (present / tot) * 100;

      int needed = 0;
      if (tot > 0 && target < 100 && currentPct < target) {
        needed = ((target * tot - 100 * present) / (100 - target)).ceil();
      }

      return {
        'subject': subject,
        'present': present,
        'total': tot,
        'currentPct': currentPct,
        'needed': needed,
      };
    }).toList();

    // Sort: needed > 0 first (descending), then alphabetically or by currentPct
    processed.sort((a, b) {
      final neededA = a['needed'] as int;
      final neededB = b['needed'] as int;
      if (neededA != neededB) {
        return neededB.compareTo(neededA); // More needed at top
      }
      final pctA = a['currentPct'] as double;
      final pctB = b['currentPct'] as double;
      return pctA.compareTo(pctB); // Lower percentage at top
    });

    return processed.map((item) {
      final subject = item['subject'] as String;
      final present = item['present'] as int;
      final tot = item['total'] as int;
      final currentPct = item['currentPct'] as double;
      final needed = item['needed'] as int;
      final isBelow = needed > 0;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isBelow ? const Color(0xFFFF6B6B).withValues(alpha: 0.5) : const Color(0xFF20C997).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subject,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isBelow
                          ? const Color(0xFFFF6B6B).withValues(alpha: 0.15)
                          : const Color(0xFF20C997).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${currentPct.toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: isBelow ? const Color(0xFFFF6B6B) : const Color(0xFF20C997),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Current attendance: $present/$tot classes",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
              ),
              const SizedBox(height: 8),
              if (isBelow)
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB547), size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Attend the next $needed consecutive classes to reach $target%",
                        style: const TextStyle(
                          color: Color(0xFFFFB547),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF20C997), size: 18),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        "On track! Target achieved.",
                        style: TextStyle(
                          color: Color(0xFF20C997),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final current = total == 0 ? 0.0 : attended * 100 / total;
    final needed = classesNeeded;
    final recovered = total == 0
        ? 0.0
        : (attended + needed) * 100 / (total + needed);

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),
      appBar: AppBar(title: const Text('Attendance recovery')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF087F5B), Color(0xFF20C997)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(Icons.trending_up_rounded, size: 58),
                  const SizedBox(height: 12),
                  Text(
                    needed == 0
                        ? 'You are on target'
                        : 'Attend the next $needed classes',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    needed == 0
                        ? 'Keep showing up to protect your buffer.'
                        : 'Without missing one, you will reach ${recovered.toStringAsFixed(1)}%.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Current overall'),
                    trailing: Text('${current.toStringAsFixed(1)}%'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Target'),
                    trailing: Text('${target.toStringAsFixed(1)}%'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Classes required overall'),
                    trailing: Text(
                      '$needed',
                      style: const TextStyle(
                        color: Color(0xFF20C997),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Subject-wise Recovery Plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_loadingSubjects)
              const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ))
            else if (_subjectAttendance.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(child: Text("No subjects tracked yet.")),
                ),
              )
            else
              ..._buildSubjectRecoveryList(),
            const SizedBox(height: 22),
            const Text(
              'Recovery checklist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.check_circle_outline),
                    title: Text(
                      'Attend every upcoming class until the target is reached',
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.notifications_active_outlined),
                    title: Text(
                      'Use exam alerts to avoid missing internal assessments',
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.update_rounded),
                    title: Text('Update attendance after each college day'),
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
