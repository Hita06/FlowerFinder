// Created by Iris
//This file is the bottom navigation bar used to switch between the main sections of the Flower Finder application.

// Flutter Material Design widgets.
import 'package:flutter/material.dart';

// Application theme and custom colours.
import '../theme.dart';


// Bottom navigation bar used to switch between the main
// sections of the Flower Finder application.
class BottomNav extends StatelessWidget {
  // Index of the currently selected navigation item.
  final int currentIndex;

  // Callback that tells MainNavigation which tab was selected.
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // Highlights the currently selected page.
      currentIndex: currentIndex,

      // Handles navigation when the user selects a tab.
      onTap: onTap,

      // Keeps all five navigation items visible.
      type: BottomNavigationBarType.fixed,

      // Uses the application's custom colour scheme.
      backgroundColor: AppColors.cream,
      selectedItemColor: AppColors.green,
      unselectedItemColor: Colors.grey,

      // Sets the text size for navigation labels.
      selectedFontSize: 12,
      unselectedFontSize: 12,

      items: const [
        // 0 - Scanner: take or upload photos for flower identification.
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          activeIcon: Icon(Icons.camera_alt),
          label: 'Scanner',
        ),

        // 1 - Maps: view flower locations.
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Maps',
        ),

        // 2 - Search: search for flowers and plant information.
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'Search',
        ),

        // 3 - Diary: view and manage the user's flower diary.
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Diary',
        ),

        // 4 - Profile: access the user's profile and saved stickers.
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person_outline,
            key: ValueKey('nav-profile'),
          ),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}