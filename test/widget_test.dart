// FlowerFinder G5 - Widget Test
// Updated by Hita
// This test checks that the Flower Information page displays correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowerfinderscanner/flower_information_page.dart';

void main() {
  testWidgets('Flower Information page displays correctly', (
    WidgetTester tester,
  ) async {
    // Opens the Flower Information page using test information.
    await tester.pumpWidget(
      const MaterialApp(
        home: FlowerInformationPage(
          flowerName: 'Rose',
          scientificName: 'Rosa',
          description:
              'Roses are flowering plants known for their colourful flowers.',
          flowerType: 'Garden flower',
          flowerColour: 'Red',
          season: 'Spring and summer',
          careTips: 'Place in sunlight and water regularly.',
        ),
      ),
    );

    // Checks that the main flower information is displayed.
    expect(find.text('Flower Information'), findsOneWidget);
    expect(find.text('Rose'), findsOneWidget);
    expect(find.text('Rosa'), findsOneWidget);
  });
}
