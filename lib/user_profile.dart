import 'dart:typed_data';

import 'package:flutter/material.dart';

class UserAccount {
  UserAccount({required this.name, required this.username, required this.email});

  String name;
  String username;
  String email;
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

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({
    super.key,
    this.savedFlowerPhotos = const [],
    this.onCreateSticker,
    this.onStickerSelected,
  });

  final List<SavedFlowerPhoto> savedFlowerPhotos;
  final VoidCallback? onCreateSticker;
  final ValueChanged<SavedFlowerPhoto>? onStickerSelected;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserAccount _account = UserAccount(
    name: 'New Flower Finder User',
    username: 'flower_finder_user',
    email: 'user@example.com',
  );
  SavedFlowerPhoto? _selectedSticker;

  Future<void> _editAccount() async {
    final updatedAccount = await showModalBottomSheet<UserAccount>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditAccountSheet(account: _account),
    );
    if (updatedAccount == null) return;
    setState(() {
      _account
        ..name = updatedAccount.name
        ..username = updatedAccount.username
        ..email = updatedAccount.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stickerCount = widget.savedFlowerPhotos
        .where((photo) => photo.stickerBytes != null)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xfff8faf7),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile'),
        backgroundColor: const Color(0xff2f6b4f),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: widget.onCreateSticker,
          tooltip: 'Create sticker',
          icon: const Icon(Icons.add),
        ),
        actions: [
          IconButton(
            onPressed: _editAccount,
            tooltip: 'Edit profile details',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xffdce9d8),
                child: Icon(Icons.person_outline, color: Color(0xff2f6b4f), size: 48),
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
          Text(_account.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('@${_account.username}', style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text(_account.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 28),
          _StickersSection(
            photos: widget.savedFlowerPhotos,
            selectedSticker: _selectedSticker,
            onCreateSticker: widget.onCreateSticker,
            onStickerSelected: (sticker) {
              setState(() => _selectedSticker = sticker);
              widget.onStickerSelected?.call(sticker);
            },
          ),
        ],
      ),
      bottomNavigationBar: const _ProfileBottomNavigation(),
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
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ],
      );
}

class _StickersSection extends StatelessWidget {
  const _StickersSection({
    required this.photos,
    required this.selectedSticker,
    required this.onCreateSticker,
    required this.onStickerSelected,
  });

  final List<SavedFlowerPhoto> photos;
  final SavedFlowerPhoto? selectedSticker;
  final VoidCallback? onCreateSticker;
  final ValueChanged<SavedFlowerPhoto> onStickerSelected;

  @override
  Widget build(BuildContext context) {
    final stickers = photos.where((photo) => photo.stickerBytes != null).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Stickers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        if (stickers.isEmpty)
          _AddStickerTile(onTap: onCreateSticker)
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
              if (index == stickers.length) return _AddStickerTile(onTap: onCreateSticker);
              final sticker = stickers[index];
              return _StickerTile(
                        key: ValueKey('saved-sticker-${sticker.stickerId ?? index}'),
                sticker: sticker,
                selected: identical(sticker, selectedSticker),
                onTap: () => onStickerSelected(sticker),
              );
            },
          ),
      ],
    );
  }
}

class _StickerTile extends StatelessWidget {
  const _StickerTile({super.key, required this.sticker, required this.selected, required this.onTap});

  final SavedFlowerPhoto sticker;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xffeef3ed),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? const Color(0xff2f6b4f) : Colors.transparent,
              width: 3,
            ),
          ),
          child: Stack(
            children: [
              Center(child: Image.memory(sticker.stickerBytes!, fit: BoxFit.contain)),
              if (selected)
                const Align(
                  alignment: Alignment.topRight,
                  child: Icon(Icons.check_circle, color: Color(0xff2f6b4f)),
                ),
            ],
          ),
        ),
      );
}

class _AddStickerTile extends StatelessWidget {
  const _AddStickerTile({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xffeef3ed),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Color(0xff2f6b4f), size: 32),
              SizedBox(height: 4),
              Text('Add Sticker'),
            ],
          ),
        ),
      );
}

class _ProfileBottomNavigation extends StatelessWidget {
  const _ProfileBottomNavigation();

  @override
  Widget build(BuildContext context) => Container(
        height: 74,
        decoration: const BoxDecoration(
          color: Color(0xff2f6b4f),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _BottomNavigationItem(icon: Icons.qr_code_scanner_outlined, label: 'Scanner'),
            _BottomNavigationItem(icon: Icons.menu_book_outlined, label: 'Diary'),
            _BottomNavigationItem(icon: Icons.map_outlined, label: 'Map'),
            _BottomNavigationItem(icon: Icons.person, label: 'Profile', selected: true),
          ],
        ),
      );
}

class _BottomNavigationItem extends StatelessWidget {
  const _BottomNavigationItem({required this.icon, required this.label, this.selected = false});

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: selected ? Colors.white : Colors.white70, size: selected ? 28 : 25),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white70, fontSize: 10)),
        ],
      );
}

class _EditAccountSheet extends StatefulWidget {
  const _EditAccountSheet({required this.account});

  final UserAccount account;

  @override
  State<_EditAccountSheet> createState() => _EditAccountSheetState();
}

class _EditAccountSheetState extends State<_EditAccountSheet> {
  late final _nameController = TextEditingController(text: widget.account.name);
  late final _usernameController = TextEditingController(text: widget.account.username);
  late final _emailController = TextEditingController(text: widget.account.email);

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
                Text('Change profile details', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 12),
                TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.alternate_email))),
                const SizedBox(height: 12),
                TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text('Save changes'))),
              ],
            ),
          ),
        ),
      );

  void _save() {
    if (_nameController.text.trim().isEmpty || _usernameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) return;
    Navigator.pop(
      context,
      UserAccount(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
      ),
    );
  }
}