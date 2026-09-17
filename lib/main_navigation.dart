import 'package:flutter/material.dart';

import 'scanner_page.dart';
import 'sticker_creation.dart';
import 'theme.dart';
import 'user_profile.dart';
import 'widgets/bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, this.enableCamera = true});

  final bool enableCamera;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  static const profileTab = 3;

  final _scannerKey = GlobalKey();
  final _profileKey = GlobalKey<UserProfilePageState>();
  final List<SavedFlowerPhoto> _savedFlowerPhotos = [];
  int currentIndex = 0;

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
            });
          },
        ),
      ),
    );
  }

  void _saveScannerSticker(SavedFlowerPhoto photo) {
    setState(() {
      _savedFlowerPhotos.add(photo);
      currentIndex = profileTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ScannerPage(
        key: _scannerKey,
        enableCamera: widget.enableCamera,
        onStickerSaved: _saveScannerSticker,
      ),
      const _ComingSoonPage(
        icon: Icons.location_on_outlined,
        title: 'Map',
        description: 'Connect the flower map page here.',
      ),
      const _ComingSoonPage(
        icon: Icons.menu_book_outlined,
        title: 'Diary',
        description: 'Connect the diary page here.',
      ),
      _ProfileTab(
        profileKey: _profileKey,
        savedFlowerPhotos: _savedFlowerPhotos,
        onCreateSticker: _openStickerCreation,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: FlowerBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.profileKey,
    required this.savedFlowerPhotos,
    required this.onCreateSticker,
  });

  final GlobalKey<UserProfilePageState> profileKey;
  final List<SavedFlowerPhoto> savedFlowerPhotos;
  final VoidCallback onCreateSticker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8faf7),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile'),
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
      ),
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AppColors.darkGreen),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
