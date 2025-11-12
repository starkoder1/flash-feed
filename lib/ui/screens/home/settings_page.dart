import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flash_feed/data/categories/providers/theme_provider.dart';
import 'package:flash_feed/utils/util.dart';

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
          SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: Icon(
              isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
            value: isDarkMode,
            onChanged: (newValue) {
              ref.read(themeProvider.notifier).state = newValue;
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.tune),
            title: Text("Customize Feed"),
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notifications"),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("About App"),
          ),
        ],
      ),
    );
  }
}
