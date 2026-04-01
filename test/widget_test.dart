import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flex_printing/main.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    binding.window.physicalSizeTestValue = const Size(1400, 900);
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  tearDown(() {
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  testWidgets('home page shows logo/name and navigation buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('TEX PRINT'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Events'), findsWidgets);
  });

  testWidgets('about nav button scrolls to about section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('About'));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('About Us'), findsOneWidget);
  });
}
