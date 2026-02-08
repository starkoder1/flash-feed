import 'dart:math';
import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

// CONSTANTS
const String taskName = "flashfeed_random_news_task";
const String uniqueWorkName = "flashfeed_background_service";
const String channelId = "daily_news_channel";
const String channelName = "FlashFeed Updates";

/// The Entry Point for the Background Isolate
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 1. Initialize Dependencies
      if (Platform.isAndroid) {
        final appDocumentDir = await getApplicationDocumentsDirectory();
        Hive.init(appDocumentDir.path);
      }

      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const initSettings = InitializationSettings(android: androidSettings);
      // v20.0.0 requires named parameter 'settings:'
      await flutterLocalNotificationsPlugin.initialize(settings: initSettings);

      // 2. Open the Hive Box
      final box = await Hive.openBox('forYouNews');

      // 3. CHECK FRESHNESS (The 24-Hour Rule)
      final lastSavedTime = box.get('lastSavedTime', defaultValue: 0) as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - lastSavedTime;
      final oneDayInMillis = 24 * 60 * 60 * 1000;

      if (lastSavedTime == 0 || diff > oneDayInMillis) {
        print("Worker: Data is stale. Skipping.");
        return Future.value(true);
      }

      // 4. Retrieve Articles
      final rawArticles = box.get('savedArticles', defaultValue: []);
      if (rawArticles.isEmpty) {
        return Future.value(true);
      }

      // 5. Pick ONE Random Article
      final randomIndex = Random().nextInt(rawArticles.length);
      final articleData = rawArticles[randomIndex];

      String title = "News Update";
      String link = "";

      // Handle Map format saved by for_you_provider
      if (articleData is Map) {
        title = articleData['title'] ?? 'News Update';
        link = articleData['link'] ?? '';
      } else {
        title = articleData.toString();
      }

      // 6. Show Notification (v20.0.0 uses named parameters)
      await flutterLocalNotificationsPlugin.show(
        id: Random().nextInt(10000),
        title: "FlashFeed Daily",
        body: title,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(''),
          ),
        ),
        payload: link,
      );
    } catch (e) {
      print("Worker Error: $e");
      return Future.value(true);
    } finally {
      // 7. THE DAISY CHAIN (Reschedule)
      scheduleNextRandomTask();
    }

    return Future.value(true);
  });
}

/// Helper function to schedule the next task
void scheduleNextRandomTask() {
  int randomDelayMinutes = 30;

  Workmanager().registerOneOffTask(
    uniqueWorkName,
    taskName,
    initialDelay: Duration(minutes: randomDelayMinutes),
    existingWorkPolicy: ExistingWorkPolicy.keep, // Don't cancel if already scheduled
    constraints: Constraints(networkType: NetworkType.notRequired),
  );
}
