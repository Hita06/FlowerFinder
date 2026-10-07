// FlowerFinder - Perenual API Service
// Created by Hita
// This file sends plant search and filter requests to the Perenual API.

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Handles communication between FlowerFinder and Perenual.
class PerenualService {
  // Stores common flower colours for the G9 colour-filter prototype.
  // This catalogue is used because the Perenual species-list endpoint
  // does not provide a flower-colour parameter.
  static const List<Map<String, dynamic>> colourCatalogue = [
    {
      'id': 'local-red-rose',
      'common_name': 'Red Rose',
      'scientific_name': ['Rosa'],
      'flower_colour': 'red',
      'cycle': 'perennial',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-red-tulip',
      'common_name': 'Red Tulip',
      'scientific_name': ['Tulipa'],
      'flower_colour': 'red',
      'cycle': 'perennial',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-red-poppy',
      'common_name': 'Red Poppy',
      'scientific_name': ['Papaver rhoeas'],
      'flower_colour': 'red',
      'cycle': 'annual',
      'watering': 'minimum',
      'default_image': null,
    },
    {
      'id': 'local-pink-rose',
      'common_name': 'Pink Rose',
      'scientific_name': ['Rosa'],
      'flower_colour': 'pink',
      'cycle': 'perennial',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-pink-carnation',
      'common_name': 'Pink Carnation',
      'scientific_name': ['Dianthus caryophyllus'],
      'flower_colour': 'pink',
      'cycle': 'perennial',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-cherry-blossom',
      'common_name': 'Pink Cherry Blossom',
      'scientific_name': ['Prunus serrulata'],
      'flower_colour': 'pink',
      'cycle': 'perennial',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-white-lily',
      'common_name': 'White Lily',
      'scientific_name': ['Lilium candidum'],
      'flower_colour': 'white',
      'cycle': 'perennial',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-white-daisy',
      'common_name': 'White Daisy',
      'scientific_name': ['Bellis perennis'],
      'flower_colour': 'white',
      'cycle': 'perennial',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-gardenia',
      'common_name': 'White Gardenia',
      'scientific_name': ['Gardenia jasminoides'],
      'flower_colour': 'white',
      'cycle': 'perennial',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-sunflower',
      'common_name': 'Yellow Sunflower',
      'scientific_name': ['Helianthus annuus'],
      'flower_colour': 'yellow',
      'cycle': 'annual',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-daffodil',
      'common_name': 'Yellow Daffodil',
      'scientific_name': ['Narcissus'],
      'flower_colour': 'yellow',
      'cycle': 'perennial',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-yellow-marigold',
      'common_name': 'Yellow Marigold',
      'scientific_name': ['Tagetes'],
      'flower_colour': 'yellow',
      'cycle': 'annual',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-orange-marigold',
      'common_name': 'Orange Marigold',
      'scientific_name': ['Tagetes erecta'],
      'flower_colour': 'orange',
      'cycle': 'annual',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-tiger-lily',
      'common_name': 'Orange Tiger Lily',
      'scientific_name': ['Lilium lancifolium'],
      'flower_colour': 'orange',
      'cycle': 'perennial',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-calendula',
      'common_name': 'Orange Calendula',
      'scientific_name': ['Calendula officinalis'],
      'flower_colour': 'orange',
      'cycle': 'annual',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-lavender',
      'common_name': 'Purple Lavender',
      'scientific_name': ['Lavandula'],
      'flower_colour': 'purple',
      'cycle': 'perennial',
      'watering': 'minimum',
      'default_image': null,
    },
    {
      'id': 'local-purple-iris',
      'common_name': 'Purple Iris',
      'scientific_name': ['Iris germanica'],
      'flower_colour': 'purple',
      'cycle': 'perennial',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-violet',
      'common_name': 'Purple Violet',
      'scientific_name': ['Viola'],
      'flower_colour': 'purple',
      'cycle': 'perennial',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-blue-hydrangea',
      'common_name': 'Blue Hydrangea',
      'scientific_name': ['Hydrangea macrophylla'],
      'flower_colour': 'blue',
      'cycle': 'perennial',
      'watering': 'frequent',
      'default_image': null,
    },
    {
      'id': 'local-cornflower',
      'common_name': 'Blue Cornflower',
      'scientific_name': ['Centaurea cyanus'],
      'flower_colour': 'blue',
      'cycle': 'annual',
      'watering': 'average',
      'default_image': null,
    },
    {
      'id': 'local-forget-me-not',
      'common_name': 'Blue Forget-me-not',
      'scientific_name': ['Myosotis'],
      'flower_colour': 'blue',
      'cycle': 'biennial',
      'watering': 'average',
      'default_image': null,
    },
  ];

  // Searches by colour using the local prototype catalogue.
  List<Map<String, dynamic>> searchColourCatalogue(
    String searchText, {
    required String colour,
    String? cycle,
    String? watering,
  }) {
    final String normalisedSearch = searchText.trim().toLowerCase();
    final String normalisedColour = colour.trim().toLowerCase();

    return colourCatalogue
        .where((plant) {
          final String commonName =
              plant['common_name']?.toString().toLowerCase() ?? '';

          final List<dynamic> scientificNames =
              plant['scientific_name'] as List<dynamic>? ?? [];

          final String searchableNames = [
            commonName,
            ...scientificNames.map((name) => name.toString().toLowerCase()),
          ].join(' ');

          final bool matchesName = searchableNames.contains(normalisedSearch);

          final bool matchesColour =
              plant['flower_colour']?.toString().toLowerCase() ==
              normalisedColour;

          final bool matchesCycle =
              cycle == null ||
              plant['cycle']?.toString().toLowerCase() == cycle.toLowerCase();

          final bool matchesWatering =
              watering == null ||
              plant['watering']?.toString().toLowerCase() ==
                  watering.toLowerCase();

          return matchesName &&
              matchesColour &&
              matchesCycle &&
              matchesWatering;
        })
        .map((plant) {
          return Map<String, dynamic>.from(plant);
        })
        .toList();
  }

  // Searches Perenual using a name and optional plant filters.
  Future<List<Map<String, dynamic>>> searchPlants(
    String searchText, {
    String? cycle,
    String? watering,
    String? colour,
    String? sunlight,
    bool? indoor,
  }) async {
    // Uses the local catalogue whenever a colour is selected.
    if (colour != null && colour.trim().isNotEmpty) {
      return searchColourCatalogue(
        searchText,
        colour: colour,
        cycle: cycle,
        watering: watering,
      );
    }

    final String? apiKey = dotenv.env['PERENUAL_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('The Perenual API key is missing.');
    }

    final Map<String, String> queryParameters = {
      'key': apiKey,
      'q': searchText.trim(),
    };

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
            .map((plant) => Map<String, dynamic>.from(plant as Map))
            .toList();
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('The Perenual API key was not accepted.');
      }

      if (response.statusCode == 429) {
        throw Exception('The Perenual request limit has been reached.');
      }

      throw Exception(
        'The plant search could not be completed. '
        'Status: ${response.statusCode}',
      );
    } on http.ClientException {
      throw Exception('A network connection to Perenual could not be made.');
    } on FormatException {
      throw Exception('Perenual returned information in an unexpected format.');
    }
  }
}
