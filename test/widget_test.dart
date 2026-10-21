import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowerfinderscanner/homepage.dart';
import 'package:flowerfinderscanner/main_navigation.dart';
import 'package:flowerfinderscanner/diary_entry.dart';
import 'package:flowerfinderscanner/diary_storage.dart';
import 'package:flowerfinderscanner/pages/diary_page.dart';
import 'package:flowerfinderscanner/profile_storage.dart';
import 'package:flowerfinderscanner/sticker_creation.dart';
import 'package:flowerfinderscanner/sticker_animation_overlay.dart';
import 'package:flowerfinderscanner/sticker_storage.dart';
import 'package:flowerfinderscanner/user_profile.dart';

import 'package:google_fonts/google_fonts.dart';

late Directory _testStorageDirectory;

class _MemoryDiaryStorage extends DiaryStorage {
  final Map<String, List<DiaryEntry>> entriesByAccount = {};

  @override
  Future<List<DiaryEntry>?> loadEntries(String accountId) async {
    final entries = entriesByAccount[accountId];
    return entries
        ?.map((entry) => DiaryEntry.fromJson(entry.toJson()))
        .toList();
  }

  @override
  Future<void> saveEntries(String accountId, List<DiaryEntry> entries) async {
    entriesByAccount[accountId] = entries
        .map((entry) => DiaryEntry.fromJson(entry.toJson()))
        .toList();
  }
}

MainNavigation _mainNavigation() {
  return MainNavigation(
    profileStorage: ProfileStorage(
      directoryProvider: () async => _testStorageDirectory,
    ),
    stickerStorage: StickerStorage(
      directoryProvider: () async => _testStorageDirectory,
    ),
    diaryStorage: DiaryStorage(
      directoryProvider: () async => _testStorageDirectory,
    ),
  );
}

Future<void> _openProfileTab(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('nav-profile')));
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pump();
}

Future<void> _scrollToFinder(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) {
    await tester.ensureVisible(finder);
  } else {
    await tester.scrollUntilVisible(
      finder,
      260,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    _testStorageDirectory = await Directory.systemTemp.createTemp(
      'flower_finder_widget_test_',
    );
  });

  tearDown(() async {
    if (await _testStorageDirectory.exists()) {
      await _testStorageDirectory.delete(recursive: true);
    }
  });

  testWidgets('profile tab opens the profile page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: _mainNavigation()));

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Add Sticker'), findsNothing);

    await _openProfileTab(tester);

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Profile')),
      findsOneWidget,
    );
    expect(find.byType(UserProfilePage), findsOneWidget);
    await _scrollToFinder(tester, find.text('Your Stickers'));
    expect(find.text('Your Stickers'), findsOneWidget);
    expect(find.text('Add Sticker'), findsWidgets);
  });

  testWidgets('profile opens sticker creation', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: _mainNavigation()));
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
    await tester.pumpWidget(MaterialApp(home: _mainNavigation()));
    await _openProfileTab(tester);
    await tester.tap(find.byTooltip('Edit profile details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Change profile details'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
  });

  testWidgets('profile logout page confirms before handoff', (
    WidgetTester tester,
  ) async {
    var loggedOut = false;

    await tester.pumpWidget(
      MaterialApp(home: UserProfilePage(onLogout: () => loggedOut = true)),
    );

    expect(find.widgetWithText(OutlinedButton, 'Log out'), findsNothing);
    final state = tester.state<UserProfilePageState>(
      find.byType(UserProfilePage),
    );
    state.openLogoutPage();
    await tester.pumpAndSettle();

    expect(find.byType(LogoutPage), findsOneWidget);
    expect(find.text('Log out of FlowerFinder?'), findsOneWidget);
    expect(loggedOut, isFalse);

    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(loggedOut, isTrue);
    expect(find.byType(LogoutPage), findsNothing);
  });

  testWidgets('profile colour can be changed from the details sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: _mainNavigation()));
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

  testWidgets('sticker creation exposes colour wheel and advanced effects', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: _mainNavigation()));
    await _openProfileTab(tester);
    await tester.tap(find.byTooltip('Create sticker'));
    await tester.pumpAndSettle();
    final stickerScroll = find
        .descendant(
          of: find.byKey(const ValueKey('sticker-scroll')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Advanced effects'),
      180,
      scrollable: stickerScroll,
    );
    await tester.pumpAndSettle();

    expect(find.text('Advanced effects'), findsOneWidget);
    expect(find.text('Bright Glitter'), findsOneWidget);
    expect(find.text('3D Bubble'), findsNothing);
    expect(find.text('Rainbow Prism'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sticker animation'),
      180,
      scrollable: stickerScroll,
    );
    expect(find.text('No animation'), findsOneWidget);
    expect(find.text('Add animation'), findsOneWidget);
    expect(find.text('Fire'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Save sticker'),
      180,
      scrollable: stickerScroll,
    );
    expect(find.text('Choose sticker colour'), findsOneWidget);
    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save sticker'),
    );
    expect(saveButton.onPressed, isNull);
  });

  testWidgets('saved sticker appears in profile after returning from creation', (
    WidgetTester tester,
  ) async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );

    await tester.pumpWidget(MaterialApp(home: _mainNavigation()));
    await _openProfileTab(tester);
    await tester.tap(find.byTooltip('Create sticker'));
    await tester.pumpAndSettle();

    final creation = tester.widget<StickerCreationPage>(
      find.byType(StickerCreationPage),
    );
    creation.onSaved(
      SavedFlowerPhoto(image: MemoryImage(stickerBytes), label: 'Saved rose'),
      stickerBytes,
      'colour_change',
      null,
    );
    Navigator.of(tester.element(find.byType(StickerCreationPage))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await _scrollToFinder(tester, find.text('Your Stickers'));
    expect(find.text('Your Stickers'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('saved-sticker-colour_change')),
      findsOneWidget,
    );
    expect(find.text('Add Sticker'), findsWidgets);
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
    final savedStickerFinder = find.byKey(
      const ValueKey('saved-sticker-saved-sticker'),
    );
    await _scrollToFinder(tester, savedStickerFinder);
    await tester.tap(savedStickerFinder);
    await tester.pump();

    expect(selectedSticker?.stickerBytes, isNotNull);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('profile shares only generated sticker bytes', (
    WidgetTester tester,
  ) async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      label: 'Saved rose',
      stickerId: 'colour_change',
      stickerBytes: stickerBytes,
      createdAt: DateTime(2026, 9, 17),
    );
    GeneratedStickerAsset? sharedSticker;

    await tester.pumpWidget(
      MaterialApp(
        home: UserProfilePage(
          savedFlowerPhotos: [sticker],
          onShareSticker: (asset) => sharedSticker = asset,
        ),
      ),
    );
    final savedStickerFinder = find.byKey(
      const ValueKey('saved-sticker-colour_change'),
    );
    await _scrollToFinder(tester, savedStickerFinder);
    await tester.tap(savedStickerFinder);
    await tester.pump();

    expect(find.text('Your Sticker'), findsOneWidget);
    expect(
      find.text('What would you like to do with this sticker?'),
      findsOneWidget,
    );
    expect(sharedSticker, isNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Share Sticker'));
    await tester.pump();

    expect(sharedSticker?.stickerBytes, stickerBytes);
    expect(sharedSticker?.stickerId, 'colour_change');
    expect(sharedSticker?.label, 'Saved rose');
  });

  testWidgets('profile sends only generated sticker bytes to diary handoff', (
    WidgetTester tester,
  ) async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      label: 'Diary rose',
      stickerId: 'colour_variation',
      stickerBytes: stickerBytes,
      createdAt: DateTime(2026, 9, 18),
    );
    GeneratedStickerAsset? diarySticker;

    await tester.pumpWidget(
      MaterialApp(
        home: UserProfilePage(
          savedFlowerPhotos: [sticker],
          onAddStickerToDiary: (asset) => diarySticker = asset,
        ),
      ),
    );
    final savedStickerFinder = find.byKey(
      const ValueKey('saved-sticker-colour_variation'),
    );
    await _scrollToFinder(tester, savedStickerFinder);
    await tester.tap(savedStickerFinder);
    await tester.pump();
    expect(find.text('Your Sticker'), findsOneWidget);
    expect(diarySticker, isNull);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add to Diary'));
    await tester.pump();

    expect(diarySticker?.stickerBytes, stickerBytes);
    expect(diarySticker?.stickerId, 'colour_variation');
    expect(diarySticker?.createdAt, DateTime(2026, 9, 18));
  });

  testWidgets('diary opens a new entry with the generated sticker selected', (
    WidgetTester tester,
  ) async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final sticker = GeneratedStickerAsset(
      stickerBytes: stickerBytes,
      stickerId: 'diary-rose',
      label: 'Diary rose',
    );
    final diaryStorage = _MemoryDiaryStorage();

    await tester.pumpWidget(
      MaterialApp(
        home: DiaryPage(
          accountId: 'diary-test@example.com',
          storage: diaryStorage,
          stickerToAdd: sticker,
          stickerRequestId: 1,
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add Diary Entry'), findsOneWidget);
    expect(find.text('Diary rose'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    expect(
      tester.widget<EditableText>(find.byType(EditableText).first).autofocus,
      isFalse,
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Rose');
    await tester.enterText(find.byType(TextFormField).at(1), 'Garden');
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(0))
          .controller!
          .text,
      'Rose',
    );
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text,
      'Garden',
    );
    final saveButton = find.widgetWithText(FilledButton, 'Save');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(find.text('Add Diary Entry'), findsNothing);
    expect(find.text('Rose'), findsOneWidget);

    final persistedEntries = await diaryStorage.loadEntries(
      'diary-test@example.com',
    );
    expect(persistedEntries, hasLength(3));
    expect(find.text('Rose'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);

    await tester.pumpWidget(
      MaterialApp(
        home: DiaryPage(
          accountId: 'diary-test@example.com',
          storage: diaryStorage,
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rose'), findsOneWidget);
    expect(find.textContaining('Garden'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('sticker action dialog is safe without handoff callbacks', (
    WidgetTester tester,
  ) async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      stickerId: 'safe-sticker',
      stickerBytes: stickerBytes,
    );

    await tester.pumpWidget(
      MaterialApp(home: UserProfilePage(savedFlowerPhotos: [sticker])),
    );
    final savedStickerFinder = find.byKey(
      const ValueKey('saved-sticker-safe-sticker'),
    );
    await _scrollToFinder(tester, savedStickerFinder);
    await tester.tap(savedStickerFinder);
    await tester.pump();

    expect(find.text('Your Sticker'), findsOneWidget);
    final shareButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Share Sticker'),
    );
    final diaryButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Add to Diary'),
    );
    expect(shareButton.onPressed, isNull);
    expect(diaryButton.onPressed, isNull);
  });

  testWidgets('profile confirms before deleting a saved sticker', (
    WidgetTester tester,
  ) async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      label: 'Delete rose',
      stickerId: 'delete-sticker',
      stickerBytes: stickerBytes,
    );
    SavedFlowerPhoto? deletedSticker;

    await tester.pumpWidget(
      MaterialApp(
        home: UserProfilePage(
          savedFlowerPhotos: [sticker],
          onDeleteSticker: (value) => deletedSticker = value,
        ),
      ),
    );

    final manageButton = find.widgetWithText(TextButton, 'Manage');
    await _scrollToFinder(tester, manageButton);
    await tester.tap(manageButton);
    await tester.pumpAndSettle();
    expect(find.text('Delete rose'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete sticker'));
    await tester.pumpAndSettle();
    expect(find.text('Delete sticker?'), findsOneWidget);
    expect(deletedSticker, isNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(deletedSticker, same(sticker));
    expect(find.text('Delete sticker?'), findsNothing);
  });

  testWidgets('profile exposes reorder callback from manage mode', (
    WidgetTester tester,
  ) async {
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
    int? oldReorderIndex;
    int? newReorderIndex;

    await tester.pumpWidget(
      MaterialApp(
        home: UserProfilePage(
          savedFlowerPhotos: [firstSticker, secondSticker],
          onReorderStickers: (oldIndex, newIndex) {
            oldReorderIndex = oldIndex;
            newReorderIndex = newIndex;
          },
        ),
      ),
    );

    final manageButton = find.widgetWithText(TextButton, 'Manage');
    await _scrollToFinder(tester, manageButton);
    await tester.tap(manageButton);
    await tester.pumpAndSettle();

    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    list.onReorderItem!(0, 1);

    expect(oldReorderIndex, 0);
    expect(newReorderIndex, 1);
  });

  testWidgets('profile opens edit handoff from sticker action dialog', (
    WidgetTester tester,
  ) async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      stickerId: 'editable-sticker',
      stickerBytes: stickerBytes,
    );
    SavedFlowerPhoto? editedSticker;

    await tester.pumpWidget(
      MaterialApp(
        home: UserProfilePage(
          savedFlowerPhotos: [sticker],
          onEditSticker: (value) => editedSticker = value,
        ),
      ),
    );

    final savedStickerFinder = find.byKey(
      const ValueKey('saved-sticker-editable-sticker'),
    );
    await _scrollToFinder(tester, savedStickerFinder);
    await tester.tap(savedStickerFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Edit Sticker'));
    await tester.pumpAndSettle();

    expect(editedSticker, same(sticker));
    expect(find.text('Your Sticker'), findsNothing);
  });

  testWidgets('your stickers can switch to a large square display', (
    WidgetTester tester,
  ) async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      label: 'Board sticker',
      stickerId: 'board-sticker',
      stickerBytes: stickerBytes,
    );

    await tester.pumpWidget(
      MaterialApp(home: UserProfilePage(savedFlowerPhotos: [sticker])),
    );

    await _scrollToFinder(tester, find.text('Large square'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Large square'));
    await tester.pump();

    expect(find.text('Your Stickers'), findsOneWidget);
    expect(
      find.text(
        'Show all generated stickers in one large square. Tap Edit to move or resize.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('large-sticker-board-sticker')),
      findsOneWidget,
    );
  });

  testWidgets('large square lets stickers move and resize', (
    WidgetTester tester,
  ) async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      label: 'Move sticker',
      stickerId: 'move-sticker',
      stickerBytes: stickerBytes,
    );

    await tester.pumpWidget(
      MaterialApp(home: UserProfilePage(savedFlowerPhotos: [sticker])),
    );

    await _scrollToFinder(tester, find.text('Large square'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Large square'));
    await tester.pump();

    final largeSticker = find.byKey(
      const ValueKey('large-sticker-move-sticker'),
    );
    expect(largeSticker, findsOneWidget);
    await tester.tap(largeSticker);
    await tester.pump();
    expect(find.text('Edit'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pump();
    expect(find.text('Done'), findsOneWidget);
    await tester.drag(largeSticker, const Offset(24, 18));
    await tester.pump();
    expect(
      find.descendant(of: largeSticker, matching: find.byType(Image)),
      findsOneWidget,
    );
    expect(largeSticker, findsOneWidget);
  });

  testWidgets('your stickers uploads a gallery photo as its own item', (
    WidgetTester tester,
  ) async {
    final photoBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    ProfileCollectionSettings? savedSettings;

    await tester.pumpWidget(
      MaterialApp(
        home: UserProfilePage(
          pickProfileImage: () async => photoBytes,
          onCollectionSettingsChanged: (settings) => savedSettings = settings,
        ),
      ),
    );

    await tester.tap(find.text('Add Sticker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload photo'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('uploaded-photo-0')), findsOneWidget);
    expect(savedSettings?.uploadedPhotos, hasLength(1));
    expect(
      savedSettings!.uploadedPhotos.single.imageBytes,
      orderedEquals(photoBytes),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Large square'));
    await tester.pump();
    expect(savedSettings?.displaySizeId, 'largeSquare');

    await tester.pumpWidget(
      MaterialApp(home: UserProfilePage(collectionSettings: savedSettings!)),
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Large square'))
          .selected,
      isTrue,
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'Small grid'));
    await tester.pump();
    expect(find.byKey(const ValueKey('uploaded-photo-0')), findsOneWidget);
  });

  testWidgets('add sticker tile asks whether to create or upload', (
    WidgetTester tester,
  ) async {
    var createStickerTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: UserProfilePage(
          onCreateSticker: () => createStickerTapped = true,
        ),
      ),
    );

    await tester.tap(find.text('Add Sticker'));
    await tester.pumpAndSettle();

    expect(find.text('Add to Your Stickers'), findsOneWidget);
    expect(find.text('Create sticker'), findsOneWidget);
    expect(find.text('Upload photo'), findsOneWidget);

    await tester.tap(find.text('Create sticker'));
    await tester.pumpAndSettle();

    expect(createStickerTapped, isTrue);
  });

  testWidgets('sticker creation edits an existing generated sticker', (
    WidgetTester tester,
  ) async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      label: 'Editable rose',
      stickerId: 'editable-sticker',
      stickerBytes: stickerBytes,
    );
    SavedFlowerPhoto? savedPhoto;
    List<int>? savedBytes;
    String? savedStickerId;

    await tester.pumpWidget(
      MaterialApp(
        home: StickerCreationPage(
          photos: [sticker],
          initialSticker: sticker,
          onSaved: (photo, bytes, stickerId, animationAsset) {
            savedPhoto = photo;
            savedBytes = bytes;
            savedStickerId = stickerId;
          },
        ),
      ),
    );

    expect(find.text('Edit Sticker'), findsOneWidget);
    expect(find.text('Generate sticker'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Update sticker'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Update sticker'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Update sticker'));
    await tester.pumpAndSettle();

    expect(savedPhoto?.image, same(sticker.image));
    expect(savedPhoto?.label, sticker.label);
    expect(savedPhoto?.baseStickerBytes, sticker.stickerBytes);
    expect(savedBytes, stickerBytes);
    expect(savedStickerId, 'editable-sticker');
  });

  testWidgets('editing inner shadow starts from the saved base sticker', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final baseStickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final stickerBytes = (await tester.runAsync(
      () => applyStickerEffects(baseStickerBytes, innerShadow: true),
    ))!;
    Uint8List? savedBytes;
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      stickerId: 'original',
      stickerBytes: stickerBytes,
      baseStickerBytes: baseStickerBytes,
      innerShadowEnabled: true,
      stickerTintEnabled: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: StickerCreationPage(
          photos: [sticker],
          initialSticker: sticker,
          onSaved: (photo, bytes, stickerId, animationAsset) {
            savedBytes = bytes;
          },
        ),
      ),
    );

    final innerShadowTile = find.widgetWithText(SwitchListTile, 'Inner Shadow');
    expect(tester.widget<SwitchListTile>(innerShadowTile).value, isTrue);
    await tester.ensureVisible(innerShadowTile);
    await tester.tap(
      find.descendant(of: innerShadowTile, matching: find.byType(Switch)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Update sticker'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Update sticker'));
    await tester.pumpAndSettle();

    expect(savedBytes, baseStickerBytes);
  });

  testWidgets('reward light effect renders behind the sticker preview', (
    WidgetTester tester,
  ) async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      stickerBytes: stickerBytes,
      animationAsset: 'Animations/Reward light effect.json',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: StickerCreationPage(
          photos: [sticker],
          initialSticker: sticker,
          onSaved: (photo, bytes, stickerId, animationAsset) {},
        ),
      ),
    );

    final previewLayers = tester.widget<Stack>(
      find.byKey(const ValueKey('sticker-preview-animation-layers')),
    );
    expect(previewLayers.children.first, isA<StickerAnimationOverlay>());
    expect(previewLayers.children.last, isA<Image>());
  });

  testWidgets('sticker editor offers selectable gradient colour presets', (
    WidgetTester tester,
  ) async {
    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      stickerBytes: stickerBytes,
      baseStickerBytes: stickerBytes,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: StickerCreationPage(
          photos: [sticker],
          initialSticker: sticker,
          onSaved: (photo, bytes, stickerId, animationAsset) {},
        ),
      ),
    );
    await tester.scrollUntilVisible(
      find.widgetWithText(ChoiceChip, 'Sunset'),
      180,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Sunset'));
    await tester.pump();

    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Sunset'))
          .selected,
      isTrue,
    );

    await tester.scrollUntilVisible(
      find.widgetWithText(ChoiceChip, 'Pastel Rainbow'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'Pastel Rainbow'));
    await tester.pump();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Pastel Rainbow'))
          .selected,
      isTrue,
    );
  });

  testWidgets('sticker animation can be added or removed while editing', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final stickerBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final sticker = SavedFlowerPhoto(
      image: MemoryImage(stickerBytes),
      stickerBytes: stickerBytes,
    );
    String? savedAnimationAsset;

    await tester.pumpWidget(
      MaterialApp(
        home: StickerCreationPage(
          photos: [sticker],
          initialSticker: sticker,
          onSaved: (photo, bytes, stickerId, animationAsset) {
            savedAnimationAsset = animationAsset;
          },
        ),
      ),
    );

    final addAnimationChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Add animation'),
    );
    addAnimationChip.onSelected!(true);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Fire'), findsOneWidget);
    expect(find.text('Bubble explosion'), findsOneWidget);
    expect(find.text('Success celebration'), findsOneWidget);
    expect(find.text('Fireworks'), findsOneWidget);
    expect(find.text('Red White & Blue Firework'), findsOneWidget);
    expect(find.text('Reward Light Effect'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Fire'))
          .selected,
      isTrue,
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    expect(find.byType(ShaderMask), findsOneWidget);
    tester
        .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Bubble explosion'))
        .onSelected!(true);
    await tester.pump();
    expect(find.byType(ShaderMask), findsNothing);
    tester
        .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Bubble explosion'))
        .onSelected!(true);
    await tester.pump();
    expect(
      tester
          .widget<ChoiceChip>(
            find.widgetWithText(ChoiceChip, 'Bubble explosion'),
          )
          .selected,
      isTrue,
    );
    final noAnimationChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'No animation'),
    );
    noAnimationChip.onSelected!(true);
    await tester.pump();
    expect(find.text('Fire'), findsNothing);

    tester
        .widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Update sticker'),
        )
        .onPressed!();
    await tester.pumpAndSettle();

    expect(savedAnimationAsset, isNull);
    expect(sticker.copyWith(clearAnimationAsset: true).animationAsset, isNull);
  });
}
