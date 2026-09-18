import 'package:flutter/material.dart';

import 'scanner_page.dart';
import 'flower_search_page.dart';
import '/pages/diary_page.dart';
import 'user_profile.dart';
import 'widgets/bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  void onNavTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      // 0 - Scanner
      const ScannerPage(),

      // 1 - Maps
      const MapsPlaceholderPage(),

      // 2 - Search
      const FlowerSearchPage(),

      // 3 - Diary
      const DiaryPage(),

      // 4 - Profile
      const UserProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNav(
        currentIndex: currentIndex,
        onTap: onNavTap,
      ),
    );
  }
}

// ============================================================
// MAPS PLACEHOLDER
// ============================================================

class MapsPlaceholderPage extends StatelessWidget {
  const MapsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps'),
      ),
      body: const Center(
        child: Text(
          'Maps coming soon',
        ),
      ),
    );
  }
}