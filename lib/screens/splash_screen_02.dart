import 'package:flutter/material.dart';

class SplashScreenTwo extends StatelessWidget {
  const SplashScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Icon(Icons.article, size: 80),
            SizedBox(height: 15),
            Text("Explore latest news"),
            SizedBox(height: 15),
            Text("rgnrshgenbbfrahbfhd bs hb dhbg hbfefnasufhaiusfhuasd"),
            SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {},
              label: Text("NEXT"),
              icon: Icon(Icons.navigate_next),
            ),
          ],
        ),
      ),
    );
  }
}
