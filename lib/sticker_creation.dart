import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'flower_photo_service.dart';
import 'package:flutter_sticker_maker/flutter_sticker_maker.dart';

import 'user_profile.dart';

class StickerCreationPage extends StatefulWidget {
  const StickerCreationPage({
    required this.photos,
    required this.onSaved,
    this.loadFlowers,
    this.pickPhoto,
    super.key,
  });

  final List<SavedFlowerPhoto> photos;
  final Future<List<SavedFlowerPhoto>> Function(String query)? loadFlowers;
  final Future<Uint8List?> Function()? pickPhoto;
  final void Function(
    SavedFlowerPhoto photo,
    Uint8List stickerBytes,
    String stickerId,
  )
  onSaved;

  @override
  State<StickerCreationPage> createState() => _StickerCreationPageState();
}

class _StickerCreationPageState extends State<StickerCreationPage> {
  int selectedPhotoIndex = 0;
  late final List<SavedFlowerPhoto> _photos = List.of(widget.photos);
  final _searchController = TextEditingController(text: 'rose');
  bool _loadingPhotos = false;
  bool _pickingPhoto = false;
  String? _photoError;
  int _searchRequest = 0;
  bool get _busy => _isGenerating || _pickingPhoto;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFlowers() async {
    final request = ++_searchRequest;
    setState(() {
      _loadingPhotos = true;
      _photoError = null;
    });
    try {
      final photos =
          await (widget.loadFlowers ?? const FlowerPhotoService().search)(
            _searchController.text,
          );
      if (!mounted || request != _searchRequest) return;
      setState(() {
        _photos.removeWhere((photo) => photo.image is NetworkImage);
        _photos.addAll(photos);
        selectedPhotoIndex = 0;
        _stickerBytes = null;
        _photoError = photos.isEmpty
            ? 'No flower photos found. Try another name.'
            : null;
      });
    } catch (_) {
      if (!mounted || request != _searchRequest) return;
      setState(
        () => _photoError =
            'Unable to load flower photos. Try again or choose your own photo.',
      );
    } finally {
      if (mounted && request == _searchRequest) {
        setState(() => _loadingPhotos = false);
      }
    }
  }

  Future<void> _pickPhoto() async {
    setState(() {
      _pickingPhoto = true;
      _errorMessage = null;
    });
    try {
      Uint8List? bytes;
      if (widget.pickPhoto != null) {
        bytes = await widget.pickPhoto!();
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
        _photos.add(
          SavedFlowerPhoto(image: MemoryImage(bytes!), label: 'My photo'),
        );
        selectedPhotoIndex = _photos.length - 1;
        _stickerBytes = null;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage =
              'Could not open this photo. Please try another image.',
        );
      }
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  String selectedStickerId = 'colour_change';
  Uint8List? _stickerBytes;
  bool _isGenerating = false;
  String? _errorMessage;

  static const stickers = {
    'colour_change': (
      'Colour Change',
      'A brighter colour treatment for the generated flower sticker.',
    ),
    'colour_variation': (
      'Colour Variation',
      'A softer, subtly different flower colour treatment.',
    ),
    'bubble_border': (
      'Bubble Border',
      'Keep this option available while its border treatment is refined.',
    ),
  };

  @override
  void initState() {
    super.initState();
    unawaited(_loadFlowers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Sticker')),
      body: ListView(
        key: const ValueKey("sticker-scroll"),
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose a flower photo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _busy || _loadingPhotos ? null : _pickPhoto,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              _pickingPhoto ? 'Opening photos...' : 'Choose my own photo',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            enabled: !_busy && !_loadingPhotos,
            onSubmitted: (_) => _loadFlowers(),
            decoration: InputDecoration(
              labelText: 'Search flower photos',
              hintText: 'Rose, daisy, lavender...',
              suffixIcon: IconButton(
                onPressed: _busy || _loadingPhotos ? null : _loadFlowers,
                icon: const Icon(Icons.search),
                tooltip: 'Search flowers',
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Flower photos from Perenual',
            style: TextStyle(fontSize: 12),
          ),
          if (_loadingPhotos) const LinearProgressIndicator(),
          if (_photoError != null) Text(_photoError!),
          const SizedBox(height: 14),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length,
              separatorBuilder: (_, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return GestureDetector(
                  onTap: _busy || _loadingPhotos
                      ? null
                      : () => setState(() {
                          selectedPhotoIndex = index;
                          _stickerBytes = null;
                          _errorMessage = null;
                        }),
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
                    child: Image(
                      image: photo.image,
                      fit: BoxFit.cover,
                      semanticLabel: photo.label,
                      errorBuilder: (_, error, stack) => const Center(
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _StickerPreview(
            photo: _photos.isEmpty ? null : _photos[selectedPhotoIndex],
            stickerBytes: _stickerBytes,
            stickerId: selectedStickerId,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _photos.isEmpty || _busy || _loadingPhotos
                ? null
                : _generateSticker,
            icon: _isGenerating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              _isGenerating ? 'Generating sticker...' : 'Generate sticker',
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
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
            onPressed: _stickerBytes == null || _busy || _loadingPhotos
                ? null
                : _saveSticker,
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
      await FlutterStickerMaker.initialize();
      final imageBytes = await _imageProviderToPng(
        _photos[selectedPhotoIndex].image,
      );
      final stickerBytes = await FlutterStickerMaker.makeSticker(
        imageBytes,
        addBorder: false,
      );
      final croppedStickerBytes = stickerBytes == null
          ? null
          : await cropStickerTransparentPadding(stickerBytes);
      if (!mounted) return;
      setState(() {
        _stickerBytes = croppedStickerBytes;
        _errorMessage = croppedStickerBytes == null
            ? 'The sticker could not be generated.'
            : null;
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
    if (stickerBytes == null || _photos.isEmpty) return;
    widget.onSaved(
      _photos[selectedPhotoIndex],
      stickerBytes,
      selectedStickerId,
    );
    Navigator.pop(context);
  }

  Future<Uint8List> _imageProviderToPng(ImageProvider imageProvider) async {
    final stream = imageProvider.resolve(ImageConfiguration.empty);
    final imageCompleter = Completer<ui.Image>();
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (imageInfo, synchronousCall) {
        if (!imageCompleter.isCompleted) {
          imageCompleter.complete(imageInfo.image);
        }
        stream.removeListener(listener);
      },
      onError: (error, stackTrace) {
        if (!imageCompleter.isCompleted) {
          imageCompleter.completeError(error, stackTrace);
        }
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    final image = await imageCompleter.future;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('The selected flower photo has no image data.');
    }
    return Uint8List.fromList(byteData.buffer.asUint8List());
  }
}

@visibleForTesting
Future<Uint8List> cropStickerTransparentPadding(
  Uint8List stickerBytes, {
  double paddingFraction = 0.06,
}) async {
  try {
    final codec = await ui.instantiateImageCodec(stickerBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final width = image.width;
    final height = image.height;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return stickerBytes;

    final pixels = byteData.buffer.asUint8List();
    var left = width;
    var top = height;
    var right = -1;
    var bottom = -1;

    for (var y = 0; y < height; y += 1) {
      for (var x = 0; x < width; x += 1) {
        final alpha = pixels[((y * width + x) * 4) + 3];
        if (alpha == 0) continue;
        if (x < left) left = x;
        if (x > right) right = x;
        if (y < top) top = y;
        if (y > bottom) bottom = y;
      }
    }

    if (right < left || bottom < top) return stickerBytes;

    final originalAspectRatio = width / height;
    final contentWidth = right - left + 1;
    final contentHeight = bottom - top + 1;
    final padding =
        (contentWidth > contentHeight ? contentWidth : contentHeight) *
        paddingFraction;
    final centerX = (left + right + 1) / 2;
    final centerY = (top + bottom + 1) / 2;
    var cropWidth = contentWidth + padding * 2;
    var cropHeight = contentHeight + padding * 2;

    if (cropWidth / cropHeight > originalAspectRatio) {
      cropHeight = cropWidth / originalAspectRatio;
    } else {
      cropWidth = cropHeight * originalAspectRatio;
    }

    if (cropWidth >= width && cropHeight >= height) return stickerBytes;

    cropWidth = cropWidth.clamp(1, width).toDouble();
    cropHeight = cropHeight.clamp(1, height).toDouble();
    var cropLeft = centerX - cropWidth / 2;
    var cropTop = centerY - cropHeight / 2;
    cropLeft = cropLeft.clamp(0, width - cropWidth).toDouble();
    cropTop = cropTop.clamp(0, height - cropHeight).toDouble();

    final outputWidth = cropWidth.round();
    final outputHeight = cropHeight.round();
    if (outputWidth <= 0 || outputHeight <= 0) return stickerBytes;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final sourceRect = Rect.fromLTWH(
      cropLeft,
      cropTop,
      outputWidth.toDouble(),
      outputHeight.toDouble(),
    );
    final destinationRect = Rect.fromLTWH(
      0,
      0,
      outputWidth.toDouble(),
      outputHeight.toDouble(),
    );
    canvas.drawImageRect(image, sourceRect, destinationRect, Paint());
    final croppedImage = await recorder.endRecording().toImage(
      outputWidth,
      outputHeight,
    );
    final croppedBytes = await croppedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return croppedBytes?.buffer.asUint8List() ?? stickerBytes;
  } catch (_) {
    return stickerBytes;
  }
}

class _StickerPreview extends StatelessWidget {
  const _StickerPreview({
    required this.photo,
    required this.stickerBytes,
    required this.stickerId,
  });

  final SavedFlowerPhoto? photo;
  final Uint8List? stickerBytes;
  final String stickerId;

  @override
  Widget build(BuildContext context) {
    if (photo == null) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('Select a flower photo to preview')),
      );
    }
    final image = stickerBytes == null
        ? Image(
            image: photo!.image,
            fit: BoxFit.contain,
            errorBuilder: (_, error, stack) => const Center(
              child: Text('Photo unavailable. Please choose another.'),
            ),
          )
        : Image.memory(stickerBytes!, fit: BoxFit.contain);
    if (stickerId == 'bubble_border' || stickerBytes == null) {
      return SizedBox(height: 220, child: image);
    }
    return SizedBox(
      height: 220,
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(
          stickerId == 'colour_change'
              ? _colourChangeMatrix
              : _colourVariationMatrix,
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
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: stickerId == 'colour_change'
          ? const Color(0xffd6eaa9)
          : const Color(0xffd9e7f3),
      border: stickerId == 'bubble_border'
          ? Border.all(color: const Color(0xff6c9274), width: 3)
          : null,
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

const _colourChangeMatrix = <double>[
  1.18,
  0,
  0,
  0,
  8,
  0,
  1.08,
  0,
  0,
  8,
  0,
  0,
  .82,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
];

const _colourVariationMatrix = <double>[
  .92,
  0,
  0,
  0,
  8,
  0,
  1.02,
  0,
  0,
  4,
  0,
  0,
  1.12,
  0,
  8,
  0,
  0,
  0,
  1,
  0,
];
