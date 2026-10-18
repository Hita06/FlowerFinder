
// FlowerFinder - PlantNet API Service
// Sends flower images through the secure backend proxy.

import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class FlowerApi {
  // Public Cloudflare Worker URL.
  // No ADB reverse forwarding is needed for backend access.
  static const String _backendUrl =
      'https://flowerfinder-plantnet-proxy.flowerfinder.workers.dev/identify';

  // Sends a flower image to the backend for identification.
  static Future<Map<String, dynamic>> identifyFlower(
    String imagePath,
  ) async {
    // Get the currently signed-in Firebase user.
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
        'Please sign in before identifying a flower.',
      );
    }

    // Get the Firebase ID token for backend authentication.
    final String? idToken = await user.getIdToken();

    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Could not verify your login. Please sign in again.',
      );
    }

    // Confirm that the selected image exists.
    final File imageFile = File(imagePath);

    if (!await imageFile.exists()) {
      throw Exception(
        'The selected image could not be found.',
      );
    }

    try {
      // Create a multipart request to the public backend.
      final http.MultipartRequest request =
          http.MultipartRequest(
        'POST',
        Uri.parse(_backendUrl),
      );

      // Authenticate the request using Firebase.
      request.headers['Authorization'] = 'Bearer $idToken';

      // Upload the image using the field name expected by the backend.
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
        ),
      );

      final http.StreamedResponse streamedResponse =
          await request.send();

      final String responseBody =
          await streamedResponse.stream.bytesToString();

      final dynamic decodedResponse =
          jsonDecode(responseBody);

      if (streamedResponse.statusCode == 200) {
        if (decodedResponse is! Map<String, dynamic>) {
          throw const FormatException(
            'Unexpected PlantNet response.',
          );
        }

        return decodedResponse;
      }

      if (streamedResponse.statusCode == 401) {
        throw Exception(
          'Your login could not be verified. '
          'Please sign in again.',
        );
      }

      if (streamedResponse.statusCode == 429) {
        throw Exception(
          'Too many requests. Please try again later.',
        );
      }

      if (decodedResponse is Map<String, dynamic> &&
          decodedResponse['error'] is String) {
        throw Exception(
          decodedResponse['error'] as String,
        );
      }

      throw Exception(
        'Flower identification failed '
        '(status ${streamedResponse.statusCode}).',
      );
    } on SocketException {
      throw Exception(
        'Could not connect to the flower identification server.',
      );
    } on http.ClientException {
      throw Exception(
        'Could not connect to the flower identification server.',
      );
    } on FormatException {
      throw Exception(
        'The server returned information in an unexpected format.',
      );
    }
  }
}
