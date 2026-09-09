// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flower_finder/main.dart';

void main() {
  testWidgets('user account page displays account details', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('My account'), findsOneWidget);
    expect(find.text('New Flower Finder User'), findsNWidgets(2));
    expect(find.text('@flower_finder_user'), findsOneWidget);
    expect(find.text('Saved flowers'), findsOneWidget);
  });

  testWidgets('user can edit and save account details', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Edit account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Linda Chen');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Linda Chen'), findsNWidgets(2));
  });
}
