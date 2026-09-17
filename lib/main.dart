import 'package:flutter/material.dart';

import 'main_navigation.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.enableCamera = true});

  final bool enableCamera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flower Finder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainNavigation(enableCamera: enableCamera),
    );
  }
}
