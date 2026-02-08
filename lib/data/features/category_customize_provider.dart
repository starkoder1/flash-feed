import 'package:flash_feed/data/models/news_category.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedCategoriesNotifier extends Notifier<List<NewsCategory>> {
  @override
  List<NewsCategory> build() {
    _loadcategories();
    return [];
  }

  void _loadcategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCategories = prefs.getStringList('selected_categories') ?? [];
      final list = savedCategories
          .map(
            (name) => NewsCategory.values.firstWhere(
              (category) => (category.name) == name,
            ),
          )
          .toList();
      state = list;
      debugPrint(
        'Successfully loaded selected categories: ${list.map((e) => e.name).toList()}',
      );
    } catch (e) {
      debugPrint('Failed to load selected categories: $e');
    }
  }

  Future<void> _savecategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'selected_categories',
        state.map((element) => element.name).toList(),
      );
      debugPrint(
        'Successfully saved selected categories: ${state.map((e) => e.name).toList()}',
      );
    } catch (e) {
      debugPrint('Failed to save selected categories: $e');
    }
  }

  void toggleCategory(NewsCategory category) { // Toggle the category in the state list
    if (state.contains(category)) {  // If the category is already selected, remove it from the list
      state = [...state]..remove(category);  // Create a new list to trigger state change and remove the category
    } else {
      state = [...state, category];  // If the category is not selected, add it to the list by creating a new list with the existing categories and the new category
    }
    _savecategories(); //save the categories as soon as user makes changes
  }

  void clear() {
    state = [];
  }
}

final selectedCategoriesProvider =
    NotifierProvider<SelectedCategoriesNotifier, List<NewsCategory>>(() {
      return SelectedCategoriesNotifier();
    });
