import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../services/api_service.dart';

class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({super.key});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> {
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
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load holidays');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text("Holidays"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : holidays.isEmpty
          ? const Center(
              child: Text(
                "No Holidays Found",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            )
          : ListView.builder(
              itemCount: holidays.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(
                      holidays[index]["name"].toString(),
                    ),
                    subtitle: Text(
                      holidays[index]["date"].toString(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}