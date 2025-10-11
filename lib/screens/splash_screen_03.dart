import 'package:flash_feed/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';

class SplashScreenThree extends StatelessWidget {
  const SplashScreenThree({super.key, required this.controller});
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
            Text("Bookmark, share & comments on news"),
            SizedBox(height: 15),
            Text(
              "Save articles to read later or share interesting stories with your friends instantly.",
            ),
            SizedBox(height: 15),
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
