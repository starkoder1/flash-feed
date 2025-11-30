import 'package:flash_feed/ui/screens/home/about_screen.dart';
import 'package:flash_feed/ui/screens/home/customize_category_screen.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flash_feed/data/features/theme_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  // --- Logic: Open URLs ---
  Future<void> _launchSocial(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  // --- Logic: Rate App ---
  Future<void> _rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      // Shows the native bottom sheet for 5-star rating
      inAppReview.requestReview();
    } else {
      // Fallback: Opens the Google Play Store page
      inAppReview.openStoreListing(appStoreId: 'com.redfstudios.flashfeed');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final theme = Theme.of(context);

    // Reusable text style for section headers
    TextStyle sectionHeaderStyle = GoogleFonts.manrope(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
      letterSpacing: 1.2,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        // backgroundColor: primaryShade, // From your util.dart
        elevation: 0,
      ),
      // CustomScrollView allows mixing list items with the sticky footer
      body: CustomScrollView(
        slivers: [
          // 1. Main List Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: PREFERENCES ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Text("PREFERENCES", style: sectionHeaderStyle),
                  ),

                  SwitchListTile(
                    activeThumbColor: primaryShade,
                    activeTrackColor: secondaryShade,
                    inactiveThumbColor: primaryShade,
                    inactiveTrackColor: secondaryShade,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text(
                      "Dark Mode",
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                    ),
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    value: isDarkMode,
                    onChanged: (newValue) {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: const Icon(Icons.tune),
                    title: Text(
                      "Customize Feed",
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomizeCategoryScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 40, thickness: 1),

                  // --- SECTION 2: SUPPORT & INFO ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Text("SUPPORT", style: sectionHeaderStyle),
                  ),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: const Icon(Icons.info_outline),
                    title: Text(
                      "About App",
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: const Icon(Icons.star_outline),
                    title: Text(
                      "Rate Us",
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Enjoying FlashFeed? Leave a review!",
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: _rateApp,
                  ),

                  const Divider(height: 40, thickness: 1),

                  // --- SECTION 3: CONNECT ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Text("CONNECT WITH US", style: sectionHeaderStyle),
                  ),

                  const SizedBox(height: 10),

                  // Social Icons Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _SocialButton(
                          icon: FontAwesomeIcons.xTwitter,
                          color: isDarkMode ? Colors.white : Colors.black,
                          onTap: () =>
                              _launchSocial('https://x.com/redfstudio'),
                        ),
                        _SocialButton(
                          icon: FontAwesomeIcons.instagram,
                          color: Colors.pinkAccent,
                          onTap: () => _launchSocial(
                            'https://www.instagram.com/redf.studio/',
                          ),
                        ),
                        _SocialButton(
                          icon: FontAwesomeIcons.linkedinIn,
                          color: const Color(0xFF0077B5), // LinkedIn Blue
                          onTap: () => _launchSocial(
                            'https://www.linkedin.com/in/redf-studios-847b39397/',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Version Number
                  Center(
                    child: Text(
                      "v1.0.0",
                      style: GoogleFonts.manrope(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. The Sticky Footer (Fill Remaining Space)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                const Spacer(), // Pushes content to the bottom
                Padding(
                  // FIXED: Increased to 100 to clear the BottomNavBar
                  padding: const EdgeInsets.only(bottom: 100.0, top: 20),
                  child: Text.rich(
                    TextSpan(
                      text: "Made with love ",
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(
                          text: "❤️",
                          style: TextStyle(fontSize: 10),
                        ),
                        const TextSpan(text: " by Red-F Studios"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Widget for Uniform Social Buttons ---
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: FaIcon(icon, color: color, size: 22)),
      ),
    );
  }
}
