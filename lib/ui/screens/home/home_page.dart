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
import 'package:flash_feed/data/features/update_manager.dart';
import 'package:flash_feed/data/models/news_category.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/ui/screens/news_webview_screen.dart';
import 'package:flash_feed/ui/widgets/skeleton_loading_card.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flash_feed/ui/widgets/news_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:recase/recase.dart';

class HomePage extends ConsumerStatefulWidget {
  final ValueNotifier<ScrollDirection>? scrollDirectionNotifier;

  const HomePage({super.key, this.scrollDirectionNotifier});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final ScrollController _chipsScrollController;
  bool _isChipsAtStart = true;
  bool _isChipsAtEnd = false;
  late final List<NewsCategory> _categories;
  late final List<GlobalKey> _categoryKeys;
  int _selectedIndex = 0;

  // Header animation state
  bool _isChipsVisible = true;
  double _lastScrollOffset = 0;
  bool _isPageSwiping = false;

  // Store scroll controllers for each category to preserve positions
  final Map<NewsCategory, ScrollController> _categoryScrollControllers = {};

  static const double _appBarHeight = 56.0;
  static const double _chipsHeight = 60.0;
  static const double _totalHeaderHeight = _appBarHeight + _chipsHeight;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
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

    _categoryKeys = List.generate(_categories.length, (_) => GlobalKey());

    // Initialize scroll controllers for each category
    for (final category in _categories) {
      _categoryScrollControllers[category] = ScrollController();
    }

    _chipsScrollController = ScrollController();
    _chipsScrollController.addListener(_updateChipsScrollState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateManager.checkAndShowWhatsNew(context);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chipsScrollController.removeListener(_updateChipsScrollState);
    _chipsScrollController.dispose();
    // Dispose all category scroll controllers
    for (final controller in _categoryScrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateChipsScrollState() {
    if (!_chipsScrollController.hasClients) return;
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

  void _scrollToChip(int index) {
    final context = _categoryKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  void _onChipSelected(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToChip(index);
    });
  }

  /// Called by child scroll views when they scroll
  void _onChildScroll(double offset, double delta) {
    // Don't change header visibility during page swipes
    if (_isPageSwiping) return;

    // Notify external listeners about scroll direction (for bottom nav hiding)
    if (widget.scrollDirectionNotifier != null) {
      if (delta > 5) {
        widget.scrollDirectionNotifier!.value = ScrollDirection.reverse;
      } else if (delta < -5) {
        widget.scrollDirectionNotifier!.value = ScrollDirection.forward;
      }
    }

    // Determine scroll direction and update chips visibility
    if (delta > 5 && _isChipsVisible) {
      // Scrolling down - hide chips
      setState(() => _isChipsVisible = false);
    } else if (delta < -5 && !_isChipsVisible) {
      // Scrolling up - show chips
      setState(() => _isChipsVisible = true);
    }

    _lastScrollOffset = offset;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDarkMode = ref.watch(themeProvider);
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    Widget buildChipsRow() {
      return SizedBox(
        height: _chipsHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 0, left: 5),
                controller: _chipsScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_categories.length, (index) {
                    final isSelected = _selectedIndex == index;

                    return Padding(
                      key: _categoryKeys[index],
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
                        begin: Alignment.centerRight,
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
                        begin: Alignment.centerLeft,
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

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _onChipSelected(0);
      },
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: Stack(
          children: [
            // PageView with content - positioned below header
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // Detect page swipe start/end to lock header
                  if (notification is ScrollStartNotification) {
                    if (notification.metrics.axis == Axis.horizontal) {
                      _isPageSwiping = true;
                    }
                  } else if (notification is ScrollEndNotification) {
                    if (notification.metrics.axis == Axis.horizontal) {
                      _isPageSwiping = false;
                    }
                  }
                  return false;
                },
                child: PageView.builder(
                  allowImplicitScrolling: true,
                  itemCount: _categories.length,
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _selectedIndex = index);
                    _scrollToChip(index);
                  },
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return NewsCategoryView(
                      category: category,
                      scrollController: _categoryScrollControllers[category]!,
                      topPadding: statusBarHeight + _totalHeaderHeight,
                      onScroll: _onChildScroll,
                      isChipsVisible: _isChipsVisible,
                    );
                  },
                ),
              ),
            ),

            // Fixed AppBar - always visible
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: statusBarHeight + _appBarHeight,
                padding: EdgeInsets.only(top: statusBarHeight),
                decoration: BoxDecoration(
                  color: Theme.of(context).appBarTheme.backgroundColor,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 16),
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
            ),

            // Animated Chips Header - floats in/out
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              top: _isChipsVisible
                  ? statusBarHeight + _appBarHeight
                  : statusBarHeight + _appBarHeight - _chipsHeight,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _isChipsVisible ? 1.0 : 0.0,
                child: Container(
                  height: _chipsHeight,
                  color: scaffoldBackgroundColor,
                  child: buildChipsRow(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    default:
      throw UnimplementedError('Provider for $category not found.');
  }
}

class NewsCategoryView extends ConsumerStatefulWidget {
  final NewsCategory category;
  final ScrollController scrollController;
  final double topPadding;
  final void Function(double offset, double delta) onScroll;
  final bool isChipsVisible;

  const NewsCategoryView({
    super.key,
    required this.category,
    required this.scrollController,
    required this.topPadding,
    required this.onScroll,
    required this.isChipsVisible,
  });

  @override
  ConsumerState<NewsCategoryView> createState() => _NewsCategoryViewState();
}

class _NewsCategoryViewState extends ConsumerState<NewsCategoryView>
    with AutomaticKeepAliveClientMixin {
  double _lastOffset = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    final offset = widget.scrollController.offset;
    final delta = offset - _lastOffset;
    widget.onScroll(offset, delta);
    _lastOffset = offset;
  }

  Widget _buildNewsItem(BuildContext context, NewsItem news) {
    DefaultCacheManager()
        .getFileFromCache(news.imageUrl)
        .then((fileInfo) {
          if (fileInfo == null) {
            // debug print logic
          }
        })
        .catchError((e) {
          // error logic
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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final category = widget.category;
    final provider = providerForCategory(category);
    final newsAsyncValue = ref.watch(provider);

    // Calculate dynamic top padding based on chips visibility
    final effectiveTopPadding = widget.isChipsVisible
        ? widget.topPadding
        : widget.topPadding - 60; // Subtract chips height when hidden

    return newsAsyncValue.when(
      loading: () => ListView.builder(
        controller: widget.scrollController,
        padding: EdgeInsets.only(
          top: effectiveTopPadding,
          left: 8,
          right: 8,
          bottom: 8,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => PlaceholderNewsCard(),
      ),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (newsList) {
        if (newsList.isEmpty) {
          return const Center(child: Text('No news available.'));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            bool useGrid = constraints.maxWidth > 600;

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(provider),
              edgeOffset: effectiveTopPadding,
              child: useGrid
                  ? GridView.builder(
                      controller: widget.scrollController,
                      padding: EdgeInsets.only(
                        top: effectiveTopPadding,
                        left: 12,
                        right: 12,
                        bottom: 12,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: newsList.length,
                      itemBuilder: (context, index) =>
                          _buildNewsItem(context, newsList[index]),
                    )
                  : ListView.builder(
                      controller: widget.scrollController,
                      padding: EdgeInsets.only(
                        top: effectiveTopPadding,
                        left: 0,
                        right: 0,
                        bottom: 2,
                      ),
                      itemCount: newsList.length,
                      itemBuilder: (context, index) =>
                          _buildNewsItem(context, newsList[index]),
                    ),
            );
          },
        );
      },
    );
  }
}