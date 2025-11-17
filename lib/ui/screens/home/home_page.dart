import 'package:flash_feed/data/categories/providers/automotive_provider.dart';
import 'package:flash_feed/data/categories/providers/environment_provider.dart';
import 'package:flash_feed/data/categories/providers/finance_provider.dart';
import 'package:flash_feed/data/categories/providers/gaming_provider.dart';
import 'package:flash_feed/data/categories/providers/health_provider.dart';
import 'package:flash_feed/data/categories/providers/movie_provider.dart';
import 'package:flash_feed/data/categories/providers/nasa_provider.dart';
import 'package:flash_feed/data/categories/providers/politics_provider.dart';
import 'package:flash_feed/data/categories/providers/space_provider.dart';
import 'package:flash_feed/data/categories/providers/sports_provider.dart';
import 'package:flash_feed/data/categories/providers/tech_provider.dart';
import 'package:flash_feed/data/categories/providers/world_provider.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/ui/screens/news_webview_screen.dart';
import 'package:flash_feed/ui/widgets/skeleton_loading_card.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flash_feed/ui/widgets/news_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:skeletonizer/skeletonizer.dart';

final categoryMap = {
  'Technology': techListProvider,
  'World': worldListProvider,
  'Environment': environmentListProvider,
  'Automotive': automotiveListProvider,
  'Space': spaceListProvider,
  'Politics': politicsListProvider,
  'Gaming': gameListProvider,
  'Finance': financeListProvider,
  'Sports': sportsListProvider,
  'Health': healthListProvider,
  'Movie': movieListProvider,
  'NASA': nasaListProvider,
};

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categoryMap.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/logo_alt.png", height: 40, width: 40),
            Text(
              "lashFeed",
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: primaryShade,
          labelColor: primaryShade,
          unselectedLabelColor: Theme.of(
            context,
          ).textTheme.bodyLarge?.color?.withOpacity(0.7),
          labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          unselectedLabelStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
          ),
          tabs: categoryMap.keys.map((String title) {
            return Tab(text: title);
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categoryMap.values.map((provider) {
          return NewsCategoryView(provider: provider);
        }).toList(),
      ),
    );
  }
}

class NewsCategoryView extends ConsumerWidget {
  final FutureProvider<List<NewsItem>> provider;

  const NewsCategoryView({super.key, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsyncValue = ref.watch(provider);

    return newsAsyncValue.when(
      loading: () => ListView.builder(
        itemCount: 6,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) => PlaceholderNewsCard(),
      ),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (newsList) {
        if (newsList.isEmpty) {
          return const Center(child: Text('No news available.'));
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(provider.future),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
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
    );
  }
}
