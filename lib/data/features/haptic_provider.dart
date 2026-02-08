import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final hapticProvider =
    StateNotifierProvider<HapticNotifier, bool>((ref) {
  return HapticNotifier();
});

class HapticNotifier extends StateNotifier<bool> {
  static const _key = 'haptic_feedback_enabled';

  HapticNotifier() : super(true) {
    _loadPreference();
  }

  /// Load saved value on app start
  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? true;
  }

  /// Enable / Disable haptics
  Future<void> setEnabled(bool enabled) async {
    state = enabled; // update UI immediately
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}
