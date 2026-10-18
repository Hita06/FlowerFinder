import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'sticker_animation_assets.dart';

class StickerAnimationOverlay extends StatefulWidget {
  const StickerAnimationOverlay({
    required this.stickerBytes,
    required this.animationAsset,
    required this.opacity,
    super.key,
  });

  final Uint8List? stickerBytes;
  final String animationAsset;
  final double opacity;

  @override
  State<StickerAnimationOverlay> createState() =>
      _StickerAnimationOverlayState();
}

class _StickerAnimationOverlayState extends State<StickerAnimationOverlay> {
  ui.Image? _stickerMask;

  bool get _needsStickerMask =>
      widget.animationAsset == fireFeuFuegoAnimationAsset;

  @override
  void initState() {
    super.initState();
    _loadStickerMask();
  }

  @override
  void didUpdateWidget(covariant StickerAnimationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stickerBytes != widget.stickerBytes ||
        oldWidget.animationAsset != widget.animationAsset) {
      _stickerMask?.dispose();
      _stickerMask = null;
      _loadStickerMask();
    }
  }

  @override
  void dispose() {
    _stickerMask?.dispose();
    super.dispose();
  }

  Future<void> _loadStickerMask() async {
    final stickerBytes = widget.stickerBytes;
    if (!_needsStickerMask || stickerBytes == null) return;
    final animationAsset = widget.animationAsset;

    ui.Codec? codec;
    try {
      codec = await ui.instantiateImageCodec(stickerBytes);
      final frame = await codec.getNextFrame();
      if (!mounted ||
          widget.stickerBytes != stickerBytes ||
          widget.animationAsset != animationAsset) {
        frame.image.dispose();
        return;
      }
      setState(() => _stickerMask = frame.image);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'sticker animation overlay',
          context: ErrorDescription('while loading the sticker alpha mask'),
        ),
      );
    } finally {
      codec?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final animation = Lottie.asset(
      widget.animationAsset,
      fit: BoxFit.contain,
      repeat: true,
    );
    final needsStickerMask = _needsStickerMask;
    if (needsStickerMask) {
      final stickerMask = _stickerMask;
      if (stickerMask == null) return const SizedBox.shrink();
      return IgnorePointer(
        child: Opacity(
          opacity: widget.opacity,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) {
              final scale = math.min(
                bounds.width / stickerMask.width,
                bounds.height / stickerMask.height,
              );
              final dx = (bounds.width - stickerMask.width * scale) / 2;
              final dy = (bounds.height - stickerMask.height * scale) / 2;
              final transform = Float64List.fromList([
                scale,
                0,
                0,
                0,
                0,
                scale,
                0,
                0,
                0,
                0,
                1,
                0,
                dx,
                dy,
                0,
                1,
              ]);
              return ImageShader(
                stickerMask,
                TileMode.decal,
                TileMode.decal,
                transform,
              );
            },
            child: animation,
          ),
        ),
      );
    }

    return IgnorePointer(
      child: Opacity(opacity: widget.opacity, child: animation),
    );
  }
}
