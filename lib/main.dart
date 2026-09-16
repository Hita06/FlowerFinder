// FlowerFinder Application
// Created by the FlowerFinder team
// This file starts the app and loads the private API configuration.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'flower_search_page.dart';

// Loads the local environment file before starting FlowerFinder.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

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