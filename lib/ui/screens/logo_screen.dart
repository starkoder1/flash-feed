import 'package:flash_feed/ui/screens/onboarding/splash_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for full animation to finish before navigating
    Future.delayed(const Duration(seconds: 7), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreenController()),
      );
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
                // --- Text appears after logo has moved ---
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
                          // initially hidden
                          .animate()
                          .fadeIn(
                            delay: 2
                                .seconds, // shows after logo shift starts finishing
                            duration: 1.5.seconds,
                            curve: Curves.easeIn,
                          )
                          .slide(
                            begin: const Offset(-0.9, 0), // from behind logo
                            end: Offset.zero,
                            duration: 1.2.seconds,
                            curve: Curves.easeOut,
                          ),
                ),

                // --- Logo animates from center to left ---
                Image.asset("assets/logo.png", height: 100)
                    .animate()
                    .slide(
                      begin: Offset.zero,
                      end: const Offset(-0.9, 0), // slide to left
                      duration: 2.seconds,
                      curve: Curves.easeIn,
                    )
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.0, 1.0),
                    ), // keeps smooth layout
              ],
            ),
            SizedBox(height: 50),
            Text(
              "News - in a Flash⚡",
              style: const TextStyle(
                fontSize: 25,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ).animate().fadeIn(
              delay: 3.5.seconds, // after logo + name finish
              duration: 0.5.seconds,
              curve: Curves.easeInBack,
            ),
          ],
        ),
      ),
    );
  }
}
