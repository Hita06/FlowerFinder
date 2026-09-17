import 'package:flutter/material.dart';

import 'mock_flower_photos.dart';
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
  final List<SavedFlowerPhoto> _savedFlowerPhotos = List.of(MockFlowerPhotoSource.photos);

  Future<void> _openStickerCreation() async {
    await _navigatorKey.currentState!.push<void>(
      MaterialPageRoute<void>(
        builder: (context) => StickerCreationPage(
          photos: _savedFlowerPhotos,
          onSaved: (photoIndex, stickerBytes, stickerId) {
            setState(() {
              _savedFlowerPhotos[photoIndex] = _savedFlowerPhotos[photoIndex].copyWith(
                    stickerId: stickerId,
                    stickerBytes: stickerBytes,
                    createdAt: DateTime.now(),
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
