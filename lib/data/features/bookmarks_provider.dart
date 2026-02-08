import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final bookMarksProvider = NotifierProvider<BookmarksNotifier, List<NewsItem>>(
  BookmarksNotifier.new,
);

class BookmarksNotifier extends Notifier<List<NewsItem>> {
  final _box = Hive.box('bookmarks');

  @override
  List<NewsItem> build() {
    return _box.values.map((e) {  // Convert each stored bookmark back into a NewsItem
      final map = Map<String, dynamic>.from(e as Map);  // Ensure the stored data is treated as a Map<String, dynamic>
      return NewsItem.fromJson(map); // Convert the map back into a NewsItem using the fromJson constructor
    }).toList();
  }

  void addBookmark(NewsItem item) async {
    try {
      await _box.put(item.link, item.toJson());
      debugPrint("✔ BOOKMARK ADDED");
      debugPrint("   TITLE → ${item.title}");
      debugPrint("   LINK → ${item.link}");
      debugPrint("   TOTAL → ${_box.length}");
      state = [...state, item];
    } catch (e) {
      debugPrint("❌ FAILED TO ADD BOOKMARK");
      debugPrint("   TITLE → ${item.title}");
      debugPrint("   LINK → ${item.link}");
      debugPrint("   ERROR → $e");
    }
  }

  void removeBookmark(NewsItem item) async {
    try {
      await _box.delete(item.link);
      debugPrint("✔ BOOKMARK REMOVED");
      debugPrint("   TITLE → ${item.title}");
      debugPrint("   LINK → ${item.link}");
      debugPrint("   TOTAL → ${_box.length}");
      state = state.where((i) => i.link != item.link).toList(); // Update the state by filtering out the removed bookmark
    } catch (e) {
      debugPrint("❌ FAILED TO DELETE BOOKMARK");
      debugPrint("   TITLE → ${item.title}");
      debugPrint("   LINK → ${item.link}");
      debugPrint("   ERROR → $e");
    }
  }

  bool isBookmarked(NewsItem item) {
    return _box.containsKey(item.link);
  }
}
