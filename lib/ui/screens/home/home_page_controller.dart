import 'package:flash_feed/ui/screens/home/home_page.dart';
import 'package:flutter/material.dart';
// import 'package:flash_feed/screens/feed_page.dart';
import 'package:flash_feed/ui/screens/home/settings_page.dart';
import 'package:flash_feed/utils/util.dart';
// import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class HomePageController extends StatefulWidget {
  const HomePageController({super.key});

  @override
  State<HomePageController> createState() => _MainScreenState();
}

class _MainScreenState extends State<HomePageController> {
  int _selectedIndex = 0;
  late PageController
  _pageController; // Add this for controlling page animations

  final List<Widget> _pages = const [HomePage(), SettingsPage()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Initialize the controller
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose to avoid memory leaks
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      // Animate to the new page with a smooth slide
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        // Replace the simple body with PageView for animated transitions
        controller: _pageController,
        reverse:
            false, // Reverses the slide direction: tapping right tab slides left-to-right, vice versa
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index; // Sync the nav bar with page changes
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: secondaryShade,
        selectedItemColor: primaryShade,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.shifting,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
