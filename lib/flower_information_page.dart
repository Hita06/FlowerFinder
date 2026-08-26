// FlowerFinder G5 - Flower Information Page
// Created by Hita
// This page displays additional information about an identified flower.

import 'package:flutter/material.dart';

// Creates the Flower Information page.
class FlowerInformationPage extends StatelessWidget {
  const FlowerInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),

      // Displays the page title.
      appBar: AppBar(
        title: const Text('Flower Information'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6F8F72),
        foregroundColor: Colors.white,
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
                color: const Color(0xFFDDE8D8),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.local_florist,
                size: 120,
                color: Color(0xFF6F8F72),
              ),
            ),

            const SizedBox(height: 24),

            // Displays the identified flower name.
            const Text(
              'Rose',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F5941),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Rosa',
              style: TextStyle(
                fontSize: 17,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // Displays a short description of the flower.
            const InformationCard(
              title: 'About',
              icon: Icons.info_outline,
              information:
                  'Roses are flowering plants known for their colourful petals and pleasant fragrance. They are commonly grown in gardens and are available in many colours.',
            ),

            const SizedBox(height: 14),

            // Displays the flower type and colour.
            const InformationCard(
              title: 'Flower Details',
              icon: Icons.local_florist_outlined,
              information:
                  'Type: Garden flower\nColour: Red\nSeason: Spring and summer',
            ),

            const SizedBox(height: 14),

            // Displays the meaning of the flower.
            const InformationCard(
              title: 'Meaning',
              icon: Icons.favorite_outline,
              information:
                  'Red roses commonly represent love, respect and appreciation.',
            ),

            const SizedBox(height: 14),

            // Displays basic care information.
            const InformationCard(
              title: 'Care Information',
              icon: Icons.water_drop_outlined,
              information:
                  'Place the flower in sunlight, water it regularly and make sure the soil can drain properly.',
            ),

            const SizedBox(height: 22),

            // Allows the identified flower to be saved.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rose saved to your collection'),
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Save to Collection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6F8F72),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Creates a reusable card for each flower information section.
class InformationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String information;

  const InformationCard({
    super.key,
    required this.title,
    required this.icon,
    required this.information,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF6F8F72),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F5941),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            information,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ],
      ),
    );
  }
}