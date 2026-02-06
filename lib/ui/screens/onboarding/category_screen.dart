import 'dart:math';
import 'package:flash_feed/data/features/category_customize_provider.dart';
import 'package:flash_feed/data/models/news_category.dart';
import 'package:flash_feed/ui/screens/home/home_page_controller.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class _CategoryInfo {
  final IconData icon;
  final String title;
  final NewsCategory categoryEnum;

  _CategoryInfo({
    required this.icon,
    required this.title,
    required this.categoryEnum,
  });
}

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  final List<LinearGradient> _gradients = [
    LinearGradient(
      colors: [Colors.blue.shade500, Colors.cyan.shade500],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Colors.green.shade500, Colors.teal.shade500],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Colors.orange.shade500, Colors.amber.shade500],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Colors.purple.shade500, Colors.pink.shade500],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Colors.pink.shade500, Colors.red.shade400],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  final Map<String, LinearGradient> _cardGradients = {};
  List<LinearGradient> _shuffledGradients = [];
  int _gradientIndex = 0;

  void initGradients() {
    _shuffledGradients = List.from(_gradients)..shuffle();
  }

  LinearGradient _getGradientForCategory(String categoryTitle) {
    if (_cardGradients.containsKey(categoryTitle)) {
      return _cardGradients[categoryTitle]!;
    }

    if (_gradientIndex >= _shuffledGradients.length) {
      _shuffledGradients.shuffle();
      _gradientIndex = 0;
    }

    final gradient = _shuffledGradients[_gradientIndex++];
    _cardGradients[categoryTitle] = gradient;

    return gradient;
  }

  final List<_CategoryInfo> _categories = [
    _CategoryInfo(
      icon: Icons.computer_outlined,
      title: "Technology",
      categoryEnum: NewsCategory.technology,
    ),
    _CategoryInfo(
      icon: Icons.public_outlined,
      title: "World",
      categoryEnum: NewsCategory.world,
    ),
    _CategoryInfo(
      icon: Icons.eco_outlined,
      title: "Environment",
      categoryEnum: NewsCategory.environment,
    ),
    _CategoryInfo(
      icon: Icons.directions_car_outlined,
      title: "Automotive",
      categoryEnum: NewsCategory.automotive,
    ),
    _CategoryInfo(
      icon: Icons.rocket_launch_outlined,
      title: "Space",
      categoryEnum: NewsCategory.space,
    ),
    _CategoryInfo(
      icon: Icons.gavel_outlined,
      title: "Politics",
      categoryEnum: NewsCategory.politics,
    ),
    _CategoryInfo(
      icon: Icons.sports_esports_outlined,
      title: "Gaming",
      categoryEnum: NewsCategory.gaming,
    ),
    _CategoryInfo(
      icon: Icons.account_balance_wallet_outlined,
      title: "Finance",
      categoryEnum: NewsCategory.finance,
    ),
    _CategoryInfo(
      icon: Icons.favorite_border_outlined,
      title: "Health",
      categoryEnum: NewsCategory.health,
    ),
    _CategoryInfo(
      icon: Icons.movie_outlined,
      title: "Movie",
      categoryEnum: NewsCategory.movie,
    ),
    _CategoryInfo(
      icon: Icons.science_outlined,
      title: "NASA",
      categoryEnum: NewsCategory.nasa,
    ),
  ];

  void _toggleCategory(NewsCategory category) {
    ref.read(selectedCategoriesProvider.notifier).toggleCategory(category);
  }

  @override
  void initState() {
    super.initState();
    initGradients();
  }

  /* ---------------------------------------------------------- */
  /* Header text widget reused in SliverToBoxAdapter            */
  /* ---------------------------------------------------------- */
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pick Your Interests",
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Select at least 3 topics",
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /* ---------------------------------------------------------- */
  /* Main build                                                 */
  /* ---------------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    final selectedCategories = ref.watch(selectedCategoriesProvider);
    final bool showBtn = selectedCategories.length >= 3;

    final width = MediaQuery.sizeOf(context).width;
    double childAspectRatio;
    if (width >= 600) {
      childAspectRatio = 2.0;
    } else if (width > 400) {
      childAspectRatio = 1.5;
    } else {
      childAspectRatio = 1.1;
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
        backgroundColor: primaryShade,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            /* 1. Scrollable content (header + grid) ---------------- */
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _header()),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: childAspectRatio,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final category = _categories[index];
                      final isSelected = selectedCategories.contains(
                        category.categoryEnum,
                      );
                      final gradient = isSelected
                          ? _getGradientForCategory(category.title)
                          : null;
                      return _InterestCard(
                        data: category,
                        isSelected: isSelected,
                        onTap: () => _toggleCategory(category.categoryEnum),
                        selectedGradient: gradient,
                      );
                    }, childCount: _categories.length),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),

            /* 2. Floating action button ---------------------------- */
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              bottom: showBtn ? 24 : -100,
              child: Center(
                child: SizedBox(
                  width: 220,
                  height: 56,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryShade,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 6,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      'Build my feed',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact(); // Add haptic feedback on button tap
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomePageController()),
                        (_) => false,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/* Interest card (unchanged except removed fixed height)              */
/* ------------------------------------------------------------------ */
class _InterestCard extends StatelessWidget {
  final _CategoryInfo data;
  final bool isSelected;
  final VoidCallback onTap;
  final LinearGradient? selectedGradient;

  const _InterestCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
    required this.selectedGradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact(); // Add haptic feedback on card tap
        onTap();
      },
      child: Stack(
        children: [
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: BoxDecoration(
              gradient: isSelected ? selectedGradient : null,

              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color:
                            selectedGradient?.colors.first.withOpacity(0.25) ??
                            Colors.black.withOpacity(0.15),
                        blurRadius: 24,
                        spreadRadius: 6,
                        offset: Offset.zero,
                      ),
                    ]
                  : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.3)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      data.icon,
                      color: isSelected ? Colors.white : Colors.grey[800],
                      size: 24,
                    ),
                  ),
                  Text(
                    data.title,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (isSelected)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Shimmer.fromColors(
                  baseColor: Colors.transparent,
                  highlightColor: Colors.white.withOpacity(0.9),
                  period: const Duration(milliseconds: 2000),
                  child: Container(color: Colors.white.withOpacity(0.12),),
                ),
              ),
            ),
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.black.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: primaryShade,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}
