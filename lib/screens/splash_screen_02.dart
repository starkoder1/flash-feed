import 'package:flash_feed/utils/util.dart';
import 'package:flash_feed/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';

class SplashScreenTwo extends StatelessWidget {
  const SplashScreenTwo({super.key, required this.controller});

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
              Image.asset("assets/categories.png", height: 500),
              // SizedBox(height: 15),
              Text(
                "Find news with better filters",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              SizedBox(height: 15),
              Text(
                "Customize your feed by selecting categories, topics, and regions that matter most to you for a smarter news experience",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomElevatedButton(
                    text: "PREVIOUS",
                    btnHeight: 48,
                    btnWidth: 180,
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
      ),
    );
  }
}
