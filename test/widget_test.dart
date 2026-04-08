import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flex_printing/main.dart';
import 'package:flex_printing/pages/admin_page/admin_page.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // ignore: deprecated_member_use
    binding.window.physicalSizeTestValue = const Size(1400, 900);
    // ignore: deprecated_member_use
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  tearDown(() {
    // ignore: deprecated_member_use
    binding.window.clearPhysicalSizeTestValue();
    // ignore: deprecated_member_use
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

  testWidgets('admin page starts on landing and opens new product form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdminPage(),
      ),
    );
    await tester.pump();

    expect(find.text('New Product'), findsOneWidget);
    expect(find.text('Create Product'), findsNothing);

    await tester.tap(find.text('New Product'));
    await tester.pumpAndSettle();

    expect(find.text('Create Product'), findsOneWidget);
    expect(find.text('Save Product'), findsOneWidget);
  });
}
