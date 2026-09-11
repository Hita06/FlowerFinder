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
  testWidgets('profile page displays profile layout', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Profile Page'), findsOneWidget);
    expect(find.text('@flower_finder_user'), findsOneWidget);
    expect(find.text('Stickers'), findsOneWidget);
    expect(find.text('Images'), findsOneWidget);
    expect(find.text('Diary'), findsOneWidget);
    expect(find.byIcon(Icons.local_florist_outlined), findsNWidgets(6));
    expect(find.byIcon(Icons.add), findsNWidgets(2));
  });

  testWidgets('user can edit and save account details', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), 'new_flower_finder_user');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('@new_flower_finder_user'), findsOneWidget);
  });
}
