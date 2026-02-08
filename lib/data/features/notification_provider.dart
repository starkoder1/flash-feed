import 'package:flash_feed/utils/notification_worker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class NotificationNotifier extends Notifier<bool> {
  static const _notificationKey = 'notifications_enabled';

  @override
  bool build() {
    loadNotificationState();
    return true; // Default to enabled
  }

  // Load the notification state from SharedPreferences
  Future<void> loadNotificationState() async {
    final prefs = await SharedPreferences.getInstance();
    final loaded = prefs.getBool(_notificationKey) ?? true;
    debugPrint("NotificationNotifier: Loaded state $loaded");
    state = loaded;
  }

  // Save the notification state to SharedPreferences
  Future<void> _saveNotificationState(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationKey, isEnabled);
  }

  // Toggle the notification state and save
  void toggleNotifications() {
    state = !state;
    debugPrint("NotificationNotifier: Toggle Notifications -> $state");
    _saveNotificationState(state);
    _handleWorkScheduling(state);
  }

  // Set specific state and save
  void setNotifications(bool isEnabled) {
    state = isEnabled;
    debugPrint("NotificationNotifier: Set Notifications -> $state");
    _saveNotificationState(isEnabled);
    _handleWorkScheduling(isEnabled);
  }

  // Schedule or cancel background work based on state
  void _handleWorkScheduling(bool isEnabled) {
    if (isEnabled) {
      scheduleNextRandomTask();
    } else {
      Workmanager().cancelByUniqueName(uniqueWorkName);
    }
  }
}

// Declare provider
final notificationProvider = NotifierProvider<NotificationNotifier, bool>(
  () => NotificationNotifier(),
);
