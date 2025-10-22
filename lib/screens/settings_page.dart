import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flash_feed/utils/util.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: primaryShade,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.tune),
            title: Text("Customize Feed"),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notifications"),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("About App"),
          ),
        ],
      ),
    );
  }
}
