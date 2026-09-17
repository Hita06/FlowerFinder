import 'package:flutter/material.dart';

import 'sticker_creation.dart';
import 'user_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final List<SavedFlowerPhoto> _savedFlowerPhotos = [];

  Future<void> _openStickerCreation() async {
    await _navigatorKey.currentState!.push<void>(
      MaterialPageRoute<void>(
        builder: (context) => StickerCreationPage(
          photos: _savedFlowerPhotos,
          onSaved: (photo, stickerBytes, stickerId) {
            setState(() {
              _savedFlowerPhotos.add(
                photo.copyWith(
                  stickerId: stickerId,
                  stickerBytes: stickerBytes,
                  createdAt: DateTime.now(),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Flower Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2f6b4f)),
        scaffoldBackgroundColor: const Color(0xfff7f7f2),
        useMaterial3: true,
      ),
      home: UserProfilePage(
        savedFlowerPhotos: _savedFlowerPhotos,
        onCreateSticker: _openStickerCreation,
      ),
    );
  }
}
