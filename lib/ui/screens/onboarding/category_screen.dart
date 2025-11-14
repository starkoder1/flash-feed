import 'dart:math'; // Added for Random
import 'package:flash_feed/ui/screens/home/home_page_controller.dart';
import 'package:flash_feed/ui/widgets/custom_elevated_button.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

// Updated data class (removed the 'color' property)
class _CategoryInfo {
  final IconData icon;
  final String title;

  _CategoryInfo({required this.icon, required this.title});
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final Set<String> _selectedCategories = {};

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
    _CategoryInfo(icon: Icons.business_center_outlined, title: "Business"),
    _CategoryInfo(icon: Icons.restaurant_outlined, title: "Food & Culture"),
    _CategoryInfo(icon: Icons.coffee_outlined, title: "Office Productivity"),
    _CategoryInfo(
      icon: Icons.account_balance_wallet_outlined,
      title: "Finance & Accounting",
    ),
    _CategoryInfo(icon: Icons.computer_outlined, title: "IT & SOFTWARE"),
    _CategoryInfo(icon: Icons.water_drop_outlined, title: "Weather"),
    _CategoryInfo(
      icon: Icons.psychology_outlined,
      title: "Personal Development",
    ),
    _CategoryInfo(icon: Icons.design_services_outlined, title: "Design"),
    _CategoryInfo(
      icon: Icons.camera_alt_outlined,
      title: "Photography & Video",
    ),
    _CategoryInfo(icon: Icons.calendar_month_outlined, title: "Lifestyle"),
    _CategoryInfo(
      icon: Icons.favorite_border_outlined,
      title: "Health & Fitness",
    ),
    _CategoryInfo(icon: Icons.code_outlined, title: "Development"),
  ];

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  bool get _isNextButtonEnabled => _selectedCategories.length >= 3;
  @override
  void initState() {
    super.initState();
    initGradients();
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: CustomElevatedButton(
              text: 'NEXT',
              onTap: () {
                _isNextButtonEnabled
                    ? Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePageController(),
                        ),
                        (route) => false,
                      )
                    : null;
              },
              txtColor: primaryShade,
              btnHeight: 40,
              btnWidth: 105,
              btnColor: secondaryShade,
              icon: Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
              const SizedBox(height: 8),
              Text(
                "Select at least 3 topics",
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1, // square cards
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategories.contains(
                      category.title,
                    );

                    // --- 4. Get the gradient for the card ---
                    final gradient = isSelected
                        ? _getGradientForCategory(category.title)
                        : null;

                    return _InterestCard(
                      data: category,
                      isSelected: isSelected,
                      onTap: () => _toggleCategory(category.title),
                      // Pass the gradient to the card
                      selectedGradient: gradient,
                    );
                  },
                ),
              ),
            ],
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
  final LinearGradient? selectedGradient; // New property

  const _InterestCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
    required this.selectedGradient, // Added to constructor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // 1. The Card Container
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              // --- UPDATED: Use gradient if selected, white if not ---
              gradient: isSelected ? selectedGradient : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors
                          .transparent // No border when gradient is active
                    : Colors.grey[200]!,
                width: 1.0, // Thinner default border
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        // Use gradient's first color for a nice glow
                        color:
                            selectedGradient?.colors.first.withOpacity(0.3) ??
                            Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Card Content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // --- UPDATED: Translucent white on gradient ---
                          color: isSelected
                              ? Colors.white.withOpacity(0.3)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // --- UPDATED: White icon on gradient ---
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
                          // --- UPDATED: White text on gradient ---
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // SHINE EFFECT
                if (isSelected)
                  Positioned.fill(
                    child: Transform.rotate(
                      angle: 45 * 3.1415926535 / 180,
                      child: Shimmer.fromColors(
                        baseColor: Colors.transparent,
                        highlightColor: Colors.white.withOpacity(0.2),
                        period: const Duration(milliseconds: 1500),
                        child: Container(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 2. The Checkmark Overlay
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
