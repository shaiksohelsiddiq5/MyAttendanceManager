import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AcademicCalendarViewerScreen extends StatelessWidget {
  final Uint8List pdfBytes;

  const AcademicCalendarViewerScreen({
    super.key,
    required this.pdfBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Academic Calendar",
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SfPdfViewer.memory(
              pdfBytes,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Calendar Confirmed',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Confirm & Continue',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}