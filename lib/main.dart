// FlowerFinder Application
// G5 Flower Information Page created by Hita
// This file starts the app and opens the Flower Information page.

import 'package:flutter/material.dart';
import 'flower_information_page.dart';

// Starts the FlowerFinder application.
void main() {
  runApp(const FlowerFinderApp());
}

// Sets up the main Flutter application.
class FlowerFinderApp extends StatelessWidget {
  const FlowerFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowerFinder',
      debugShowCheckedModeBanner: false,

      // Sets the main colours used by the application.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6F8F72),
        ),
        useMaterial3: true,
      ),

      // Opens Hita's G5 Flower Information page.
      home: const FlowerInformationPage(),
    ); 
  }
}