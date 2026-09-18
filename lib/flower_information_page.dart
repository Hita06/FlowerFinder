// FlowerFinder G5 - Flower Information Page
// Created by Hita
// This page displays additional information about an identified flower.

import 'package:flutter/material.dart';

// Colours used to match the shared FlowerFinder theme.
const Color mainGreen = Color(0xFF5BC68D);
const Color darkGreen = Color(0xFF276749);
const Color creamBackground = Color(0xFFFFF9F2);
const Color lightGreen = Color(0xFFE4F3E8);
const Color pinkAccent = Color(0xFFF7A8C4);

// Creates the Flower Information page.
class FlowerInformationPage extends StatelessWidget {
  // Stores the information received for the identified flower.
  final String flowerName;
  final String scientificName;
  final String description;
  final String flowerType;
  final String flowerColour;
  final String season;
  final String careTips;

  // Requires flower information when this page is opened.
  const FlowerInformationPage({
    super.key,
    required this.flowerName,
    required this.scientificName,
    required this.description,
    required this.flowerType,
    required this.flowerColour,
    required this.season,
    required this.careTips,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,

      // Displays the page title.
      appBar: AppBar(
        title: const Text(
          'Flower Information',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: mainGreen,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      // Allows the user to scroll through the flower information.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displays a temporary flower image area.
            Container(
              width: double.infinity,
              height: 230,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.local_florist,
                size: 120,
                color: darkGreen,
              ),
            ),

            const SizedBox(height: 24),

            // Displays the identified flower name.
            Text(
              flowerName,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),

            const SizedBox(height: 6),

            // Displays the scientific flower name.
            Text(
              scientificName,
              style: const TextStyle(
                fontSize: 17,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            // Displays general information about the flower.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: darkGreen),
                      SizedBox(width: 10),
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.5,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Displays the main flower details.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_florist_outlined, color: darkGreen),
                      SizedBox(width: 10),
                      Text(
                        'Flower Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Type: $flowerType',
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.7,
                      color: Color(0xFF555555),
                    ),
                  ),
                  Text(
                    'Colour: $flowerColour',
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.7,
                      color: Color(0xFF555555),
                    ),
                  ),
                  Text(
                    'Season: $season',
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.7,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Displays basic care information.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: pinkAccent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.favorite_outline, color: pinkAccent),
                      SizedBox(width: 10),
                      Text(
                        'Care Tips',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    careTips,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.7,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
