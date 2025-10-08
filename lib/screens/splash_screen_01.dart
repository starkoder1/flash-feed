import 'dart:async';

import 'package:flutter/material.dart';
import 'splash_screen_02.dart';

class SplashScreenOne extends StatefulWidget {
  const SplashScreenOne({super.key});

  @override
  State<SplashScreenOne> createState() => _SplashScreenOneState();
}

class _SplashScreenOneState extends State<SplashScreenOne> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreenTwo()),
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
