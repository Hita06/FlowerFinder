import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flowerfinderscanner/diary_entry.dart';
import 'package:flowerfinderscanner/diary_storage.dart';
import 'package:flowerfinderscanner/user_profile.dart';

void main() {
  late Directory tempDirectory;
  late DiaryStorage storage;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('diary_storage_');
    storage = DiaryStorage(directoryProvider: () async => tempDirectory);
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('persists diary fields and generated sticker per account', () async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final entry = DiaryEntry(
      flowerName: 'Rose',
      location: 'Garden',
      notes: 'Found in the morning',
      date: DateTime(2026, 10, 21),
      sticker: 'Saved rose',
      generatedSticker: GeneratedStickerAsset(
        stickerBytes: stickerBytes,
        stickerId: 'rose-sticker',
        createdAt: DateTime(2026, 10, 20),
        label: 'Saved rose',
      ),
      isFavorite: true,
    );

    await storage.saveEntries('linda@example.com', [entry]);

    final restoredEntries = await storage.loadEntries('linda@example.com');
    final otherAccountEntries = await storage.loadEntries('other@example.com');

    expect(restoredEntries, hasLength(1));
    expect(restoredEntries!.single.flowerName, 'Rose');
    expect(restoredEntries.single.location, 'Garden');
    expect(restoredEntries.single.notes, 'Found in the morning');
    expect(restoredEntries.single.date, DateTime(2026, 10, 21));
    expect(restoredEntries.single.isFavorite, isTrue);
    expect(restoredEntries.single.generatedSticker?.stickerBytes, stickerBytes);
    expect(restoredEntries.single.generatedSticker?.stickerId, 'rose-sticker');
    expect(restoredEntries.single.generatedSticker?.label, 'Saved rose');
    expect(otherAccountEntries, isNull);
  });
}
