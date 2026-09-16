// FlowerFinder - Perenual API Service
// Created by Hita
// This file sends plant search and filter requests to the Perenual API.

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Handles communication between FlowerFinder and Perenual.
class PerenualService {
  // Searches Perenual using a name and optional plant filters.
  Future<List<Map<String, dynamic>>> searchPlants(
    String searchText, {
    String? cycle,
    String? watering,
    String? sunlight,
    bool? indoor,
  }) async {
    // Reads the private API key from the local .env file.
    final String? apiKey = dotenv.env['PERENUAL_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('The Perenual API key is missing.');
    }

    // Stores the values that will be sent to Perenual.
    final Map<String, String> queryParameters = {
      'key': apiKey,
    };

    // Adds the search text only when one was entered.
    if (searchText.trim().isNotEmpty) {
      queryParameters['q'] = searchText.trim();
    }

    // Adds only the filters selected by the user.
    if (cycle != null) {
      queryParameters['cycle'] = cycle;
    }

    if (watering != null) {
      queryParameters['watering'] = watering;
    }

    if (sunlight != null) {
      queryParameters['sunlight'] = sunlight;
    }

    if (indoor != null) {
      queryParameters['indoor'] = indoor ? '1' : '0';
    }

    // Builds the API address without placing the key in this code.
    final Uri requestUrl = Uri.https(
      'perenual.com',
      '/api/v2/species-list',
      queryParameters,
    );

    try {
      final http.Response response = await http.get(requestUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(response.body) as Map<String, dynamic>;

        final List<dynamic> plants =
            responseData['data'] as List<dynamic>? ?? [];

        return plants
            .map(
              (plant) => Map<String, dynamic>.from(
                plant as Map,
              ),
            )
            .toList();
      }

      if (response.statusCode == 401 ||
          response.statusCode == 403) {
        throw Exception(
          'The Perenual API key was not accepted.',
        );
      }

      if (response.statusCode == 429) {
        throw Exception(
          'The Perenual request limit has been reached.',
        );
      }

      throw Exception(
        'The plant search could not be completed. '
        'Status: ${response.statusCode}',
      );
    } on http.ClientException {
      throw Exception(
        'A network connection to Perenual could not be made.',
      );
    } on FormatException {
      throw Exception(
        'Perenual returned information in an unexpected format.',
      );
    }
  }
}