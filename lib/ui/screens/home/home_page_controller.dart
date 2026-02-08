import 'package:flash_feed/data/features/haptic_provider.dart';
import 'package:flash_feed/data/features/sticky_navigation_provider.dart';
import 'package:flash_feed/data/features/theme_provider.dart';
import 'package:flash_feed/ui/screens/home/bookmark_screen.dart';
import 'package:flash_feed/ui/screens/home/home_page.dart';
import 'package:flash_feed/ui/widgets/hiding_bottom_nav_bar.dart';
import 'package:flash_feed/utils/haptic_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flash_feed/ui/screens/home/settings_page.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the Sticky Navigation setting
// False = Hides on scroll (Default)
// True = Always visible (Sticky)

class HomePageController extends ConsumerStatefulWidget {
  const HomePageController({super.key});

  @override
  ConsumerState<HomePageController> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<HomePageController> {
  int _selectedIndex = 0;
  late PageController _pageController;
  late final List<Widget> pages;

  // Notifier for scroll direction - used to communicate between HomePage and HidingBottomNavBar
  final ValueNotifier<ScrollDirection> _scrollDirectionNotifier =
      ValueNotifier(ScrollDirection.idle);


  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    pages = [
      HomePage(scrollDirectionNotifier: _scrollDirectionNotifier),
      const BookmarkScreen(),
      const SettingsPage(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollDirectionNotifier.dispose();
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
    final isSticky = ref.watch(stickyNavProvider);

    // Extract the BottomNavigationBar to a local variable for reuse
    final bottomNav = Theme(data: Theme.of(context).copyWith(splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: BottomNavigationBar(enableFeedback: true,
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
    );

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
          controller: _pageController,
          reverse: false,
          // Disable swipe here so it doesn't conflict with News Categories swipe
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            final hapticOn = ref.read(hapticProvider);
  HapticService.select(hapticOn);// Add haptic feedback on page change
            setState(() {
              _selectedIndex = index;
            });
          },
          children: pages,
        ),
        // Conditionally Wrap:
        // If Sticky is ON (isSticky == true), we display the bottomNav directly.
        // If Sticky is OFF (isSticky == false), we wrap it in HidingBottomNavBar.
        bottomNavigationBar: isSticky
            ? bottomNav
            : HidingBottomNavBar(
                scrollDirectionNotifier: _scrollDirectionNotifier,
                enableHiding: true, // Only instantiated when hiding is wanted
                duration: const Duration(milliseconds: 200),
                child: bottomNav,
              ),
      ),
    );
  }
}
