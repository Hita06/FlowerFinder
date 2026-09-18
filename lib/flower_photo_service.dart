import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'user_profile.dart';

class FlowerPhotoService {
  const FlowerPhotoService({
    this.apiKey = const String.fromEnvironment('PERENUAL_API_KEY'),
  });

  final String apiKey;

  Future<List<SavedFlowerPhoto>> search(String query) async {
    if (apiKey.isEmpty) {
      throw StateError(
        'Flower photos are not connected yet. You can still choose your own photo.',
      );
    }
    final client = http.Client();
    try {
      final response = await client
          .get(
            Uri.https('perenual.com', '/api/v2/species-list', {
              'key': apiKey,
              'q': query.trim().isEmpty ? 'rose' : query.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw StateError(
          response.statusCode == 429
              ? 'Flower photo limit reached. Please try again later.'
              : 'Flower photos are unavailable. Please try again later.',
        );
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
    } finally {
      client.close();
    }
  }
}
