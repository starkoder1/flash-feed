import 'package:flash_feed/data/features/theme_provider.dart';
import 'package:flash_feed/ui/screens/home/home_page.dart';
import 'package:flash_feed/ui/screens/logo_screen.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(), // ✅ use MyApp here
    ),
  );
}

//  ConsumerWidget for theme change
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // 🌞 Light Theme
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: primaryShade),
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.manropeTextTheme().apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
      ),

      // 🌚 Dark Theme
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(color: Color(0xFF101C4D)),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: GoogleFonts.manropeTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),

      home: HomePage(), //  You can navigate to SettingsPage from here
    );
  }
}
