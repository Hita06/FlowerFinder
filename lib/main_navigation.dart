// This file manages the main navigation of the app, including the bottom
// navigation bar and the pages for Scanner, Maps, Search, Diary, and Profile.

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'flower_search_page.dart';
import 'pages/diary_page.dart';
import 'scanner_page.dart';
import 'sticker_creation.dart';
import 'sticker_storage.dart';
import 'user_profile.dart';
import 'widgets/bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, this.account});

  final UserAccount? account;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  static const diaryTab = 3;
  static const profileTab = 4;

  final _profileKey = GlobalKey<UserProfilePageState>();
  final List<SavedFlowerPhoto> _savedFlowerPhotos = [];
  final StickerStorage _stickerStorage = const StickerStorage();
  int currentIndex = 0;
  bool _stickersLoaded = false;

  UserAccount get _account =>
      widget.account ?? UserProfilePageState.defaultAccount;

  String get _accountStorageId => _account.email;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSavedStickers());
  }

  @override
  void didUpdateWidget(covariant MainNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.account?.email == widget.account?.email) return;
    setState(() {
      _savedFlowerPhotos.clear();
      _stickersLoaded = false;
    });
    unawaited(_loadSavedStickers());
  }

  Future<void> _loadSavedStickers() async {
    final savedStickers = await _stickerStorage.loadStickers(_accountStorageId);
    if (!mounted) return;
    setState(() {
      _savedFlowerPhotos
        ..clear()
        ..addAll(savedStickers);
      _stickersLoaded = true;
    });
  }

  Future<void> _persistSavedStickers() async {
    await _stickerStorage.saveStickers(_accountStorageId, _savedFlowerPhotos);
  }

  void _addSavedSticker(SavedFlowerPhoto photo) {
    setState(() {
      _savedFlowerPhotos.add(photo);
      currentIndex = profileTab;
    });
    unawaited(_persistSavedStickers());
  }

  void _deleteSavedSticker(SavedFlowerPhoto sticker) {
    setState(() {
      _savedFlowerPhotos.remove(sticker);
    });
    unawaited(_persistSavedStickers());
  }

  void _reorderSavedStickers(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final sticker = _savedFlowerPhotos.removeAt(oldIndex);
      _savedFlowerPhotos.insert(newIndex, sticker);
    });
    unawaited(_persistSavedStickers());
  }

  void onNavTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Future<void> _openStickerCreation() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => StickerCreationPage(
          photos: _savedFlowerPhotos,
          onSaved: (photo, stickerBytes, stickerId) {
            _addSavedSticker(
              photo.copyWith(
                stickerId: stickerId,
                stickerBytes: stickerBytes,
                createdAt: DateTime.now(),
              ),
            );
          },
        ),
      ),
    );
  }

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
            _addSavedSticker(
              photo.copyWith(
                stickerId: stickerId,
                stickerBytes: stickerBytes,
                createdAt: DateTime.now(),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleShareSticker(GeneratedStickerAsset sticker) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sticker is ready for sharing.')),
    );
  }

  void _handleAddStickerToDiary(GeneratedStickerAsset sticker) {
    setState(() {
      currentIndex = diaryTab;
    });

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
      ScannerPage(onAddSticker: _openStickerCreationFromScanner),
      const MapsPlaceholderPage(),
      const FlowerSearchPage(),
      const DiaryPage(),
      _ProfileTab(
        profileKey: _profileKey,
        account: _account,
        savedFlowerPhotos: _savedFlowerPhotos,
        stickersLoaded: _stickersLoaded,
        onCreateSticker: _openStickerCreation,
        onShareSticker: _handleShareSticker,
        onAddStickerToDiary: _handleAddStickerToDiary,
        onDeleteSticker: _deleteSavedSticker,
        onReorderStickers: _reorderSavedStickers,
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
    required this.account,
    required this.savedFlowerPhotos,
    required this.stickersLoaded,
    required this.onCreateSticker,
    required this.onShareSticker,
    required this.onAddStickerToDiary,
    required this.onDeleteSticker,
    required this.onReorderStickers,
    required this.onLogout,
  });

  final GlobalKey<UserProfilePageState> profileKey;
  final UserAccount account;
  final List<SavedFlowerPhoto> savedFlowerPhotos;
  final bool stickersLoaded;
  final VoidCallback onCreateSticker;
  final ValueChanged<GeneratedStickerAsset> onShareSticker;
  final ValueChanged<GeneratedStickerAsset> onAddStickerToDiary;
  final ValueChanged<SavedFlowerPhoto> onDeleteSticker;
  final void Function(int oldIndex, int newIndex) onReorderStickers;
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
      body: Stack(
        children: [
          UserProfilePage(
            key: profileKey,
            account: account,
            savedFlowerPhotos: savedFlowerPhotos,
            onCreateSticker: onCreateSticker,
            onShareSticker: onShareSticker,
            onAddStickerToDiary: onAddStickerToDiary,
            onDeleteSticker: onDeleteSticker,
            onReorderStickers: onReorderStickers,
            onLogout: onLogout,
          ),
          if (!stickersLoaded) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}

class MapsPlaceholderPage extends StatelessWidget {
  const MapsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maps')),
      body: const Center(child: Text('Maps coming soon')),
    );
  }
}
