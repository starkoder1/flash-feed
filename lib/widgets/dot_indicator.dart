import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    required this.controller,
    required this.count,
  });

  final PageController controller;
  final int count;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: SmoothPageIndicator(
        controller: controller,
        count: count,
        effect: ExpandingDotsEffect(
          activeDotColor: Colors.blue,
          dotColor: Colors.blue.shade200,
          dotHeight: 8,
          dotWidth: 8,spacing: 8,
          expansionFactor: 4,
        ),
      ),
    );
  }
}
