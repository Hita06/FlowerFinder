import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flower_finder/main.dart';

void main() {
  testWidgets('profile opens sticker creation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Profile Page'), findsOneWidget);
    expect(find.text('Add Sticker'), findsOneWidget);
    await tester.tap(find.byTooltip('Create sticker'));
    await tester.pumpAndSettle();

    expect(find.text('Create Sticker'), findsOneWidget);
    expect(find.text('Generate sticker'), findsOneWidget);
  });

  testWidgets('sticker creation keeps all existing styles', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Create sticker'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -360));
    await tester.pumpAndSettle();

    expect(find.text('Colour Change'), findsOneWidget);
    expect(find.text('Colour Variation'), findsOneWidget);
    expect(find.text('Bubble Border'), findsOneWidget);
    final saveButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save sticker'));
    expect(saveButton.onPressed, isNull);
  });
}
