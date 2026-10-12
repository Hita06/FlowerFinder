import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowerfinderscanner/sticker_creation.dart';
import 'package:flowerfinderscanner/user_profile.dart';

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
