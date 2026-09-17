import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flower_finder/main.dart';
import 'package:flower_finder/scanner_page.dart';
import 'package:flower_finder/user_profile.dart';

import 'package:google_fonts/google_fonts.dart';

Future<void> _openProfileTab(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('nav-profile')));
  await tester.pump();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('profile tab opens the profile page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(enableCamera: false));

    expect(find.byType(ScannerPage), findsOneWidget);
    expect(find.text('Add Sticker'), findsNothing);

    await _openProfileTab(tester);

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Profile')),
      findsOneWidget,
    );
    expect(find.byType(UserProfilePage), findsOneWidget);
    expect(find.text('Your Stickers'), findsOneWidget);
    expect(find.text('Add Sticker'), findsOneWidget);
  });

  testWidgets('profile opens sticker creation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(enableCamera: false));
    await _openProfileTab(tester);

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
    expect(find.text('Generate sticker'), findsOneWidget);
  });

  testWidgets('profile edit button opens the existing details sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(enableCamera: false));
    await _openProfileTab(tester);
    await tester.tap(find.byTooltip('Edit profile details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Change profile details'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
  });

  testWidgets('profile colour can be changed from the details sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(enableCamera: false));
    await _openProfileTab(tester);
    await tester.tap(find.byTooltip('Edit profile details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Profile colour'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Rose'));
    await tester.pump();
    await tester.tap(find.text('Save changes'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundColor, const Color(0xffffd9e6));
  });

  testWidgets('profile can receive username from login account boundary', (
    WidgetTester tester,
  ) async {
    final account = UserAccount(
      name: 'Linda',
      username: 'login_linda',
      email: 'linda@example.com',
    );

    await tester.pumpWidget(
      MaterialApp(home: UserProfilePage(account: account)),
    );

    expect(find.text('@login_linda'), findsOneWidget);
    final state = tester.state<UserProfilePageState>(
      find.byType(UserProfilePage),
    );
    state.editProfileDetails();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final usernameField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Username',
      ),
    );
    expect(usernameField.enabled, isFalse);
  });

  testWidgets('sticker creation keeps all existing styles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(enableCamera: false));
    await _openProfileTab(tester);
    await tester.tap(find.byTooltip('Create sticker'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Save sticker'),
      180,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('sticker-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Colour Change'), findsOneWidget);
    expect(find.text('Colour Variation'), findsOneWidget);
    expect(find.text('Bubble Border'), findsOneWidget);
    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save sticker'),
    );
    expect(saveButton.onPressed, isNull);
  });

  testWidgets('profile selects a saved sticker for future upload', (
    WidgetTester tester,
  ) async {
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        ),
      ),
      stickerId: 'saved-sticker',
      stickerBytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      ),
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
