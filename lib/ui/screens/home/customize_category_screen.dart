import 'dart:math';
import 'package:flash_feed/data/features/category_customize_provider.dart';
import 'package:flash_feed/data/features/haptic_provider.dart';
import 'package:flash_feed/data/features/theme_provider.dart';
import 'package:flash_feed/data/models/news_category.dart';
import 'package:flash_feed/utils/haptic_service.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
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

class CustomizeCategoryScreen extends ConsumerStatefulWidget {
  const CustomizeCategoryScreen({super.key});

  @override
  ConsumerState<CustomizeCategoryScreen> createState() =>
      _CategoryScreenState();
}

Future<bool> _showWarningDialogue(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          children: [Icon(Icons.info), SizedBox(width: 5), Text("Alert")],
        ),
        content: const Text('Please select at least 3 categories to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

class _CategoryScreenState extends ConsumerState<CustomizeCategoryScreen> {
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final selectedCategories = ref.watch(selectedCategoriesProvider);
    final isHapticEnabled = ref.watch(hapticProvider);

    return PopScope(
      canPop: selectedCategories.length >= 3,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && selectedCategories.length < 3) {
          _showWarningDialogue(context);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            "Customize Feed",
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    clipBehavior: Clip.none,
                    padding: EdgeInsets.only(top: 10, bottom: 20),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.5,
                        ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
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
                        onTap: () {
                          HapticService.select(isHapticEnabled);
                          _toggleCategory(category.categoryEnum);
                        },
                        selectedGradient: gradient,
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InterestCard extends StatefulWidget {
  final _CategoryInfo data;
  final bool isSelected;
  final VoidCallback onTap;
  final LinearGradient? selectedGradient;
  final bool isDarkMode;

  const _InterestCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
    required this.selectedGradient,
    required this.isDarkMode,
  });

  @override
  State<_InterestCard> createState() => _InterestCardState();
}

class _InterestCardState extends State<_InterestCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    Future.delayed(Duration(milliseconds: 100), () {
      _scaleController.reverse();
    });
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: widget.isSelected ? widget.selectedGradient : null,
                color: widget.isSelected ? null : Colors.white70,
                border: Border.all(
                  color: widget.isSelected
                      ? Colors.transparent
                      : (widget.isDarkMode
                            ? Colors.transparent
                            : Colors.grey[200]!),
                  width: 1,
                ),
                // ENHANCED GLOW SHADOW FOR SELECTED CARDS
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color:
                              widget.selectedGradient?.colors.first.withOpacity(
                                0.4,
                              ) ??
                              Colors.black.withOpacity(0.15),
                          blurRadius: 10, // Softer, larger glow
                          spreadRadius: 4, // Expands outward
                          offset: Offset.zero,
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                children: [
                  // 1. Border highlight

                  // 2. MORE PROMINENT SHIMMER EFFECT
                  if (widget.isSelected)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Shimmer.fromColors(
                          baseColor: Colors.transparent,
                          highlightColor: Colors.white.withOpacity(
                            0.9,
                          ), // 80% stronger
                          period: Duration(
                            milliseconds: 2000,
                          ), // Slightly faster
                          child: Container(
                            color: Colors.white.withOpacity(
                              0.12,
                            ), // More visible overlay
                          ),
                        ),
                      ),
                    ),

                  // 3. Glass overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(
                            widget.isSelected ? 0.05 : 0.02,
                          ),
                          Colors.black.withOpacity(
                            widget.isSelected ? 0.05 : 0.02,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.isSelected
                                ? Colors.white.withOpacity(0.3)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            widget.data.icon,
                            color: widget.isSelected
                                ? Colors.white
                                : Colors.grey[800],
                            size: 24,
                          ),
                        ),
                        Text(
                          widget.data.title,
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: widget.isSelected
                                ? Colors.white
                                : Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // 5. ENHANCED CHECKMARK
                  if (widget.isSelected)
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
                              color: Colors.black.withOpacity(
                                0.15,
                              ), // Stronger shadow
                              blurRadius: 8, // Softer shadow
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
