import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.createdAt,
  });

  SavedFlowerPhoto.fromFile(
    File file, {
    String? label,
    String? stickerId,
    DateTime? createdAt,
  })
      : this(
          image: FileImage(file),
          label: label,
          stickerId: stickerId,
          createdAt: createdAt,
        );

  final ImageProvider image;
  final String? label;
  final String? stickerId;
  final DateTime? createdAt;

  SavedFlowerPhoto copyWith({
    String? label,
    String? stickerId,
    DateTime? createdAt,
  }) {
    return SavedFlowerPhoto(
      image: image,
      label: label ?? this.label,
      stickerId: stickerId ?? this.stickerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({
    super.key,
    this.savedFlowerPhotos = const [],
    this.onCreateSticker,
  });

  final List<SavedFlowerPhoto> savedFlowerPhotos;
  final VoidCallback? onCreateSticker;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserAccount _account = UserAccount(
    name: 'New Flower Finder User',
    username: 'flower_finder_user',
    email: 'user@example.com',
  );

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
    return Scaffold(
      backgroundColor: const Color(0xfff8faf7),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xff2f6b4f),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Container(
          color: const Color(0xff2f6b4f),
          child: SafeArea(
            bottom: false,
            child: Container(
              color: const Color(0xfff8faf7),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _ProfileHeader(
                      onEdit: _editAccount,
                      onCreateSticker: widget.onCreateSticker,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _ProfileSummary(
                          account: _account,
                          imageCount: widget.savedFlowerPhotos.length,
                          stickerCount: widget.savedFlowerPhotos.where((photo) => photo.stickerId != null).length,
                        ),
                        const SizedBox(height: 30),
                        _SavedFlowerPhotosSection(photos: widget.savedFlowerPhotos),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 74,
        decoration: const BoxDecoration(
          color: Color(0xff2f6b4f),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.qr_code_scanner_outlined, color: Colors.white70, size: 26),
            Icon(Icons.menu_book_outlined, color: Colors.white70, size: 26),
            Icon(Icons.map_outlined, color: Colors.white70, size: 26),
            Icon(Icons.person, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onEdit, this.onCreateSticker});

  final VoidCallback onEdit;
  final VoidCallback? onCreateSticker;

  @override
  Widget build(BuildContext context) => Container(
        height: 68,
        color: const Color(0xff2f6b4f),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: onCreateSticker,
              tooltip: 'Create sticker',
              color: Colors.white,
              icon: const Icon(Icons.add, size: 28),
            ),
            const Expanded(
              child: Text(
                'Profile Page',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'More options',
              icon: const Icon(Icons.more_horiz, color: Colors.white, size: 28),
              onSelected: (value) {
                if (value == 'edit') onEdit();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit account')),
              ],
            ),
          ],
        ),
      );
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.account, required this.imageCount, required this.stickerCount});

  final UserAccount account;
  final int imageCount;
  final int stickerCount;

  @override
  Widget build(BuildContext context) => Column(
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
                    _ProfileStat(value: '$imageCount', label: 'Images'),
                    const _ProfileStat(value: '0', label: 'Diary'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '@${account.username}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff23352a)),
            ),
          ),
        ],
      );
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xff23352a))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ],
      );
}

class _SavedFlowerPhotosSection extends StatelessWidget {
  const _SavedFlowerPhotosSection({required this.photos});

  final List<SavedFlowerPhoto> photos;

  @override
  Widget build(BuildContext context) {
    final itemCount = photos.isEmpty ? 6 : photos.length + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your flowers',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xff23352a)),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index == photos.length) return const _AddGalleryTile();
            if (photos.isEmpty) return _PlaceholderGalleryTile(index: index);

            final photo = photos[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(image: photo.image, fit: BoxFit.cover),
                  if (photo.stickerId != null)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              _stickerIcon(photo.stickerId!),
                              color: Color(0xff2f6b4f),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _stickerIcon(String stickerId) {
    return switch (stickerId) {
      'colour_variation' => Icons.tonality,
      'bubble_border' => Icons.bubble_chart_outlined,
      _ => Icons.color_lens_outlined,
    };
  }
}

class _PlaceholderGalleryTile extends StatelessWidget {
  const _PlaceholderGalleryTile({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          color: index.isEven ? const Color(0xffdce9d8) : const Color(0xffe9efe6),
          child: const Icon(Icons.local_florist_outlined, color: Color(0xff6c9274), size: 30),
        ),
      );
}

class _AddGalleryTile extends StatelessWidget {
  const _AddGalleryTile();

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          color: const Color(0xffeef3ed),
          child: const Icon(Icons.add, color: Color(0xff2f6b4f), size: 32),
        ),
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
                Text('Edit account', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
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
