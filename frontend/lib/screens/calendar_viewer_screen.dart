import 'package:flutter/material.dart';

class CalendarReviewScreen extends StatelessWidget {
  final String extractedText;

  const CalendarReviewScreen({
    super.key,
    required this.extractedText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Review Academic Calendar",
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

            const Text(
              "Extracted Calendar Data",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Expanded(
              child:
                  SingleChildScrollView(
                child: Text(
                  extractedText,
                  style:
                      const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed: () {

                ScaffoldMessenger.of(
                        context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Calendar Confirmed",
                    ),
                  ),
                );

                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                "Confirm & Save",
              ),
            ),
          ],
        ),
      ),
    );
  }
}