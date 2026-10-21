import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'flower_photo_service.dart';
import 'package:flutter_sticker_maker/flutter_sticker_maker.dart';

import 'sticker_animation_assets.dart';
import 'sticker_animation_overlay.dart';
import 'user_profile.dart';

enum AdvancedStickerEffect {
  none('None'),
  pinkGlitter('Bright Glitter'),
  rainbowPrism('Rainbow Prism');

  const AdvancedStickerEffect(this.label);

  final String label;
}

enum StickerGradientPreset {
  sunset('Sunset', [Color(0xffff4d8d), Color(0xffff9f43), Color(0xffffe66d)]),
  ocean('Ocean', [Color(0xff36d1dc), Color(0xff4389ff), Color(0xff8c52ff)]),
  blossom('Blossom', [Color(0xffff73b9), Color(0xffbd6bff), Color(0xff6a8dff)]),
  spring('Spring', [Color(0xffffdf62), Color(0xff75d66f), Color(0xff38c9b0)]),
  rainbow('Pastel Rainbow', [
    Color(0xffff9ed2),
    Color(0xffffc58a),
    Color(0xffffef8a),
    Color(0xffafe8a3),
    Color(0xff8ee5d9),
    Color(0xff91c7ff),
    Color(0xffc2a2ff),
  ]);

  const StickerGradientPreset(this.label, this.colors);

  final String label;
  final List<Color> colors;

  String get stickerId => 'gradient_$name';
}

enum StickerAnimation {
  none('No animation', null),
  fire('Fire', fireAnimationAsset),
  bubbles('Bubble explosion', 'Animations/Bubble Explosion.json'),
  celebration('Success celebration', 'Animations/Success celebration.json'),
  fireworks('Fireworks', 'Animations/Fireworks 4_3.json'),
  redWhiteBlueFirework(
    'Red White & Blue Firework',
    'Animations/Red White & Blue Firework.json',
  ),
  rewardLightEffect('Reward Light Effect', rewardLightAnimationAsset);

  const StickerAnimation(this.label, this.assetPath);

  final String label;
  final String? assetPath;
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
    String? animationAsset,
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

  Color _selectedStickerColour = StickerColourWheel.defaultColour;
  String? _preservedStickerId;
  Uint8List? _baseStickerBytes;
  Uint8List? _stickerBytes;
  bool _whiteOutlineEnabled = false;
  double _outlineThickness = 8;
  bool _innerShadowEnabled = false;
  bool _dropShadowEnabled = false;
  double _dropShadowStrength = 0.6;
  AdvancedStickerEffect _advancedEffect = AdvancedStickerEffect.none;
  bool _stickerTintEnabled = false;
  StickerGradientPreset? _selectedGradient;
  StickerAnimation _stickerAnimation = StickerAnimation.none;
  bool _isGenerating = false;
  String? _errorMessage;

  String get selectedStickerId =>
      _selectedGradient?.stickerId ??
      _preservedStickerId ??
      StickerColourWheel.encodeStickerId(_selectedStickerColour);

  @override
  void initState() {
    super.initState();
    final initialSticker = widget.initialSticker;
    if (initialSticker?.stickerBytes != null) {
      _baseStickerBytes =
          initialSticker!.baseStickerBytes ?? initialSticker.stickerBytes;
      _stickerBytes = initialSticker.stickerBytes;
      _selectedStickerColour = StickerColourWheel.colourFromStickerId(
        initialSticker.stickerId,
      );
      _stickerTintEnabled =
          initialSticker.stickerTintEnabled ??
          StickerColourWheel.isColourStickerId(initialSticker.stickerId);
      _selectedGradient = StickerGradientPreset.values
          .where(
            (preset) =>
                preset.stickerId ==
                (initialSticker.gradientColorId ??
                    (initialSticker.stickerId?.startsWith('gradient_') == true
                        ? initialSticker.stickerId
                        : null)),
          )
          .firstOrNull;
      _whiteOutlineEnabled = initialSticker.whiteOutlineEnabled;
      _outlineThickness = initialSticker.outlineThickness;
      _innerShadowEnabled = initialSticker.innerShadowEnabled;
      _dropShadowEnabled = initialSticker.dropShadowEnabled;
      _dropShadowStrength = initialSticker.dropShadowStrength;
      _advancedEffect = AdvancedStickerEffect.values.firstWhere(
        (effect) => effect.name == initialSticker.advancedEffectId,
        orElse: () => AdvancedStickerEffect.none,
      );
      if (!StickerColourWheel.isColourStickerId(initialSticker.stickerId)) {
        _preservedStickerId = initialSticker.stickerId;
      }
      if (_photos.isEmpty) {
        _photos.add(initialSticker);
      }
      _stickerAnimation = StickerAnimation.values.firstWhere(
        (animation) => animation.assetPath == initialSticker.animationAsset,
        orElse: () => StickerAnimation.none,
      );
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
            animationAsset: _stickerAnimation.assetPath,
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
          const SizedBox(height: 24),
          const Text(
            'Sticker animation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose whether to play an animation over this sticker in previews and Profile.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('No animation'),
                selected: _stickerAnimation == StickerAnimation.none,
                onSelected: _baseStickerBytes == null || _busy
                    ? null
                    : (_) => setState(
                        () => _stickerAnimation = StickerAnimation.none,
                      ),
              ),
              ChoiceChip(
                label: const Text('Add animation'),
                selected: _stickerAnimation != StickerAnimation.none,
                onSelected: _baseStickerBytes == null || _busy
                    ? null
                    : (_) {
                        if (_stickerAnimation == StickerAnimation.none) {
                          setState(
                            () => _stickerAnimation = StickerAnimation.fire,
                          );
                        }
                      },
              ),
            ],
          ),
          if (_stickerAnimation != StickerAnimation.none) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: StickerAnimation.values
                  .where((animation) => animation != StickerAnimation.none)
                  .map(
                    (animation) => ChoiceChip(
                      label: Text(animation.label),
                      selected: _stickerAnimation == animation,
                      onSelected: _baseStickerBytes == null || _busy
                          ? null
                          : (_) =>
                                setState(() => _stickerAnimation = animation),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 28),
          const Text(
            'Choose sticker colour',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a colour from the wheel to tint the final sticker PNG.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
          const SizedBox(height: 14),
          StickerColourWheel(
            selectedColour: _selectedStickerColour,
            enabled: _baseStickerBytes != null && !_busy,
            onColourSelected: (colour) {
              setState(() {
                _selectedStickerColour = colour;
                _selectedGradient = null;
                _stickerTintEnabled = true;
                _preservedStickerId = null;
              });
              unawaited(_refreshStickerEffects());
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Gradient colours',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: StickerGradientPreset.values
                .map(
                  (preset) => ChoiceChip(
                    avatar: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: preset.colors),
                      ),
                    ),
                    label: Text(preset.label),
                    selected: _selectedGradient == preset,
                    onSelected: _baseStickerBytes == null || _busy
                        ? null
                        : (_) {
                            setState(() {
                              _selectedGradient = preset;
                              _stickerTintEnabled = false;
                              _preservedStickerId = null;
                            });
                            unawaited(_refreshStickerEffects());
                          },
                  ),
                )
                .toList(),
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
              stickerTintColor: _stickerTintEnabled
                  ? _selectedStickerColour
                  : null,
              stickerGradientColors: _selectedGradient?.colors,
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
      stickerTintColor: _stickerTintEnabled ? _selectedStickerColour : null,
      stickerGradientColors: _selectedGradient?.colors,
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
    final baseStickerBytes = _baseStickerBytes;
    if (stickerBytes == null || baseStickerBytes == null || _photos.isEmpty) {
      return;
    }
    widget.onSaved(
      _photos[selectedPhotoIndex].copyWith(
        baseStickerBytes: baseStickerBytes,
        whiteOutlineEnabled: _whiteOutlineEnabled,
        outlineThickness: _outlineThickness,
        innerShadowEnabled: _innerShadowEnabled,
        dropShadowEnabled: _dropShadowEnabled,
        dropShadowStrength: _dropShadowStrength,
        advancedEffectId: _advancedEffect.name,
        stickerTintEnabled: _stickerTintEnabled,
        gradientColorId: _selectedGradient?.stickerId,
        clearGradientColorId: _selectedGradient == null,
      ),
      stickerBytes,
      selectedStickerId,
      _stickerAnimation.assetPath,
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
  Color? stickerTintColor,
  List<Color>? stickerGradientColors,
}) async {
  if (!whiteOutline &&
      !innerShadow &&
      !dropShadow &&
      advancedEffect == AdvancedStickerEffect.none &&
      stickerTintColor == null &&
      stickerGradientColors == null) {
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
    if (stickerTintColor != null) {
      await _drawColourTintSurface(
        canvas,
        image,
        Offset(margin.toDouble(), margin.toDouble()),
        stickerTintColor,
      );
    }
    if (stickerGradientColors != null) {
      await _drawColourGradientSurface(
        canvas,
        image,
        Offset(margin.toDouble(), margin.toDouble()),
        stickerGradientColors,
      );
    }
    switch (advancedEffect) {
      case AdvancedStickerEffect.none:
        break;
      case AdvancedStickerEffect.pinkGlitter:
        await _drawBrightGlitterSurface(
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

Future<void> _drawColourTintSurface(
  Canvas canvas,
  ui.Image image,
  Offset origin,
  Color colour,
) async {
  await _drawMaskedSurface(canvas, image, origin, (canvas, bounds) {
    final tintPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colour.withValues(alpha: 0.28),
          Color.lerp(colour, Colors.white, 0.42)!.withValues(alpha: 0.20),
          Color.lerp(colour, Colors.black, 0.12)!.withValues(alpha: 0.24),
        ],
        stops: const [0.0, 0.46, 1.0],
      ).createShader(bounds)
      ..blendMode = BlendMode.srcOver;
    canvas.drawRect(bounds, tintPaint);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.45, -0.55),
        radius: 1.05,
        colors: [
          Colors.white.withValues(alpha: 0.14),
          colour.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(bounds)
      ..blendMode = BlendMode.plus;
    canvas.drawRect(bounds, glowPaint);
  });
}

Future<void> _drawColourGradientSurface(
  Canvas canvas,
  ui.Image image,
  Offset origin,
  List<Color> colours,
) async {
  await _drawMaskedSurface(canvas, image, origin, (canvas, bounds) {
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colours
            .map((colour) => colour.withValues(alpha: 0.56))
            .toList(),
      ).createShader(bounds)
      ..blendMode = BlendMode.srcOver;
    canvas.drawRect(bounds, gradientPaint);

    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.45, -0.55),
        radius: 1.05,
        colors: [Colors.white.withValues(alpha: 0.04), Colors.transparent],
      ).createShader(bounds)
      ..blendMode = BlendMode.plus;
    canvas.drawRect(bounds, highlightPaint);
  });
}

Future<void> _drawBrightGlitterSurface(
  Canvas canvas,
  ui.Image image,
  Offset origin,
) async {
  await _drawMaskedSurface(canvas, image, origin, (canvas, bounds) {
    final velvetPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xffff00ba).withValues(alpha: 0.82),
          const Color(0xff5b003f).withValues(alpha: 0.92),
          const Color(0xffff64d4).withValues(alpha: 0.84),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(bounds)
      ..blendMode = BlendMode.srcATop;
    canvas.drawRect(bounds, velvetPaint);

    final glitterPalette = <Color>[
      const Color(0xffff2fc4),
      const Color(0xffff9ee8),
      const Color(0xffffffff),
      const Color(0xffa30079),
      const Color(0xff00eaff),
      const Color(0xfffff166),
      const Color(0xff9d4dff),
    ];

    for (var row = 0; row < 18; row += 1) {
      for (var col = 0; col < 18; col += 1) {
        final x =
            bounds.left +
            (col + 0.22 + ((row * 5 + col) % 7) * 0.045) * bounds.width / 18.1;
        final y =
            bounds.top +
            (row + 0.18 + ((col * 3 + row) % 5) * 0.055) * bounds.height / 18.1;
        final radius =
            bounds.shortestSide * (0.0045 + ((row + col) % 4) * 0.0022);
        canvas.drawCircle(
          Offset(x, y),
          radius,
          Paint()
            ..isAntiAlias = true
            ..color = glitterPalette[(row * 2 + col) % glitterPalette.length]
                .withValues(alpha: 0.92)
            ..blendMode = BlendMode.plus,
        );
      }
    }

    for (var i = 0; i < 42; i += 1) {
      final center = Offset(
        bounds.left + (((i * 37 + 9) % 127) / 126.0) * bounds.width,
        bounds.top + (((i * 59 + 17) % 131) / 130.0) * bounds.height,
      );
      final size = bounds.shortestSide * (0.014 + (i % 5) * 0.0045);
      final path = Path()
        ..moveTo(center.dx, center.dy - size)
        ..lineTo(center.dx + size * 0.92, center.dy - size * 0.18)
        ..lineTo(center.dx + size * 0.38, center.dy + size * 0.18)
        ..lineTo(center.dx + size * 0.62, center.dy + size)
        ..lineTo(center.dx, center.dy + size * 0.48)
        ..lineTo(center.dx - size * 0.62, center.dy + size)
        ..lineTo(center.dx - size * 0.38, center.dy + size * 0.18)
        ..lineTo(center.dx - size * 0.92, center.dy - size * 0.18)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..isAntiAlias = true
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 1),
              glitterPalette[i % glitterPalette.length].withValues(alpha: 0.95),
              const Color(0xffff00b7).withValues(alpha: 0.54),
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: size * 1.25))
          ..blendMode = BlendMode.plus,
      );
    }

    final sparklePaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 1)
      ..blendMode = BlendMode.plus;
    for (final centerFraction in const <Offset>[
      Offset(0.14, 0.28),
      Offset(0.24, 0.64),
      Offset(0.38, 0.18),
      Offset(0.50, 0.52),
      Offset(0.64, 0.32),
      Offset(0.76, 0.70),
      Offset(0.88, 0.44),
      Offset(0.42, 0.84),
    ]) {
      _drawSparkle(
        canvas,
        Offset(
          bounds.left + centerFraction.dx * bounds.width,
          bounds.top + centerFraction.dy * bounds.height,
        ),
        bounds.shortestSide * 0.055,
        sparklePaint,
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
    final foilWashPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xff00f6ff).withValues(alpha: 0.40),
          const Color(0xff47ff73).withValues(alpha: 0.34),
          const Color(0xffffff45).withValues(alpha: 0.38),
          const Color(0xffff8a00).withValues(alpha: 0.34),
          const Color(0xffff40d4).withValues(alpha: 0.42),
          const Color(0xff5e65ff).withValues(alpha: 0.38),
          const Color(0xff00f6ff).withValues(alpha: 0.40),
        ],
      ).createShader(bounds)
      ..blendMode = BlendMode.plus;
    canvas.drawRect(bounds, foilWashPaint);

    final prismColors = <Color>[
      const Color(0xff00f5ff),
      const Color(0xff39ff88),
      const Color(0xffffff4d),
      const Color(0xffff7f00),
      const Color(0xffff35ce),
      const Color(0xff865cff),
      Colors.white,
    ];

    for (var stripe = 0; stripe < 9; stripe += 1) {
      final stripePaint = Paint()
        ..isAntiAlias = true
        ..strokeWidth = bounds.shortestSide * (0.030 + (stripe % 3) * 0.006)
        ..strokeCap = StrokeCap.round
        ..color = prismColors[stripe % prismColors.length].withValues(
          alpha: 0.36,
        )
        ..blendMode = BlendMode.plus;
      final y = bounds.top + bounds.height * (0.08 + stripe * 0.105);
      canvas.drawLine(
        Offset(bounds.left - bounds.width * 0.05, y),
        Offset(bounds.right + bounds.width * 0.05, y + bounds.height * 0.20),
        stripePaint,
      );
    }

    for (var i = 0; i < 46; i += 1) {
      final center = Offset(
        bounds.left + (((i * 29 + 7) % 149) / 148.0) * bounds.width,
        bounds.top + (((i * 43 + 13) % 151) / 150.0) * bounds.height,
      );
      final w = bounds.shortestSide * (0.032 + (i % 5) * 0.008);
      final h = bounds.shortestSide * (0.010 + (i % 4) * 0.004);
      final path = Path()
        ..moveTo(center.dx - w * 0.65, center.dy - h)
        ..lineTo(center.dx + w * 0.55, center.dy - h * 0.34)
        ..lineTo(center.dx + w * 0.65, center.dy + h)
        ..lineTo(center.dx - w * 0.55, center.dy + h * 0.34)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..isAntiAlias = true
          ..shader =
              LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.96),
                  prismColors[i % prismColors.length].withValues(alpha: 0.86),
                  prismColors[(i + 2) % prismColors.length].withValues(
                    alpha: 0.70,
                  ),
                ],
              ).createShader(
                Rect.fromCenter(center: center, width: w * 2, height: h * 2),
              )
          ..blendMode = BlendMode.plus,
      );
    }

    for (var i = 0; i < 120; i += 1) {
      final radius = bounds.shortestSide * (0.004 + (i % 5) * 0.0022);
      canvas.drawCircle(
        Offset(
          bounds.left + (((i * 17 + 5) % 157) / 156.0) * bounds.width,
          bounds.top + (((i * 31 + 19) % 163) / 162.0) * bounds.height,
        ),
        radius,
        Paint()
          ..isAntiAlias = true
          ..color = prismColors[i % prismColors.length].withValues(alpha: 0.88)
          ..blendMode = BlendMode.plus,
      );
    }

    final sparklePaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 2.9
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 1)
      ..blendMode = BlendMode.plus;
    for (final centerFraction in const <Offset>[
      Offset(0.13, 0.30),
      Offset(0.25, 0.58),
      Offset(0.38, 0.18),
      Offset(0.50, 0.46),
      Offset(0.62, 0.72),
      Offset(0.74, 0.34),
      Offset(0.86, 0.61),
      Offset(0.45, 0.84),
    ]) {
      _drawSparkle(
        canvas,
        Offset(
          bounds.left + centerFraction.dx * bounds.width,
          bounds.top + centerFraction.dy * bounds.height,
        ),
        bounds.shortestSide * 0.048,
        sparklePaint,
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
    required this.animationAsset,
  });

  final SavedFlowerPhoto? photo;
  final Uint8List? stickerBytes;
  final String? animationAsset;

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
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        key: const ValueKey('sticker-preview-animation-layers'),
        children: [
          if (animationAsset == rewardLightAnimationAsset)
            StickerAnimationOverlay(
              key: ValueKey(animationAsset),
              stickerBytes: stickerBytes,
              animationAsset: animationAsset!,
              opacity: 0.82,
            ),
          image,
          if (animationAsset != null &&
              animationAsset != rewardLightAnimationAsset &&
              (animationAsset != fireAnimationAsset || stickerBytes != null))
            StickerAnimationOverlay(
              key: ValueKey(animationAsset),
              stickerBytes: stickerBytes,
              animationAsset: animationAsset!,
              opacity: 0.82,
            ),
        ],
      ),
    );
  }
}

class StickerColourWheel extends StatelessWidget {
  const StickerColourWheel({
    required this.selectedColour,
    required this.enabled,
    required this.onColourSelected,
    super.key,
  });

  static const defaultColour = Color(0xffff6fb5);

  static const colours = <Color>[
    Color(0xffff6fb5),
    Color(0xffff3b6b),
    Color(0xffff8a00),
    Color(0xffffd84d),
    Color(0xff5be36b),
    Color(0xff1fc9a8),
    Color(0xff45c7ff),
    Color(0xff4978ff),
    Color(0xff9b5cff),
    Color(0xffff62e2),
  ];

  final Color selectedColour;
  final bool enabled;
  final ValueChanged<Color> onColourSelected;

  static String encodeStickerId(Color colour) =>
      'colour_${colour.toARGB32().toRadixString(16).padLeft(8, '0')}';

  static bool isColourStickerId(String? stickerId) =>
      stickerId != null &&
      (stickerId == 'colour_change' ||
          stickerId == 'colour_variation' ||
          stickerId == 'bubble_border' ||
          stickerId.startsWith('gradient_') ||
          stickerId.startsWith('colour_'));

  static Color colourFromStickerId(String? stickerId) {
    if (stickerId == null) return defaultColour;
    if (stickerId == 'colour_change') return const Color(0xffd6eaa9);
    if (stickerId == 'colour_variation') return const Color(0xff9cc7ff);
    if (stickerId == 'bubble_border') return const Color(0xffc8f7ff);
    if (!stickerId.startsWith('colour_')) return defaultColour;
    final value = int.tryParse(stickerId.substring(7), radix: 16);
    return value == null ? defaultColour : Color(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox.square(
            dimension: 188,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedColour,
                    boxShadow: [
                      BoxShadow(
                        color: selectedColour.withValues(alpha: 0.36),
                        blurRadius: 18,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.brush, color: Colors.white),
                ),
                for (var i = 0; i < colours.length; i += 1)
                  Transform.translate(
                    offset: Offset.fromDirection(
                      -1.5708 + (i / colours.length) * 6.28318,
                      74,
                    ),
                    child: _ColourWheelButton(
                      colour: colours[i],
                      selected:
                          colours[i].toARGB32() == selectedColour.toARGB32(),
                      enabled: enabled,
                      onTap: () => onColourSelected(colours[i]),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            enabled
                ? 'Selected colour is applied to the sticker preview and saved PNG.'
                : 'Generate a sticker first, then choose a colour.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _ColourWheelButton extends StatelessWidget {
  const _ColourWheelButton({
    required this.colour,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final Color colour;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sticker colour',
      selected: selected,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: selected ? 46 : 40,
          height: selected ? 46 : 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colour.withValues(alpha: enabled ? 1 : 0.34),
            border: Border.all(
              color: selected ? const Color(0xff2f6b4f) : Colors.white,
              width: selected ? 4 : 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colour.withValues(alpha: 0.48),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: selected ? const Icon(Icons.check, color: Colors.white) : null,
        ),
      ),
    );
  }
}
