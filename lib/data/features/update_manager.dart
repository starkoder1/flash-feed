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
            WhatsNewFeature(
              icon: Icons.view_stream_rounded,
              title: "Smoother Home Feed",
              description:
                  "Fixed the scrolling glitch on the Home screen for a fluid experience.",
            ),
            WhatsNewFeature(
              icon: Icons.tune_rounded,
              title: "Settings Access",
              description:
                  "The Settings menu is now fully scrollable. No more hidden options on small screens.",
            ),
            WhatsNewFeature(
              icon: Icons.dark_mode_rounded,
              title: "Clearer Alerts",
              description:
                  "Pop-up messages (SnackBars) are now fully readable when using Dark Mode.",
            ),
            WhatsNewFeature(
              icon: Icons.palette_outlined,
              title: "Visual Polish",
              description:
                  "Fixed Bookmark tag colors and restored the responsiveness of the 'Rate Us' button.",
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
