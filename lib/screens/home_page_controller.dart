import 'package:flash_feed/screens/home_page.dart';
import 'package:flutter/material.dart';
// import 'package:flash_feed/screens/feed_page.dart';
import 'package:flash_feed/screens/settings_page.dart';
import 'package:flash_feed/utils/util.dart';

class HomePageController extends StatefulWidget {
  const HomePageController({super.key});

  @override
  State<HomePageController> createState() => _MainScreenState();
}

class _MainScreenState extends State<HomePageController> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [HomePage(), SettingsPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: secondaryShade,
        selectedItemColor: primaryShade,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
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
