import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'flower_photo_service.dart';
import 'package:flutter_sticker_maker/flutter_sticker_maker.dart';

import 'user_profile.dart';

enum AdvancedStickerEffect {
  none('None'),
  pinkGlitter('Bright Glitter'),
  bubble3d('3D Bubble'),
  rainbowPrism('Rainbow Prism');

  const AdvancedStickerEffect(this.label);

  final String label;
}

class StickerCreationPage extends StatefulWidget {
  const StickerCreationPage({
    required this.photos,
    required this.onSaved,
    this.loadFlowers,
    this.pickPhoto,
    this.initialSticker,
    super.key,
  });

  final List<SavedFlowerPhoto> photos;
  final Future<List<SavedFlowerPhoto>> Function(String query)? loadFlowers;
  final Future<Uint8List?> Function()? pickPhoto;
  final SavedFlowerPhoto? initialSticker;
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
  bool get _isEditingSavedSticker =>
      widget.initialSticker?.stickerBytes != null;

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
        _baseStickerBytes = null;
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
        _baseStickerBytes = null;
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
  Uint8List? _baseStickerBytes;
  Uint8List? _stickerBytes;
  bool _whiteOutlineEnabled = false;
  double _outlineThickness = 8;
  bool _innerShadowEnabled = false;
  bool _dropShadowEnabled = false;
  double _dropShadowStrength = 0.6;
  AdvancedStickerEffect _advancedEffect = AdvancedStickerEffect.none;
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
    final initialSticker = widget.initialSticker;
    if (initialSticker?.stickerBytes != null) {
      _baseStickerBytes = initialSticker!.stickerBytes;
      _stickerBytes = initialSticker.stickerBytes;
      selectedStickerId = initialSticker.stickerId ?? selectedStickerId;
      if (_photos.isEmpty) {
        _photos.add(initialSticker);
      }
    } else {
      unawaited(_loadFlowers());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditingSavedSticker ? 'Edit Sticker' : 'Create Sticker'),
      ),
      body: ListView(
        key: const ValueKey("sticker-scroll"),
        padding: const EdgeInsets.all(20),
        children: [
          if (_isEditingSavedSticker) ...[
            const Text(
              'Edit saved sticker',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Adjust the generated sticker effects, then save to update it in your Profile.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ] else ...[
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
                            _baseStickerBytes = null;
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
          ],
          const SizedBox(height: 24),
          _StickerPreview(
            photo: _photos.isEmpty ? null : _photos[selectedPhotoIndex],
            stickerBytes: _stickerBytes,
            stickerId: selectedStickerId,
          ),
          const SizedBox(height: 18),
          if (!_isEditingSavedSticker)
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
          const SizedBox(height: 24),
          const Text(
            'Custom effects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('White Outline'),
            subtitle: Text('Thickness: ${_outlineThickness.round()} px'),
            value: _whiteOutlineEnabled,
            onChanged: _baseStickerBytes == null || _busy
                ? null
                : (value) {
                    setState(() => _whiteOutlineEnabled = value);
                    unawaited(_refreshStickerEffects());
                  },
          ),
          Slider(
            value: _outlineThickness,
            min: 2,
            max: 24,
            divisions: 11,
            label: '${_outlineThickness.round()} px',
            onChanged:
                !_whiteOutlineEnabled || _baseStickerBytes == null || _busy
                ? null
                : (value) {
                    setState(() => _outlineThickness = value);
                    unawaited(_refreshStickerEffects());
                  },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Inner Shadow'),
            subtitle: const Text('Softly darkens the inside edge'),
            value: _innerShadowEnabled,
            onChanged: _baseStickerBytes == null || _busy
                ? null
                : (value) {
                    setState(() => _innerShadowEnabled = value);
                    unawaited(_refreshStickerEffects());
                  },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Drop Shadow'),
            subtitle: Text('Strength: ${(_dropShadowStrength * 100).round()}%'),
            value: _dropShadowEnabled,
            onChanged: _baseStickerBytes == null || _busy
                ? null
                : (value) {
                    setState(() => _dropShadowEnabled = value);
                    unawaited(_refreshStickerEffects());
                  },
          ),
          Slider(
            value: _dropShadowStrength,
            min: 0.25,
            max: 1,
            divisions: 15,
            label: '${(_dropShadowStrength * 100).round()}%',
            onChanged: !_dropShadowEnabled || _baseStickerBytes == null || _busy
                ? null
                : (value) {
                    setState(() => _dropShadowStrength = value);
                    unawaited(_refreshStickerEffects());
                  },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _baseStickerBytes == null || _busy
                ? null
                : _applyClassicStickerPreset,
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Use classic sticker preset'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Advanced effects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a themed effect directly onto the saved PNG sticker.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AdvancedStickerEffect.values
                .map(
                  (effect) => ChoiceChip(
                    label: Text(effect.label),
                    selected: _advancedEffect == effect,
                    onSelected: _baseStickerBytes == null || _busy
                        ? null
                        : (_) {
                            setState(() => _advancedEffect = effect);
                            unawaited(_refreshStickerEffects());
                          },
                  ),
                )
                .toList(),
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
            onPressed: _stickerBytes == null || _busy || _loadingPhotos
                ? null
                : _saveSticker,
            icon: const Icon(Icons.save_outlined),
            label: Text(
              _isEditingSavedSticker ? 'Update sticker' : 'Save sticker',
            ),
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
      final finalStickerBytes = croppedStickerBytes == null
          ? null
          : await applyStickerEffects(
              croppedStickerBytes,
              whiteOutline: _whiteOutlineEnabled,
              outlineThickness: _outlineThickness,
              innerShadow: _innerShadowEnabled,
              dropShadow: _dropShadowEnabled,
              dropShadowStrength: _dropShadowStrength,
              advancedEffect: _advancedEffect,
            );
      if (!mounted) return;
      setState(() {
        _baseStickerBytes = croppedStickerBytes;
        _stickerBytes = finalStickerBytes;
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

  Future<void> _refreshStickerEffects() async {
    final baseStickerBytes = _baseStickerBytes;
    if (baseStickerBytes == null) return;
    final renderedStickerBytes = await applyStickerEffects(
      baseStickerBytes,
      whiteOutline: _whiteOutlineEnabled,
      outlineThickness: _outlineThickness,
      innerShadow: _innerShadowEnabled,
      dropShadow: _dropShadowEnabled,
      dropShadowStrength: _dropShadowStrength,
      advancedEffect: _advancedEffect,
    );
    if (!mounted) return;
    setState(() => _stickerBytes = renderedStickerBytes);
  }

  void _applyClassicStickerPreset() {
    setState(() {
      _whiteOutlineEnabled = true;
      _outlineThickness = 10;
      _innerShadowEnabled = false;
      _dropShadowEnabled = true;
      _dropShadowStrength = 0.75;
      _advancedEffect = AdvancedStickerEffect.none;
    });
    unawaited(_refreshStickerEffects());
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

@visibleForTesting
Future<Uint8List> applyStickerEffects(
  Uint8List stickerBytes, {
  bool whiteOutline = false,
  double outlineThickness = 8,
  bool innerShadow = false,
  bool dropShadow = false,
  double dropShadowStrength = 0.6,
  AdvancedStickerEffect advancedEffect = AdvancedStickerEffect.none,
}) async {
  if (!whiteOutline &&
      !innerShadow &&
      !dropShadow &&
      advancedEffect == AdvancedStickerEffect.none) {
    return stickerBytes;
  }
  try {
    final codec = await ui.instantiateImageCodec(stickerBytes);
    final frame = await codec.getNextFrame();
    var image = frame.image;
    if (innerShadow) {
      image = await _drawInnerShadow(image);
    }
    final outlineRadius = whiteOutline
        ? outlineThickness.clamp(1, 64).round()
        : 0;
    final shadowStrength = dropShadowStrength.clamp(0.25, 1.0);
    final dropShadowBlur = (6 + shadowStrength * 10).round();
    final dropShadowDx = (4 + shadowStrength * 5).round();
    final dropShadowDy = (5 + shadowStrength * 7).round();
    final shadowMargin = dropShadow
        ? dropShadowBlur +
              (dropShadowDx.abs() > dropShadowDy.abs()
                  ? dropShadowDx.abs()
                  : dropShadowDy.abs())
        : 0;
    final margin = outlineRadius + shadowMargin;
    final outputWidth = image.width + margin * 2;
    final outputHeight = image.height + margin * 2;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final outlinePaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcIn);
    final originalPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    final dropShadowPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..colorFilter = ColorFilter.mode(
        Colors.black.withValues(alpha: 0.28 + shadowStrength * 0.42),
        BlendMode.srcIn,
      )
      ..imageFilter = ui.ImageFilter.blur(
        sigmaX: dropShadowBlur.toDouble(),
        sigmaY: dropShadowBlur.toDouble(),
      );

    if (dropShadow) {
      canvas.drawImage(
        image,
        Offset(
          (margin + dropShadowDx).toDouble(),
          (margin + dropShadowDy).toDouble(),
        ),
        dropShadowPaint,
      );
    }
    if (whiteOutline) {
      for (var dy = -outlineRadius; dy <= outlineRadius; dy += 1) {
        for (var dx = -outlineRadius; dx <= outlineRadius; dx += 1) {
          if (dx == 0 && dy == 0) continue;
          if (dx * dx + dy * dy > outlineRadius * outlineRadius) continue;
          canvas.drawImage(
            image,
            Offset((margin + dx).toDouble(), (margin + dy).toDouble()),
            outlinePaint,
          );
        }
      }
    }
    canvas.drawImage(
      image,
      Offset(margin.toDouble(), margin.toDouble()),
      originalPaint,
    );
    switch (advancedEffect) {
      case AdvancedStickerEffect.none:
        break;
      case AdvancedStickerEffect.pinkGlitter:
        await _drawBrightGlitterSurface(
          canvas,
          image,
          Offset(margin.toDouble(), margin.toDouble()),
        );
      case AdvancedStickerEffect.bubble3d:
        await _drawBubble3dSurface(
          canvas,
          image,
          Offset(margin.toDouble(), margin.toDouble()),
        );
      case AdvancedStickerEffect.rainbowPrism:
        await _drawRainbowPrismSurface(
          canvas,
          image,
          Offset(margin.toDouble(), margin.toDouble()),
        );
    }

    final renderedImage = await recorder.endRecording().toImage(
      outputWidth,
      outputHeight,
    );
    final byteData = await renderedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData?.buffer.asUint8List() ?? stickerBytes;
  } catch (_) {
    return stickerBytes;
  }
}

Future<void> _drawBrightGlitterSurface(
  Canvas canvas,
  ui.Image image,
  Offset origin,
) async {
  await _drawMaskedSurface(canvas, image, origin, (canvas, bounds) {
    final baseWashPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xffff10b8).withValues(alpha: 0.72),
          const Color(0xff780053).withValues(alpha: 0.84),
          const Color(0xffff86dd).withValues(alpha: 0.76),
        ],
        stops: const [0.0, 0.52, 1.0],
      ).createShader(bounds)
      ..blendMode = BlendMode.srcATop;
    canvas.drawRect(bounds, baseWashPaint);

    final glitterColors = <Color>[
      const Color(0xffff2fc4),
      const Color(0xffff79df),
      const Color(0xfffff1fb),
      const Color(0xffb00087),
      const Color(0xff00e5ff),
      const Color(0xfffff56a),
    ];

    for (var row = 0; row < 12; row += 1) {
      for (var col = 0; col < 12; col += 1) {
        final x =
            bounds.left +
            (col + 0.35 + (row.isEven ? 0.16 : -0.08)) * bounds.width / 12.2;
        final y =
            bounds.top +
            (row + 0.32 + (col.isEven ? 0.08 : -0.04)) * bounds.height / 12.3;
        final radius = 1.2 + ((row * 3 + col * 5) % 5) * 0.72;
        canvas.drawCircle(
          Offset(x, y),
          radius,
          Paint()
            ..isAntiAlias = true
            ..color = glitterColors[(row + col) % glitterColors.length]
                .withValues(alpha: 0.86),
        );
      }
    }

    for (var i = 0; i < 28; i += 1) {
      final fx = ((i * 37) % 97) / 96.0;
      final fy = ((i * 53 + 11) % 101) / 100.0;
      final center = Offset(
        bounds.left + fx * bounds.width,
        bounds.top + fy * bounds.height,
      );
      final size = bounds.shortestSide * (0.018 + (i % 4) * 0.006);
      final path = Path()
        ..moveTo(center.dx, center.dy - size)
        ..lineTo(center.dx + size * 0.76, center.dy)
        ..lineTo(center.dx, center.dy + size)
        ..lineTo(center.dx - size * 0.76, center.dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..isAntiAlias = true
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.98),
              glitterColors[i % glitterColors.length].withValues(alpha: 0.9),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: size)),
      );
    }

    final shinePaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.98)
      ..blendMode = BlendMode.plus;
    for (final centerFraction in const <Offset>[
      Offset(0.16, 0.28),
      Offset(0.30, 0.58),
      Offset(0.44, 0.20),
      Offset(0.56, 0.46),
      Offset(0.72, 0.30),
      Offset(0.84, 0.68),
      Offset(0.38, 0.82),
    ]) {
      _drawSparkle(
        canvas,
        Offset(
          bounds.left + centerFraction.dx * bounds.width,
          bounds.top + centerFraction.dy * bounds.height,
        ),
        10,
        shinePaint,
      );
    }
  });
}

Future<void> _drawBubble3dSurface(
  Canvas canvas,
  ui.Image image,
  Offset origin,
) async {
  await _drawMaskedSurface(canvas, image, origin, (canvas, bounds) {
    final glassBodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.58, -0.62),
        radius: 1.18,
        colors: [
          Colors.white.withValues(alpha: 0.82),
          const Color(0xffeffcff).withValues(alpha: 0.58),
          const Color(0xff8ce8ff).withValues(alpha: 0.46),
          const Color(0xff8d65ff).withValues(alpha: 0.34),
          const Color(0xff2457ff).withValues(alpha: 0.22),
        ],
        stops: const [0.0, 0.22, 0.50, 0.78, 1.0],
      ).createShader(bounds)
      ..blendMode = BlendMode.srcATop;
    canvas.drawRect(bounds, glassBodyPaint);

    final lowerShadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          const Color(0xff1672ff).withValues(alpha: 0.36),
          const Color(0xff4c189e).withValues(alpha: 0.42),
        ],
        stops: const [0.42, 0.76, 1.0],
      ).createShader(bounds)
      ..blendMode = BlendMode.srcATop;
    canvas.drawRect(bounds, lowerShadowPaint);

    final rimPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = bounds.shortestSide * 0.07
      ..color = Colors.white.withValues(alpha: 0.70)
      ..blendMode = BlendMode.plus;
    final cyanRimPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = bounds.shortestSide * 0.045
      ..color = const Color(0xff6effff).withValues(alpha: 0.58)
      ..blendMode = BlendMode.plus;
    final purpleRimPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = bounds.shortestSide * 0.035
      ..color = const Color(0xffff8dff).withValues(alpha: 0.36)
      ..blendMode = BlendMode.plus;

    canvas.drawOval(bounds.deflate(bounds.shortestSide * 0.08), rimPaint);
    canvas.drawOval(bounds.deflate(bounds.shortestSide * 0.13), cyanRimPaint);
    canvas.drawOval(bounds.deflate(bounds.shortestSide * 0.22), purpleRimPaint);

    final mainHighlightPaint = Paint()
      ..isAntiAlias = true
      ..color = Colors.white.withValues(alpha: 0.94)
      ..blendMode = BlendMode.plus;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          bounds.left + bounds.width * 0.30,
          bounds.top + bounds.height * 0.24,
        ),
        width: bounds.width * 0.34,
        height: bounds.height * 0.12,
      ),
      mainHighlightPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          bounds.left + bounds.width * 0.22,
          bounds.top + bounds.height * 0.40,
        ),
        width: bounds.width * 0.16,
        height: bounds.height * 0.07,
      ),
      Paint()
        ..isAntiAlias = true
        ..color = Colors.white.withValues(alpha: 0.78)
        ..blendMode = BlendMode.plus,
    );

    final bubbleSpecs = <(Offset, double)>[
      (const Offset(0.62, 0.28), 0.054),
      (const Offset(0.74, 0.44), 0.036),
      (const Offset(0.58, 0.70), 0.048),
      (const Offset(0.36, 0.68), 0.030),
      (const Offset(0.82, 0.76), 0.040),
    ];
    for (final spec in bubbleSpecs) {
      final center = Offset(
        bounds.left + spec.$1.dx * bounds.width,
        bounds.top + spec.$1.dy * bounds.height,
      );
      final radius = bounds.shortestSide * spec.$2;
      final bubbleBounds = Rect.fromCircle(center: center, radius: radius);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..isAntiAlias = true
          ..shader = RadialGradient(
            center: const Alignment(-0.45, -0.55),
            colors: [
              Colors.white.withValues(alpha: 0.88),
              const Color(0xffcaffff).withValues(alpha: 0.42),
              const Color(0xff5f7cff).withValues(alpha: 0.26),
            ],
          ).createShader(bubbleBounds)
          ..blendMode = BlendMode.plus,
      );
    }
  });
}

Future<void> _drawRainbowPrismSurface(
  Canvas canvas,
  ui.Image image,
  Offset origin,
) async {
  await _drawMaskedSurface(canvas, image, origin, (canvas, bounds) {
    final foilBasePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.22),
          const Color(0xff00f5ff).withValues(alpha: 0.30),
          const Color(0xfffff15a).withValues(alpha: 0.26),
          const Color(0xffff4bce).withValues(alpha: 0.30),
          Colors.white.withValues(alpha: 0.18),
        ],
        stops: const [0.0, 0.26, 0.48, 0.72, 1.0],
      ).createShader(bounds)
      ..blendMode = BlendMode.plus;
    canvas.drawRect(bounds, foilBasePaint);

    final prismColors = <Color>[
      const Color(0xff00f5ff),
      const Color(0xff2dff73),
      const Color(0xffffff37),
      const Color(0xffff7a00),
      const Color(0xffff39d0),
      const Color(0xff7c4dff),
      Colors.white,
    ];

    for (var i = 0; i < 24; i += 1) {
      final fx = ((i * 29 + 7) % 101) / 100.0;
      final fy = ((i * 43 + 13) % 103) / 102.0;
      final center = Offset(
        bounds.left + fx * bounds.width,
        bounds.top + fy * bounds.height,
      );
      final w = bounds.shortestSide * (0.045 + (i % 4) * 0.012);
      final h = bounds.shortestSide * (0.014 + (i % 3) * 0.007);
      final path = Path()
        ..moveTo(center.dx - w * 0.55, center.dy - h)
        ..lineTo(center.dx + w * 0.45, center.dy - h * 0.35)
        ..lineTo(center.dx + w * 0.55, center.dy + h)
        ..lineTo(center.dx - w * 0.45, center.dy + h * 0.35)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..isAntiAlias = true
          ..color = prismColors[i % prismColors.length].withValues(alpha: 0.72)
          ..blendMode = BlendMode.plus,
      );
    }

    final sparklePaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.98)
      ..blendMode = BlendMode.plus;
    for (final centerFraction in const <Offset>[
      Offset(0.16, 0.32),
      Offset(0.28, 0.58),
      Offset(0.40, 0.20),
      Offset(0.52, 0.48),
      Offset(0.64, 0.72),
      Offset(0.76, 0.36),
      Offset(0.88, 0.62),
    ]) {
      _drawSparkle(
        canvas,
        Offset(
          bounds.left + centerFraction.dx * bounds.width,
          bounds.top + centerFraction.dy * bounds.height,
        ),
        9,
        sparklePaint,
      );
    }

    for (var i = 0; i < 72; i += 1) {
      final fx = ((i * 17 + 5) % 113) / 112.0;
      final fy = ((i * 31 + 19) % 109) / 108.0;
      final radius = bounds.shortestSide * (0.006 + (i % 4) * 0.004);
      canvas.drawCircle(
        Offset(
          bounds.left + fx * bounds.width,
          bounds.top + fy * bounds.height,
        ),
        radius,
        Paint()
          ..isAntiAlias = true
          ..color = prismColors[i % prismColors.length].withValues(alpha: 0.86)
          ..blendMode = BlendMode.plus,
      );
    }
  });
}

Future<void> _drawMaskedSurface(
  Canvas canvas,
  ui.Image image,
  Offset origin,
  void Function(Canvas canvas, Rect bounds) drawSurface,
) async {
  final bounds = Rect.fromLTWH(
    origin.dx,
    origin.dy,
    image.width.toDouble(),
    image.height.toDouble(),
  );
  canvas.saveLayer(bounds, Paint());
  drawSurface(canvas, bounds);
  canvas.drawImage(
    image,
    origin,
    Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..blendMode = BlendMode.dstIn,
  );
  canvas.restore();
}

void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
  canvas
    ..drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    )
    ..drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    )
    ..drawLine(
      Offset(center.dx - radius * 0.55, center.dy - radius * 0.55),
      Offset(center.dx + radius * 0.55, center.dy + radius * 0.55),
      paint,
    )
    ..drawLine(
      Offset(center.dx - radius * 0.55, center.dy + radius * 0.55),
      Offset(center.dx + radius * 0.55, center.dy - radius * 0.55),
      paint,
    );
}

Future<ui.Image> _drawInnerShadow(ui.Image image) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final bounds = Rect.fromLTWH(
    0,
    0,
    image.width.toDouble(),
    image.height.toDouble(),
  );
  final originalPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high;
  final shadowPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..colorFilter = ColorFilter.mode(
      Colors.black.withValues(alpha: 0.38),
      BlendMode.srcIn,
    )
    ..imageFilter = ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5);

  canvas.saveLayer(bounds, Paint());
  canvas.drawImage(image, Offset.zero, originalPaint);
  canvas.saveLayer(bounds, Paint()..blendMode = BlendMode.srcATop);
  canvas.drawImage(image, const Offset(-4, -4), shadowPaint);
  canvas.restore();
  canvas.restore();
  return recorder.endRecording().toImage(image.width, image.height);
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
