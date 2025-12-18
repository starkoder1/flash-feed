import 'package:flash_feed/ui/screens/home/licenses_screen.dart'; // Your license screen
import 'package:flash_feed/ui/screens/home/mini_webivew_screen.dart';
import 'package:flash_feed/utils/util.dart'; // For your colors
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// --- ADD THIS IMPORT FOR THE NEW SCREEN BELOW ---
import 'company_info_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About",
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),

          // --- 1. APP HERO SECTION ---
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: primaryShade, // Your brand color
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: primaryShade.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              image: const DecorationImage(
                image: AssetImage(
                  'assets/logo_alt.png',
                ), // Make sure this exists
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "FlashFeed",
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            "${appBuildNumber} ",
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 40),

          // --- 2. LEGAL LINKS ---
          _SectionHeader(title: "LEGAL"),
          _SimpleTile(
            title: "Privacy & Terms",
            icon: Icons.shield_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MiniWebivewScreen(
                    title: "Privacy & Terms",
                    url: "https://naveen7050.github.io/flashfeed-policy/",
                  ),
                ),
              );
            },
          ),
          _SimpleTile(
            title: "Open Source Licenses",
            icon: Icons.code,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LicensesScreen()),
            ),
          ),

          const SizedBox(height: 20),

          // --- 3. COMPANY LINK ---
          _SectionHeader(title: "DEVELOPER"),
          _SimpleTile(
            title: "About Red-F Studios",
            icon: FontAwesomeIcons.building,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CompanyInfoScreen(),
              ),
            ),
          ),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Text(
              "© 2025 Red-F Studios",
              style: GoogleFonts.manrope(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGETS (Keep code clean) ---

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: primaryShade,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _SimpleTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SimpleTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      leading: Icon(icon, size: 22, color: Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}
