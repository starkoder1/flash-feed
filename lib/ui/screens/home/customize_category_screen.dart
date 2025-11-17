import 'dart:math'; // Added for Random
import 'package:flash_feed/data/features/category_customize_provider.dart';
import 'package:flash_feed/data/features/theme_provider.dart';
import 'package:flash_feed/data/models/news_category.dart';
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

//function for showing warning dialogue box
Future<bool> _showWarningDialogue(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          children: [Icon(Icons.info), SizedBox(width: 5), Text("Alert")],
        ),
        content: const Text(
          'Please select at least 3 category before leaving.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

class _CategoryScreenState extends ConsumerState<CustomizeCategoryScreen> {
  // --- 1. Translated Gradients from your React code ---
  final List<LinearGradient> _gradients = [
    // from-blue-500 to-cyan-500
    LinearGradient(
      colors: [Colors.blue.shade500, Colors.cyan.shade500],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // from-emerald-500 to-teal-500
    LinearGradient(
      colors: [Colors.green.shade500, Colors.teal.shade500],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // from-orange-500 to-amber-500
    LinearGradient(
      colors: [Colors.orange.shade500, Colors.amber.shade500],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // from-purple-500 to-pink-500
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

  // --- 2. Map to store the randomly assigned gradient for each card ---
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

    // Shuffle again if all gradients are used
    if (_gradientIndex >= _shuffledGradients.length) {
      _shuffledGradients.shuffle();
      _gradientIndex = 0;
    }

    final gradient = _shuffledGradients[_gradientIndex++];
    _cardGradients[categoryTitle] = gradient;

    return gradient;
  }

  // --- 3. Updated categories list (removed 'color') ---
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
    // Initialize the local state with the provider's state when the screen loads.
    // This ensures that previously selected categories are shown as selected.
    // Note: This is a one-time sync. The UI will then react to provider changes.
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final selectedCategories = ref.watch(selectedCategoriesProvider);

    return PopScope(
      canPop: selectedCategories.length >= 3,
      onPopInvoked: (didPop) async {
        if (!didPop && selectedCategories.length < 3) {
          await _showWarningDialogue(context);
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1, // square cards
                        ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = selectedCategories.contains(
                        category.categoryEnum,
                      );

                      // --- 4. Get the gradient for the card ---
                      final gradient = isSelected
                          ? _getGradientForCategory(category.title)
                          : null;

                      return _InterestCard(
                        data: category,
                        isSelected: isSelected,
                        onTap: () => _toggleCategory(category.categoryEnum),
                        // Pass the gradient to the card
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

// --- 5. Updated _InterestCard ---
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
    required this.isDarkMode,
  });
  final bool isDarkMode;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // MAIN CARD
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              gradient: isSelected ? selectedGradient : null,
              color: isSelected ? null : Colors.white70,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? Colors.transparent : Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color:
                            selectedGradient?.colors.first.withOpacity(0.3) ??
                            Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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

          // ⭐ FULL CARD SHIMMER EFFECT
          // ⭐ FIXED SHIMMER (no leak in dark mode)
          if (isSelected)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // This prevents glow from touching card edges
                    Positioned.fill(
                      top: 10,
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Shimmer.fromColors(
                        direction: ShimmerDirection.ltr,
                        baseColor: Colors.white.withOpacity(0.05),
                        highlightColor: Colors.white.withOpacity(0.60),
                        period: Duration(milliseconds: 1200),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // CHECKMARK
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(Icons.check, color: Colors.grey[900], size: 18),
              ),
            ),
        ],
      ),
    );
  }
}
