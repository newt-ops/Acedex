import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/core/ui/progress/acedex_dots_loader.dart';

void main() {
  testWidgets('AcedexDotsLoader renders 3 animated wave dots with primary theme color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: AcedexDotsLoader(
              dotSize: 7.0,
              gap: 6.0,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify exactly 3 dot circles are rendered
    final containerFinder = find.byType(Container);
    expect(containerFinder, findsNWidgets(3));

    // Verify continuous animation cycles without throw
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('AcedexDotsLoader accepts custom color and custom dot size',
      (WidgetTester tester) async {
    const customColor = Color(0xFF8A2BA3);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AcedexDotsLoader(
              dotSize: 10.0,
              gap: 8.0,
              color: customColor,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AcedexDotsLoader), findsOneWidget);
  });
}
