// This file manages the main navigation of the app, including the bottom
// navigation bar and the pages for Home, Search, Scanner, Diary, and Profile.

// Handles local files, used for loading scanned images into stickers.
import 'dart:io';

// Firebase authentication for logging the user out.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'flower_search_page.dart';
import 'homepage.dart';
import 'pages/diary_page.dart';
import 'scanner_page.dart';
import 'sticker_creation.dart';
import 'user_profile.dart';
import 'widgets/bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Tab indexes used when navigating between the main sections.
  static const homeTab = 0;
  static const searchTab = 1;
  static const scannerTab = 2;
  static const diaryTab = 3;
  static const profileTab = 4;

  // Allows MainNavigation to access functions in UserProfilePage.
  final _profileKey = GlobalKey<UserProfilePageState>();

  // Stores photos and stickers created by the user.
  final List<SavedFlowerPhoto> _savedFlowerPhotos = [];

  // Tracks the currently selected bottom navigation tab.
  int currentIndex = homeTab;

  // BOTTOM NAVIGATION

  // Updates the selected page when the user taps a navigation item.
  void onNavTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  // Opens the Scanner tab from a homepage shortcut.
  void _openScanner() {
    setState(() {
      currentIndex = scannerTab;
    });
  }

  // Opens the Diary tab from a homepage shortcut or sticker action.
  void _openDiary() {
    setState(() {
      currentIndex = diaryTab;
    });
  }

  // STICKER CREATION

  // Opens sticker creation from the Profile page and saves the
  // completed sticker to the user's saved photos.
  Future<void> _openStickerCreation() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => StickerCreationPage(
          photos: _savedFlowerPhotos,
          onSaved: (photo, stickerBytes, stickerId) {
            setState(() {
              _savedFlowerPhotos.add(
                photo.copyWith(
                  stickerId: stickerId,
                  stickerBytes: stickerBytes,
                  createdAt: DateTime.now(),
                ),
              );

              currentIndex = profileTab;
            });
          },
        ),
      ),
    );
  }

  // Opens sticker creation using the photo taken or selected
  // from the Scanner page.
  Future<void> _openStickerCreationFromScanner(String imagePath) async {
    final scannedPhoto = SavedFlowerPhoto(
      image: FileImage(File(imagePath)),
      createdAt: DateTime.now(),
    );

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => StickerCreationPage(
          photos: [scannedPhoto],
          onSaved: (photo, stickerBytes, stickerId) {
            setState(() {
              _savedFlowerPhotos.add(
                photo.copyWith(
                  stickerId: stickerId,
                  stickerBytes: stickerBytes,
                  createdAt: DateTime.now(),
                ),
              );

              currentIndex = profileTab;
            });
          },
        ),
      ),
    );
  }

  // STICKER ACTIONS

  // Handles sharing a generated sticker.
  void _handleShareSticker(GeneratedStickerAsset sticker) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sticker is ready for sharing.')),
    );
  }

  // Switches to the Diary when the user adds a sticker there.
  void _handleAddStickerToDiary(GeneratedStickerAsset sticker) {
    _openDiary();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sticker selected for Diary integration.')),
    );
  }

  // LOGOUT

  // Signs the current user out through Firebase Authentication.
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    // Rebuilds the tab widgets so Profile receives newly saved stickers.
    final pages = [
      // 0 - Home
      HomePage(
        onOpenScanner: _openScanner,
        onOpenWateringReminders: _openDiary,
        onOpenRecentlyIdentified: _openScanner,
      ),

      // 1 - Search
      const FlowerSearchPage(),

      // 2 - Scanner
      ScannerPage(onAddSticker: _openStickerCreationFromScanner),

      // 3 - Diary
      const DiaryPage(),

      // 4 - Profile
      _ProfileTab(
        profileKey: _profileKey,
        savedFlowerPhotos: _savedFlowerPhotos,
        onCreateSticker: _openStickerCreation,
        onShareSticker: _handleShareSticker,
        onAddStickerToDiary: _handleAddStickerToDiary,
        onLogout: _handleLogout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: BottomNav(
        currentIndex: currentIndex,
        onTap: onNavTap,
      ),
    );
  }
}

// PROFILE TAB

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.profileKey,
    required this.savedFlowerPhotos,
    required this.onCreateSticker,
    required this.onShareSticker,
    required this.onAddStickerToDiary,
    required this.onLogout,
  });

  final GlobalKey<UserProfilePageState> profileKey;
  final List<SavedFlowerPhoto> savedFlowerPhotos;
  final VoidCallback onCreateSticker;
  final ValueChanged<GeneratedStickerAsset> onShareSticker;
  final ValueChanged<GeneratedStickerAsset> onAddStickerToDiary;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8faf7),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile'),
        leading: IconButton(
          onPressed: () => profileKey.currentState?.openLogoutPage(),
          tooltip: 'Log out',
          icon: const Icon(Icons.logout),
        ),
        actions: [
          IconButton(
            onPressed: onCreateSticker,
            tooltip: 'Create sticker',
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () => profileKey.currentState?.editProfileDetails(),
            tooltip: 'Edit profile details',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: UserProfilePage(
        key: profileKey,
        savedFlowerPhotos: savedFlowerPhotos,
        onCreateSticker: onCreateSticker,
        onShareSticker: onShareSticker,
        onAddStickerToDiary: onAddStickerToDiary,
        onLogout: onLogout,
      ),
    );
  }
}
