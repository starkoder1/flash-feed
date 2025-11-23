import 'package:flash_feed/ui/screens/onboarding/category_screen.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flash_feed/ui/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
    required this.controller,
    required this.title,
    required this.description,
    required this.imagePath,
    this.isFirstScreen = false,
    this.isLastScreen = false,
  });

  final PageController controller;
  final String title;
  final String description;
  final String imagePath;
  final bool isFirstScreen;
  final bool isLastScreen;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🖼️ Top Section
              Column(
                children: [
                  SizedBox(height: size.height * 0.05), // small top gap
                  Image.asset(
                    imagePath,
                    height: size.height * 0.5, // responsive image
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 25),
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // 🔘 Bottom Buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isFirstScreen
                        ? SizedBox.shrink()
                        : CustomElevatedButton(
                            text: "PREVIOUS",
                            iconAlign: IconAlignment.start,
                            btnHeight: 48,
                            btnWidth: 180,
                            onTap: () {
                              if (controller.hasClients) {
                                controller.previousPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            btnColor: secondaryShade,
                            txtColor: primaryShade,
                            icon: Icon(Icons.arrow_back, color: primaryShade),
                          ),
                    const SizedBox(width: 12),
                    CustomElevatedButton(
                      text: "NEXT",
                      btnHeight: 48,
                      btnWidth: isFirstScreen ? 300 : 180,
                      onTap: () {
                        if (isLastScreen) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryScreen(),
                            ),
                          );
                        } else if (controller.hasClients) {
                          controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },

                      txtColor: Colors.white,
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
