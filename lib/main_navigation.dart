import 'package:flutter/material.dart';

import 'scanner_page.dart';
import 'flower_search_page.dart';
import 'pages/diary_page.dart';
// import 'pages/sticker_page.dart';
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
  // 2 = Stickers
  // 3 = Diary
  // 4 = Profile
  int currentIndex = 0;

  // Only the pages that currently exist.
  final List<Widget> pages = const [
    ScannerPage(),
    FlowerSearchPage(),
    DiaryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: FlowerBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          // Stickers button
          if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sticker page coming soon.'),
              ),
            );
            return;
          }

          // Profile button
          if (index == 4) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile page coming soon.'),
              ),
            );
            return;
          }

          // Diary button
          if (index == 3) {
            setState(() {
              currentIndex = 2;
            });
            return;
          }

          // Scanner and Search
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}