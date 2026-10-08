import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flower_finder/sticker_creation.dart';
import 'package:flower_finder/user_profile.dart';

void main() {
  final bytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );

  testWidgets('personal photo remains usable when the API fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StickerCreationPage(
          photos: const [],
          onSaved: (_, sticker, style) {},
          loadFlowers: (_) async => throw Exception('offline'),
          pickPhoto: () async => bytes,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Unable to load flower photos'), findsOneWidget);
    await tester.tap(find.text('Choose my own photo'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Generate sticker'),
      180,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('sticker-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Generate sticker'),
    );
    expect(button.onPressed, isNotNull);
    expect(find.text('Select a flower photo to preview'), findsNothing);
  });

  testWidgets('search loads API photos and cancelling picker keeps selection', (
    tester,
  ) async {
    final queries = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: StickerCreationPage(
          photos: const [],
          onSaved: (_, sticker, style) {},
          loadFlowers: (query) async {
            queries.add(query);
            return [SavedFlowerPhoto(image: MemoryImage(bytes), label: 'Rose')];
          },
          pickPhoto: () async => null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(queries, ['rose']);
    await tester.tap(find.text('Choose my own photo'));
    await tester.pumpAndSettle();
    expect(find.text('Select a flower photo to preview'), findsNothing);
    await tester.enterText(find.byType(TextField), 'daisy');
    await tester.tap(find.byTooltip('Search flowers'));
    await tester.pumpAndSettle();
    expect(queries, ['rose', 'daisy']);
  });

  test('white outline follows generated sticker alpha shape', () async {
    final stickerBytes = await _transparentPngWithFlowerBounds(
      canvasSize: 24,
      flowerBounds: const Rect.fromLTWH(8, 8, 8, 8),
    );

    final outlinedBytes = await applyStickerEffects(
      stickerBytes,
      whiteOutline: true,
      outlineThickness: 4,
    );
    final codec = await ui.instantiateImageCodec(outlinedBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final pixels = byteData!.buffer.asUint8List();

    expect(image.width, 32);
    expect(image.height, 32);
    expect(_hasVisibleWhitePixel(pixels, image.width, image.height), isTrue);
    expect(_alphaAt(pixels, image.width, 0, 0), 0);
  });

  test('inner shadow keeps transparency and darkens sticker edges', () async {
    final stickerBytes = await _transparentPngWithFlowerBounds(
      canvasSize: 24,
      flowerBounds: const Rect.fromLTWH(6, 6, 12, 12),
    );

    final shadowedBytes = await applyStickerEffects(
      stickerBytes,
      innerShadow: true,
    );
    final original = await _decodeRawRgba(stickerBytes);
    final shadowed = await _decodeRawRgba(shadowedBytes);

    expect(shadowed.width, original.width);
    expect(shadowed.height, original.height);
    expect(_alphaAt(shadowed.pixels, shadowed.width, 0, 0), 0);
    expect(
      _brightnessAt(shadowed.pixels, shadowed.width, 6, 6),
      lessThan(_brightnessAt(original.pixels, original.width, 6, 6)),
    );
  });

  test('generated sticker transparent padding is cropped', () async {
    final stickerBytes = await _transparentPngWithFlowerBounds(
      canvasSize: 100,
      flowerBounds: const Rect.fromLTWH(40, 40, 20, 20),
    );

    final croppedBytes = await cropStickerTransparentPadding(stickerBytes);
    final codec = await ui.instantiateImageCodec(croppedBytes);
    final frame = await codec.getNextFrame();

    expect(frame.image.width, lessThan(40));
    expect(frame.image.height, lessThan(40));
    expect(frame.image.width, frame.image.height);
  });
}

Future<Uint8List> _transparentPngWithFlowerBounds({
  required int canvasSize,
  required Rect flowerBounds,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(flowerBounds, Paint()..color = Colors.pink);
  final image = await recorder.endRecording().toImage(canvasSize, canvasSize);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

int _alphaAt(Uint8List pixels, int width, int x, int y) {
  return pixels[((y * width + x) * 4) + 3];
}

bool _hasVisibleWhitePixel(Uint8List pixels, int width, int height) {
  for (var y = 0; y < height; y += 1) {
    for (var x = 0; x < width; x += 1) {
      final index = (y * width + x) * 4;
      final isWhite =
          pixels[index] == 255 &&
          pixels[index + 1] == 255 &&
          pixels[index + 2] == 255;
      if (isWhite && pixels[index + 3] > 0) return true;
    }
  }
  return false;
}

Future<_RawImage> _decodeRawRgba(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return _RawImage(
    width: image.width,
    height: image.height,
    pixels: byteData!.buffer.asUint8List(),
  );
}

int _brightnessAt(Uint8List pixels, int width, int x, int y) {
  final index = (y * width + x) * 4;
  return pixels[index] + pixels[index + 1] + pixels[index + 2];
}

class _RawImage {
  const _RawImage({
    required this.width,
    required this.height,
    required this.pixels,
  });

  final int width;
  final int height;
  final Uint8List pixels;
}
