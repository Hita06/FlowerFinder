import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FlowerApi {
  static String get apiKey => dotenv.env['PLANTNET_API_KEY'] ?? '';

  static Future<Map<String, dynamic>> identifyFlower(
    String imagePath,
  ) async {
    if (apiKey.isEmpty) {
      throw Exception('PlantNet API key is missing.');
    }

    final uri = Uri.https(
      'my-api.plantnet.org',
      '/v2/identify/all',
      {
        'api-key': apiKey,
        'lang': 'en',
        'nb-results': '3',
      },
    );

    print('Sending PlantNet identification request...');

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'images',
        imagePath,
      ),
    );

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    print('API status: ${response.statusCode}');
    print('PlantNet response received.');

    if (response.statusCode != 200) {
      throw Exception(
        'Identification failed: ${response.statusCode}\n$responseBody',
      );
    }

    return jsonDecode(responseBody);
  }
}
