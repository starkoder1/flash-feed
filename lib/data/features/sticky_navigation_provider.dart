import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StickyNavNotifier extends Notifier<bool> {
  static const _stickyKey = 'is_sticky_nav';

  @override
  bool build() {
    loadStickyState();
    return false; // Default to hiding mode (false) initially
  }

  // Load the sticky state from SharedPreferences
  Future<void> loadStickyState() async {
    final prefs = await SharedPreferences.getInstance();
    final loaded = prefs.getBool(_stickyKey) ?? false;
    debugPrint("StickyNavNotifier: Loaded state $loaded");
    state = loaded;
  }

  // Save the sticky state to SharedPreferences
  Future<void> _saveStickyState(bool isSticky) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_stickyKey, isSticky);
  }

  // Toggle the sticky state and save
  void toggleSticky() {
    state = !state;
    debugPrint("StickyNavNotifier: Toggle Sticky -> $state");
    _saveStickyState(state);
  }

  // Set specific state and save
  void setSticky(bool isSticky) {
    state = isSticky;
    debugPrint("StickyNavNotifier: Set Sticky -> $state");
    _saveStickyState(isSticky);
  }
}

// declare provider
final stickyNavProvider = NotifierProvider<StickyNavNotifier, bool>(
  () => StickyNavNotifier(),
);
