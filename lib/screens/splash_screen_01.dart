import 'package:flash_feed/utils/util.dart';
import 'package:flash_feed/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';

class SplashScreenOne extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  SplashScreenOne({super.key, required this.controller});

  final PageController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/search_news.png", height: 500),
            Text(
              "Explore latest news",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            SizedBox(height: 15),
            Text(
              "Stay updated with real-time headlines and trending stories from trusted sources across the globe — all in one place",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomElevatedButton(
                  text: "PREVIOUS",
                  iconAlign: IconAlignment.start,
                  btnHeight: 48,
                  btnWidth: 180,
                  onTap: () {
                    if (controller.hasClients) {
                      controller.previousPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  btnColor: secondaryShade,
                  txtColor: primaryShade,
                  icon: Icon(Icons.arrow_back, color: primaryShade),
                ),
                SizedBox(width: 10),
                CustomElevatedButton(
                  text: "NEXT",
                  btnHeight: 48,
                  btnWidth: 180,
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
          ],
        ),
      ),
    );
  }
}
