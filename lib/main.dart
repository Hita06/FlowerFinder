// FlowerFinder Application
// Created by the FlowerFinder team
// This file starts the app and opens the Flower Search page.

import 'package:flutter/material.dart';
import 'flower_search_page.dart';

void main() {
  runApp(const MyApp());
}

// Creates the main FlowerFinder application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowerFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: mainGreen,
        ),
        useMaterial3: true,
      ),

      // Opens the G9 Flower Search and Filter page.
      home: const FlowerSearchPage(),
    );
  }
}