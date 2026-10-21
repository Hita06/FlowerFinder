// This file manages the main navigation of the app, including the bottom
// navigation bar and the pages for Home, Search, Scanner, Diary, and Profile.

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'flower_search_page.dart';
import 'homepage.dart';
import 'diary_storage.dart';
import 'pages/diary_page.dart';
import 'profile_storage.dart';
import 'scanner_page.dart';
import 'sticker_creation.dart';
import 'sticker_storage.dart';
import 'user_profile.dart';
import 'widgets/bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({
    super.key,
    this.account,
    this.profileStorage,
    this.stickerStorage,
    this.diaryStorage,
  });

  final UserAccount? account;
  final ProfileStorage? profileStorage;
  final StickerStorage? stickerStorage;
  final DiaryStorage? diaryStorage;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Tab indexes used when navigating between the main sections.
  static const homeTab = 0;
  static const scannerTab = 2;
  static const diaryTab = 3;
  static const profileTab = 4;

  final _profileKey = GlobalKey<UserProfilePageState>();
  final List<SavedFlowerPhoto> _savedFlowerPhotos = [];
  late final StickerStorage _stickerStorage =
      widget.stickerStorage ?? StickerStorage();
  late final DiaryStorage _diaryStorage = widget.diaryStorage ?? DiaryStorage();
  late final ProfileStorage _profileStorage =
      widget.profileStorage ?? const ProfileStorage();
  EditableProfileDetails? _savedProfileDetails;
  ProfileCollectionSettings _savedCollectionSettings =
      const ProfileCollectionSettings();
  Future<void> _profileWriteQueue = Future<void>.value();
  Future<void> _collectionWriteQueue = Future<void>.value();
  Future<void> _stickerWriteQueue = Future<void>.value();
  Future<void> _pendingProfileWrite = Future<void>.value();
  Future<void> _pendingCollectionWrite = Future<void>.value();
  Future<void> _pendingStickerWrite = Future<void>.value();
  Timer? _stickerWriteDebounce;
  int currentIndex = homeTab;
  int _diaryStickerRequestId = 0;
  GeneratedStickerAsset? _diaryStickerToAdd;
  int _accountLoadGeneration = 0;
  bool _profileLoaded = false;
  bool _collectionLoaded = false;
  bool _stickersLoaded = false;

  UserAccount get _baseAccount =>
      widget.account ?? UserProfilePageState.defaultAccount;

  UserAccount get _account => _accountWithSavedProfile(_baseAccount);

  UserAccount _accountWithSavedProfile(UserAccount baseAccount) {
    final details = _savedProfileDetails;
    if (details == null) return baseAccount;
    return UserAccount(
      name: details.name ?? baseAccount.name,
      username: baseAccount.username,
      email: details.email ?? baseAccount.email,
      profileColorId: details.profileColorId ?? baseAccount.profileColorId,
    );
  }

  String get _accountStorageId => _baseAccount.email;

  @override
  void dispose() {
    _stickerWriteDebounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final generation = _accountLoadGeneration;
    unawaited(_loadSavedProfile(generation));
    unawaited(_loadSavedCollectionSettings(generation));
    unawaited(_loadSavedStickers(generation));
  }

  @override
  void didUpdateWidget(covariant MainNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.account?.email == widget.account?.email) return;
    if (_stickerWriteDebounce != null) {
      _stickerWriteDebounce!.cancel();
      _stickerWriteDebounce = null;
      _enqueueSavedStickerWrite(
        accountId:
            oldWidget.account?.email ??
            UserProfilePageState.defaultAccount.email,
      );
    }
    final generation = ++_accountLoadGeneration;
    setState(() {
      _savedFlowerPhotos.clear();
      _savedProfileDetails = null;
      _savedCollectionSettings = const ProfileCollectionSettings();
      _profileLoaded = false;
      _collectionLoaded = false;
      _stickersLoaded = false;
    });
    unawaited(_loadSavedProfile(generation));
    unawaited(_loadSavedCollectionSettings(generation));
    unawaited(_loadSavedStickers(generation));
  }

  Future<void> _loadSavedProfile(int generation) async {
    final accountId = _accountStorageId;
    final savedProfile = await _profileStorage.loadProfile(accountId);
    if (!mounted ||
        generation != _accountLoadGeneration ||
        accountId != _accountStorageId) {
      return;
    }
    setState(() {
      _savedProfileDetails = savedProfile;
      _profileLoaded = true;
    });
  }

  Future<void> _loadSavedCollectionSettings(int generation) async {
    final accountId = _accountStorageId;
    final settings = await _profileStorage.loadCollectionSettings(accountId);
    if (!mounted ||
        generation != _accountLoadGeneration ||
        accountId != _accountStorageId) {
      return;
    }
    setState(() {
      _savedCollectionSettings = settings;
      _collectionLoaded = true;
    });
  }

  void _persistSavedProfile(UserAccount account) {
    final details = EditableProfileDetails(
      name: account.name,
      email: account.email,
      profileColorId: account.profileColorId,
    );
    final accountId = _accountStorageId;
    setState(() {
      _savedProfileDetails = details;
    });
    final write = _profileWriteQueue.then(
      (_) => _profileStorage.saveProfile(accountId, details),
    );
    // Recover the queue after a failure; the original Future reports it below.
    _profileWriteQueue = write.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    _pendingProfileWrite = write;
    unawaited(
      write.then<void>(
        (_) {},
        onError: (Object error, StackTrace stackTrace) {
          _reportPersistenceError('profile', error, stackTrace);
        },
      ),
    );
  }

  Future<void> _loadSavedStickers(int generation) async {
    final accountId = _accountStorageId;
    final savedStickers = await _stickerStorage.loadStickers(accountId);
    if (!mounted ||
        generation != _accountLoadGeneration ||
        accountId != _accountStorageId) {
      return;
    }
    setState(() {
      _savedFlowerPhotos
        ..clear()
        ..addAll(savedStickers);
      _stickersLoaded = true;
    });
  }

  void _persistSavedCollectionSettings(ProfileCollectionSettings settings) {
    final accountId = _accountStorageId;
    setState(() => _savedCollectionSettings = settings);
    final write = _collectionWriteQueue.then(
      (_) => _profileStorage.saveCollectionSettings(accountId, settings),
    );
    _collectionWriteQueue = write.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    _pendingCollectionWrite = write;
    unawaited(
      write.then<void>(
        (_) {},
        onError: (Object error, StackTrace stackTrace) {
          _reportPersistenceError('profile collection', error, stackTrace);
        },
      ),
    );
  }

  void _persistSavedStickers({bool debounce = false}) {
    _stickerWriteDebounce?.cancel();
    if (debounce) {
      _stickerWriteDebounce = Timer(const Duration(milliseconds: 300), () {
        _stickerWriteDebounce = null;
        _enqueueSavedStickerWrite();
      });
      return;
    }
    _enqueueSavedStickerWrite();
  }

  void _enqueueSavedStickerWrite({String? accountId}) {
    final targetAccountId = accountId ?? _accountStorageId;
    final snapshot = List<SavedFlowerPhoto>.of(_savedFlowerPhotos);
    final write = _stickerWriteQueue.then(
      (_) => _stickerStorage.saveStickers(targetAccountId, snapshot),
    );
    // Recover the queue after a failure; the original Future reports it below.
    _stickerWriteQueue = write.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    _pendingStickerWrite = write;
    unawaited(
      write.then<void>(
        (_) {},
        onError: (Object error, StackTrace stackTrace) {
          _reportPersistenceError('stickers', error, stackTrace);
        },
      ),
    );
  }

  void _updateStickerBoardPlacement(
    SavedFlowerPhoto sticker,
    double positionX,
    double positionY,
    double scale,
  ) {
    final index = _savedStickerIndex(sticker);
    if (index < 0) return;
    setState(() {
      _savedFlowerPhotos[index] = sticker.copyWith(
        boardPositionX: positionX,
        boardPositionY: positionY,
        boardScale: scale,
      );
    });
    _persistSavedStickers(debounce: true);
  }

  int _savedStickerIndex(SavedFlowerPhoto sticker) {
    final directIndex = _savedFlowerPhotos.indexOf(sticker);
    if (directIndex >= 0) return directIndex;
    if (sticker.createdAt != null) {
      return _savedFlowerPhotos.indexWhere(
        (saved) =>
            saved.createdAt == sticker.createdAt &&
            saved.stickerId == sticker.stickerId,
      );
    }
    return _savedFlowerPhotos.indexWhere(
      (saved) => identical(saved.stickerBytes, sticker.stickerBytes),
    );
  }

  void _reportPersistenceError(
    String dataType,
    Object error,
    StackTrace stackTrace,
  ) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'account data persistence',
        context: ErrorDescription('while saving $dataType'),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not save your $dataType. Please try again.'),
      ),
    );
  }

  void _addSavedSticker(SavedFlowerPhoto photo) {
    setState(() {
      _savedFlowerPhotos.add(photo);
      currentIndex = profileTab;
    });
    _persistSavedStickers();
  }

  void _deleteSavedSticker(SavedFlowerPhoto sticker) {
    setState(() {
      _savedFlowerPhotos.remove(sticker);
    });
    _persistSavedStickers();
  }

  void _updateStickerGridSize(SavedFlowerPhoto sticker, String sizeId) {
    setState(() {
      final index = _savedFlowerPhotos.indexOf(sticker);
      if (index == -1) return;
      _savedFlowerPhotos[index] = sticker.copyWith(profileGridSizeId: sizeId);
    });
    _persistSavedStickers();
  }

  void _reorderSavedStickers(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final sticker = _savedFlowerPhotos.removeAt(oldIndex);
      _savedFlowerPhotos.insert(newIndex, sticker);
    });
    _persistSavedStickers();
  }

  // BOTTOM NAVIGATION

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
          onSaved: (photo, stickerBytes, stickerId, animationAsset) {
            _addSavedSticker(
              photo.copyWith(
                stickerId: stickerId,
                stickerBytes: stickerBytes,
                createdAt: DateTime.now(),
                animationAsset: animationAsset,
                clearAnimationAsset: animationAsset == null,
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
          onSaved: (photo, stickerBytes, stickerId, animationAsset) {
            _addSavedSticker(
              photo.copyWith(
                stickerId: stickerId,
                stickerBytes: stickerBytes,
                createdAt: DateTime.now(),
                animationAsset: animationAsset,
                clearAnimationAsset: animationAsset == null,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openStickerEditor(SavedFlowerPhoto sticker) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => StickerCreationPage(
          photos: [sticker],
          initialSticker: sticker,
          onSaved: (photo, stickerBytes, stickerId, animationAsset) {
            setState(() {
              final index = _savedFlowerPhotos.indexOf(sticker);
              if (index == -1) return;
              _savedFlowerPhotos[index] = photo.copyWith(
                stickerId: stickerId,
                stickerBytes: stickerBytes,
                createdAt: DateTime.now(),
                animationAsset: animationAsset,
                clearAnimationAsset: animationAsset == null,
              );
              currentIndex = profileTab;
            });
            _persistSavedStickers();
          },
        ),
      ),
    );
  }

  Future<void> _handleShareSticker(GeneratedStickerAsset sticker) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          title: 'FlowerFinder sticker',
          files: [XFile.fromData(sticker.stickerBytes, mimeType: 'image/png')],
          fileNameOverrides: ['flowerfinder_sticker.png'],
        ),
      );

      if (!mounted) return;
      final message = switch (result.status) {
        ShareResultStatus.success => 'Sticker shared successfully',
        ShareResultStatus.dismissed => 'Sharing cancelled',
        ShareResultStatus.unavailable =>
          'Sharing is not available on this device',
      };
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      debugPrint('Sticker sharing error: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Unable to share this sticker')),
        );
    }
  }

  void _handleAddStickerToDiary(GeneratedStickerAsset sticker) {
    setState(() {
      _diaryStickerToAdd = sticker;
      _diaryStickerRequestId += 1;
      currentIndex = diaryTab;
    });
  }

  // LOGOUT

  // Signs the current user out through Firebase Authentication.
  Future<void> _handleLogout() async {
    _stickerWriteDebounce?.cancel();
    _enqueueSavedStickerWrite();
    try {
      await Future.wait([
        _pendingProfileWrite,
        _pendingCollectionWrite,
        _pendingStickerWrite,
      ]);
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your changes could not be saved. Please try again.'),
        ),
      );
    }
  }

  // BUILD

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
      DiaryPage(
        accountId: _accountStorageId,
        storage: _diaryStorage,
        stickerToAdd: _diaryStickerToAdd,
        stickerRequestId: _diaryStickerRequestId,
      ),
      _ProfileTab(
        profileKey: _profileKey,
        account: _account,
        savedFlowerPhotos: _savedFlowerPhotos,
        collectionSettings: _savedCollectionSettings,
        accountDataLoaded:
            _profileLoaded && _collectionLoaded && _stickersLoaded,
        onCreateSticker: _openStickerCreation,
        onShareSticker: _handleShareSticker,
        onAddStickerToDiary: _handleAddStickerToDiary,
        onDeleteSticker: _deleteSavedSticker,
        onReorderStickers: _reorderSavedStickers,
        onStickerGridSizeChanged: _updateStickerGridSize,
        onStickerBoardPlacementChanged: _updateStickerBoardPlacement,
        onCollectionSettingsChanged: _persistSavedCollectionSettings,
        onEditSticker: (sticker) => unawaited(_openStickerEditor(sticker)),
        onProfileChanged: _persistSavedProfile,
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
    required this.account,
    required this.savedFlowerPhotos,
    required this.collectionSettings,
    required this.accountDataLoaded,
    required this.onCreateSticker,
    required this.onShareSticker,
    required this.onAddStickerToDiary,
    required this.onDeleteSticker,
    required this.onReorderStickers,
    required this.onStickerGridSizeChanged,
    required this.onStickerBoardPlacementChanged,
    required this.onCollectionSettingsChanged,
    required this.onEditSticker,
    required this.onProfileChanged,
    required this.onLogout,
  });

  final GlobalKey<UserProfilePageState> profileKey;
  final UserAccount account;
  final List<SavedFlowerPhoto> savedFlowerPhotos;
  final ProfileCollectionSettings collectionSettings;
  final bool accountDataLoaded;
  final VoidCallback onCreateSticker;
  final ValueChanged<GeneratedStickerAsset> onShareSticker;
  final ValueChanged<GeneratedStickerAsset> onAddStickerToDiary;
  final ValueChanged<SavedFlowerPhoto> onDeleteSticker;
  final void Function(int oldIndex, int newIndex) onReorderStickers;
  final void Function(SavedFlowerPhoto sticker, String sizeId)
  onStickerGridSizeChanged;
  final void Function(
    SavedFlowerPhoto sticker,
    double positionX,
    double positionY,
    double scale,
  )
  onStickerBoardPlacementChanged;
  final ValueChanged<ProfileCollectionSettings> onCollectionSettingsChanged;
  final ValueChanged<SavedFlowerPhoto> onEditSticker;
  final ValueChanged<UserAccount> onProfileChanged;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8faf7),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile'),
        leading: IconButton(
          onPressed: !accountDataLoaded
              ? null
              : () => profileKey.currentState?.openLogoutPage(),
          tooltip: 'Log out',
          icon: const Icon(Icons.logout),
        ),
        actions: [
          IconButton(
            onPressed: accountDataLoaded ? onCreateSticker : null,
            tooltip: 'Create sticker',
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: !accountDataLoaded
                ? null
                : () => profileKey.currentState?.editProfileDetails(),
            tooltip: 'Edit profile details',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: !accountDataLoaded,
            child: UserProfilePage(
              key: profileKey,
              account: account,
              savedFlowerPhotos: savedFlowerPhotos,
              collectionSettings: collectionSettings,
              onCreateSticker: onCreateSticker,
              onShareSticker: onShareSticker,
              onAddStickerToDiary: onAddStickerToDiary,
              onDeleteSticker: onDeleteSticker,
              onReorderStickers: onReorderStickers,
              onStickerGridSizeChanged: onStickerGridSizeChanged,
              onStickerBoardPlacementChanged: onStickerBoardPlacementChanged,
              onCollectionSettingsChanged: onCollectionSettingsChanged,
              onEditSticker: onEditSticker,
              onProfileChanged: onProfileChanged,
              onLogout: onLogout,
            ),
          ),
          if (!accountDataLoaded) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
