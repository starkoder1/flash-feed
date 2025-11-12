import 'package:flash_feed/data/categories/providers/finance_provider.dart';
import 'package:flash_feed/data/categories/providers/gaming_provider.dart';
import 'package:flash_feed/data/categories/providers/sports_provider.dart';
import 'package:flash_feed/data/categories/providers/tech_provider.dart';
import 'package:flash_feed/data/categories/providers/world_provider.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/ui/screens/news_webview_screen.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flash_feed/ui/widgets/news_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the provider. This will trigger the fetch and rebuild on state change.
    final AsyncValue<List<NewsItem>> newsAsyncValue = ref.watch(
      techListProvider,
    );

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
        // backgroundColor: Color(0xFF101C4D),
      ),
      // 2. Use .when to handle loading/error/data states gracefully.
      body: newsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (newsList) {
          if (newsList.isEmpty) {
            return const Center(child: Text('No news available.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(techListProvider.future),
            child: ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final news = newsList[index];
                print(newsList.length);
                print(newsList);
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsWebViewScreen(news: news),
                      ),
                    );
                  },
                  child: NewsCard(newsItem: news),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
