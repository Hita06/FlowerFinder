// FlowerFinder - Saved Flowers and Water Care
// Created by Hita

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'flower_information_page.dart';
import 'flower_storage_service.dart';
import 'local_reminder_scheduler.dart';
import 'watering_reminder_page.dart';

class SavedFlowersPage extends StatefulWidget {
  const SavedFlowersPage({super.key, this.wateringCare = false});

  final bool wateringCare;

  @override
  State<SavedFlowersPage> createState() => _SavedFlowersPageState();
}

class _SavedFlowersPageState extends State<SavedFlowersPage> {
  final FlowerStorageService _storage = FlowerStorageService();

  List<Map<String, dynamic>> _flowers = [];
  bool _isLoading = true;
  bool _deleting = false;
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
      final resolved = <Map<String, dynamic>>[];

      for (final flower in flowers) {
        final imagePath = await _storage.resolveImagePath(
          flower['imageFileName'] as String?,
        );
        resolved.add({...flower, 'imagePath': imagePath});
      }

      if (!mounted) return;

      setState(() {
        _flowers = resolved;
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

  String _text(Map<String, dynamic> flower, String field) {
    return flower[field]?.toString() ?? 'Not available';
  }

  Future<void> _openFlower(Map<String, dynamic> flower) async {
    await Navigator.of(context).push<void>(
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

    if (mounted) await _loadFlowers();
  }

  Future<void> _openReminder(Map<String, dynamic> flower) async {
    final plantId = flower['id']?.toString();

    if (plantId == null || plantId.trim().isEmpty) {
      _message('This flower needs a saved ID for reminders.');
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => WateringReminderPage(
          plantId: plantId,
          plantName: _text(flower, 'flowerName'),
        ),
      ),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _deleteFlower(Map<String, dynamic> flower) async {
    if (_deleting) return;

    final plantId = flower['id']?.toString();
    if (plantId == null || plantId.trim().isEmpty) {
      _message('This flower has no saved ID.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete saved flower?'),
        content: Text(
          'Delete ${_text(flower, 'flowerName')} from Saved Flowers '
          'and Water Care? Its watering reminder will also be cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep Flower'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);

    try {
      final preferences = await SharedPreferences.getInstance();

      // Cancel first so a deleted flower cannot leave an active reminder.
      if (preferences.containsKey('watering.notificationId.$plantId')) {
        await LocalReminderScheduler.instance.cancel(plantId: plantId);
      }

      final settingsKey = 'watering.settings.$plantId';
      if (preferences.containsKey(settingsKey)) {
        final removed = await preferences.remove(settingsKey);
        if (!removed) {
          throw StateError('Could not remove reminder settings.');
        }
      }

      await _storage.deleteFlower(plantId);

      if (!mounted) return;
      await _loadFlowers();
      if (!mounted) return;

      _message('Saved flower deleted.');
    } catch (_) {
      if (!mounted) return;

      _message(
        'Deletion could not be completed. Please try again. '
        'The reminder may already be cancelled.',
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
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
      return const Center(child: CircularProgressIndicator(color: darkGreen));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadFlowers,
              child: const Text('Try Again'),
            ),
          ],
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
              Icon(Icons.local_florist_outlined, size: 72, color: darkGreen),
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
        separatorBuilder: (context, index) => const SizedBox(height: 12),
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Watering reminder',
                    icon: const Icon(
                      Icons.notifications_active_outlined,
                      color: darkGreen,
                    ),
                    onPressed: () => _openReminder(flower),
                  ),
                  IconButton(
                    tooltip: 'Delete saved flower',
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteFlower(flower),
                  ),
                ],
              ),
              onTap: () {
                if (widget.wateringCare) {
                  _openReminder(flower);
                } else {
                  _openFlower(flower);
                }
              },
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
        title: Text(widget.wateringCare ? 'Water Care' : 'Saved Flowers'),
        centerTitle: true,
        backgroundColor: mainGreen,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: 'Refresh saved flowers',
            onPressed: _isLoading || _deleting ? null : _loadFlowers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _deleting,
        child: Column(
          children: [
            if (_deleting) const LinearProgressIndicator(),
            if (widget.wateringCare)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'Select a flower to manage its reminder, '
                  'or use the trash icon to delete it.',
                ),
              ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }
}
