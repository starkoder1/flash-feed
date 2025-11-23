import 'package:flash_feed/data/features/theme_provider.dart';
import 'package:flash_feed/ui/screens/home/bookmark_screen.dart';
import 'package:flash_feed/ui/screens/home/home_page.dart';
import 'package:flash_feed/ui/widgets/hiding_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
// import 'package:flash_feed/screens/feed_page.dart';
import 'package:flash_feed/ui/screens/home/settings_page.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class HomePageController extends ConsumerStatefulWidget {
  const HomePageController({super.key});

  @override
  ConsumerState<HomePageController> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<HomePageController> {
  int _selectedIndex = 0;
  late PageController _pageController; // Add this for controlling page animations
  late ScrollController _scrollController;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Initialize the controller
    _scrollController = ScrollController();
    pages = [
      HomePage(scrollController: _scrollController),
      const BookmarkScreen(),
      const SettingsPage(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose to avoid memory leaks
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    // Define pages here to pass the scroll controller

    // ✅ FIXED: Wrapped in PopScope to handle Bottom Bar back navigation
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _onItemTapped(0); // Go back to "Feed"
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xFF101C4D),
        body: PageView(
          // Replace the simple body with PageView for animated transitions
          controller: _pageController,
          reverse: false, 
          // ✅ FIXED: Disable swipe here so it doesn't conflict with News Categories swipe
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index; // Sync the nav bar with page changes
            });
          },
          children: pages,
        ),
        bottomNavigationBar: HidingBottomNavBar(
          controller: _scrollController,
          duration: const Duration(milliseconds: 200),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,

            selectedItemColor: isDarkMode ? secondaryShade : primaryShade,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined),
                activeIcon: Icon(Icons.article),
                label: 'Feed',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_outline),
                activeIcon: Icon(Icons.bookmark),
                label: 'Bookmarks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}