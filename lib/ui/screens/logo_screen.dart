import 'package:flash_feed/data/features/all_category_provider.dart';
import 'package:flash_feed/data/features/for_you_provider.dart';
import 'package:flash_feed/ui/screens/home/home_page_controller.dart';
import 'package:flash_feed/ui/screens/onboarding/splash_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoScreen extends ConsumerStatefulWidget {
  const LogoScreen({super.key});

  @override
  ConsumerState<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends ConsumerState<LogoScreen> {
  @override
  void initState() {
    _checkOnboardingStatus();
    super.initState();
    ref.read(allCategoryProvider.future);
  }

  Future<void> _checkOnboardingStatus() async {
    // Wait for full animation to finish before navigating
    Future.delayed(const Duration(seconds: 6), () async {
      final prefs = await SharedPreferences.getInstance();
      final isShown = prefs.getBool('onboarding_shown') ?? false;
      if (isShown) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageController()),
        );
        debugPrint(isShown.toString());
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SplashScreenController(),
          ),
        );
        prefs.setBool('onboarding_shown', true);
        debugPrint(isShown.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0071ff),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // ---------- FLASHFEED TEXT ----------
                Padding(
                  padding: const EdgeInsets.only(left: 96),
                  child:
                      Text(
                            "FlashFeed",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                          // Text should appear AFTER logo has started moving
                          .animate()
                          .fadeIn(
                            delay: 2
                                .seconds, // 2 sec wait + 0.8 sec slide start buffer
                            duration: 1.5.seconds,
                            curve: Curves.easeIn,
                          )
                          .slide(
                            begin: const Offset(-0.9, 0),
                            end: Offset.zero,
                            duration: 1.seconds,
                            curve: Curves.easeOut,
                          ),
                ),

                // ---------- LOGO (WAITS 2 SEC BEFORE MOVE) ----------
                Image.asset("assets/logo.png", height: 100)
                    .animate()
                    .slide(
                      begin: Offset.zero,
                      end: const Offset(-0.9, 0),
                      duration: 0.8.seconds,
                      curve: Curves.easeIn,
                      delay: 1.seconds, // logo stays still for 2 seconds
                    )
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.0, 1.0),
                    ),
              ],
            ),

            const SizedBox(height: 50),

            // ---------- TAGLINE ----------
            Text(
              "News - in a Flash⚡",
              style: const TextStyle(
                fontSize: 25,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ).animate().fadeIn(
              delay: 3.seconds, // after logo + text animations
              duration: 0.5.seconds,
              curve: Curves.easeInBack,
            ),
          ],
        ),
      ),
    );
  }
}
