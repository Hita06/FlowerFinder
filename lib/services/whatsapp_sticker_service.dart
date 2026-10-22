import 'dart:io';
import 'dart:isolate';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:whatsapp_stickers_handler/model/sticker_pack.dart';
import 'package:whatsapp_stickers_handler/model/sticker_pack_exception.dart';
import 'package:whatsapp_stickers_handler/service/sticker_pack_util.dart';
import 'package:whatsapp_stickers_handler/whatsapp_stickers_handler.dart';

import '../sticker_animation_assets.dart';
import '../user_profile.dart';

/// Must stay top-level so it can run in a background isolate.
Uint8List _encodeAnimatedWebPInBackground({
  required List<Uint8List> frames,
  required int frameDurationMs,
  required List<int> qualityLevels,
  required int canvasSize,
  required int maxBytes,
}) {
  if (frames.isEmpty) {
    throw Exception('No animation frames were rendered.');
  }

  final animation = img.Image.fromBytes(
    width: canvasSize,
    height: canvasSize,
    bytes: frames.first.buffer,
    bytesOffset: frames.first.offsetInBytes,
    numChannels: 4,
    frameType: img.FrameType.animation,
    loopCount: 0,
    frameDuration: frameDurationMs,
  );

  for (var i = 1; i < frames.length; i++) {
    animation.addFrame(
      img.Image.fromBytes(
        width: canvasSize,
        height: canvasSize,
        bytes: frames[i].buffer,
        bytesOffset: frames[i].offsetInBytes,
        numChannels: 4,
        frameDuration: frameDurationMs,
      ),
    ).frameDuration = frameDurationMs;
  }

  for (final quality in qualityLevels) {
    final encoded = img.encodeWebP(
      animation,
      lossless: false,
      quality: quality,
      method: 0,
      alphaQuality: 100,
    );
    if (encoded.length <= maxBytes) {
      return Uint8List.fromList(encoded);
    }
  }

  throw Exception(
    'An animated sticker exceeds WhatsApp’s 500 KB limit after '
    'compression. Try a simpler or shorter animation.',
  );
}

class WhatsAppStickerService {
  final WhatsappStickersHandler _whatsapp = WhatsappStickersHandler();

  static const int _canvasSize = 512;
  static const int _maxAnimatedStickerBytes = 500 * 1024;
  static const int _maxAnimationDurationMs = 10000;
  static const int _framesPerSecond = 6;

  Future<void> shareSticker({
    required Uint8List stickerBytes,
    String? stickerId,
  }) async {
    if (stickerBytes.isEmpty) {
      throw Exception('Sticker could not be shared.');
    }

    final directory = await getTemporaryDirectory();
    final safeId = (stickerId ?? '${DateTime.now().millisecondsSinceEpoch}')
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final stickerFile = File(
      '${directory.path}/flower_finder_sticker_$safeId.png',
    );
    await stickerFile.writeAsBytes(stickerBytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(stickerFile.path)],
        text: 'Check out my Flower Finder sticker!',
      ),
    );
  }

  bool canCreateStickerPack(int stickerCount) =>
      stickerCount >= 3 && stickerCount <= 30;

  /// Exports saved stickers with their existing Lottie overlays as animated
  /// WebP files, then asks WhatsApp to add the pack.
  Future<void> addSavedStickersToWhatsApp({
    required List<SavedFlowerPhoto> stickers,
  }) async {
    if (!canCreateStickerPack(stickers.length)) {
      throw Exception(
        'Choose between 3 and 30 animated stickers to create a pack.',
      );
    }

    for (var i = 0; i < stickers.length; i++) {
      final sticker = stickers[i];
      if (sticker.stickerBytes == null || sticker.stickerBytes!.isEmpty) {
        throw Exception('Sticker ${i + 1} has no image data.');
      }
      if (sticker.animationAsset == null ||
          sticker.animationAsset!.trim().isEmpty) {
        throw Exception(
          'Every sticker in an animated pack must have an animation. '
          'Choose only stickers with animations.',
        );
      }
    }

    if (!await _whatsapp.isWhatsAppInstalled) {
      throw Exception('WhatsApp is not installed on this device.');
    }

    final appDirectory = await getApplicationDocumentsDirectory();
    final packDirectory = Directory(
      '${appDirectory.path}/flower_finder_blooms',
    );
    await packDirectory.create(recursive: true);

    final webpDirectory = Directory('${packDirectory.path}/animated_webp');
    if (await webpDirectory.exists()) {
      await webpDirectory.delete(recursive: true);
    }
    await webpDirectory.create(recursive: true);

    final webpPaths = <String>[];
    for (var i = 0; i < stickers.length; i++) {
      final sticker = stickers[i];
      final bytes = await _renderAnimatedWebP(
        stickerBytes: sticker.stickerBytes!,
        animationAsset: sticker.animationAsset!,
      );
      final file = File('${webpDirectory.path}/sticker_$i.webp');
      await file.writeAsBytes(bytes, flush: true);
      webpPaths.add(file.path);
    }

    final trayImage = await StickerPackUtil().saveWebpAsTrayImage(
      webpPaths.first,
    );
    final pack = StickerPack(
      identifier: 'flowerFinderBlooms',
      name: 'Flower Finder Blooms',
      publisher: 'Flower Finder',
      animatedStickerPack: true,
    )
      ..stickers = webpPaths
      ..trayImage = trayImage;

    try {
      await _whatsapp.addStickerPack(pack);
    } on StickerPackException catch (e) {
      // Preserve the validator's useful explanation for the UI/log.
      throw Exception('Sticker pack validation failed: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception(
        e.message ?? 'WhatsApp could not add the sticker pack.',
      );
    }
  }

  Future<Uint8List> _renderAnimatedWebP({
    required Uint8List stickerBytes,
    required String animationAsset,
  }) async {
    final composition = await AssetLottie(animationAsset).load();
    final durationMs = composition.duration.inMilliseconds;
    if (durationMs <= 0) {
      throw Exception('The animation "$animationAsset" has no duration.');
    }
    if (durationMs > _maxAnimationDurationMs) {
      throw Exception(
        'The animation "$animationAsset" exceeds WhatsApp’s 10-second limit.',
      );
    }

    final codec = await ui.instantiateImageCodec(stickerBytes);
    ui.Image? stickerImage;
    try {
      stickerImage = (await codec.getNextFrame()).image;
      final drawable = LottieDrawable(composition);
      final frameCount = (durationMs * _framesPerSecond / 1000)
          .ceil()
          .clamp(3, _framesPerSecond * 10);
      final frameDurationMs = (durationMs / frameCount).round().clamp(8, 1000);

      final firstUiFrame = await _renderFrame(
        stickerImage: stickerImage,
        drawable: drawable,
        progress: 0,
        maskAnimationToSticker: animationAsset == fireAnimationAsset,
      );
      final firstBytes = await firstUiFrame.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      firstUiFrame.dispose();
      if (firstBytes == null) {
        throw Exception('Could not render the first animation frame.');
      }

      final frames = <Uint8List>[
        Uint8List.fromList(
          firstBytes.buffer.asUint8List(
            firstBytes.offsetInBytes,
            firstBytes.lengthInBytes,
          ),
        ),
      ];

      for (var i = 1; i < frameCount; i++) {
        final uiFrame = await _renderFrame(
          stickerImage: stickerImage,
          drawable: drawable,
          progress: i / frameCount,
          maskAnimationToSticker: animationAsset == fireAnimationAsset,
        );
        try {
          final raw = await uiFrame.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          if (raw == null) {
            throw Exception('Could not render animation frame ${i + 1}.');
          }
          frames.add(
            Uint8List.fromList(
              raw.buffer.asUint8List(raw.offsetInBytes, raw.lengthInBytes),
            ),
          );
        } finally {
          uiFrame.dispose();
        }
      }

      // Image encoding is CPU-heavy. Run it in a background isolate so the
      // Flutter UI isolate remains responsive while WebP is compressed.
      final encoded = await Isolate.run(
        () => _encodeAnimatedWebPInBackground(
          frames: frames,
          frameDurationMs: frameDurationMs,
          qualityLevels: const [70, 55, 40, 30, 20, 10],
          canvasSize: _canvasSize,
          maxBytes: _maxAnimatedStickerBytes,
        ),
      );
      if (!_isAnimatedWebP(encoded)) {
        throw Exception('The encoder did not produce animated WebP.');
      }
      return encoded;
    } finally {
      stickerImage?.dispose();
      codec.dispose();
    }
  }

  Future<ui.Image> _renderFrame({
    required ui.Image stickerImage,
    required LottieDrawable drawable,
    required double progress,
    required bool maskAnimationToSticker,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final bounds = ui.Rect.fromLTWH(
      0,
      0,
      _canvasSize.toDouble(),
      _canvasSize.toDouble(),
    );

    final scale = math.min(
      _canvasSize / stickerImage.width,
      _canvasSize / stickerImage.height,
    );
    final width = stickerImage.width * scale;
    final height = stickerImage.height * scale;
    final destination = ui.Rect.fromLTWH(
      (_canvasSize - width) / 2,
      (_canvasSize - height) / 2,
      width,
      height,
    );
    final source = ui.Rect.fromLTWH(
      0,
      0,
      stickerImage.width.toDouble(),
      stickerImage.height.toDouble(),
    );

    canvas.drawImageRect(
      stickerImage,
      source,
      destination,
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    );

    drawable.setProgress(progress);
    if (maskAnimationToSticker) {
      // Match the existing fire overlay: constrain its alpha to the sticker.
      canvas.saveLayer(bounds, ui.Paint());
      drawable.draw(canvas, bounds);
      canvas.drawImageRect(
        stickerImage,
        source,
        destination,
        ui.Paint()..blendMode = ui.BlendMode.dstIn,
      );
      canvas.restore();
    } else {
      canvas.saveLayer(
        bounds,
        ui.Paint()..color = const ui.Color(0xD1FFFFFF),
      );
      drawable.draw(canvas, bounds);
      canvas.restore();
    }

    final picture = recorder.endRecording();
    try {
      return await picture.toImage(_canvasSize, _canvasSize);
    } finally {
      picture.dispose();
    }
  }

  bool _isAnimatedWebP(Uint8List bytes) {
    if (bytes.length < 12 ||
        String.fromCharCodes(bytes.sublist(0, 4)) != 'RIFF' ||
        String.fromCharCodes(bytes.sublist(8, 12)) != 'WEBP') {
      return false;
    }
    final text = String.fromCharCodes(bytes);
    return text.contains('ANIM') && text.contains('ANMF');
  }
}
