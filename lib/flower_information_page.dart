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
  const FlowerInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,

      // Displays the page title.
      appBar: AppBar(
        title: const Text(
          'Flower Information',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
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
            const Text(
              'Rose',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),

            const SizedBox(height: 6),

            // Displays the scientific flower name.
            const Text(
              'Rosa',
              style: TextStyle(
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: darkGreen,
                      ),
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
                  SizedBox(height: 14),
                  Text(
                    'Roses are flowering plants known for their colourful '
                    'petals and pleasant fragrance. They are commonly grown '
                    'in gardens and are available in many colours.',
                    style: TextStyle(
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_florist_outlined,
                        color: darkGreen,
                      ),
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
                  SizedBox(height: 14),
                  Text(
                    'Type: Garden flower',
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.7,
                      color: Color(0xFF555555),
                    ),
                  ),
                  Text(
                    'Colour: Red',
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.7,
                      color: Color(0xFF555555),
                    ),
                  ),
                  Text(
                    'Season: Spring and summer',
                    style: TextStyle(
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
                border: Border.all(
                  color: pinkAccent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_outline,
                        color: pinkAccent,
                      ),
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
                  SizedBox(height: 14),
                  Text(
                    '• Place in an area with plenty of sunlight.\n'
                    '• Water regularly without flooding the soil.\n'
                    '• Remove damaged or dried leaves.',
                    style: TextStyle(
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