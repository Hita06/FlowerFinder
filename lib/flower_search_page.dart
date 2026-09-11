// FlowerFinder G9 - Flower Search and Filter Page
// Created by Hita
// This page allows users to search for flowers and filter the results.

import 'package:flutter/material.dart';

// Colours used to match the shared FlowerFinder theme.
const Color mainGreen = Color(0xFF5BC68D);
const Color darkGreen = Color(0xFF276749);
const Color creamBackground = Color(0xFFFFF9F2);
const Color lightGreen = Color(0xFFE4F3E8);
const Color pinkAccent = Color(0xFFF7A8C4);

// Creates the Flower Search and Filter page.
class FlowerSearchPage extends StatefulWidget {
  const FlowerSearchPage({super.key});

  @override
  State<FlowerSearchPage> createState() => _FlowerSearchPageState();
}

class _FlowerSearchPageState extends State<FlowerSearchPage> {
  // Controls and reads the text entered into the search bar.
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    // Removes the controller when the page is closed.
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: mainGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Search Flowers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find a Flower',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Search by flower name or use the filters.',
                style: TextStyle(
                  color: Color(0xFF4F473C),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),

              // Search bar used to enter a flower name.
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search flowers...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: darkGreen,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: lightGreen,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: mainGreen,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // The flower results will be displayed here.
              const Expanded(
                child: Center(
                  child: Text(
                    'Flower results will appear here.',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}