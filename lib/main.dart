// FlowerFinder Application
// Includes the shared navigation, theme and environment configuration.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'main_navigation.dart';
import 'theme.dart';

// Loads the API key and starts the FlowerFinder application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  runApp(const FlowerFinderApp());
}

// Sets up the main Flutter application.
class FlowerFinderApp extends StatelessWidget {
  const FlowerFinderApp({super.key, this.enableCamera = true});

  final bool enableCamera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flower Finder',
      theme: AppTheme.lightTheme,
      home: MainNavigation(enableCamera: enableCamera),
    );
  }
}
