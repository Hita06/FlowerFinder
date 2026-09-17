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

  @override
  Widget build(BuildContext context) {
    final stickerCount = widget.savedFlowerPhotos
        .where((photo) => photo.stickerBytes != null)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xfff8faf7),
      appBar: AppBar(
        title: const Text('Profile Page'),
        backgroundColor: const Color(0xff2f6b4f),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: widget.onCreateSticker,
            tooltip: 'Create sticker',
            icon: const Icon(Icons.add),
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
                    _ProfileStat(value: '${widget.savedFlowerPhotos.length}', label: 'Images'),
                    const _ProfileStat(value: '0', label: 'Diary'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('@${_account.username}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 28),
          const Text('Your flowers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: widget.savedFlowerPhotos.length + 1,
            itemBuilder: (context, index) {
              if (index == widget.savedFlowerPhotos.length) {
                return _AddGalleryTile(onTap: widget.onCreateSticker);
              }
              final photo = widget.savedFlowerPhotos[index];
              return _FlowerTile(photo: photo);
            },
          ),
        ],
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
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ],
      );
}

class _FlowerTile extends StatelessWidget {
  const _FlowerTile({required this.photo});

  final SavedFlowerPhoto photo;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(image: photo.image, fit: BoxFit.cover),
            if (photo.stickerBytes != null)
              Center(child: Image.memory(photo.stickerBytes!, fit: BoxFit.contain)),
            if (photo.label != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  color: Colors.black54,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  child: Text(
                    photo.label!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
          ],
        ),
      );
}

class _AddGalleryTile extends StatelessWidget {
  const _AddGalleryTile({this.onTap});

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