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

  static final photos = [
    SavedFlowerPhoto(
      image: _testImage,
      label: 'Daisy',
    ),
    SavedFlowerPhoto(
      image: _testImage,
      label: 'Lavender',
    ),
    SavedFlowerPhoto(
      image: _testImage,
      label: 'Sunflower',
    ),
  ];
}
