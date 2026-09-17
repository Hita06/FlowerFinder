import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flower_finder/main.dart';
import 'package:flower_finder/user_profile.dart';

void main() {
  testWidgets('profile opens sticker creation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Profile')),
      findsOneWidget,
    );
    expect(find.text('Add Sticker'), findsOneWidget);
    expect(find.byTooltip('Create sticker'), findsOneWidget);
    expect(find.byTooltip('Edit profile details'), findsOneWidget);
    await tester.tap(find.byTooltip('Create sticker'));
    await tester.pumpAndSettle();

    expect(find.text('Create Sticker'), findsOneWidget);
    expect(find.text('Generate sticker'), findsOneWidget);
  });

  testWidgets('sticker creation keeps all existing styles', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Create sticker'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -360));
    await tester.pumpAndSettle();

    expect(find.text('Colour Change'), findsOneWidget);
    expect(find.text('Colour Variation'), findsOneWidget);
    expect(find.text('Bubble Border'), findsOneWidget);
    final saveButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save sticker'));
    expect(saveButton.onPressed, isNull);
  });

  testWidgets('profile selects a saved sticker for future upload', (WidgetTester tester) async {
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=')),
      stickerId: 'saved-sticker',
      stickerBytes: base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='),
    );
    SavedFlowerPhoto? selectedSticker;

    await tester.pumpWidget(
      MaterialApp(
        home: UserProfilePage(
          savedFlowerPhotos: [sticker],
          onStickerSelected: (value) => selectedSticker = value,
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('saved-sticker-saved-sticker')));
    await tester.pump();

    expect(selectedSticker?.stickerBytes, isNotNull);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
