import 'package:flash_feed/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';

class SplashScreenTwo extends StatelessWidget {
  const SplashScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logo.png", height: 150),
            SizedBox(height: 15),
            Text("Explore latest news"),
            SizedBox(height: 15),
            Text("rgnrshgenbbfrahbfhd bs hb dhbg hbfefnasufhaiusfhuasd"),
            SizedBox(height: 15),
            CustomElevatedButton(
              text: "NEXT",
              txtColor: Colors.white,
              hPadding: 64,
              vPadding: 12,
              onTap: () {},
              icon: Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
