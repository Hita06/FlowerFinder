import 'package:flutter_test/flutter_test.dart';

import 'package:flowerfinderscanner/main.dart';

void main() {
  testWidgets('Flower Finder app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const FlowerFinderApp());

    expect(find.text('Flower Finder'), findsOneWidget);
  });
}
