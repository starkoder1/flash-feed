import 'package:flash_feed/screens/splash_screen_01.dart';
import 'package:flash_feed/widgets/dot_indicator.dart';
import 'package:flutter/material.dart';

class SplashScreenController extends StatefulWidget {
  const SplashScreenController({super.key});

  @override
  State<SplashScreenController> createState() => _SplashScreenControllerState();
}

class _SplashScreenControllerState extends State<SplashScreenController> {
  final PageController _controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              children: [
                SplashScreenOne(controller: _controller,),
                SplashScreenOne(controller: _controller,),
                SplashScreenOne(controller: _controller,),
              ],
            ),
          ),
          SizedBox(height: 30),
          DotIndicator(controller: _controller, count: 3)
        ],
      ),
    );
  }
}
