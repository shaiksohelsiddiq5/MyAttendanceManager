import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'storage_service.dart';

class TimetableUploadService {
  static Future<Map<String, dynamic>> uploadTimetable(
    Uint8List bytes,
    String fileName,
  ) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${ApiService.baseUrl}/api/timetable/upload-timetable"),
    );

    request.files.add(
      http.MultipartFile.fromBytes("file", bytes, filename: fileName),
    );
    request.fields['rollNo'] = await StorageService.getRollNo();

    var response = await request.send();

    var responseBody = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Timetable upload failed: $responseBody');
    }

    return jsonDecode(responseBody) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getTimetable(String rollNo) async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/api/timetable/$rollNo"),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load timetable: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['sessions'] as List<dynamic>? ?? [];
  }
}
