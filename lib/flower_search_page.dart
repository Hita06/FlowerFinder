// FlowerFinder G9 - Flower Search and Filter Page
// Created by Hita
// This page allows users to search for flowers using the Perenual API.

import 'package:flutter/material.dart';

import 'perenual_service.dart';

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

  // Provides access to the Perenual plant search API.
  final PerenualService perenualService = PerenualService();

  // Stores the plants returned by the API.
  List<Map<String, dynamic>> searchResults = [];

  // Controls the loading, error and search result messages.
  bool isLoading = false;
  bool hasSearched = false;
  String? errorMessage;

  // Sends the entered flower name to the Perenual service.
  Future<void> searchFlowers() async {
    final String searchText = searchController.text.trim();

    if (searchText.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a flower name.';
        searchResults = [];
        hasSearched = false;
      });

      return;
    }

    // Closes the keyboard after the user starts the search.
    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      errorMessage = null;
      hasSearched = true;
    });

    try {
      final results = await perenualService.searchPlants(searchText);

      if (!mounted) {
        return;
      }

      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        searchResults = [];
        isLoading = false;
        errorMessage =
            'The flower search could not be completed. Please try again.';
      });
    }
  }

  // Gets the first scientific name returned for a plant.
  String getScientificName(Map<String, dynamic> plant) {
    final dynamic scientificNames = plant['scientific_name'];

    if (scientificNames is List && scientificNames.isNotEmpty) {
      return scientificNames.first.toString();
    }

    return 'Scientific name unavailable';
  }

  // Gets a safe image URL from the returned plant information.
  String? getImageUrl(Map<String, dynamic> plant) {
    final dynamic defaultImage = plant['default_image'];

    if (defaultImage is Map) {
      return defaultImage['thumbnail']?.toString();
    }

    return null;
  }

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
                'Search the plant database using a flower name.',
                style: TextStyle(
                  color: Color(0xFF4F473C),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),

              // Search bar used to enter a flower name.
              TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => searchFlowers(),
                decoration: InputDecoration(
                  hintText: 'For example, rose',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: darkGreen,
                  ),
                  suffixIcon: IconButton(
                    onPressed: isLoading ? null : searchFlowers,
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: darkGreen,
                    ),
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
              const SizedBox(height: 16),

              // Search button used to send the request.
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : searchFlowers,
                  icon: const Icon(Icons.local_florist),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Displays the loading indicator, message or results.
              Expanded(
                child: buildResultsArea(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the correct content for the current search state.
  Widget buildResultsArea() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: mainGreen,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
          ),
        ),
      );
    }

    if (!hasSearched) {
      return const Center(
        child: Text(
          'Enter a flower name to begin searching.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: darkGreen,
            fontSize: 16,
          ),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No flowers matched your search.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: darkGreen,
            fontSize: 16,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${searchResults.length} result(s) found',
          style: const TextStyle(
            color: darkGreen,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final plant = searchResults[index];
              final String? imageUrl = getImageUrl(plant);

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 58,
                      height: 58,
                      child: imageUrl == null
                          ? const ColoredBox(
                              color: lightGreen,
                              child: Icon(
                                Icons.local_florist,
                                color: darkGreen,
                              ),
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const ColoredBox(
                                  color: lightGreen,
                                  child: Icon(
                                    Icons.local_florist,
                                    color: darkGreen,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  title: Text(
                    plant['common_name']?.toString() ??
                        'Unknown plant',
                    style: const TextStyle(
                      color: darkGreen,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      getScientificName(plant),
                      style: const TextStyle(
                        color: Color(0xFF4F473C),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}