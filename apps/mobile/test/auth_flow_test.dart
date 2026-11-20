import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/features/auth/screens/auth_screen.dart';
import 'package:acedex/features/auth/services/auth_service.dart';
import 'package:acedex/features/onboarding/screens/onboarding_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService phone normalization and validation', () {
    test('normalizes 09 and 07 local format to E.164 +251', () {
      expect(AuthService.normalizePhone('0912345678'), '+251912345678');
      expect(AuthService.normalizePhone('0712345678'), '+251712345678');
      expect(AuthService.normalizePhone('912345678'), '+251912345678');
      expect(AuthService.normalizePhone('+251912345678'), '+251912345678');
      expect(AuthService.normalizePhone('251912345678'), '+251912345678');
    });

    test('validates Ethiopian mobile numbers', () {
      expect(AuthService.isValidPhone('+251912345678'), true);
      expect(AuthService.isValidPhone('0912345678'), true);
      expect(AuthService.isValidPhone('0712345678'), true);
      expect(AuthService.isValidPhone('123456'), false);
      expect(AuthService.isValidPhone('+1234567890'), false);
    });
  });

  group('Onboarding and Auth UI Widgets', () {
    testWidgets('Onboarding advances slides on Continue tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Master Every Subject'), findsOneWidget);

      // Tap Continue to advance to slide 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Simulate the EUEE'), findsOneWidget);

      // Tap Continue to advance to slide 3
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Track Your Growth'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
    });

    testWidgets('AuthScreen switches between Sign In and Create Account',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AuthScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Starts in Sign In
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);

      // Tap Create Account tab
      await tester.tap(find.text('Create Account').first);
      await tester.pumpAndSettle();

      expect(find.text('Create Student Account'), findsWidgets);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('GENDER'), findsOneWidget);
      expect(find.text('GRADE LEVEL'), findsOneWidget);
      // Grade 12 is selected by default, so stream selector is visible
      expect(find.text('Natural Science'), findsOneWidget);
      expect(find.text('Social Science'), findsOneWidget);

      // Tap Grade 9 chip -> stream selector hides
      await tester.ensureVisible(find.text('G 9'));
      await tester.tap(find.text('G 9'));
      await tester.pumpAndSettle();

      expect(find.text('Natural Science'), findsNothing);
      expect(find.text('Social Science'), findsNothing);

      // Tap Grade 11 chip -> stream selector reappears
      await tester.ensureVisible(find.text('G 11'));
      await tester.tap(find.text('G 11'));
      await tester.pumpAndSettle();

      expect(find.text('Natural Science'), findsOneWidget);
      expect(find.text('Social Science'), findsOneWidget);
    });
  });
}
