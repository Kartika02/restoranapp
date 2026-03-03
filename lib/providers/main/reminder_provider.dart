import 'package:flutter/material.dart';
import 'package:restoranapp/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderProvider extends ChangeNotifier {
  final NotificationService _notificationService;

  static const String _key = "daily_reminder";

  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  ReminderProvider(this._notificationService) {
    _loadReminderStatus();
  }

  Future<void> _loadReminderStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> toggleReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    _isEnabled = value;
    await prefs.setBool(_key, value);

    if (value) {
      await _notificationService.scheduleDaily11AMNotification(id: 1);
      final pending = await _notificationService.pendingNotificationRequests();
      print("Pending notifications: ${pending.length}");
    } else {
      await _notificationService.cancelNotification(1);
    }

    notifyListeners();
  }

  int _notificationId = 0;
  bool? _permission = false;
  bool? get permission => _permission;

  // todo-02-provider-01: add the state
  List<PendingNotificationRequest> pendingNotificationRequests = [];

  Future<void> requestPermissions() async {
    _permission = await _notificationService.requestPermissions();
    notifyListeners();
  }

  void showNotification() {
    _notificationId += 1;
    _notificationService.showNotification(
      id: _notificationId,
      title: "New Notification",
      body: "This is a new notification with id $_notificationId",
      payload: "This is a payload from notification with id $_notificationId",
    );
  }

  // todo-02-provider-02: create a schedule notification
  void scheduleDaily11AMNotification() {
    _notificationId += 1;
    _notificationService.scheduleDaily11AMNotification(id: _notificationId);
  }

  // todo-02-provider-03: show a list of pending notification
  Future<void> checkPendingNotificationRequests(BuildContext context) async {
    pendingNotificationRequests = await _notificationService
        .pendingNotificationRequests();
    notifyListeners();
  }

  // todo-02-provider-04: cancel a notification
  Future<void> cancelNotification(int id) async {
    await _notificationService.cancelNotification(id);
  }
}
