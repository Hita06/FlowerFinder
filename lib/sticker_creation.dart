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
  String selectedStickerId = 'colour_change';

  static const stickers = {
    'colour_change': (
      'Colour Change',
      'A brighter colour treatment for the original flower photo.',
    ),
    'colour_variation': (
      'Colour Variation',
      'A softer, subtly different flower colour treatment.',
    ),
    'bubble_border': (
      'Bubble Border',
      'A translucent, organic edge around the flower photo.',
    ),
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
          const SizedBox(height: 24),
          _StickerPreview(
            photo: widget.photos.isEmpty ? null : widget.photos[selectedPhotoIndex],
            stickerId: selectedStickerId,
          ),
          const SizedBox(height: 28),
          const Text(
            'Choose a sticker style',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ...stickers.entries.map(
            (entry) => ListTile(
              onTap: () => setState(() => selectedStickerId = entry.key),
              leading: _StyleSwatch(stickerId: entry.key),
              title: Text(entry.value.$1),
              subtitle: Text(entry.value.$2),
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

class _StickerPreview extends StatelessWidget {
  const _StickerPreview({required this.photo, required this.stickerId});

  final SavedFlowerPhoto? photo;
  final String stickerId;

  @override
  Widget build(BuildContext context) {
    if (photo == null) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('Select a flower photo to preview')),
      );
    }

    final image = Image(image: photo!.image, fit: BoxFit.contain);
    if (stickerId == 'bubble_border') {
      return SizedBox(
        height: 220,
        child: image,
      );
    }

    return SizedBox(
      height: 220,
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(
          stickerId == 'colour_change' ? _colourChangeMatrix : _colourVariationMatrix,
        ),
        child: image,
      ),
    );
  }
}

class _StyleSwatch extends StatelessWidget {
  const _StyleSwatch({required this.stickerId});

  final String stickerId;

  @override
  Widget build(BuildContext context) {
    if (stickerId == 'bubble_border') {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xffdce9d8),
          border: Border.all(color: const Color(0xff6c9274), width: 3),
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: stickerId == 'colour_change' ? const Color(0xffd6eaa9) : const Color(0xffd9e7f3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

const _colourChangeMatrix = <double>[
  1.18, 0, 0, 0, 8,
  0, 1.08, 0, 0, 8,
  0, 0, .82, 0, 0,
  0, 0, 0, 1, 0,
];

const _colourVariationMatrix = <double>[
  .92, 0, 0, 0, 8,
  0, 1.02, 0, 0, 4,
  0, 0, 1.12, 0, 8,
  0, 0, 0, 1, 0,
];
