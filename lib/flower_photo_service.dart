import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'mock_flower_photos.dart';
import 'user_profile.dart';

class FlowerPhotoService {
  const FlowerPhotoService({this.apiKey});

  final String? apiKey;

  String get _resolvedApiKey => apiKey?.trim().isNotEmpty == true
      ? apiKey!.trim()
      : dotenv.env['PERENUAL_API_KEY']?.trim() ?? '';

  Future<List<SavedFlowerPhoto>> search(String query) async {
    final resolvedApiKey = _resolvedApiKey;
    if (resolvedApiKey.isEmpty) {
      return MockFlowerPhotoSource.photos;
    }
    final client = http.Client();
    try {
      final response = await client
          .get(
            Uri.https('www.perenual.com', '/api/v2/species-list', {
              'key': resolvedApiKey,
              'q': query.trim().isEmpty ? 'rose' : query.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        return MockFlowerPhotoSource.photos;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['data'] is! List) {
        throw const FormatException('Invalid flower response');
      }
      return (body['data'] as List).whereType<Map<String, dynamic>>().expand((
        item,
      ) {
        final image = item['default_image'];
        if (image is! Map) return <SavedFlowerPhoto>[];
        final url =
            image['regular_url'] ??
            image['medium_url'] ??
            image['original_url'];
        final uri = url is String ? Uri.tryParse(url) : null;
        if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
          return <SavedFlowerPhoto>[];
        }
        return [
          SavedFlowerPhoto(
            image: NetworkImage(url as String),
            label: item['common_name'] as String?,
          ),
        ];
      }).toList();
    } catch (_) {
      return MockFlowerPhotoSource.photos;
    } finally {
      client.close();
    }
  }
}
