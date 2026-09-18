import 'package:flutter/material.dart';

import 'scanner_page.dart';
import 'flower_search_page.dart';
import 'pages/diary_page.dart';
// import 'pages/profile_page.dart';
import 'widgets/bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // 0 = Scanner
  // 1 = Flower Search
  // 2 = Diary
  // 3 = Profile
  int currentIndex = 0;

  final List<Widget> pages = const [
    ScannerPage(),
    FlowerSearchPage(),
    DiaryPage(),
    // ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),

      bottomNavigationBar: FlowerBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
