import 'package:flash_feed/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';

class SplashScreenTwo extends StatelessWidget {
  const SplashScreenTwo({super.key, required this.controller});

  final PageController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logo.png", height: 150),
            SizedBox(height: 15),
            Text("Find news with better filters."),
            SizedBox(height: 15),
            Text(
              "Customize your feed by selecting categories, topics, and regions that matter most to you for a smarter news experience.",
            ),
            SizedBox(height: 15),
            CustomElevatedButton(
              text: "NEXT",
              onTap: () {
                if (controller.hasClients) {
                  controller.nextPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
              txtColor: Colors.white,
              icon: Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
