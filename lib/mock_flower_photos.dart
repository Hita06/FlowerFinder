import 'dart:convert';

import 'package:flutter/material.dart';

import 'user_profile.dart';

class MockFlowerPhotoSource {
  const MockFlowerPhotoSource._();

  static final _testImage = MemoryImage(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    ),
  );

  static ImageProvider _image(String url) {
    final isFlutterTest = WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');
    return isFlutterTest ? _testImage : NetworkImage(url);
  }

  static final photos = [
    SavedFlowerPhoto(
      image: _image(
        'https://perenual.com/storage/image/page-image-asset/plant%202%20compress.png',
      ),
      label: 'Daisy',
    ),
    SavedFlowerPhoto(
      image: _image(
        'https://perenual.com/storage/image/page-image-asset/plant%203%20compress.png',
      ),
      label: 'Lavender',
    ),
    SavedFlowerPhoto(
      image: _image(
        'https://perenual.com/storage/image/page-image-asset/plant%204%20compress.png',
      ),
      label: 'Sunflower',
    ),
  ];
}
