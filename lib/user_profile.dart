import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserAccount {
  UserAccount({
    required this.name,
    required this.username,
    required this.email,
    this.profileColorId = ProfilePalette.defaultColorId,
  });

  String name;
  String username;
  String email;
  String profileColorId;
}

class ProfilePalette {
  const ProfilePalette._();

  static const defaultColorId = 'leaf';

  static const choices = <ProfileColorChoice>[
    ProfileColorChoice(
      id: defaultColorId,
      label: 'Leaf',
      color: Color(0xff2f6b4f),
      softColor: Color(0xffeef3ed),
      avatarColor: Color(0xffdce9d8),
    ),
    ProfileColorChoice(
      id: 'rose',
      label: 'Rose',
      color: Color(0xff9b3f5f),
      softColor: Color(0xffffeef4),
      avatarColor: Color(0xffffd9e6),
    ),
    ProfileColorChoice(
      id: 'sky',
      label: 'Sky',
      color: Color(0xff2f5f8f),
      softColor: Color(0xffedf4fb),
      avatarColor: Color(0xffd7e8f8),
    ),
    ProfileColorChoice(
      id: 'gold',
      label: 'Gold',
      color: Color(0xff7a5a12),
      softColor: Color(0xfffff7df),
      avatarColor: Color(0xffffedb3),
    ),
  ];

  static ProfileColorChoice byId(String id) => choices.firstWhere(
    (choice) => choice.id == id,
    orElse: () => choices.first,
  );
}

class ProfileColorChoice {
  const ProfileColorChoice({
    required this.id,
    required this.label,
    required this.color,
    required this.softColor,
    required this.avatarColor,
  });

  final String id;
  final String label;
  final Color color;
  final Color softColor;
  final Color avatarColor;
}

class SavedFlowerPhoto {
  const SavedFlowerPhoto({
    required this.image,
    this.label,
    this.stickerId,
    this.stickerBytes,
    this.createdAt,
  });

  final ImageProvider image;
  final String? label;
  final String? stickerId;
  final Uint8List? stickerBytes;
  final DateTime? createdAt;

  SavedFlowerPhoto copyWith({
    String? label,
    String? stickerId,
    Uint8List? stickerBytes,
    DateTime? createdAt,
  }) {
    return SavedFlowerPhoto(
      image: image,
      label: label ?? this.label,
      stickerId: stickerId ?? this.stickerId,
      stickerBytes: stickerBytes ?? this.stickerBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class GeneratedStickerAsset {
  const GeneratedStickerAsset({
    required this.stickerBytes,
    this.stickerId,
    this.createdAt,
    this.label,
  });

  final Uint8List stickerBytes;
  final String? stickerId;
  final DateTime? createdAt;
  final String? label;

  static GeneratedStickerAsset? fromSavedFlowerPhoto(SavedFlowerPhoto photo) {
    final stickerBytes = photo.stickerBytes;
    if (stickerBytes == null) return null;
    return GeneratedStickerAsset(
      stickerBytes: stickerBytes,
      stickerId: photo.stickerId,
      createdAt: photo.createdAt,
      label: photo.label,
    );
  }
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({
    super.key,
    this.account,
    this.savedFlowerPhotos = const [],
    this.onCreateSticker,
    this.onStickerSelected,
    this.onShareSticker,
    this.onAddStickerToDiary,
    this.onDeleteSticker,
    this.onReorderStickers,
    this.onEditSticker,
    this.onProfileChanged,
    this.onLogout,
    this.pickProfileImage,
  });

  final UserAccount? account;
  final List<SavedFlowerPhoto> savedFlowerPhotos;
  final VoidCallback? onCreateSticker;
  final ValueChanged<SavedFlowerPhoto>? onStickerSelected;
  final ValueChanged<GeneratedStickerAsset>? onShareSticker;
  final ValueChanged<GeneratedStickerAsset>? onAddStickerToDiary;
  final ValueChanged<SavedFlowerPhoto>? onDeleteSticker;
  final void Function(int oldIndex, int newIndex)? onReorderStickers;
  final ValueChanged<SavedFlowerPhoto>? onEditSticker;
  final ValueChanged<UserAccount>? onProfileChanged;
  final VoidCallback? onLogout;
  final Future<Uint8List?> Function()? pickProfileImage;

  @override
  State<UserProfilePage> createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  late final UserAccount _account = _copyAccount(
    widget.account ?? defaultAccount,
  );
  static final UserAccount defaultAccount = UserAccount(
    name: 'New Flower Finder User',
    username: 'flower_finder_user',
    email: 'user@example.com',
  );
  SavedFlowerPhoto? _selectedSticker;
  bool _isManagingStickers = false;
  _StickerDisplaySize _stickerDisplaySize = _StickerDisplaySize.smallGrid;
  final List<_UploadedProfilePhoto> _uploadedProfilePhotos = [];

  static UserAccount _copyAccount(UserAccount account) {
    return UserAccount(
      name: account.name,
      username: account.username,
      email: account.email,
      profileColorId: account.profileColorId,
    );
  }

  @override
  void didUpdateWidget(covariant UserProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final account = widget.account;
    if (account == null || identical(account, oldWidget.account)) return;
    setState(() {
      _account
        ..name = account.name
        ..username = account.username
        ..email = account.email
        ..profileColorId = account.profileColorId;
    });
  }

  Future<void> _pickProfilePhoto() async {
    Uint8List? bytes;
    if (widget.pickProfileImage != null) {
      bytes = await widget.pickProfileImage!();
    } else {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        requestFullMetadata: false,
      );
      bytes = await file?.readAsBytes();
    }
    if (!mounted || bytes == null) return;
    setState(() {
      _uploadedProfilePhotos.add(
        _UploadedProfilePhoto(
          imageBytes: Uint8List.fromList(bytes!),
          label: 'Gallery photo',
        ),
      );
    });
  }

  Future<void> _showAddStickerOptions(ProfileColorChoice profileColor) async {
    final action = await showModalBottomSheet<_StickerAddAction>(
      context: context,
      builder: (context) => _AddStickerOptionsSheet(profileColor: profileColor),
    );
    if (action == null) return;
    switch (action) {
      case _StickerAddAction.createSticker:
        widget.onCreateSticker?.call();
      case _StickerAddAction.uploadPhoto:
        await _pickProfilePhoto();
    }
  }

  Future<void> _editAccount() async {
    final hasLoginAccount = widget.account != null;
    final updatedAccount = await showModalBottomSheet<UserAccount>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditAccountSheet(
        account: _account,
        usernameReadOnly: hasLoginAccount,
      ),
    );
    if (updatedAccount == null) return;
    setState(() {
      _account
        ..name = updatedAccount.name
        ..username = hasLoginAccount
            ? widget.account!.username
            : updatedAccount.username
        ..email = updatedAccount.email
        ..profileColorId = updatedAccount.profileColorId;
    });
    widget.onProfileChanged?.call(_copyAccount(_account));
  }

  Future<void> editProfileDetails() => _editAccount();

  Future<void> openLogoutPage() async {
    final profileColor = ProfilePalette.byId(_account.profileColorId);
    final shouldLogout = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) =>
            LogoutPage(accountName: _account.name, profileColor: profileColor),
      ),
    );

    if (shouldLogout == true) {
      widget.onLogout?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileColor = ProfilePalette.byId(_account.profileColorId);
    final stickerCount = widget.savedFlowerPhotos
        .where((photo) => photo.stickerBytes != null)
        .length;

    return Material(
      color: const Color(0xfff8faf7),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: profileColor.avatarColor,
                child: Icon(
                  Icons.person_outline,
                  color: profileColor.color,
                  size: 48,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ProfileStat(value: '$stickerCount', label: 'Stickers'),
                    const _ProfileStat(value: '0', label: 'Identified'),
                    const _ProfileStat(value: '0', label: 'Collections'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _account.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '@${_account.username}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            _account.email,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 28),
          _StickersSection(
            photos: widget.savedFlowerPhotos,
            selectedSticker: _selectedSticker,
            profileColor: profileColor,
            uploadedPhotos: _uploadedProfilePhotos,
            displaySize: _stickerDisplaySize,
            onDisplaySizeChanged: (size) {
              setState(() => _stickerDisplaySize = size);
            },
            onCreateSticker: widget.onCreateSticker,
            onUploadPhoto: _pickProfilePhoto,
            onShowAddOptions: () => _showAddStickerOptions(profileColor),
            onShareSticker: widget.onShareSticker,
            onAddStickerToDiary: widget.onAddStickerToDiary,
            onDeleteSticker: widget.onDeleteSticker == null
                ? null
                : (sticker) => _confirmDeleteSticker(sticker, profileColor),
            onReorderStickers: widget.onReorderStickers,
            isManaging: _isManagingStickers,
            onToggleManaging: () {
              setState(() => _isManagingStickers = !_isManagingStickers);
            },
            onStickerSelected: (sticker) {
              setState(() => _selectedSticker = sticker);
              widget.onStickerSelected?.call(sticker);
              _showStickerActions(sticker, profileColor);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showStickerActions(
    SavedFlowerPhoto sticker,
    ProfileColorChoice profileColor,
  ) async {
    final asset = GeneratedStickerAsset.fromSavedFlowerPhoto(sticker);
    if (asset == null) return;

    await showDialog<void>(
      context: context,
      builder: (context) => _StickerActionDialog(
        asset: asset,
        profileColor: profileColor,
        onShareSticker: widget.onShareSticker,
        onAddStickerToDiary: widget.onAddStickerToDiary,
        onEditSticker: widget.onEditSticker == null
            ? null
            : () => widget.onEditSticker!(sticker),
      ),
    );
  }

  Future<void> _confirmDeleteSticker(
    SavedFlowerPhoto sticker,
    ProfileColorChoice profileColor,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete sticker?'),
        content: const Text(
          'This removes the saved sticker from your profile collection.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;
    if (_selectedSticker == sticker) {
      setState(() => _selectedSticker = null);
    }
    widget.onDeleteSticker?.call(sticker);
  }
}

class LogoutPage extends StatelessWidget {
  const LogoutPage({
    super.key,
    required this.accountName,
    required this.profileColor,
  });

  final String accountName;
  final ProfileColorChoice profileColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8faf7),
      appBar: AppBar(centerTitle: true, title: const Text('Log out')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: profileColor.avatarColor,
                      child: Icon(
                        Icons.logout,
                        color: profileColor.color,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Log out of FlowerFinder?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You are signed in as $accountName. Your saved profile and stickers stay ready for the next login.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(context, true),
                        icon: const Icon(Icons.logout),
                        label: const Text('Log out'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _StickerDisplaySize { smallGrid, largeSquare }

enum _StickerAddAction { createSticker, uploadPhoto }

class _UploadedProfilePhoto {
  const _UploadedProfilePhoto({required this.imageBytes, required this.label});

  final Uint8List imageBytes;
  final String label;
}

class _StickerCollectionItem {
  const _StickerCollectionItem.sticker(this.sticker)
    : uploadedPhoto = null,
      isSticker = true;

  const _StickerCollectionItem.photo(this.uploadedPhoto)
    : sticker = null,
      isSticker = false;

  final SavedFlowerPhoto? sticker;
  final _UploadedProfilePhoto? uploadedPhoto;
  final bool isSticker;

  Uint8List get imageBytes =>
      isSticker ? sticker!.stickerBytes! : uploadedPhoto!.imageBytes;

  String get label =>
      isSticker ? sticker!.label ?? 'Saved sticker' : uploadedPhoto!.label;
}

class _AddStickerOptionsSheet extends StatelessWidget {
  const _AddStickerOptionsSheet({required this.profileColor});

  final ProfileColorChoice profileColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add to Your Stickers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: profileColor.softColor,
                child: Icon(Icons.auto_fix_high, color: profileColor.color),
              ),
              title: const Text('Create sticker'),
              subtitle: const Text('Make a new generated flower sticker'),
              onTap: () =>
                  Navigator.pop(context, _StickerAddAction.createSticker),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: profileColor.softColor,
                child: Icon(
                  Icons.photo_library_outlined,
                  color: profileColor.color,
                ),
              ),
              title: const Text('Upload photo'),
              subtitle: const Text('Add a photo from your gallery'),
              onTap: () =>
                  Navigator.pop(context, _StickerAddAction.uploadPhoto),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
    ],
  );
}

class _StickersSection extends StatelessWidget {
  const _StickersSection({
    required this.photos,
    required this.uploadedPhotos,
    required this.selectedSticker,
    required this.profileColor,
    required this.displaySize,
    required this.onDisplaySizeChanged,
    required this.onCreateSticker,
    required this.onUploadPhoto,
    required this.onShowAddOptions,
    required this.onStickerSelected,
    required this.onShareSticker,
    required this.onAddStickerToDiary,
    required this.onDeleteSticker,
    required this.onReorderStickers,
    required this.isManaging,
    required this.onToggleManaging,
  });

  final List<SavedFlowerPhoto> photos;
  final List<_UploadedProfilePhoto> uploadedPhotos;
  final SavedFlowerPhoto? selectedSticker;
  final ProfileColorChoice profileColor;
  final _StickerDisplaySize displaySize;
  final ValueChanged<_StickerDisplaySize> onDisplaySizeChanged;
  final VoidCallback? onCreateSticker;
  final VoidCallback onUploadPhoto;
  final VoidCallback onShowAddOptions;
  final ValueChanged<SavedFlowerPhoto> onStickerSelected;
  final ValueChanged<GeneratedStickerAsset>? onShareSticker;
  final ValueChanged<GeneratedStickerAsset>? onAddStickerToDiary;
  final ValueChanged<SavedFlowerPhoto>? onDeleteSticker;
  final void Function(int oldIndex, int newIndex)? onReorderStickers;
  final bool isManaging;
  final VoidCallback onToggleManaging;

  @override
  Widget build(BuildContext context) {
    final stickers = photos
        .where((photo) => photo.stickerBytes != null)
        .toList();
    final collectionItems = <_StickerCollectionItem>[
      ...stickers.map(_StickerCollectionItem.sticker),
      ...uploadedPhotos.map(_StickerCollectionItem.photo),
    ];
    final canManage =
        stickers.isNotEmpty &&
        (onDeleteSticker != null || onReorderStickers != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Your Stickers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            TextButton.icon(
              onPressed: onUploadPhoto,
              icon: Icon(
                Icons.photo_library_outlined,
                color: profileColor.color,
              ),
              label: const Text('Upload Photo'),
            ),
            if (canManage)
              TextButton.icon(
                onPressed: onToggleManaging,
                icon: Icon(
                  isManaging ? Icons.check : Icons.tune,
                  color: profileColor.color,
                ),
                label: Text(isManaging ? 'Done' : 'Manage'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Display size:',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            ChoiceChip(
              label: const Text('Small grid'),
              selected: displaySize == _StickerDisplaySize.smallGrid,
              onSelected: (_) =>
                  onDisplaySizeChanged(_StickerDisplaySize.smallGrid),
            ),
            ChoiceChip(
              label: const Text('Large square'),
              selected: displaySize == _StickerDisplaySize.largeSquare,
              onSelected: (_) =>
                  onDisplaySizeChanged(_StickerDisplaySize.largeSquare),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isManaging && stickers.isNotEmpty)
          Text(
            'Drag to rearrange your saved stickers, or delete stickers you no longer want.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          )
        else
          Text(
            displaySize == _StickerDisplaySize.largeSquare
                ? 'Show up to four stickers or uploaded photos inside one large square.'
                : 'Show saved stickers and uploaded photos as small squares.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        const SizedBox(height: 14),
        if (isManaging && stickers.isNotEmpty)
          _ManageStickersList(
            stickers: stickers,
            profileColor: profileColor,
            onDeleteSticker: onDeleteSticker,
            onReorderStickers: onReorderStickers,
          )
        else if (displaySize == _StickerDisplaySize.largeSquare)
          _LargeStickerSquare(
            items: collectionItems,
            selectedSticker: selectedSticker,
            profileColor: profileColor,
            onStickerSelected: onStickerSelected,
            onAddTap: onShowAddOptions,
          )
        else
          _SmallStickerGrid(
            items: collectionItems,
            selectedSticker: selectedSticker,
            profileColor: profileColor,
            onStickerSelected: onStickerSelected,
            onAddTap: onShowAddOptions,
          ),
      ],
    );
  }
}

class _SmallStickerGrid extends StatelessWidget {
  const _SmallStickerGrid({
    required this.items,
    required this.selectedSticker,
    required this.profileColor,
    required this.onStickerSelected,
    required this.onAddTap,
  });

  final List<_StickerCollectionItem> items;
  final SavedFlowerPhoto? selectedSticker;
  final ProfileColorChoice profileColor;
  final ValueChanged<SavedFlowerPhoto> onStickerSelected;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _AddStickerTile(onTap: onAddTap, profileColor: profileColor);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return _AddStickerTile(onTap: onAddTap, profileColor: profileColor);
        }
        final item = items[index];
        return _CollectionTile(
          key: ValueKey(_collectionItemKey(item, index)),
          item: item,
          selected:
              item.sticker != null && identical(item.sticker, selectedSticker),
          profileColor: profileColor,
          onTap: item.sticker == null
              ? null
              : () => onStickerSelected(item.sticker!),
        );
      },
    );
  }
}

class _LargeStickerSquare extends StatelessWidget {
  const _LargeStickerSquare({
    required this.items,
    required this.selectedSticker,
    required this.profileColor,
    required this.onStickerSelected,
    required this.onAddTap,
  });

  final List<_StickerCollectionItem> items;
  final SavedFlowerPhoto? selectedSticker;
  final ProfileColorChoice profileColor;
  final ValueChanged<SavedFlowerPhoto> onStickerSelected;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: profileColor.softColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: profileColor.color.withValues(alpha: 0.16),
                width: 2,
              ),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                if (index >= visibleItems.length) {
                  return _LargeSquarePlaceholder(
                    profileColor: profileColor,
                    onTap: onAddTap,
                  );
                }
                final item = visibleItems[index];
                return _CollectionTile(
                  key: ValueKey(_collectionItemKey(item, index)),
                  item: item,
                  selected:
                      item.sticker != null &&
                      identical(item.sticker, selectedSticker),
                  profileColor: profileColor,
                  onTap: item.sticker == null
                      ? null
                      : () => onStickerSelected(item.sticker!),
                );
              },
            ),
          ),
        ),
        if (items.length > 4) ...[
          const SizedBox(height: 8),
          Text(
            '+${items.length - 4} more shown in Small grid',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _LargeSquarePlaceholder extends StatelessWidget {
  const _LargeSquarePlaceholder({
    required this.profileColor,
    required this.onTap,
  });

  final ProfileColorChoice profileColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Ink(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: profileColor.color.withValues(alpha: 0.14)),
      ),
      child: Icon(Icons.add, color: profileColor.color, size: 30),
    ),
  );
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    super.key,
    required this.item,
    required this.selected,
    required this.profileColor,
    required this.onTap,
  });

  final _StickerCollectionItem item;
  final bool selected;
  final ProfileColorChoice profileColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Ink(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: item.isSticker
            ? profileColor.softColor
            : Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? profileColor.color : Colors.transparent,
          width: 3,
        ),
      ),
      child: Stack(
        children: [
          Center(child: Image.memory(item.imageBytes, fit: BoxFit.contain)),
          if (!item.isSticker)
            Align(
              alignment: Alignment.topLeft,
              child: Icon(
                Icons.photo_library_outlined,
                color: profileColor.color,
                size: 18,
              ),
            ),
          if (selected)
            Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.check_circle, color: profileColor.color),
            ),
        ],
      ),
    ),
  );
}

String _collectionItemKey(_StickerCollectionItem item, int index) {
  if (item.sticker != null) {
    return 'saved-sticker-${item.sticker!.stickerId ?? index.toString()}';
  }
  return 'uploaded-photo-$index';
}

class _ManageStickersList extends StatelessWidget {
  const _ManageStickersList({
    required this.stickers,
    required this.profileColor,
    required this.onDeleteSticker,
    required this.onReorderStickers,
  });

  final List<SavedFlowerPhoto> stickers;
  final ProfileColorChoice profileColor;
  final ValueChanged<SavedFlowerPhoto>? onDeleteSticker;
  final void Function(int oldIndex, int newIndex)? onReorderStickers;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: stickers.length,
      onReorderItem: onReorderStickers ?? (_, _) {},
      itemBuilder: (context, index) {
        final sticker = stickers[index];
        return Card(
          key: ObjectKey(sticker),
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: profileColor.softColor, width: 2),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: Container(
              width: 54,
              height: 54,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: profileColor.softColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.memory(sticker.stickerBytes!, fit: BoxFit.contain),
            ),
            title: Text(sticker.label ?? 'Saved sticker'),
            subtitle: Text(
              sticker.createdAt == null
                  ? 'Generated sticker'
                  : 'Saved ${_formatStickerDate(sticker.createdAt!)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Delete sticker',
                  onPressed: onDeleteSticker == null
                      ? null
                      : () => onDeleteSticker!(sticker),
                  icon: const Icon(Icons.delete_outline),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.drag_handle, color: profileColor.color),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _formatStickerDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _StickerActionDialog extends StatelessWidget {
  const _StickerActionDialog({
    required this.asset,
    required this.profileColor,
    required this.onShareSticker,
    required this.onAddStickerToDiary,
    required this.onEditSticker,
  });

  final GeneratedStickerAsset asset;
  final ProfileColorChoice profileColor;
  final ValueChanged<GeneratedStickerAsset>? onShareSticker;
  final ValueChanged<GeneratedStickerAsset>? onAddStickerToDiary;
  final VoidCallback? onEditSticker;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Your Sticker'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: profileColor.softColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Image.memory(asset.stickerBytes, fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          const Text(
            'What would you like to do with this sticker?',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        OutlinedButton.icon(
          onPressed: onEditSticker == null
              ? null
              : () {
                  Navigator.pop(context);
                  onEditSticker!();
                },
          icon: Icon(Icons.edit_outlined, color: profileColor.color),
          label: const Text('Edit Sticker'),
        ),
        OutlinedButton.icon(
          onPressed: onAddStickerToDiary == null
              ? null
              : () {
                  onAddStickerToDiary!(asset);
                  Navigator.pop(context);
                },
          icon: Icon(Icons.menu_book_outlined, color: profileColor.color),
          label: const Text('Add to Diary'),
        ),
        FilledButton.icon(
          onPressed: onShareSticker == null
              ? null
              : () {
                  onShareSticker!(asset);
                  Navigator.pop(context);
                },
          icon: const Icon(Icons.ios_share),
          label: const Text('Share Sticker'),
        ),
      ],
    );
  }
}

class _AddStickerTile extends StatelessWidget {
  const _AddStickerTile({this.onTap, required this.profileColor});

  final VoidCallback? onTap;
  final ProfileColorChoice profileColor;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Ink(
      decoration: BoxDecoration(
        color: profileColor.softColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, color: profileColor.color, size: 32),
          const SizedBox(height: 4),
          const Text('Add Sticker'),
        ],
      ),
    ),
  );
}

class _EditAccountSheet extends StatefulWidget {
  const _EditAccountSheet({
    required this.account,
    required this.usernameReadOnly,
  });

  final UserAccount account;
  final bool usernameReadOnly;

  @override
  State<_EditAccountSheet> createState() => _EditAccountSheetState();
}

class _EditAccountSheetState extends State<_EditAccountSheet> {
  late final _nameController = TextEditingController(text: widget.account.name);
  late final _usernameController = TextEditingController(
    text: widget.account.username,
  );
  late final _emailController = TextEditingController(
    text: widget.account.email,
  );
  late String _selectedColorId = widget.account.profileColorId;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: Material(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change profile details',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameController,
              enabled: !widget.usernameReadOnly,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.alternate_email),
                helperText: 'Connected from login when available',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Profile colour',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ProfilePalette.choices.map((choice) {
                final selected = choice.id == _selectedColorId;
                return ChoiceChip(
                  selected: selected,
                  label: Text(choice.label),
                  avatar: CircleAvatar(backgroundColor: choice.color),
                  selectedColor: choice.softColor,
                  checkmarkColor: choice.color,
                  labelStyle: TextStyle(
                    color: selected ? choice.color : Colors.black87,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: selected ? choice.color : Colors.grey.shade300,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedColorId = choice.id);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _save() {
    if (_nameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      return;
    }
    Navigator.pop(
      context,
      UserAccount(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        profileColorId: _selectedColorId,
      ),
    );
  }
}
