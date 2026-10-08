import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowerfinderscanner/sticker_storage.dart';
import 'package:flowerfinderscanner/user_profile.dart';

void main() {
  late Directory tempDirectory;
  late StickerStorage storage;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('sticker_storage_');
    storage = StickerStorage(directoryProvider: () async => tempDirectory);
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('stores generated stickers separately for each account', () async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      label: 'Saved rose',
      stickerId: 'colour_change',
      stickerBytes: stickerBytes,
      createdAt: DateTime(2026, 10, 8),
    );

    await storage.saveStickers('linda@example.com', [sticker]);

    final lindaStickers = await storage.loadStickers('linda@example.com');
    final otherStickers = await storage.loadStickers('iris@example.com');

    expect(lindaStickers, hasLength(1));
    expect(lindaStickers.single.label, 'Saved rose');
    expect(lindaStickers.single.stickerId, 'colour_change');
    expect(lindaStickers.single.stickerBytes, stickerBytes);
    expect(lindaStickers.single.createdAt, DateTime(2026, 10, 8));
    expect(otherStickers, isEmpty);
  });

  test(
    'does not persist original photos without generated sticker bytes',
    () async {
      final originalPhoto = SavedFlowerPhoto(
        image: MemoryImage(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
          ),
        ),
        label: 'Original only',
      );

      await storage.saveStickers('linda@example.com', [originalPhoto]);

      expect(await storage.loadStickers('linda@example.com'), isEmpty);
    },
  );
}
