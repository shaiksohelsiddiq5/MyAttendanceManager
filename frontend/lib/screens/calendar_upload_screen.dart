import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/upload_service.dart';
import '../services/storage_service.dart';

class CalendarUploadScreen extends StatefulWidget {
  const CalendarUploadScreen({super.key});

  @override
  State<CalendarUploadScreen> createState() => _CalendarUploadScreenState();
}

class _CalendarUploadScreenState extends State<CalendarUploadScreen> {
  String fileName = "No Academic Calendar Uploaded";

  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadCalendarName();
  }

  Future<void> _loadCalendarName() async {
    final name = await StorageService.getCalendarFileName();
    if (name.isNotEmpty) {
      setState(() {
        fileName = "Academic Calendar: $name";
      });
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (result == null) return;

      final file = result.files.first;

      Uint8List bytes = file.bytes!;

      setState(() {
        fileName = file.name;
        isUploading = true;
      });

      String response = await UploadService.uploadCalendar(bytes, file.name);
      final analysis = jsonDecode(response) as Map<String, dynamic>;

      await StorageService.saveCalendar(file.name);

      setState(() {
        isUploading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload Success")));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text("Review Academic Calendar")),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    analysis['analysisSource'] == 'local-ai'
                        ? Icons.auto_awesome_rounded
                        : Icons.rule_rounded,
                    color: analysis['analysisSource'] == 'local-ai'
                        ? const Color(0xFF9B91FF)
                        : Colors.orangeAccent,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    analysis['analysisSource'] == 'local-ai'
                        ? 'Local AI analysis complete'
                        : 'Calendar processed with fallback',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        _AnalysisSection(
                          title: 'Semester dates',
                          icon: Icons.date_range_rounded,
                          items: analysis['semesterDates'],
                        ),
                        _AnalysisSection(
                          title: 'Exams',
                          icon: Icons.school_rounded,
                          items: analysis['exams'],
                        ),
                        _AnalysisSection(
                          title: 'Holidays',
                          icon: Icons.celebration_rounded,
                          items: analysis['holidays'],
                        ),
                        if ((analysis['warnings'] as List? ?? []).isNotEmpty)
                          _AnalysisSection(
                            title: 'Needs review',
                            icon: Icons.warning_amber_rounded,
                            items: analysis['warnings'],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      '/timetable-upload',
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Continue to Timetable'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isUploading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),
      appBar: AppBar(title: const Text("Academic Calendar Upload")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.upload_file, size: 100, color: Colors.white),

              const SizedBox(height: 20),

              Text(
                fileName,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),

              const SizedBox(height: 30),

              isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: pickFile,
                      child: Text(fileName.startsWith("Academic Calendar:") ? "Re-upload Calendar" : "Choose Calendar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalysisSection extends StatelessWidget {
  const _AnalysisSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final dynamic items;

  @override
  Widget build(BuildContext context) {
    final values = (items as List? ?? [])
        .map((item) => item.toString())
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF9B91FF)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (values.isEmpty)
              const Text('Nothing detected')
            else
              ...values.map(
                (value) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Text('• $value'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
