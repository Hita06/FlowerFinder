import 'package:flutter/material.dart';
import 'login_page.dart';

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
      home: const LoginPage(),
    );
  }
}