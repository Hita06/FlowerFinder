import 'package:flutter/material.dart';
import '../theme.dart';

class FlowerBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FlowerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,

      type: BottomNavigationBarType.fixed,

      backgroundColor: AppColors.green,

      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,

      showSelectedLabels: false,
      showUnselectedLabels: false,

      elevation: 0,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.center_focus_strong),
          label: 'Scan',
        ),

        BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Map'),

        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Diary'),

        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
