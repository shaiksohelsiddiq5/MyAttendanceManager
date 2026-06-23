import 'package:flutter/material.dart';

class SmartRecommendationScreen extends StatelessWidget {
  const SmartRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final recommendations = [
      "📚 Attend Java classes this week",
      "🎯 Avoid bunking DBMS tomorrow",
      "📅 Take leave after upcoming holiday",
      "🔥 You can safely bunk 1 class today",
      "🏆 Maintain 85% attendance target",
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text(
          "Smart Recommendations",
        ),
      ),

      body: ListView.builder(
        itemCount: recommendations.length,

        itemBuilder: (context, index) {

          return Card(
            margin: const EdgeInsets.all(10),

            child: ListTile(
              leading: const Icon(
                Icons.lightbulb,
                color: Colors.orange,
              ),

              title: Text(
                recommendations[index],
              ),
            ),
          );
        },
      ),
    );
  }
}