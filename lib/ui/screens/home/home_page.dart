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
import 'package:flash_feed/data/features/all_category_provider.dart';
import 'package:flash_feed/data/features/for_you_provider.dart';
import 'package:flash_feed/data/features/theme_provider.dart';
import 'package:flash_feed/data/models/news_category.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/ui/screens/news_webview_screen.dart';
import 'package:flash_feed/ui/widgets/chips_delgate.dart';
import 'package:flash_feed/ui/widgets/skeleton_loading_card.dart';
import 'package:flash_feed/utils/util.dart';
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

class _HomePageState extends ConsumerState<HomePage>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  // We will store the keys directly, not the providers, to simplify typing.
  late final ScrollController _chipsScrollController;
  bool _isChipsAtStart = true;
  bool _isChipsAtEnd = false;
  late final List<NewsCategory> _categories;
  int _selectedIndex = 0;

  @override
  bool get wantKeepAlive => true;

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

    _chipsScrollController = ScrollController();
    _chipsScrollController.addListener(_updateChipsScrollState);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chipsScrollController.removeListener(_updateChipsScrollState);
    _chipsScrollController.dispose();
    super.dispose();
  }

  void _updateChipsScrollState() {
    final max = _chipsScrollController.position.maxScrollExtent;
    final offset = _chipsScrollController.offset;

    final start = offset <= 2;
    final end = offset >= max - 2;

    if (start != _isChipsAtStart || end != _isChipsAtEnd) {
      setState(() {
        _isChipsAtStart = start;
        _isChipsAtEnd = end;
      });
    }
  }

  void _onChipSelected(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDarkMode = ref.watch(themeProvider);
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    Widget buildChipsRow() {
      return SizedBox(
        height: 60,
        child: Stack(
          children: [
            // ===== Scrollable chip row =====
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 0, left: 5),
                controller: _chipsScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_categories.length, (index) {
                    final isSelected = _selectedIndex == index;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () => _onChipSelected(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDarkMode ? darkmodeShade : primaryShade)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _categories[index].name.toString().sentenceCase,
                            style: GoogleFonts.manrope(
                              color: isSelected
                                  ? Colors.white
                                  : (isDarkMode ? Colors.white : Colors.black),
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // ===== Left fade =====
            IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isChipsAtStart ? 0 : 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 26,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment
                            .centerRight, // Fade from right (transparent) to left (background)
                        end: Alignment.centerLeft,
                        colors: [
                          scaffoldBackgroundColor.withOpacity(0),
                          scaffoldBackgroundColor.withOpacity(0.7),
                          scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ===== Right fade =====
            IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isChipsAtEnd ? 0 : 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 26,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment
                            .centerLeft, // Fade from left (transparent) to right (background)
                        end: Alignment.centerRight,
                        colors: [
                          scaffoldBackgroundColor.withOpacity(0),
                          scaffoldBackgroundColor.withOpacity(0.7),
                          scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,

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
            delegate: ChipsDelgate(child: Center(child: buildChipsRow())),
            floating: true,
          ),
        ],

        body: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          itemBuilder: (context, index) {
            final category = _categories[index];
            return NewsCategoryView(
              category: category,
              myIndex: index,
              userSelectedIndex:
                  _selectedIndex, //index user is currently looking at
            );
          },
        ),
      ),
    );
  }
}

/// A helper function to map a NewsCategory to its corresponding provider.
/// This avoids the need for a map with complex generic types and provides
/// the concrete provider type needed for `ref.invalidate`.
ProviderBase<AsyncValue<List<NewsItem>>> providerForCategory(
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

class NewsCategoryView extends ConsumerStatefulWidget {
  final NewsCategory category;
  final int myIndex; //my index means the index of the category
  final int
  userSelectedIndex; //the index of the category which user is curently looking at

  const NewsCategoryView({
    super.key,
    required this.category,
    required this.myIndex,
    required this.userSelectedIndex,
  });
  @override
  ConsumerState<NewsCategoryView> createState() => _NewsCategoryViewState();
}

class _NewsCategoryViewState extends ConsumerState<NewsCategoryView>
    with AutomaticKeepAliveClientMixin {
  @override
  // Determine whether to keep this page alive based on its distance from the user selected index
  bool get wantKeepAlive {
    final myIndex = widget.myIndex;
    final userSelectedIndex = widget.userSelectedIndex;
    final int distance = (myIndex - userSelectedIndex).abs();

    if (distance <= 2) {
      return true;
    } else {
      return false;
    }
  }

  //to update keep alive when userSelectedIndex changes
  @override
  void didUpdateWidget(covariant NewsCategoryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the user selected index has changed, we need to update keepAlive
    if (oldWidget.userSelectedIndex != widget.userSelectedIndex) {
      updateKeepAlive();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final category =
        widget.category; // Get the specific provider for this category
    final provider = providerForCategory(category);
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
