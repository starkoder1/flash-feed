import 'dart:async';

import 'package:flash_feed/screens/splash_screen_controller.dart';
import 'package:flutter/material.dart';
import 'splash_screen_01.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  SplashScreenController()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogo(size: 120, style: FlutterLogoStyle.markOnly),
    );
  }
}
