import 'package:flash_feed/ui/screens/home/home_page.dart';
import 'package:flash_feed/ui/screens/logo_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.manropeTextTheme(),
        primaryTextTheme: GoogleFonts.manropeTextTheme(),
      ),
      home: Scaffold(body: HomePage()),
    ),
  );
}
