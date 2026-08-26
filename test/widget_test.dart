// FlowerFinder G5 - Widget Test
// Updated by Hita
// This test checks that the Flower Information page displays correctly.

import 'package:flutter_test/flutter_test.dart';
import 'package:flower_finder/main.dart';

void main() {
  testWidgets('Flower Information page displays correctly', (
    WidgetTester tester,
  ) async {
    // Opens the FlowerFinder application for testing.
    await tester.pumpWidget(const FlowerFinderApp());

    // Checks that the main flower information is displayed.
    expect(find.text('Flower Information'), findsOneWidget);
    expect(find.text('Rose'), findsOneWidget);
    expect(find.text('Save to Collection'), findsOneWidget);
  });
}