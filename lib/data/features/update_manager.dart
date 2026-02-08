import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flash_feed/ui/widgets/whats_new_sheet.dart';

class UpdateManager {
  static const String _lastShownVersionKey = 'last_shown_version';

  /// Call this in initState of your Home Page
  static Future<void> checkAndShowWhatsNew(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();

    final String currentVersion = packageInfo.version; // e.g., "1.1.0"
    final String? lastShownVersion = prefs.getString(_lastShownVersionKey);

    // Show only when app version changes
    if (lastShownVersion != currentVersion) {
      if (!context.mounted) return;

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => WhatsNewSheet(
          features: const [
            // FEATURE 1: Sticky Navbar
            WhatsNewFeature(
              icon: Icons.auto_awesome,
              title: "Smart News Feed",
              description:
                  "Trending and breaking news in a clean, fast layout.",
            ),

            WhatsNewFeature(
              icon: Icons.category_outlined,
              title: "News Categories",
              description:
                  "Technology, Business, Sports, Entertainment & more.",
            ),

            WhatsNewFeature(
              icon: Icons.bookmark_outline,
              title: "Bookmarks",
              description: "Save articles and read them anytime.",
            ),

            WhatsNewFeature(
              icon: Icons.lock_outline,
              title: "Lock Navigation Bar",
              description: "Keep navigation visible while reading.",
            ),

            WhatsNewFeature(
              icon: Icons.speed,
              title: "Smooth Performance",
              description: "Faster loading and smooth scrolling.",
            ),

            WhatsNewFeature(
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
              description: "Comfortable reading in low light.",
            ),

            WhatsNewFeature(
              icon: Icons.tablet_mac_outlined,
              title: "Large Screen Support",
              description: "Optimized for tablets and landscape mode.",
            ),

            WhatsNewFeature(
              icon: Icons.share_outlined,
              title: "Quick Sharing",
              description: "Share news instantly with friends.",
            ),
          ],
          onDismiss: () {
            Navigator.pop(context);
            HapticFeedback.mediumImpact(); // Haptic feedback on dismiss
          },
        ),
      );

      // Save current version so it doesn't show again
      await prefs.setString(_lastShownVersionKey, currentVersion);
    }
  }
}