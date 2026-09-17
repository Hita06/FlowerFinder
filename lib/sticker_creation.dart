import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_sticker_maker/flutter_sticker_maker.dart';

import 'user_profile.dart';

class StickerCreationPage extends StatefulWidget {
  const StickerCreationPage({required this.photos, required this.onSaved, super.key});

  final List<SavedFlowerPhoto> photos;
  final void Function(int photoIndex, Uint8List stickerBytes, String stickerId) onSaved;

  @override
  State<StickerCreationPage> createState() => _StickerCreationPageState();
}

class _StickerCreationPageState extends State<StickerCreationPage> {
  int selectedPhotoIndex = 0;
  String selectedStickerId = 'colour_change';
  Uint8List? _stickerBytes;
  bool _isGenerating = false;
  String? _errorMessage;

  static const stickers = {
    'colour_change': ('Colour Change', 'A brighter colour treatment for the generated flower sticker.'),
    'colour_variation': ('Colour Variation', 'A softer, subtly different flower colour treatment.'),
    'bubble_border': ('Bubble Border', 'Keep this option available while its border treatment is refined.'),
  };

  @override
  void initState() {
    super.initState();
    unawaited(FlutterStickerMaker.initialize());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Sticker')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Choose a flower photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
                  onTap: () => setState(() {
                    selectedPhotoIndex = index;
                    _stickerBytes = null;
                    _errorMessage = null;
                  }),
                  child: Container(
                    width: 112,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedPhotoIndex == index ? const Color(0xff2f6b4f) : Colors.transparent,
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
            stickerBytes: _stickerBytes,
            stickerId: selectedStickerId,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: widget.photos.isEmpty || _isGenerating ? null : _generateSticker,
            icon: _isGenerating
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? 'Generating sticker...' : 'Generate sticker'),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 28),
          const Text('Choose a sticker style', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
            onPressed: _stickerBytes == null ? null : _saveSticker,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save sticker'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateSticker() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });
    try {
      final imageBytes = await _imageProviderToPng(widget.photos[selectedPhotoIndex].image);
      final stickerBytes = await FlutterStickerMaker.makeSticker(imageBytes, addBorder: false);
      if (!mounted) return;
      setState(() {
        _stickerBytes = stickerBytes;
        _errorMessage = stickerBytes == null ? 'The sticker could not be generated.' : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Could not create sticker: $error');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _saveSticker() {
    final stickerBytes = _stickerBytes;
    if (stickerBytes == null || widget.photos.isEmpty) return;
    widget.onSaved(selectedPhotoIndex, stickerBytes, selectedStickerId);
    Navigator.pop(context);
  }

  Future<Uint8List> _imageProviderToPng(ImageProvider imageProvider) async {
    final stream = imageProvider.resolve(ImageConfiguration.empty);
    final imageCompleter = Completer<ui.Image>();
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (imageInfo, synchronousCall) {
        if (!imageCompleter.isCompleted) imageCompleter.complete(imageInfo.image);
        stream.removeListener(listener);
      },
      onError: (error, stackTrace) {
        if (!imageCompleter.isCompleted) imageCompleter.completeError(error, stackTrace);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    final image = await imageCompleter.future;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw StateError('The selected flower photo has no image data.');
    return Uint8List.fromList(byteData.buffer.asUint8List());
  }
}

class _StickerPreview extends StatelessWidget {
  const _StickerPreview({required this.photo, required this.stickerBytes, required this.stickerId});

  final SavedFlowerPhoto? photo;
  final Uint8List? stickerBytes;
  final String stickerId;

  @override
  Widget build(BuildContext context) {
    if (photo == null) {
      return const SizedBox(height: 220, child: Center(child: Text('Select a flower photo to preview')));
    }
    final image = stickerBytes == null
        ? Image(image: photo!.image, fit: BoxFit.contain)
        : Image.memory(stickerBytes!, fit: BoxFit.contain);
    if (stickerId == 'bubble_border' || stickerBytes == null) {
      return SizedBox(height: 220, child: image);
    }
    return SizedBox(
      height: 220,
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(stickerId == 'colour_change' ? _colourChangeMatrix : _colourVariationMatrix),
        child: image,
      ),
    );
  }
}

class _StyleSwatch extends StatelessWidget {
  const _StyleSwatch({required this.stickerId});

  final String stickerId;

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: stickerId == 'colour_change' ? const Color(0xffd6eaa9) : const Color(0xffd9e7f3),
          border: stickerId == 'bubble_border' ? Border.all(color: const Color(0xff6c9274), width: 3) : null,
          borderRadius: BorderRadius.circular(12),
        ),
      );
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