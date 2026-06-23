import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AttendanceService {
  static const String baseUrl = ApiService.baseUrl;

  static Future<List<dynamic>> getAttendance(String rollNo) async {
    final response = await http.get(Uri.parse("$baseUrl/attendance/$rollNo"));

    return jsonDecode(response.body);
  }

  static Future<void> addAttendance(
    String rollNo,
    String subject,
    int present,
    int total,
  ) async {
    await http.post(
      Uri.parse("$baseUrl/attendance"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "rollNo": rollNo,
        "subject": subject,
        "present": present,
        "total": total,
      }),
    );
  }
}
