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

     // Opens the Flower Information page with identified flower data.
home: const FlowerInformationPage(
  flowerName: 'Sunflower',
  scientificName: 'Helianthus annuus',
  description:
      'Sunflowers are tall, robust plants known for their large, bright yellow flowers. They are commonly grown for their seeds and as ornamental plants.',

  flowerType: 'Garden flower',
  flowerColour: 'Red',
  season: 'Spring and summer',
  careTips:
      '• Place in an area with plenty of sunlight.\n'
      '• Water regularly without flooding the soil.\n'
      '• Remove damaged or dried leaves.',
),
    ); 
  }
}

