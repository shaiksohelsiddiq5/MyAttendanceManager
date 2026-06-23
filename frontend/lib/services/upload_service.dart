import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'storage_service.dart';

class UploadService {
  static Future<String> uploadCalendar(Uint8List bytes, String fileName) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${ApiService.baseUrl}/upload-calendar"),
    );

    request.files.add(
      http.MultipartFile.fromBytes("file", bytes, filename: fileName),
    );

    request.fields['rollNo'] = await StorageService.getRollNo();

    var response = await request.send();

    var body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Calendar upload failed: $body');
    }

    return body;
  }
}
