import 'package:flash_feed/data/features/notification_navigation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Centralized notification service for handling plugin initialization
/// and notification tap events.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static FlutterLocalNotificationsPlugin get plugin => _plugin;

  /// Initialize the notification plugin with tap callback.
  /// Must be called in main() before runApp().
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    // v20.0.0 requires named parameter 'settings:'
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// Handle notification tap - navigates to the news article using existing implementation
  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    // Use existing navigateToNotification with link in map
    navigateToNotification({'link': payload});
  }

  /// Request notification permission (Android 13+)
  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Manually trigger a test notification for debugging
  static Future<void> triggerTestNotification({
    String title = 'FlashFeed Test',
    String body = 'This is a test notification',
    String? link,
  }) async {
    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_news_channel',
          'FlashFeed Updates',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: link ?? 'https://example.com',
    );
  }
}
