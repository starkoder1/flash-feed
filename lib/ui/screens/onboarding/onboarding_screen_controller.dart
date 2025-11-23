import 'package:flash_feed/ui/screens/onboarding/onboarding_screen.dart';
import 'package:flash_feed/ui/widgets/dot_indicator.dart';
import 'package:flutter/material.dart';

class OnboardingScreenController extends StatefulWidget {
  const OnboardingScreenController({super.key});

  @override
  State<OnboardingScreenController> createState() =>
      _OnboardingScreenControllerState();
}

class _OnboardingScreenControllerState
    extends State<OnboardingScreenController> {
  final PageController _controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _controller,
                children: [
                  SplashScreen(
                    controller: _controller,
                    title: "Explore latest news",
                    description:
                        "Stay updated with real-time headlines and trending stories from trusted sources across the globe — all in one place",
                    imagePath: "assets/search_news.png",
                    isFirstScreen: true,
                  ),
                  SplashScreen(
                    controller: _controller,
                    title: "Find news with better filters",
                    description:
                        "Customize your feed by selecting categories, topics, and regions that matter most to you for a smarter news experience",
                    imagePath: "assets/categories.png",
                  ),
                  SplashScreen(
                    controller: _controller,
                    title: "Bookmark & share News",
                    description:
                        "Save articles to read later or share interesting stories with your friends instantly",
                    imagePath: "assets/shared.png",
                    isLastScreen: true,
                  ),
                  // SplashScreenTwo(controller: _controller),
                  // SplashScreenThree(controller: _controller),
                ],
              ),
            ),
            SizedBox(height: 30),
            DotIndicator(controller: _controller, count: 3),
          ],
        ),
      ),
    );
  }
}
