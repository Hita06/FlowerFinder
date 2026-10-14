// FlowerFinder - Saved Flowers
// Created by Hita
// Includes debug-only sample data for reminder testing.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'flower_information_page.dart';
import 'flower_storage_service.dart';
import 'watering_reminder_page.dart';

class SavedFlowersPage extends StatefulWidget {
  const SavedFlowersPage({super.key});

  @override
  State<SavedFlowersPage> createState() => _SavedFlowersPageState();
}

class _SavedFlowersPageState extends State<SavedFlowersPage> {
  final FlowerStorageService _storage = FlowerStorageService();

  List<Map<String, dynamic>> _flowers = [];
  bool _isLoading = true;
  bool _addingSample = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFlowers();
  }

  Future<void> _loadFlowers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final flowers = await _storage.loadFlowers();
      final resolvedFlowers = <Map<String, dynamic>>[];

      for (final flower in flowers) {
        final imagePath = await _storage.resolveImagePath(
          flower['imageFileName'] as String?,
        );

        resolvedFlowers.add({
          ...flower,
          'imagePath': imagePath,
        });
      }

      if (!mounted) return;

      setState(() {
        _flowers = resolvedFlowers;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not load your saved flowers.';
        _isLoading = false;
      });
    }
  }

  Future<void> _addSample() async {
    if (!kDebugMode || _addingSample || _isLoading) return;

    setState(() => _addingSample = true);

    try {
      const sampleName = 'Rose — TEST SAMPLE';
      final existing = await _storage.loadFlowers();

      if (!existing.any((flower) => flower['flowerName'] == sampleName)) {
        await _storage.saveFlower(
          flowerName: sampleName,
          scientificName: 'Test data',
          description:
              'Sample record for testing watering reminders. '
              'This flower was not identified by PlantNet.',
          flowerType: 'Test sample',
          flowerColour: 'Not verified',
          season: 'Not verified',
          careTips:
              'Use this sample to test notification scheduling '
              'and cancellation.',
        );
      }

      if (!mounted) return;
      await _loadFlowers();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test sample ready. Tap its bell to test reminders.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the test sample.')),
      );
    } finally {
      if (mounted) setState(() => _addingSample = false);
    }
  }

  String _text(Map<String, dynamic> flower, String field) {
    return flower[field]?.toString() ?? 'Not available';
  }

  Future<void> _openFlower(Map<String, dynamic> flower) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => FlowerInformationPage(
          flowerName: _text(flower, 'flowerName'),
          scientificName: _text(flower, 'scientificName'),
          description: _text(flower, 'description'),
          flowerType: _text(flower, 'flowerType'),
          flowerColour: _text(flower, 'flowerColour'),
          season: _text(flower, 'season'),
          careTips: _text(flower, 'careTips'),
          imagePath: flower['imagePath'] as String?,
          isAlreadySaved: true,
        ),
      ),
    );

    if (!mounted) return;
    await _loadFlowers();
  }

  Future<void> _openReminder(Map<String, dynamic> flower) async {
    final plantId = flower['id']?.toString();

    if (plantId == null || plantId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This flower needs a saved ID for reminders.'),
        ),
      );
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => WateringReminderPage(
          plantId: plantId,
          plantName: _text(flower, 'flowerName'),
        ),
      ),
    );
  }

  Widget _thumbnail(String? imagePath) {
    const fallback = ColoredBox(
      color: lightGreen,
      child: Icon(Icons.local_florist, color: darkGreen),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        height: 64,
        child: imagePath == null
            ? fallback
            : Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
      ),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: darkGreen),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadFlowers,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_flowers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_florist_outlined,
                size: 72,
                color: darkGreen,
              ),
              SizedBox(height: 16),
              Text(
                'No saved flowers yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Identify a flower and tap Save Flower '
                'on its information page.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFlowers,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _flowers.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final flower = _flowers[index];

          return Card(
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: _thumbnail(flower['imagePath'] as String?),
              title: Text(
                _text(flower, 'flowerName'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              subtitle: Text(_text(flower, 'scientificName')),
              trailing: IconButton(
                tooltip: 'Watering reminder',
                icon: const Icon(
                  Icons.notifications_active_outlined,
                  color: darkGreen,
                ),
                onPressed: () => _openReminder(flower),
              ),
              onTap: () => _openFlower(flower),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        title: const Text('Saved Flowers'),
        centerTitle: true,
        backgroundColor: mainGreen,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: 'Refresh saved flowers',
            onPressed: _isLoading || _addingSample ? null : _loadFlowers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _body(),
      bottomNavigationBar: kDebugMode
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: _isLoading || _addingSample ? null : _addSample,
                  icon: const Icon(Icons.science_outlined),
                  label: Text(
                    _addingSample
                        ? 'Saving sample…'
                        : 'Add sample flower (debug testing)',
                  ),
                ),
              ),
            )
          : null,
    );
  }
}