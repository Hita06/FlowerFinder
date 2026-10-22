import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowerfinderscanner/sticker_animation_assets.dart';
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
      baseStickerBytes: stickerBytes,
      createdAt: DateTime(2026, 10, 8),
      profileGridSizeId: 'large',
      animationAsset: fireAnimationAsset,
      boardPositionX: 0.3,
      boardPositionY: 0.4,
      boardScale: 1.2,
      whiteOutlineEnabled: true,
      outlineThickness: 12,
      innerShadowEnabled: true,
      dropShadowEnabled: true,
      dropShadowStrength: 0.8,
      advancedEffectId: 'rainbowPrism',
      stickerTintEnabled: false,
      gradientColorId: 'gradient_rainbow',
    );

    await storage.saveStickers('linda@example.com', [sticker]);

    final lindaStickers = await storage.loadStickers('linda@example.com');
    final otherStickers = await storage.loadStickers('iris@example.com');

    expect(lindaStickers, hasLength(1));
    expect(lindaStickers.single.label, 'Saved rose');
    expect(lindaStickers.single.stickerId, 'colour_change');
    expect(lindaStickers.single.stickerBytes, stickerBytes);
    expect(lindaStickers.single.baseStickerBytes, stickerBytes);
    expect(lindaStickers.single.createdAt, DateTime(2026, 10, 8));
    expect(lindaStickers.single.profileGridSizeId, 'large');
    expect(lindaStickers.single.animationAsset, fireAnimationAsset);
    expect(lindaStickers.single.boardPositionX, 0.3);
    expect(lindaStickers.single.boardPositionY, 0.4);
    expect(lindaStickers.single.boardScale, 1.2);
    expect(lindaStickers.single.whiteOutlineEnabled, isTrue);
    expect(lindaStickers.single.outlineThickness, 12);
    expect(lindaStickers.single.innerShadowEnabled, isTrue);
    expect(lindaStickers.single.dropShadowEnabled, isTrue);
    expect(lindaStickers.single.dropShadowStrength, 0.8);
    expect(lindaStickers.single.advancedEffectId, 'rainbowPrism');
    expect(lindaStickers.single.stickerTintEnabled, isFalse);
    expect(lindaStickers.single.gradientColorId, 'gradient_rainbow');
    expect(otherStickers, isEmpty);
  });

  test(
    'restores stickers with each newly added animation after reload',
    () async {
      final stickerBytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      );
      const animationAssets = [
        'Animations/Fireworks 4_3.json',
        'Animations/Red White & Blue Firework.json',
        'Animations/Reward light effect.json',
      ];
      final stickers = [
        for (var index = 0; index < animationAssets.length; index += 1)
          SavedFlowerPhoto(
            image: MemoryImage(stickerBytes),
            label: 'Sticker $index',
            stickerId: 'sticker-$index',
            stickerBytes: stickerBytes,
            createdAt: DateTime(2026, 10, 20, 12, index),
            profileGridSizeId: index.isEven ? 'small' : 'large',
            animationAsset: animationAssets[index],
          ),
      ];

      await storage.saveStickers('linda@example.com', stickers);

      final restoredStickers = await storage.loadStickers('linda@example.com');

      expect(
        restoredStickers.map((sticker) => sticker.animationAsset),
        animationAssets,
      );
      expect(restoredStickers.map((sticker) => sticker.stickerId), [
        'sticker-0',
        'sticker-1',
        'sticker-2',
      ]);
      expect(restoredStickers.map((sticker) => sticker.profileGridSizeId), [
        'small',
        'large',
        'small',
      ]);
    },
  );

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

  test('migrates stickers from replaced fire animations', () async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    for (final removedAnimation in [
      'Animations/Fire - Feu - Fuego.json',
      'Animations/flamefire.json',
    ]) {
      final sticker = SavedFlowerPhoto(
        image: MemoryImage(stickerBytes),
        stickerBytes: stickerBytes,
        animationAsset: removedAnimation,
      );

      await storage.saveStickers('linda@example.com', [sticker]);

      final stickers = await storage.loadStickers('linda@example.com');

      expect(stickers.single.animationAsset, fireAnimationAsset);
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
