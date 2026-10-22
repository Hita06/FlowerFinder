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
      'baseStickerBytes': photo.baseStickerBytes == null
          ? null
          : base64Encode(photo.baseStickerBytes!),
      'profileGridSize': photo.profileGridSizeId,
      'animationAsset': photo.animationAsset,
      'boardPositionX': photo.boardPositionX,
      'boardPositionY': photo.boardPositionY,
      'boardScale': photo.boardScale,
      'whiteOutlineEnabled': photo.whiteOutlineEnabled,
      'outlineThickness': photo.outlineThickness,
      'innerShadowEnabled': photo.innerShadowEnabled,
      'dropShadowEnabled': photo.dropShadowEnabled,
      'dropShadowStrength': photo.dropShadowStrength,
      'advancedEffectId': photo.advancedEffectId,
      'stickerTintEnabled': photo.stickerTintEnabled,
      'gradientColorId': photo.gradientColorId,
    };
  }

  static SavedFlowerPhoto? _entryToPhoto(Map<String, dynamic> entry) {
    final encodedBytes = entry['stickerBytes'];
    if (encodedBytes is! String) return null;
    try {
      final stickerBytes = base64Decode(encodedBytes);
      final encodedBaseBytes = entry['baseStickerBytes'];
      final baseStickerBytes = encodedBaseBytes is String
          ? base64Decode(encodedBaseBytes)
          : null;
      return SavedFlowerPhoto(
        image: MemoryImage(Uint8List.fromList(stickerBytes)),
        label: entry['label'] as String?,
        stickerId: entry['stickerId'] as String?,
        stickerBytes: Uint8List.fromList(stickerBytes),
        baseStickerBytes: baseStickerBytes == null
            ? null
            : Uint8List.fromList(baseStickerBytes),
        createdAt: DateTime.tryParse(entry['createdAt']?.toString() ?? ''),
        profileGridSizeId: entry['profileGridSize'] as String?,
        animationAsset:
            legacyFireAnimationAssets.contains(entry['animationAsset'])
            ? fireAnimationAsset
            : entry['animationAsset'] as String?,
        boardPositionX: (entry['boardPositionX'] as num?)?.toDouble(),
        boardPositionY: (entry['boardPositionY'] as num?)?.toDouble(),
        boardScale: (entry['boardScale'] as num?)?.toDouble(),
        whiteOutlineEnabled: entry['whiteOutlineEnabled'] as bool? ?? false,
        outlineThickness: (entry['outlineThickness'] as num?)?.toDouble() ?? 8,
        innerShadowEnabled: entry['innerShadowEnabled'] as bool? ?? false,
        dropShadowEnabled: entry['dropShadowEnabled'] as bool? ?? false,
        dropShadowStrength:
            (entry['dropShadowStrength'] as num?)?.toDouble() ?? 0.6,
        advancedEffectId: entry['advancedEffectId'] as String?,
        stickerTintEnabled: entry['stickerTintEnabled'] as bool?,
        gradientColorId: entry['gradientColorId'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
