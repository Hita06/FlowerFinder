// FlowerFinder G3 - Flower Information Storage
// Created by Hita

import 'dart:io';
// G10 sharing integration added by Erin.
// This page displays and shares information about an identified flower.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'services/flower_share_service.dart';

import 'flower_storage_service.dart';

const Color mainGreen = Color(0xFF5BC68D);
const Color darkGreen = Color(0xFF276749);
const Color creamBackground = Color(0xFFFFF9F2);
const Color lightGreen = Color(0xFFE4F3E8);
const Color pinkAccent = Color(0xFFF7A8C4);

class FlowerInformationPage extends StatelessWidget {
  final String flowerName;
  final String scientificName;
  final String description;
  final String flowerType;
  final String flowerColour;
  final String season;
  final String careTips;
  final String? imagePath;
  final bool isAlreadySaved;

  const FlowerInformationPage({
    super.key,
    required this.flowerName,
    required this.scientificName,
    required this.description,
    required this.flowerType,
    required this.flowerColour,
    required this.season,
    required this.careTips,
    this.imagePath,
    this.isAlreadySaved = false,
  });

  Widget _informationCard({
    required String title,
    required IconData icon,
    required Widget content,
    bool isCareCard = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCareCard ? Border.all(color: pinkAccent, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isCareCard ? pinkAccent : darkGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          content,
        ],
      ),
    );
  }

  static const FlowerShareService _shareService = FlowerShareService();

  String _buildShareText() {
    return _shareService.buildFlowerShareText(
      flowerName: flowerName,
      scientificName: scientificName,
      description: description,
      flowerType: flowerType,
      flowerColour: flowerColour,
      season: season,
      careTips: careTips,
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _shareFlower(BuildContext context) async {
    try {
      final result = await _shareService.shareFlower(
        flowerName: flowerName,
        scientificName: scientificName,
        description: description,
        flowerType: flowerType,
        flowerColour: flowerColour,
        season: season,
        careTips: careTips,
      );

      if (!context.mounted) {
        return;
      }

      if (result.status == ShareResultStatus.success) {
        _showMessage(context, 'Flower information shared successfully');
      } else if (result.status == ShareResultStatus.dismissed) {
        _showMessage(context, 'Sharing cancelled');
      } else {
        _showMessage(context, 'Sharing is not available on this device');
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'Unable to share this flower information');
    }
  }

  Future<void> _copyFlowerInformation(
    BuildContext context,
    String shareText,
  ) async {
    try {
      await Clipboard.setData(ClipboardData(text: shareText));

      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'Flower information copied to clipboard');
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'Unable to copy flower information');
    }
  }

  Future<void> _showSharePreview(BuildContext context) async {
    final shareText = _buildShareText();

    final selectedAction = await showDialog<_SharePreviewAction>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.share_outlined, color: darkGreen),
              SizedBox(width: 12),
              Expanded(child: Text('Share Flower')),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: mainGreen),
                ),
                child: SelectableText(
                  shareText,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, _SharePreviewAction.copy);
              },
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, _SharePreviewAction.cancel);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, _SharePreviewAction.share);
              },
              style: FilledButton.styleFrom(
                backgroundColor: darkGreen,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.share),
              label: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) {
      return;
    }

    if (selectedAction == _SharePreviewAction.copy) {
      await _copyFlowerInformation(context, shareText);
    } else if (selectedAction == _SharePreviewAction.share) {
      await _shareFlower(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const detailStyle = TextStyle(
      fontSize: 17,
      height: 1.7,
      color: Color(0xFF555555),
    );

    return Scaffold(
      backgroundColor: creamBackground,

      // Displays the page title and sharing action.
      appBar: AppBar(
        title: const Text(
          'Flower Information',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: mainGreen,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _showSharePreview(context);
            },
            tooltip: 'Share flower information',
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shows the scanned or saved photo.
            Container(
              width: double.infinity,
              height: 230,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(25),
              ),
              child: imagePath == null
                  ? const Icon(Icons.local_florist, size: 120, color: darkGreen)
                  : Image.file(
                      File(imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.local_florist,
                          size: 120,
                          color: darkGreen,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            Text(
              flowerName,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              scientificName,
              style: const TextStyle(
                fontSize: 17,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            _informationCard(
              title: 'About',
              icon: Icons.info_outline,
              content: Text(
                description,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.5,
                  color: Color(0xFF555555),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _informationCard(
              title: 'Flower Details',
              icon: Icons.local_florist_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type: $flowerType', style: detailStyle),
                  Text('Colour: $flowerColour', style: detailStyle),
                  Text('Season: $season', style: detailStyle),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _informationCard(
              title: 'Care Tips',
              icon: Icons.favorite_outline,
              isCareCard: true,
              content: Text(careTips, style: detailStyle),
            ),
            const SizedBox(height: 20),
            _SaveFlowerButton(flower: this),
            const SizedBox(height: 25),

            // Opens a preview before sharing.
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: () {
                  _showSharePreview(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.share),
                label: const Text(
                  'Share Flower Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SaveFlowerButton extends StatefulWidget {
  final FlowerInformationPage flower;

  const _SaveFlowerButton({required this.flower});

  @override
  State<_SaveFlowerButton> createState() => _SaveFlowerButtonState();
}

class _SaveFlowerButtonState extends State<_SaveFlowerButton> {
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.flower.isAlreadySaved;
  }

  Future<void> _saveFlower() async {
    if (_isSaving || _isSaved) return;

    setState(() => _isSaving = true);

    try {
      final flower = widget.flower;

      await FlowerStorageService().saveFlower(
        flowerName: flower.flowerName,
        scientificName: flower.scientificName,
        description: flower.description,
        flowerType: flower.flowerType,
        flowerColour: flower.flowerColour,
        season: flower.season,
        careTips: flower.careTips,
        imagePath: flower.imagePath,
      );

      if (!mounted) return;

      setState(() => _isSaved = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flower saved successfully!')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this flower. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving || _isSaved ? null : _saveFlower,
        icon: Icon(_isSaved ? Icons.check : Icons.save_outlined),
        label: Text(
          _isSaving
              ? 'Saving...'
              : _isSaved
              ? 'Flower Saved'
              : 'Save Flower',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: darkGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}

enum _SharePreviewAction { copy, cancel, share }
