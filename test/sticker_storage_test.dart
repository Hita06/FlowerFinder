import 'dart:async';
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
      profileGridSizeId: 'large',
      animationAsset: 'Animations/Fire - Feu - Fuego.json',
    );

    await storage.saveStickers('linda@example.com', [sticker]);

    final lindaStickers = await storage.loadStickers('linda@example.com');
    final otherStickers = await storage.loadStickers('iris@example.com');

    expect(lindaStickers, hasLength(1));
    expect(lindaStickers.single.label, 'Saved rose');
    expect(lindaStickers.single.stickerId, 'colour_change');
    expect(lindaStickers.single.stickerBytes, stickerBytes);
    expect(lindaStickers.single.createdAt, DateTime(2026, 10, 8));
    expect(lindaStickers.single.profileGridSizeId, 'large');
    expect(
      lindaStickers.single.animationAsset,
      'Animations/Fire - Feu - Fuego.json',
    );
    expect(otherStickers, isEmpty);
  });

  test('serializes concurrent saves and keeps the latest snapshot', () async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final firstDirectory = Completer<Directory>();
    final firstRequestStarted = Completer<void>();
    var directoryRequests = 0;
    storage = StickerStorage(
      directoryProvider: () {
        directoryRequests += 1;
        if (directoryRequests == 1) {
          firstRequestStarted.complete();
          return firstDirectory.future;
        }
        return Future<Directory>.value(tempDirectory);
      },
    );
    final firstSticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      stickerId: 'first',
      stickerBytes: stickerBytes,
    );
    final latestSticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      stickerId: 'latest',
      stickerBytes: stickerBytes,
    );

    final firstSave = storage.saveStickers('linda@example.com', [firstSticker]);
    await firstRequestStarted.future;
    final latestSave = storage.saveStickers('linda@example.com', [
      latestSticker,
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(directoryRequests, 1);

    firstDirectory.complete(tempDirectory);
    await Future.wait([firstSave, latestSave]);

    final stickers = await storage.loadStickers('linda@example.com');
    expect(stickers.map((sticker) => sticker.stickerId), ['latest']);
  });

  test('migrates stickers from removed fire animations', () async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    for (final removedAnimation in [
      'Animations/Fire Lottie Animation.json',
      'Animations/flamefire.json',
    ]) {
      final sticker = SavedFlowerPhoto(
        image: MemoryImage(stickerBytes),
        stickerBytes: stickerBytes,
        animationAsset: removedAnimation,
      );

      await storage.saveStickers('linda@example.com', [sticker]);

      final stickers = await storage.loadStickers('linda@example.com');

      expect(
        stickers.single.animationAsset,
        'Animations/Fire - Feu - Fuego.json',
      );
    }
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

  test('keeps saved sticker order after saving and reloading', () async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final firstSticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      label: 'First sticker',
      stickerId: 'first-sticker',
      stickerBytes: stickerBytes,
    );
    final secondSticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      label: 'Second sticker',
      stickerId: 'second-sticker',
      stickerBytes: stickerBytes,
    );

    await storage.saveStickers('linda@example.com', [
      secondSticker,
      firstSticker,
    ]);

    final stickers = await storage.loadStickers('linda@example.com');

    expect(stickers.map((sticker) => sticker.stickerId), [
      'second-sticker',
      'first-sticker',
    ]);
  });
}
