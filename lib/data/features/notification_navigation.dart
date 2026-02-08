import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/ui/screens/news_webview_screen.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> notificationNavKey =
    GlobalKey<NavigatorState>();

Map<String, dynamic>? _pendingNotification;

void navigateToNotification(Map<String, dynamic> data) {
  final navigator = notificationNavKey.currentState;
  final newsItem = NewsItem.fromJson(data);

  if (navigator == null) {
    _pendingNotification = data;  // Store the notification data if navigator is not available yet
    return;
  }
  navigator.push(
    MaterialPageRoute(builder: (context) => NewsWebViewScreen(news: newsItem)),  // Navigate to the news webview screen with the news item
  );
}

void handlePendingNotification(){
    if (_pendingNotification == null) return; // No pending notification to handle

    navigateToNotification(_pendingNotification!); // Navigate to the pending notification if pending
    _pendingNotification = null;   // Clear the pending notification after handling
}