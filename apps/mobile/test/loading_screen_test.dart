import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/features/splash/screens/loading_screen.dart';

void main() {
  testWidgets('LoadingScreen renders Stage 1 Splash with Acedex wordmark',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LoadingScreen(
          duration: Duration(milliseconds: 9200),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Stage 1 Splash lockup wordmark
    expect(find.text('Acedex'), findsOneWidget);
  });

  testWidgets('LoadingScreen advances to Stage 2 (Focus deeply) and Stage 3 (Ace every exam)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LoadingScreen(
          duration: Duration(milliseconds: 9200),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    // Advance naturally past Stage 1 (2.2s) into Stage 2 (Focus deeply)
    await tester.pump(const Duration(milliseconds: 3200));

    expect(find.text('STUDY FLOW'), findsOneWidget);
    expect(find.text('Focus deeply'), findsOneWidget);
    expect(
        find.text(
            'Distraction-free study sessions engineered for deep retention.'),
        findsOneWidget);

    // Advance naturally past Stage 2 (5.2s) into Stage 3 (Ace every exam)
    await tester.pump(const Duration(milliseconds: 3500));

    expect(find.text('READY TO MASTER'), findsOneWidget);
    expect(find.text('Ace every exam'), findsOneWidget);
    expect(
        find.text('Smart flashcards, active recall & daily study streaks.'),
        findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('LoadingScreen tapping "Get Started" navigates to /onboarding',
      (WidgetTester tester) async {
    bool navigatedToOnboarding = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoadingScreen(
                duration: Duration(milliseconds: 9200),
              ),
          '/onboarding': (context) {
            navigatedToOnboarding = true;
            return const Scaffold(body: Text('Onboarding Page'));
          },
        },
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    // Advance naturally into Stage 3
    await tester.pump(const Duration(milliseconds: 6700));

    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(navigatedToOnboarding, isTrue);
    expect(find.text('Onboarding Page'), findsOneWidget);
  });

  testWidgets('LoadingScreen tapping "I already have an account" navigates to /auth',
      (WidgetTester tester) async {
    bool navigatedToAuth = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoadingScreen(
                duration: Duration(milliseconds: 9200),
              ),
          '/auth': (context) {
            navigatedToAuth = true;
            return const Scaffold(body: Text('Auth Gateway'));
          },
        },
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    // Advance naturally into Stage 3
    await tester.pump(const Duration(milliseconds: 6700));

    expect(find.text('I already have an account'), findsOneWidget);
    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();

    expect(navigatedToAuth, isTrue);
    expect(find.text('Auth Gateway'), findsOneWidget);
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
