import 'package:flash_feed/utils/util.dart';
import 'package:flash_feed/widgets/news_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/logo_alt.png", height: 40, width: 40),
            Text(
              "lashFeed",
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: primaryShade,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 0.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              NewsCard(),
              NewsCard(),
              NewsCard(),
              NewsCard(),
              NewsCard(),
              NewsCard(),
              NewsCard(),
            ],
          ),
        ),
      ),
    );
  }
}
