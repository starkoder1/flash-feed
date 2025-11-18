import 'package:flash_feed/data/categories/providers/automotive_provider.dart';
import 'package:flash_feed/data/categories/providers/environment_provider.dart';
import 'package:flash_feed/data/categories/providers/finance_provider.dart';
import 'package:flash_feed/data/categories/providers/gaming_provider.dart';
import 'package:flash_feed/data/categories/providers/health_provider.dart';
import 'package:flash_feed/data/categories/providers/movie_provider.dart';
import 'package:flash_feed/data/categories/providers/nasa_provider.dart';
import 'package:flash_feed/data/categories/providers/politics_provider.dart';
import 'package:flash_feed/data/categories/providers/science_provider.dart';
import 'package:flash_feed/data/categories/providers/space_provider.dart';
import 'package:flash_feed/data/categories/providers/sports_provider.dart';
import 'package:flash_feed/data/categories/providers/tech_provider.dart';
import 'package:flash_feed/data/categories/providers/world_provider.dart';
import 'package:flash_feed/data/features/for_you_proivder.dart';
import 'package:flash_feed/data/features/theme_provider.dart';
import 'package:flash_feed/data/models/news_category.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/ui/screens/news_webview_screen.dart';
import 'package:flash_feed/ui/widgets/chips_delgate.dart';
import 'package:flash_feed/ui/widgets/skeleton_loading_card.dart';
import 'package:flutter/material.dart';
import 'package:flash_feed/ui/widgets/news_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:recase/recase.dart';

class HomePage extends ConsumerStatefulWidget {
  final ScrollController? scrollController;

  const HomePage({super.key, this.scrollController});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final PageController _pageController = PageController();
  // We will store the keys directly, not the providers, to simplify typing.
  late final List<NewsCategory> _categories;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Define the order of categories for the UI
    _categories = [
     NewsCategory.forYou,
      NewsCategory.world,
      NewsCategory.technology,
      NewsCategory.sports,
      NewsCategory.health,
      NewsCategory.finance,
      NewsCategory.automotive,
      NewsCategory.gaming,
      NewsCategory.movie,
      NewsCategory.space,
      NewsCategory.nasa,
      NewsCategory.politics,
      NewsCategory.environment,
      NewsCategory.science,
    ];
  }

  void _onChipSelected(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    Widget buildChipsRow() {
      return Container(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_categories.length, (index) {
              final isSelected = _selectedIndex == index;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),

                // --- ONLY THIS PART IS NEW ---
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  // --------------------------------
                  child: ChoiceChip(
                    elevation: 2,
                    side: BorderSide.none,

                    label: Text(
                      _categories[index].name.toString().sentenceCase,
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

                    // keep your original behavior
                    onSelected: (_) => _onChipSelected(index),
                  ),
                ),
              );
            }),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,

      body: NestedScrollView(
        controller: widget.scrollController,
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            forceElevated: innerBoxIsScrolled,
            pinned: true,
            floating: true,
            elevation: 0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/app_bar_logo.png", height: 40, width: 40),
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
          ),

          SliverPersistentHeader(
            delegate: ChipsDelgate(child: buildChipsRow()),
            floating: true,
          ),
        ],

        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: _categories.map((category) {
            return NewsCategoryView(category: category);
          }).toList(),
        ),
      ),
    );
  }
}

/// A helper function to map a NewsCategory to its corresponding provider.
/// This avoids the need for a map with complex generic types and provides
/// the concrete provider type needed for `ref.invalidate`.
ProviderBase<AsyncValue<List<NewsItem>>> _providerForCategory(
  NewsCategory category,
) {
  switch (category) {
    case NewsCategory.forYou:
      return forYouProivder;
    case NewsCategory.world:
      return worldListProvider;
    case NewsCategory.technology:
      return techListProvider;
    case NewsCategory.sports:
      return sportsListProvider;
    case NewsCategory.health:
      return healthListProvider;
    case NewsCategory.finance:
      return financeListProvider;
    case NewsCategory.automotive:
      return automotiveListProvider;
    case NewsCategory.gaming:
      return gameListProvider;
    case NewsCategory.movie:
      return movieListProvider;
    case NewsCategory.space:
      return spaceListProvider;
    case NewsCategory.politics:
      return politicsListProvider;
    case NewsCategory.nasa:
      return nasaListProvider;
    case NewsCategory.environment:
      return environmentListProvider;
    case NewsCategory.science:
      return scienceListProvider;

    // Add default or throw error for unhandled cases
    default:
      // This should not happen if all categories are handled.
      throw UnimplementedError('Provider for $category not found.');
  }
}

class NewsCategoryView extends ConsumerWidget {
  final NewsCategory category;

  const NewsCategoryView({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the specific provider for this category
    final provider = _providerForCategory(category);
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
          onRefresh: () async => ref.invalidate(provider),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              debugPrint("BUILDING CARD → ${news.imageUrl}");
              // check disk cache (async, non-blocking)
              DefaultCacheManager()
                  .getFileFromCache(news.imageUrl)
                  .then((fileInfo) {
                    if (fileInfo == null) {
                      print(
                        "DISK CACHE: NOT FOUND → will download on first show: ${news.imageUrl}",
                      );
                    } else {
                      print("DISK CACHE: FOUND → ${fileInfo.file.path}");
                    }
                  })
                  .catchError((e) {
                    print("CACHE CHECK ERROR: $e");
                  });

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
