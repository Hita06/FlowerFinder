import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FlowerStorageService {
  Future<Directory> _storageDirectory() async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory('${documents.path}/saved_flowers');
    await directory.create(recursive: true);
    return directory;
  }

  Future<List<Map<String, dynamic>>> loadFlowers() async {
    final directory = await _storageDirectory();
    final file = File('${directory.path}/flowers.json');

    if (!await file.exists()) return [];

    final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;

    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> saveFlower({
    required String flowerName,
    required String scientificName,
    required String description,
    required String flowerType,
    required String flowerColour,
    required String season,
    required String careTips,
    String? imagePath,
  }) async {
    final directory = await _storageDirectory();
    final flowers = await loadFlowers();
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    String? imageFileName;

    if (imagePath != null) {
      final source = File(imagePath);
      final extension = source.uri.pathSegments.last.contains('.')
          ? source.uri.pathSegments.last.split('.').last
          : 'jpg';

      imageFileName = '$id.$extension';
      await source.copy('${directory.path}/$imageFileName');
    }

    flowers.insert(0, {
      'id': id,
      'flowerName': flowerName,
      'scientificName': scientificName,
      'description': description,
      'flowerType': flowerType,
      'flowerColour': flowerColour,
      'season': season,
      'careTips': careTips,
      'imageFileName': imageFileName,
      'savedAt': DateTime.now().toIso8601String(),
    });

    final file = File('${directory.path}/flowers.json');
    await file.writeAsString(jsonEncode(flowers), flush: true);
  }

  Future<void> deleteFlower(String plantId) async {
    if (plantId.trim().isEmpty) {
      throw ArgumentError('A saved flower ID is required.');
    }

    final directory = await _storageDirectory();
    final flowers = await loadFlowers();
    final removed = flowers
        .where((flower) => flower['id']?.toString() == plantId)
        .toList();

    flowers.removeWhere((flower) => flower['id']?.toString() == plantId);

    final file = File('${directory.path}/flowers.json');
    await file.writeAsString(jsonEncode(flowers), flush: true);

    // The record has been deleted even if photo cleanup fails.
    for (final flower in removed) {
      final name = flower['imageFileName'];
      if (name is String &&
          !flowers.any((item) => item['imageFileName'] == name)) {
        try {
          final image = File('${directory.path}/$name');
          if (await image.exists()) await image.delete();
        } on FileSystemException {
          // An unused photo can be cleaned up later.
        }
      }
    }
  }

  Future<String?> resolveImagePath(String? imageFileName) async {
    if (imageFileName == null) return null;

    final directory = await _storageDirectory();
    final file = File('${directory.path}/$imageFileName');

    return await file.exists() ? file.path : null;
  }
}
