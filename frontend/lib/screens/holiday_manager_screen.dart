import 'package:flutter/material.dart';

class HolidayManagerScreen extends StatefulWidget {
  const HolidayManagerScreen({super.key});

  @override
  State<HolidayManagerScreen> createState() =>
      _HolidayManagerScreenState();
}

class _HolidayManagerScreenState
    extends State<HolidayManagerScreen> {

  final List<Map<String, String>> holidays = [
    {
      "name": "Independence Day",
      "date": "15 Aug 2026",
    },
    {
      "name": "Gandhi Jayanti",
      "date": "02 Oct 2026",
    },
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text(
          "Holiday Manager",
        ),
      ),

      body: ListView.builder(
        itemCount: holidays.length,

        itemBuilder: (context, index) {

          return Card(
            margin: const EdgeInsets.all(10),

            child: ListTile(
              leading: const Icon(
                Icons.event,
              ),

              title: Text(
                holidays[index]["name"]!,
              ),

              subtitle: Text(
                holidays[index]["date"]!,
              ),
            ),
          );
        },
      ),
    );
  }
}