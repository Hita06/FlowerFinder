// FlowerFinder - PlantNet API Service
// Created by Iris
// Updated to load the PlantNet API key securely from the .env file.

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FlowerApi {
  // Sends a flower image to PlantNet for identification.
  static Future<Map<String, dynamic>> identifyFlower(String imagePath) async {
    // Reads the PlantNet API key from the local .env file.
    final String? apiKey = dotenv.env['PLANTNET_API_KEY'];

    if (apiKey == null || apiKey.trim().isEmpty) {
      throw Exception('The PlantNet API key is missing.');
    }

    // Builds the PlantNet API request address.
    final Uri uri = Uri.https('my-api.plantnet.org', '/v2/identify/all', {
      'api-key': apiKey.trim(),
      'lang': 'en',
      'nb-results': '3',
    });

    try {
      final request = http.MultipartRequest('POST', uri);

      // Adds the selected flower image.
      request.files.add(await http.MultipartFile.fromPath('images', imagePath));

      // Tells PlantNet that the image shows a flower.
      request.fields['organs'] = 'flower';

      final streamedResponse = await request.send();

      final String responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final dynamic decodedResponse = jsonDecode(responseBody);

        if (decodedResponse is! Map<String, dynamic>) {
          throw const FormatException('Unexpected PlantNet response.');
        }

        return decodedResponse;
      }

      if (streamedResponse.statusCode == 401 ||
          streamedResponse.statusCode == 403) {
        throw Exception('The PlantNet API key was not accepted.');
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
