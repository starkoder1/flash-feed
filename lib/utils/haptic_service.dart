import 'package:flutter/services.dart';

class HapticService {
  static void light(bool enabled) {
    if (enabled) HapticFeedback.lightImpact();
  }

  static void medium(bool enabled) {
    if (enabled) HapticFeedback.mediumImpact();
  }

  static void heavy(bool enabled) {
    if (enabled) HapticFeedback.heavyImpact();
  }

  static void select(bool enabled) {
    if (enabled) HapticFeedback.selectionClick();
  }
}
