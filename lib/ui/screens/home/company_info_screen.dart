import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CompanyInfoScreen extends StatelessWidget {
  const CompanyInfoScreen({super.key});

  Future<void> _contactSupport() async {
    // Launches email app
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'contact@redfstudios.com',
      query: 'subject=FlashFeed Support',
    );
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint("Could not launch email");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Logo
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.black, // Assuming Red-F logo looks good on black
                borderRadius: BorderRadius.circular(15),
                image: const DecorationImage(
                  // Use your Studio Logo here, distinct from App Logo if possible
                  image: AssetImage('assets/company_logo.png'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "Red-F Studios",
              style: GoogleFonts.manrope(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: primaryShade,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "We build apps that matter. Focused on speed, design, and user experience, Red-F Studios aims to redefine how you consume content.",
              style: GoogleFonts.manrope(
                fontSize: 16,
                height: 1.6,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 40),

            // Contact Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.3,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Get in Touch",
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Have a bug report or a feature request? We'd love to hear from you.",
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _contactSupport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryShade,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.mail_outline),
                      label: Text(
                        "Contact Support",
                        style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
