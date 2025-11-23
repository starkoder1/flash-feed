import 'package:flash_feed/ui/screens/home/customize_category_screen.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flash_feed/data/features/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        // backgroundColor: primaryShade,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // Dark Mode (Switch doesn't need an arrow)
          SwitchListTile(
            activeThumbColor: primaryShade,
            activeTrackColor: secondaryShade,
            inactiveThumbColor: primaryShade,
            inactiveTrackColor: secondaryShade,
            title: const Text("Dark Mode"),
            secondary: Icon(
              isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
            value: isDarkMode,
            onChanged: (newValue) {
              ref.read(themeProvider.notifier).state = newValue;
            },
          ),

          // Navigation Items - cleaner without dividers
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text("Customize Feed"),
            trailing: const Icon(
              Icons.chevron_right,
            ), // Shows it goes to new screen
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomizeCategoryScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About App"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
