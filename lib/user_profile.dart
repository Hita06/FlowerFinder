import 'dart:typed_data';

import 'package:flutter/material.dart';

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
  });

  final UserAccount? account;
  final List<SavedFlowerPhoto> savedFlowerPhotos;
  final VoidCallback? onCreateSticker;
  final ValueChanged<SavedFlowerPhoto>? onStickerSelected;
  final ValueChanged<GeneratedStickerAsset>? onShareSticker;
  final ValueChanged<GeneratedStickerAsset>? onAddStickerToDiary;

  @override
  State<UserProfilePage> createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  late final UserAccount _account = _copyAccount(
    widget.account ?? _defaultAccount,
  );
  static final UserAccount _defaultAccount = UserAccount(
    name: 'New Flower Finder User',
    username: 'flower_finder_user',
    email: 'user@example.com',
  );
  SavedFlowerPhoto? _selectedSticker;

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
        ..email = account.email;
    });
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
  }

  Future<void> editProfileDetails() => _editAccount();

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
            onCreateSticker: widget.onCreateSticker,
            onShareSticker: widget.onShareSticker,
            onAddStickerToDiary: widget.onAddStickerToDiary,
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
    required this.selectedSticker,
    required this.profileColor,
    required this.onCreateSticker,
    required this.onStickerSelected,
    required this.onShareSticker,
    required this.onAddStickerToDiary,
  });

  final List<SavedFlowerPhoto> photos;
  final SavedFlowerPhoto? selectedSticker;
  final ProfileColorChoice profileColor;
  final VoidCallback? onCreateSticker;
  final ValueChanged<SavedFlowerPhoto> onStickerSelected;
  final ValueChanged<GeneratedStickerAsset>? onShareSticker;
  final ValueChanged<GeneratedStickerAsset>? onAddStickerToDiary;

  @override
  Widget build(BuildContext context) {
    final stickers = photos
        .where((photo) => photo.stickerBytes != null)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Stickers',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        if (stickers.isEmpty)
          _AddStickerTile(onTap: onCreateSticker, profileColor: profileColor)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: stickers.length + 1,
            itemBuilder: (context, index) {
              if (index == stickers.length) {
                return _AddStickerTile(
                  onTap: onCreateSticker,
                  profileColor: profileColor,
                );
              }
              final sticker = stickers[index];
              return _StickerTile(
                key: ValueKey('saved-sticker-${sticker.stickerId ?? index}'),
                sticker: sticker,
                selected: identical(sticker, selectedSticker),
                profileColor: profileColor,
                onTap: () => onStickerSelected(sticker),
              );
            },
          ),
      ],
    );
  }
}

class _StickerActionDialog extends StatelessWidget {
  const _StickerActionDialog({
    required this.asset,
    required this.profileColor,
    required this.onShareSticker,
    required this.onAddStickerToDiary,
  });

  final GeneratedStickerAsset asset;
  final ProfileColorChoice profileColor;
  final ValueChanged<GeneratedStickerAsset>? onShareSticker;
  final ValueChanged<GeneratedStickerAsset>? onAddStickerToDiary;

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

class _StickerTile extends StatelessWidget {
  const _StickerTile({
    super.key,
    required this.sticker,
    required this.selected,
    required this.profileColor,
    required this.onTap,
  });

  final SavedFlowerPhoto sticker;
  final bool selected;
  final ProfileColorChoice profileColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Ink(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: profileColor.softColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? profileColor.color : Colors.transparent,
          width: 3,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Image.memory(sticker.stickerBytes!, fit: BoxFit.contain),
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
