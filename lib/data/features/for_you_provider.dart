import 'package:flash_feed/data/features/all_category_provider.dart';
import 'package:flash_feed/data/features/category_customize_provider.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForYouProvider extends AsyncNotifier<List<NewsItem>> {
  @override
  Future<List<NewsItem>> build() async {
    final selectedCategories = ref.watch(selectedCategoriesProvider);
    final allNewsItems = await ref.watch(allCategoryProvider.future);
    if (selectedCategories.isEmpty) {
      return allNewsItems;
    }
    final selectedCategoryNames = selectedCategories.map((e) => e.name).toSet();
    final filtered = allNewsItems
        .where((element) => selectedCategoryNames.contains(element.category))
        .toList();
    debugPrint('Filtered For You News Items: ${filtered.length.toString()}');
    return filtered;
  }
}

final forYouProivder = AsyncNotifierProvider<ForYouProvider, List<NewsItem>>(
  (ForYouProvider.new),
);
