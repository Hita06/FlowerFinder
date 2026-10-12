// FlowerFinder G3 - Saved Flowers
// Created by Hita
// Loads saved flowers and opens their information.

import 'dart:io';

import 'package:flutter/material.dart';

import 'flower_information_page.dart';
import 'flower_storage_service.dart';

class SavedFlowersPage extends StatefulWidget {
  const SavedFlowersPage({super.key});

  @override
  State<SavedFlowersPage> createState() => _SavedFlowersPageState();
}

class _SavedFlowersPageState extends State<SavedFlowersPage> {
  final FlowerStorageService _storage = FlowerStorageService();

  List<Map<String, dynamic>> _flowers = [];
  bool _isLoading = true;
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

      // Resolves photo filenames using the current app directory.
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

  String _text(Map<String, dynamic> flower, String field) {
    return flower[field]?.toString() ?? 'Not available';
  }

  Future<void> _openFlower(Map<String, dynamic> flower) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
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

  Widget _thumbnail(String? imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        height: 64,
        child: imagePath == null
            ? const ColoredBox(
                color: lightGreen,
                child: Icon(
                  Icons.local_florist,
                  color: darkGreen,
                ),
              )
            : Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const ColoredBox(
                    color: lightGreen,
                    child: Icon(
                      Icons.local_florist,
                      color: darkGreen,
                    ),
                  );
                },
              ),
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
            onPressed: _isLoading ? null : _loadFlowers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: darkGreen),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadFlowers,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _flowers.isEmpty
                  ? const Center(
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
                    )
                  : RefreshIndicator(
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
                              leading: _thumbnail(
                                flower['imagePath'] as String?,
                              ),
                              title: Text(
                                _text(flower, 'flowerName'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: darkGreen,
                                ),
                              ),
                              subtitle: Text(
                                _text(flower, 'scientificName'),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: darkGreen,
                              ),
                              onTap: () => _openFlower(flower),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}