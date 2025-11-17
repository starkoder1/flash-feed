import 'package:flash_feed/data/models/news_category.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedCategoriesNotifier extends Notifier<List<NewsCategory>> {
  @override
  List<NewsCategory> build() {
    return [];
  }

  void toggleCategory(NewsCategory Category) {
    if (state.contains(Category)) {
      state = [...state]..remove(Category);
    } else {
      state = [...state, Category];
    }
  }

  void clear() {
    state = [];
  }
}

final selectedCategoriesProvider =
    NotifierProvider<SelectedCategoriesNotifier, List<NewsCategory>>(() {
      return SelectedCategoriesNotifier();
    });
