import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flash_feed/ui/widgets/whats_new_sheet.dart'; // Import your widget

class UpdateManager {
  static const String _lastShownVersionKey = 'last_shown_version';

  /// Call this in initState of your Home Page
  static Future<void> checkAndShowWhatsNew(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();

    final String currentVersion = packageInfo.version; // e.g., "1.0.1"
    final String? lastShownVersion = prefs.getString(_lastShownVersionKey);

    // LOGIC: Show if saved version is different from current version
    if (lastShownVersion != currentVersion) {
      // Safety check: Ensure context is still valid before showing UI
      if (!context.mounted) return;

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Allows sheet to be taller
        backgroundColor: Colors.transparent,
        builder: (context) => WhatsNewSheet(
          features: const [
            // FEATURE 1: Sticky Navbar
            WhatsNewFeature(
              icon: Icons.lock,
              title: "Lock Navigation Bar",
              description:
                  "Want the menu to stay put while you read? You can now disable auto-hide in Settings.",
            ),

            // FEATURE 2: Tablet/Landscape UI
            WhatsNewFeature(
              icon: Icons.tablet_mac_outlined,
              title: "Optimized for Large Screens",
              description:
                  "Flash Feed now looks better than ever on tablets and in landscape mode with a responsive layout.",
            ),
          ],
          onDismiss: () {
            Navigator.pop(context);
          },
        ),
      );

      // Save the current version so it doesn't show again until next update
      await prefs.setString(_lastShownVersionKey, currentVersion);
    }
  }
}
