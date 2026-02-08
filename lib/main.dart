import 'package:flash_feed/data/features/theme_provider.dart';
import 'package:flash_feed/ui/screens/logo_screen.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This setup is CORRECT for enabling Edge-to-Edge mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 256;
  await Hive.initFlutter();
  await Hive.openBox('bookmarks');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Light Theme
      theme: ThemeData(
        // Removed the incorrect systemOverlayStyle property from here
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: primaryShade,
        ),
        // ✅ FIXED: systemOverlayStyle is now correctly inside AppBarTheme
        appBarTheme: AppBarTheme(
          backgroundColor: primaryShade,
          foregroundColor: Colors.white,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness:
                Brightness.dark, // Icons dark on light app background
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.manropeTextTheme().apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
      ),

      // Dark Theme
      darkTheme: ThemeData(
        // Removed the incorrect systemOverlayStyle property from here
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
        ),
        scaffoldBackgroundColor: const Color(0xFF151515),
        secondaryHeaderColor: Colors.black54,
        chipTheme: const ChipThemeData(
          selectedColor: Color(0xFF101C4D),
          backgroundColor: Colors.black,
        ),
        // ✅ FIXED: systemOverlayStyle is now correctly inside AppBarTheme
        appBarTheme: const AppBarTheme(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Color(0xFF101C4D),
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness:
                Brightness.light, // Icons light on dark app background
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
        brightness: Brightness.dark,
        textTheme: GoogleFonts.manropeTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),

      home: const LogoScreen(),
    );
  }
}
