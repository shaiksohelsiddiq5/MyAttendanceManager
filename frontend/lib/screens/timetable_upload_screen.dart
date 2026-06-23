import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/timetable_upload_service.dart';
import '../services/storage_service.dart';

class TimetableUploadScreen extends StatefulWidget {
  const TimetableUploadScreen({super.key});

  @override
  State<TimetableUploadScreen> createState() => _TimetableUploadScreenState();
}

class _TimetableUploadScreenState extends State<TimetableUploadScreen> {
  String fileName = "No Timetable Uploaded";

  String timetableText = "";

  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadTimetableName();
  }

  Future<void> _loadTimetableName() async {
    final name = await StorageService.getTimetableFileName();
    if (name.isNotEmpty) {
      setState(() {
        fileName = "Timetable: $name";
      });
    }
  }

  final TextEditingController reviewController = TextEditingController();

  Future<void> uploadTimetable() async {
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

      final response = await TimetableUploadService.uploadTimetable(
        bytes,
        file.name,
      );

      if (!mounted) return;

      final ocrText =
          response['ocrText']?.toString() ??
          response['text']?.toString() ??
          response.toString();

      setState(() {
        timetableText = ocrText;
        isUploading = false;
      });

      reviewController.text = ocrText;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Review Timetable')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: reviewController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Edit Timetable OCR Result',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        timetableText = reviewController.text;

                        await StorageService.saveTimetable(
                          file.name,
                          timetableText,
                        );

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Timetable Confirmed')),
                        );

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/dashboard',
                          (route) => false,
                        );
                      },
                      child: const Text('Confirm & Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Timetable")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Text(fileName),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: uploadTimetable,
              child: Text(fileName.startsWith("Timetable:") ? "Re-upload Timetable" : "Choose Timetable"),
            ),

            const SizedBox(height: 20),

            if (isUploading) const CircularProgressIndicator(),

            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(timetableText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
