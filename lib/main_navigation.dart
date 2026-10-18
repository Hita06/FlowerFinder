// This file manages the main navigation of the app, including the bottom
// navigation bar and the pages for Home, Search, Scanner, Diary, and Profile.

// Manages Home, Search, Scanner, Diary, and Profile navigation.

import 'dart:io';

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
  // Search remains at index 1 in the pages list.
  static const homeTab = 0;
  static const scannerTab = 2;
  static const diaryTab = 3;
  static const profileTab = 4;

  final _profileKey = GlobalKey<UserProfilePageState>();

  final List<SavedFlowerPhoto> _savedFlowerPhotos = [];

  int currentIndex = homeTab;

  void onNavTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _openScanner() {
    setState(() {
      currentIndex = scannerTab;
    });
  }

  void _openDiary() {
    setState(() {
      currentIndex = diaryTab;
    });
  }

  // Opens sticker creation from Profile.
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

  // Opens sticker creation using the scanned or selected photo.
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

  // Existing sticker sharing handoff.
  void _handleShareSticker(GeneratedStickerAsset sticker) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sticker is ready for sharing.')),
    );
  }

  // Existing sticker-to-diary handoff.
  void _handleAddStickerToDiary(GeneratedStickerAsset sticker) {
    _openDiary();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sticker selected for Diary integration.')),
    );
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
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
