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
<<<<<<< HEAD
        appBarTheme: AppBarTheme(color: primaryShade),
=======
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: primaryShade,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryShade,
          foregroundColor: Colors.white,
        ),
>>>>>>> 298f841 (added category provider, changes app logo & name)
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.manropeTextTheme().apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
      ),

      // 🌚 Dark Theme
      darkTheme: ThemeData(
<<<<<<< HEAD
        appBarTheme: AppBarTheme(color: darkmodeShade),
        brightness: Brightness.dark,
=======
        chipTheme: ChipThemeData(
          selectedColor: Color(0xFF101C4D),
          backgroundColor: Colors.black,
        ), //we change the color in dark mode to blend in with the color of the individual chips container
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF101C4D),
          foregroundColor: Colors.white,
        ),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF151515),
>>>>>>> 298f841 (added category provider, changes app logo & name)
        // scaffoldBackgroundColor: darkmodeShade,
        textTheme: GoogleFonts.manropeTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        // scaffoldBackgroundColor: darkmodeShade,
      ),

      home: LogoScreen(), //  You can navigate to SettingsPage from here
    );
  }
}
