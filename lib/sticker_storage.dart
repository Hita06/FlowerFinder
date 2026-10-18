import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'sticker_animation_assets.dart';
import 'user_profile.dart';

class StickerStorage {
  StickerStorage({this.directoryProvider});

  final Future<Directory> Function()? directoryProvider;
  Future<void> _saveQueue = Future<void>.value();

  Future<List<SavedFlowerPhoto>> loadStickers(String accountId) async {
    final file = await _fileFor(accountId);
    if (!await file.exists()) return <SavedFlowerPhoto>[];

    try {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <SavedFlowerPhoto>[];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_entryToPhoto)
          .whereType<SavedFlowerPhoto>()
          .toList();
    } catch (_) {
      return <SavedFlowerPhoto>[];
    }
  }

  Future<void> saveStickers(String accountId, List<SavedFlowerPhoto> stickers) {
    final snapshot = List<SavedFlowerPhoto>.of(stickers);
    final save = _saveQueue.then((_) => _writeStickers(accountId, snapshot));
    _saveQueue = save.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'sticker storage',
            context: ErrorDescription('while saving stickers'),
          ),
        );
      },
    );
    return save;
  }

  Future<void> _writeStickers(
    String accountId,
    List<SavedFlowerPhoto> stickers,
  ) async {
    final file = await _fileFor(accountId);
    await file.parent.create(recursive: true);
    final generatedStickers = stickers
        .where((photo) => photo.stickerBytes != null)
        .map(_photoToEntry)
        .toList();
    await file.writeAsString(jsonEncode(generatedStickers), flush: true);
  }

  Future<File> _fileFor(String accountId) async {
    final baseDirectory = directoryProvider == null
        ? await getApplicationDocumentsDirectory()
        : await directoryProvider!();
    final safeId = base64Url.encode(utf8.encode(accountId)).replaceAll('=', '');
    return File('${baseDirectory.path}/flower_finder/stickers_$safeId.json');
  }

  static Map<String, Object?> _photoToEntry(SavedFlowerPhoto photo) {
    return <String, Object?>{
      'label': photo.label,
      'stickerId': photo.stickerId,
      'createdAt': photo.createdAt?.toIso8601String(),
      'stickerBytes': base64Encode(photo.stickerBytes!),
      'profileGridSize': photo.profileGridSizeId,
      'animationAsset': photo.animationAsset,
    };
  }

  static SavedFlowerPhoto? _entryToPhoto(Map<String, dynamic> entry) {
    final encodedBytes = entry['stickerBytes'];
    if (encodedBytes is! String) return null;
    try {
      final stickerBytes = base64Decode(encodedBytes);
      return SavedFlowerPhoto(
        image: MemoryImage(Uint8List.fromList(stickerBytes)),
        label: entry['label'] as String?,
        stickerId: entry['stickerId'] as String?,
        stickerBytes: Uint8List.fromList(stickerBytes),
        createdAt: DateTime.tryParse(entry['createdAt']?.toString() ?? ''),
        profileGridSizeId: entry['profileGridSize'] as String?,
        animationAsset:
            replacedFireAnimationAssets.contains(entry['animationAsset'])
            ? fireFeuFuegoAnimationAsset
            : entry['animationAsset'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
