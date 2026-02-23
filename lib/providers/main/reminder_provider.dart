import 'package:flutter/material.dart';
import 'package:restoranapp/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderProvider extends ChangeNotifier {
  static const _reminderKey = 'daily_reminder';

  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  ReminderProvider() {
    _loadReminder();
  }

  Future<void> toggleReminder(bool value) async {
    _isEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderKey, value);

    if (value) {
      await NotificationService.requestPermission();
      await NotificationService.scheduleDailyReminder();
    } else {
      await NotificationService.cancelReminder();
    }
  }

  Future<void> _loadReminder() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_reminderKey) ?? false;

    if (_isEnabled) {
      await NotificationService.scheduleDailyReminder();
    }

    notifyListeners();
  }
}
