import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/features/splash/screens/loading_screen.dart';

void main() {
  testWidgets('LoadingScreen renders brand insignia, title, and preparing message',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LoadingScreen(
          duration: Duration(milliseconds: 500),
        ),
      ),
    );
    await tester.pump();

    // Verify brand crest 'A' and title
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Acedex'), findsOneWidget);
    expect(find.text('Ethiopian National Learning Platform'), findsOneWidget);
    expect(find.text('Preparing your study space...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LoadingScreen triggers onLoaded callback after duration',
      (WidgetTester tester) async {
    bool loadedFired = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: LoadingScreen(
          duration: const Duration(milliseconds: 100),
          onLoaded: () {
            loadedFired = true;
          },
        ),
      ),
    );
    await tester.pump();
    expect(loadedFired, isFalse);

    // Advance clock past duration
    await tester.pump(const Duration(milliseconds: 150));
    expect(loadedFired, isTrue);
  });
}
