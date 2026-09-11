import 'package:flutter/material.dart';
import 'scanner_page.dart';

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
      home: const ScannerPage(),
    );
  }
}