import 'package:flutter/material.dart';

import 'user_profile.dart';

class StickerCreationPage extends StatefulWidget {
  const StickerCreationPage({required this.photos, required this.onSaved, super.key});

  final List<SavedFlowerPhoto> photos;
  final void Function(int photoIndex, String stickerId) onSaved;

  @override
  State<StickerCreationPage> createState() => _StickerCreationPageState();
}

class _StickerCreationPageState extends State<StickerCreationPage> {
  int selectedPhotoIndex = 0;
  String selectedStickerId = 'sun';

  static const stickers = {
    'sun': ('Sun', Icons.wb_sunny_outlined),
    'heart': ('Heart', Icons.favorite_border),
    'sparkle': ('Sparkle', Icons.auto_awesome),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Sticker')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose a flower photo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.photos.length,
              separatorBuilder: (_, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final photo = widget.photos[index];
                return GestureDetector(
                  onTap: () => setState(() => selectedPhotoIndex = index),
                  child: Container(
                    width: 112,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedPhotoIndex == index
                            ? const Color(0xff2f6b4f)
                            : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image(image: photo.image, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Choose a sticker',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ...stickers.entries.map(
            (entry) => ListTile(
              onTap: () => setState(() => selectedStickerId = entry.key),
              leading: Icon(entry.value.$2),
              title: Text(entry.value.$1),
              trailing: selectedStickerId == entry.key
                  ? const Icon(Icons.check_circle, color: Color(0xff2f6b4f))
                  : const Icon(Icons.radio_button_unchecked),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: widget.photos.isEmpty
                ? null
                : () {
                    widget.onSaved(selectedPhotoIndex, selectedStickerId);
                    Navigator.pop(context);
                  },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save sticker'),
          ),
        ],
      ),
    );
  }
}
