import 'dart:convert';

import 'package:flash_feed/data/features/all_category_provider.dart';
import 'package:flash_feed/data/features/category_customize_provider.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForYouProvider extends AsyncNotifier<List<NewsItem>> {
  @override
  Future<List<NewsItem>> build() async {
    final selectedCategories = ref.watch(selectedCategoriesProvider);
    final allNewsItems = await ref.watch(allCategoryProvider.future);
    if (selectedCategories.isEmpty) {
      return allNewsItems;
    }
    final selectedCategoryNames = selectedCategories
        .map((e) => e.name)
        .toSet(); // Create a set of selected category names for efficient lookup
    final filtered = allNewsItems
        .where((element) => selectedCategoryNames.contains(element.category))
        .toList(); // Filter the news items based on the selected categories
    debugPrint('Filtered For You News Items: ${filtered.length.toString()}');

    // Save the filtered news items to Hive for offline access
    final box = await Hive.openBox(
      'forYouNews',
    ); // Open a Hive box named 'forYouNews' to store the filtered news items
    await box.put(
      'news',
      filtered.map((item) => item.toJson()).toList(),
    ); // Store the filtered news items in the Hive box as a list of JSON objects

    final titlesAndLinks = filtered
        .map((item) => <String, String>{'title': item.title, 'link': item.link})
        .toList(); //
    await box.put(
      'savedArticles',
      titlesAndLinks,
    ); // Save the titles and links of the filtered news items

    await box.put(
      'lastSavedTime',
      DateTime.now().millisecondsSinceEpoch,
    ); // Save the current time as the last saved time for the news items
    return filtered;
  }
}

final forYouProivder = AsyncNotifierProvider<ForYouProvider, List<NewsItem>>(
  (ForYouProvider.new),
);
