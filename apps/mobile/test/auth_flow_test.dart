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
    testWidgets('Onboarding renders initial step and advances on valid input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("What's your name?"), findsOneWidget);
      expect(find.text('01 / 07'), findsOneWidget);

      // Enter valid student name
      await tester.enterText(find.byType(TextField), 'Abebe Kebede');
      await tester.pumpAndSettle();

      // Tap Continue to advance to Step 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text("What's your phone number?"), findsOneWidget);
      expect(find.text('02 / 07'), findsOneWidget);
    });

    testWidgets('AuthScreen renders login gateway and navigates to Onboarding',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool navigatedToOnboarding = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            '/onboarding': (context) {
              navigatedToOnboarding = true;
              return const Scaffold(body: Text('Onboarding Screen Mock'));
            },
          },
          home: const AuthScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Starts in Sign In / Login Gateway
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('6-Digit Security PIN'), findsOneWidget);
      expect(find.text('Create Account'), findsWidgets);

      // Tap Create Account button
      await tester.tap(find.text('Create Account').first);
      await tester.pumpAndSettle();

      expect(navigatedToOnboarding, isTrue);
      expect(find.text('Onboarding Screen Mock'), findsOneWidget);
    });

    testWidgets('AuthScreen pre-fills phone number from initialPhone',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AuthScreen(initialPhone: '+251912345678'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('912345678'), findsOneWidget);
      expect(find.text('+251'), findsOneWidget);
    });
  });
}
