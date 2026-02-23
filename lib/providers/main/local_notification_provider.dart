import 'package:shared_preferences/shared_preferences.dart';

class ReminderPreferences {
  static const String _dailyReminderKey = 'daily_reminder';
  static const String _dailyReminderTimeKey = 'daily_reminder_time';

  /// Save reminder status (true/false)
  Future<void> setDailyReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderKey, value);
  }

  /// Get reminder status
  Future<bool> getDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dailyReminderKey) ?? false;
  }

  /// Save reminder time (contoh: "08:00")
  Future<void> setReminderTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyReminderTimeKey, time);
  }

  /// Get reminder time
  Future<String?> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dailyReminderTimeKey);
  }
}
