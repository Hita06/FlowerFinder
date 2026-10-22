// FlowerFinder - Recently Viewed Flowers
// Created by Hita

import 'dart:io';

import 'package:flutter/material.dart';

import 'flower_information_page.dart';
import 'recent_flowers_service.dart';

class RecentFlowersPage extends StatefulWidget {
  const RecentFlowersPage({super.key});

  @override
  State<RecentFlowersPage> createState() => _RecentFlowersPageState();
}

class _RecentFlowersPageState extends State<RecentFlowersPage> {
  final RecentFlowersService _storage = RecentFlowersService();

  List<Map<String, dynamic>> _flowers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFlowers();
  }

  Future<void> _loadFlowers() async {
    setState(() {
      _loading = true;
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
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not load recently viewed flowers.';
        _loading = false;
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
        ),
      ),
    );

    if (!mounted) return;

    await _loadFlowers();
  }

  Widget _thumbnail(String? imagePath) {
    const placeholder = Icon(Icons.local_florist, size: 36, color: darkGreen);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 60,
        height: 60,
        child: imagePath == null
            ? const ColoredBox(
                color: lightGreen,
                child: Center(child: placeholder),
              )
            : Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const ColoredBox(
                    color: lightGreen,
                    child: Center(child: placeholder),
                  );
                },
              ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: darkGreen));
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
              FilledButton(
                onPressed: _loadFlowers,
                child: const Text('Try again'),
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
              Icon(Icons.history, size: 64, color: darkGreen),
              SizedBox(height: 16),
              Text(
                'No recently viewed flowers yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Open a flower information page to see it here.',
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
              trailing: const Icon(Icons.chevron_right, color: darkGreen),
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
        title: const Text('Recently Viewed'),
        centerTitle: true,
        backgroundColor: mainGreen,
        foregroundColor: Colors.black,
      ),
      body: _body(),
    );
  }
}
