import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/data/sources/nasa/nasa_image_source.dart';
import 'package:flash_feed/data/sources/nasa/nasa_news_source.dart';
import 'package:flash_feed/data/sources/nasa/nasa_technology_source.dart';
import 'package:flash_feed/data/sources/science/physics_org_source.dart';
import 'package:flash_feed/data/sources/technology/ars_technica_source.dart';
import 'package:flash_feed/data/sources/technology/cnet_source.dart';
import 'package:flash_feed/data/sources/technology/nasa_jpl_source.dart';
import 'package:flash_feed/data/sources/technology/physics_org_astronomy_source.dart';
import 'package:flash_feed/data/sources/technology/the_verge_source.dart';
import 'package:flash_feed/ui/screens/news_webview_screen.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flash_feed/ui/widgets/news_card.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  late Future<List<NewsItem>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = CnetSource().fetchNews();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
      body: FutureBuilder<List<NewsItem>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No news available.'));
          }

          final newsList = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: newsList
                  .map(
                    (news) => InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsWebViewScreen(news: news),
                          ),
                        );
                      },
                      child: NewsCard(newsItem: news),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
