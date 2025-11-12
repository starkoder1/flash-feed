import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() => false; // initial state (false = light mode)

  void toggleTheme() => state = !state;
}

// declare provider
final themeProvider = NotifierProvider<ThemeNotifier, bool>(
  () => ThemeNotifier(),
);
