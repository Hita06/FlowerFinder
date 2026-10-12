// FlowerFinder - PlantNet API Service
// Created by Iris

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FlowerApi {
  static Future<Map<String, dynamic>> identifyFlower(
    String imagePath,
  ) async {
    final String? apiKey = dotenv.env['PLANTNET_API_KEY'];

    if (apiKey == null || apiKey.trim().isEmpty) {
      throw Exception('The PlantNet API key is missing.');
    }

    final Uri uri = Uri.https(
      'my-api.plantnet.org',
      '/v2/identify/all',
      {
        'api-key': apiKey.trim(),
        'lang': 'en',
        'nb-results': '3',
      },
    );

    try {
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('images', imagePath),
      );

      request.fields['organs'] = 'flower';

      final streamedResponse = await request.send();
      final String responseBody =
          await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final dynamic decodedResponse = jsonDecode(responseBody);

        if (decodedResponse is! Map<String, dynamic>) {
          throw const FormatException('Unexpected PlantNet response.');
        }

        return decodedResponse;
      }

      if (streamedResponse.statusCode == 401 ||
          streamedResponse.statusCode == 403) {
        throw Exception(
          'PlantNet rejected the request. '
          'Status: ${streamedResponse.statusCode}',
        );
      }

      if (streamedResponse.statusCode == 429) {
        throw Exception('The PlantNet request limit has been reached.');
      }

      throw Exception(
        'Flower identification failed. '
        'Status: ${streamedResponse.statusCode}',
      );
    } on http.ClientException {
      throw Exception('A network connection to PlantNet could not be made.');
    } on FormatException {
      throw Exception('PlantNet returned information in an unexpected format.');
    }
  }
}