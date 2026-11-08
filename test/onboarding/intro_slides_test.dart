import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/features/onboarding/screens/intro_splash_screen.dart';
import 'package:acedex/features/onboarding/screens/intro_slides_screen.dart';
import 'package:acedex/features/onboarding/screens/intro_flow_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:acedex/core/database/database.dart';
import 'package:acedex/core/database/database_provider.dart';
import 'package:acedex/core/theme/theme_provider.dart';

void main() {
  group('IntroSplashScreen Widget Tests', () {
    testWidgets('renders light brand logo and loading bar in light mode',
        (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: IntroSplashScreen(
            duration: const Duration(milliseconds: 500),
            onLoadingComplete: () => completed = true,
          ),
        ),
      );

      // Verify widget builds without error
      expect(find.byType(IntroSplashScreen), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      final imageWidget = tester.widget<Image>(find.byType(Image));
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName,
          'assets/logo/brand/acedex_logo_gemini_light.jpg');

      // Progress animation
      await tester.pump(const Duration(milliseconds: 250));
      expect(completed, isFalse);

      await tester.pump(const Duration(milliseconds: 300));
      expect(completed, isTrue);
    });

    testWidgets('renders dark brand logo in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: IntroSplashScreen(
            duration: const Duration(milliseconds: 500),
            onLoadingComplete: () {},
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      final imageWidget = tester.widget<Image>(find.byType(Image));
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName,
          'assets/logo/brand/acedex_logo_gemini_dark.jpg');
    });
  });

  group('IntroSlidesScreen Widget Tests', () {
    testWidgets('navigates through 3 slides with buttons and hand swiping',
        (tester) async {
      bool finished = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: IntroSlidesScreen(
            onFinish: () => finished = true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Slide 1 checks
      expect(find.textContaining('Master', findRichText: true), findsWidgets);
      expect(find.textContaining('Offline', findRichText: true), findsWidgets);
      expect(find.text('Next  ›'), findsOneWidget);

      // Tap Next to navigate to Slide 2
      await tester.tap(find.text('Next  ›'));
      await tester.pumpAndSettle();

      // Slide 2 checks
      expect(find.textContaining('Structured', findRichText: true), findsWidgets);
      expect(find.textContaining('Focus', findRichText: true), findsWidgets);
      expect(find.text('Next  ›'), findsOneWidget);

      // Use hand drag swipe gesture to navigate from Slide 2 to Slide 3
      await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
      await tester.pumpAndSettle();

      // Slide 3 checks
      expect(find.textContaining('Daily', findRichText: true), findsWidgets);
      expect(find.textContaining('EUEE', findRichText: true), findsWidgets);
      expect(find.text('Get Started  ›'), findsOneWidget);

      // Tap Get Started
      await tester.tap(find.text('Get Started  ›'));
      await tester.pumpAndSettle();

      expect(finished, isTrue);
    });
  });

  group('IntroFlowScreen Coordinator Tests', () {
    testWidgets('transitions from splash to slides when loading completes',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final testDb = AppDatabase(NativeDatabase.memory());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            databaseProvider.overrideWithValue(testDb),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const IntroFlowScreen(),
          ),
        ),
      );

      // Starts on IntroSplashScreen
      expect(find.byType(IntroSplashScreen), findsOneWidget);

      // Advance through splash duration
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pumpAndSettle();

      // Transitions to IntroSlidesScreen
      expect(find.byType(IntroSlidesScreen), findsOneWidget);

      await testDb.close();
    });
  });
}
