import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../services/api_service.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  List exams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    try {
      final rollNo = await StorageService.getRollNo();
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/exams/$rollNo"),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            exams = jsonDecode(response.body) as List;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load exams');
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
      backgroundColor:
          const Color(0xFF081B3A),

      appBar: AppBar(
        title: const Text(
          "Upcoming Exams",
        ),
        backgroundColor: Colors.black,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : exams.isEmpty
              ? const Center(
                  child: Text(
                    "No Exams Found",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: exams.length,
                  itemBuilder: (context, index) {

          return Card(
            margin:
                const EdgeInsets.all(10),

            child: ListTile(
              leading:
                  const Icon(Icons.school),

              title: Text(
                exams[index]["subject"]
                    .toString(),
              ),

              subtitle: Text(
                exams[index]["date"]
                    .toString(),
              ),
            ),
          );
        },
      ),
    );
  }
}