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
import 'package:flash_feed/data/features/theme_provider.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/ui/screens/news_webview_screen.dart';
import 'package:flash_feed/ui/widgets/skeleton_loading_card.dart';
import 'package:flutter/material.dart';
import 'package:flash_feed/ui/widgets/news_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final PageController _pageController = PageController();
  late final Map<String, FutureProvider<List<NewsItem>>> categoryMap;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    categoryMap = {
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
  }

  void _onChipSelected(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = categoryMap.keys.toList();
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: primaryShade,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: Container(
            color: isDarkMode ? Colors.black : Colors.white,
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(categories.length, (index) {
                  final isSelected = _selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      elevation: 2,
                      side: BorderSide.none,
                      label: Text(
                        categories[index],
                        style: GoogleFonts.manrope(
                          color: isSelected
                              ? Colors.white
                              : isDarkMode
                              ? Colors.white
                              : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.w900
                              : FontWeight.w500,
                        ),
                      ),
                      showCheckmark: false,
                      selected: isSelected,
                      
                      // backgroundColor: Colors.white,
                      onSelected: (_) => _onChipSelected(index),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
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
