// FlowerFinder - Perenual API Service
// Created by Hita
// This file sends plant search requests to the Perenual API.

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Handles communication between FlowerFinder and Perenual.
class PerenualService {
  // Searches Perenual using a flower or plant name.
  Future<List<Map<String, dynamic>>> searchPlants(String searchText) async {
    // Reads the private API key from the local .env file.
    final String? apiKey = dotenv.env['PERENUAL_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('The Perenual API key is missing.');
    }

    // Builds the API address without placing the key in the source code.
    final Uri requestUrl = Uri.https(
      'perenual.com',
      '/api/v2/species-list',
      {
        'key': apiKey,
        'q': searchText.trim(),
      },
    );

    final http.Response response = await http.get(requestUrl);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      final List<dynamic> plants = responseData['data'] as List<dynamic>;

      return plants
          .map((plant) => Map<String, dynamic>.from(plant as Map))
          .toList();
    }

    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      throw Exception('The Perenual API key was not accepted.');
    }

    throw Exception(
      'The plant search could not be completed. '
      'Status: ${response.statusCode}',
    );
  }
}