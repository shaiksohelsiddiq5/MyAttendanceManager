import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveStudent(String name, String rollNo) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("name", name);
    await prefs.setString("rollNo", rollNo);
  }

  static Future<void> saveSetup(
    String branch,
    String year,
    String attendance,
    String target,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("branch", branch);

    await prefs.setString("year", year);

    await prefs.setString("attendance", attendance);

    await prefs.setString("target", target);

    await prefs.setBool("setupComplete", true);
  }

  static Future<void> saveAttendanceCounts(int attended, int total) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("attendedClasses", attended);
    await prefs.setInt("totalClasses", total);
  }

  static Future<void> saveCalendar(String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("calendarFileName", fileName);
  }

  static Future<void> saveTimetable(
    String fileName,
    String extractedText,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("timetableFileName", fileName);
    await prefs.setString("timetableText", extractedText);
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("name") ?? "";
  }

  static Future<String> getRollNo() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("rollNo") ?? "";
  }

  static Future<String> getBranch() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("branch") ?? "";
  }

  static Future<String> getYear() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("year") ?? "";
  }

  static Future<String> getAttendance() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("attendance") ?? "";
  }

  static Future<String> getTarget() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("target") ?? "";
  }

  static Future<int> getAttendedClasses() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("attendedClasses") ?? 0;
  }

  static Future<int> getTotalClasses() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("totalClasses") ?? 0;
  }

  static Future<String> getCalendarFileName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("calendarFileName") ?? "";
  }

  static Future<String> getTimetableFileName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("timetableFileName") ?? "";
  }

  static Future<void> saveSelectedDate(String dateStr) async {
    final prefs = await SharedPreferences.getInstance();
    final rollNo = prefs.getString("rollNo") ?? "";
    if (rollNo.isNotEmpty) {
      await prefs.setString("selectedDate_$rollNo", dateStr);
    } else {
      await prefs.setString("selectedDate", dateStr);
    }
  }

  static Future<String> getSelectedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final rollNo = prefs.getString("rollNo") ?? "";
    if (rollNo.isNotEmpty) {
      return prefs.getString("selectedDate_$rollNo") ?? prefs.getString("selectedDate") ?? "";
    }
    return prefs.getString("selectedDate") ?? "";
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList();
    for (final key in keys) {
      if (!key.startsWith("selectedDate")) {
        await prefs.remove(key);
      }
    }
  }
}
