import 'package:flutter/material.dart';

import 'main_navigation.dart';
import 'theme.dart';

void main() {
  runApp(const FlowerFinderApp());
}

class FlowerFinderApp extends StatelessWidget {
  const FlowerFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flower Finder',
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}