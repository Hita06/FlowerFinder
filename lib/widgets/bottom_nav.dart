// Bottom navigation bar for Flower Finder.

import 'package:flutter/material.dart';
import '../theme.dart';

class BottomNav extends StatelessWidget {
  // Index of the currently selected navigation item.
  final int currentIndex;

  // Callback that handles navigation.
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.cream,
      selectedItemColor: AppColors.green,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        // 0 - Home
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),

        // 1 - Search
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'Search',
        ),

        // 2 - Scanner
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          activeIcon: Icon(Icons.camera_alt),
          label: 'Scanner',
        ),

        // 3 - Diary
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Diary',
        ),

        // 4 - Profile
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, key: ValueKey('nav-profile')),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
