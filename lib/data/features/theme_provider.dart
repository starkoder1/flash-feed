import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends Notifier<bool> {
  static const _themeKey = 'is_dark_mode';

  @override
  bool build() {
    // _loadTheme(); // We will call this manually after the logo screen
    
    return false; // Default to light mode initially
  }

  // Load the theme state from SharedPreferences
  void loadThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    state =
        prefs.getBool(_themeKey) ??
        false; // Use saved value or default to false
  }

  // Save the theme state to SharedPreferences
  Future<void> _saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  // Toggle the theme and save the new state
  void toggleTheme() {
    state = !state;
    _saveTheme(state);
  }

  void setTheme(bool isDarkMode) {
    state = isDarkMode;
    _saveTheme(isDarkMode);
  }
}

// declare provider
final themeProvider = NotifierProvider<ThemeNotifier, bool>(
  () => ThemeNotifier(),
);
