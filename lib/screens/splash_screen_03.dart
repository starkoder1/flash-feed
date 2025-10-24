import 'package:flash_feed/screens/category_screen.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flash_feed/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';

class SplashScreenThree extends StatelessWidget {
  const SplashScreenThree({super.key, required this.controller});
  final PageController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/share.png", height: 500),

              Text(
                "Bookmark, share & comments on news",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              SizedBox(height: 15),
              Text(
                "Save articles to read later or share interesting stories with your friends instantly",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomElevatedButton(
                    text: "PREVIOUS",
                    btnHeight: 48, // Swapped from 180
                    btnWidth: 180, // Swapped from 48
                    iconAlign: IconAlignment.start,
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
                    icon: Icon(Icons.arrow_back_sharp, color: primaryShade),
                  ),
                  SizedBox(width: 10),
                  CustomElevatedButton(
                    text: "NEXT",
                    btnHeight: 48,
                    btnWidth: 180,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    txtColor: Colors.white,
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
