import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String rollNo = "";
  String branch = "";
  String year = "";
  String attendance = "";
  String target = "";

  @override
  void initState() {
    super.initState();
    loadStudentData();
  }

  Future<void> loadStudentData() async {
    name = await StorageService.getName();
    rollNo = await StorageService.getRollNo();
    branch = await StorageService.getBranch();
    year = await StorageService.getYear();
    attendance = await StorageService.getAttendance();
    target = await StorageService.getTarget();
    if (mounted) setState(() {});
  }

  void showEditDialog() {
    final nameController = TextEditingController(text: name);
    final branchController = TextEditingController(text: branch);
    final yearController = TextEditingController(text: year);
    final targetController = TextEditingController(text: target);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile Info"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Student Name"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: branchController,
                  decoration: const InputDecoration(labelText: "Branch"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: "Year (e.g. 2-1)"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetController,
                  decoration: const InputDecoration(labelText: "Target Attendance (%)"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                final newBranch = branchController.text.trim();
                final newYear = yearController.text.trim();
                final newTarget = targetController.text.trim();

                if (newName.isEmpty || newBranch.isEmpty || newYear.isEmpty || newTarget.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required")),
                  );
                  return;
                }

                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);

                try {
                  final roll = await StorageService.getRollNo();
                  final attClasses = await StorageService.getAttendedClasses();
                  final totClasses = await StorageService.getTotalClasses();

                  final response = await http.post(
                    Uri.parse("${ApiService.baseUrl}/api/setup"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "rollNo": roll,
                      "name": newName,
                      "branch": newBranch,
                      "year": newYear,
                      "attendance": attendance,
                      "target": newTarget,
                      "attendedClasses": attClasses,
                      "totalClasses": totClasses,
                    }),
                  );

                  if (response.statusCode == 200) {
                    await StorageService.saveStudent(newName, roll);
                    await StorageService.saveSetup(newBranch, newYear, attendance, newTarget);
                    await loadStudentData();
                    messenger.showSnackBar(
                      const SnackBar(content: Text("Profile updated successfully")),
                    );
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(content: Text("Failed to update profile")),
                    );
                  }
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text("Error updating profile: $e")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget profileTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081B3A),
      appBar: AppBar(
        title: const Text("Student Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: showEditDialog,
            tooltip: "Edit Profile",
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 60,
            child: Icon(
              Icons.person,
              size: 70,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          profileTile(
            Icons.person,
            "Student Name",
            name,
          ),
          profileTile(
            Icons.badge,
            "Roll Number",
            rollNo,
          ),
          profileTile(
            Icons.school,
            "Branch",
            branch,
          ),
          profileTile(
            Icons.menu_book,
            "Year",
            year,
          ),
          profileTile(
            Icons.percent,
            "Attendance",
            "$attendance%",
          ),
          profileTile(
            Icons.flag,
            "Target",
            "$target%",
          ),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                "Student information loaded from saved profile settings.",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}