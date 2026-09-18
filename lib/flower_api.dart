import 'dart:convert';

import 'package:http/http.dart' as http;

class FlowerApi {
  static const String apiKey = '2b10cxcNdTAe2uxSXejQ0tRvWO';

  static Future<Map<String, dynamic>> identifyFlower(
    String imagePath,
  ) async {
    final uri = Uri.https(
      'my-api.plantnet.org',
      '/v2/identify/all',
      {
        'api-key': apiKey,
        'lang': 'en',
        'nb-results': '3',
      },
    );

    print('Sending request to: $uri');

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
    print('API response: $responseBody');

    if (response.statusCode != 200) {
      throw Exception(
        'Identification failed: ${response.statusCode}\n$responseBody',
      );
    }

    return jsonDecode(responseBody);
  }
}