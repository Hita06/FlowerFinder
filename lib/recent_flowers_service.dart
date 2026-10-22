// FlowerFinder - Recently Viewed Flowers
// Created by Hita

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class RecentFlowersService {
  RecentFlowersService({this.directoryProvider});

  final Future<Directory> Function()? directoryProvider;

  // Keeps overlapping updates in order.
  static Future<void> _writeQueue = Future<void>.value();

  Future<Directory> _directory() async {
    final documents = directoryProvider == null
        ? await getApplicationDocumentsDirectory()
        : await directoryProvider!();

    final directory = Directory('${documents.path}/recent_flowers');
    await directory.create(recursive: true);
    return directory;
  }

  Future<List<Map<String, dynamic>>> loadFlowers() async {
    final directory = await _directory();
    final file = File('${directory.path}/history.json');

    if (!await file.exists()) return [];

    final decoded = jsonDecode(await file.readAsString());

    if (decoded is! List) {
      throw const FormatException('Invalid flower history');
    }

    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> recordView({
    required String flowerName,
    required String scientificName,
    required String description,
    required String flowerType,
    required String flowerColour,
    required String season,
    required String careTips,
    String? imagePath,
  }) {
    final write = _writeQueue.then((_) async {
      final directory = await _directory();
      final flowers = await loadFlowers();

      final identity = jsonEncode([
        flowerName.trim().toLowerCase(),
        scientificName.trim().toLowerCase(),
      ]);

      String identityFor(Map<String, dynamic> flower) => jsonEncode([
        flower['flowerName'].toString().trim().toLowerCase(),
        flower['scientificName'].toString().trim().toLowerCase(),
      ]);

      final previous = flowers.where(
        (flower) => identityFor(flower) == identity,
      );

      String? imageFileName = previous.isEmpty
          ? null
          : previous.first['imageFileName'] as String?;

      if (imagePath != null && await File(imagePath).exists()) {
        final id = DateTime.now().microsecondsSinceEpoch;
        final extension = imagePath.split('.').last.toLowerCase();
        final safeExtension = RegExp(r'^[a-z0-9]{1,5}$').hasMatch(extension)
            ? extension
            : 'jpg';

        imageFileName = '$id.$safeExtension';
        await File(imagePath).copy('${directory.path}/$imageFileName');
      }

      final updated = <Map<String, dynamic>>[
        {
          'flowerName': flowerName,
          'scientificName': scientificName,
          'description': description,
          'flowerType': flowerType,
          'flowerColour': flowerColour,
          'season': season,
          'careTips': careTips,
          'imageFileName': imageFileName,
          'viewedAt': DateTime.now().toIso8601String(),
        },
        ...flowers.where((flower) => identityFor(flower) != identity),
      ].take(30).toList();

      final file = File('${directory.path}/history.json');
      await file.writeAsString(jsonEncode(updated), flush: true);

      final retainedImages = updated
          .map((flower) => flower['imageFileName'])
          .whereType<String>()
          .toSet();

      // Remove photos no longer referenced by the history.
      await for (final entity in directory.list()) {
        if (entity is File) {
          final name = entity.uri.pathSegments.last;
          if (name != 'history.json' && !retainedImages.contains(name)) {
            await entity.delete();
          }
        }
      }
    });

    _writeQueue = write.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );

    return write;
  }

  Future<String?> resolveImagePath(String? imageFileName) async {
    if (imageFileName == null) return null;

    final directory = await _directory();
    final file = File('${directory.path}/$imageFileName');

    return await file.exists() ? file.path : null;
  }
}
