import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flex_printing/main.dart';

void main() {
  testWidgets('home page shows logo/name and navigation buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(FlutterLogo), findsOneWidget);
    expect(find.text('Flex Printing'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Welcome to Flex Printing Home Page'), findsOneWidget);
  });

  testWidgets('about nav button opens about dummy page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.widgetWithText(TextButton, 'About'));
    await tester.pumpAndSettle();

    expect(find.text('About Page'), findsOneWidget);
  });
}
