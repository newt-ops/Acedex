import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/features/auth/screens/auth_screen.dart';
import 'package:acedex/features/auth/screens/login_pin_screen.dart';
import 'package:acedex/features/auth/services/auth_service.dart';
import 'package:acedex/features/onboarding/screens/onboarding_screen.dart';
import 'package:acedex/features/onboarding/widgets/numeric_keypad.dart';

class MockLoginAuthService extends AuthService {
  bool loginCalled = false;
  String? loginPhone;
  String? loginPin;
  bool phoneRegistered = true;

  @override
  Future<bool> checkPhoneRegistered(String phone) async {
    return phoneRegistered;
  }

  @override
  Future<UserProfile> login({
    required String phone,
    required String pin,
  }) async {
    loginCalled = true;
    loginPhone = phone;
    loginPin = pin;

    return UserProfile(
      id: 'test_student_id',
      acedexId: 'ACX-26-4432',
      displayName: 'Abebe Student',
      phone: phone,
      gender: 'male',
      grade: 12,
      stream: 'natural',
      role: 'student',
      status: 'active',
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService phone normalization and validation (Universal permutations)', () {
    test('normalizes 09, 07, 9, 7, +2510, and +251 formats to E.164 +251', () {
      expect(AuthService.normalizePhone('0912345678'), '+251912345678');
      expect(AuthService.normalizePhone('0712345678'), '+251712345678');
      expect(AuthService.normalizePhone('912345678'), '+251912345678');
      expect(AuthService.normalizePhone('712345678'), '+251712345678');
      expect(AuthService.normalizePhone('+2510912345678'), '+251912345678');
      expect(AuthService.normalizePhone('+2510712345678'), '+251712345678');
      expect(AuthService.normalizePhone('2510912345678'), '+251912345678');
      expect(AuthService.normalizePhone('+251912345678'), '+251912345678');
      expect(AuthService.normalizePhone('251912345678'), '+251912345678');
    });

    test('validates Ethiopian mobile numbers regardless of input prefix', () {
      expect(AuthService.isValidPhone('+251912345678'), true);
      expect(AuthService.isValidPhone('0912345678'), true);
      expect(AuthService.isValidPhone('0712345678'), true);
      expect(AuthService.isValidPhone('912345678'), true);
      expect(AuthService.isValidPhone('712345678'), true);
      expect(AuthService.isValidPhone('+2510912345678'), true);
      expect(AuthService.isValidPhone('123456'), false);
      expect(AuthService.isValidPhone('+1234567890'), false);
      expect(AuthService.isValidPhone('0812345678'), false);
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

      // Enter valid student name
      await tester.enterText(find.byType(TextField), 'Abebe Kebede');
      await tester.pumpAndSettle();

      // Tap Continue to advance to Step 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text("What's your phone number?"), findsOneWidget);
    });

    testWidgets('AuthScreen renders login gateway and navigates to Onboarding on Create Account tap',
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

      // Starts in Sign In / Login Gateway (Phone only)
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Create Account'), findsWidgets);

      // Tap Create Account button
      await tester.tap(find.text('Create Account').first);
      await tester.pumpAndSettle();

      expect(navigatedToOnboarding, isTrue);
      expect(find.text('Onboarding Screen Mock'), findsOneWidget);
    });

    testWidgets('AuthScreen phone submission navigates to /auth/pin',
        (WidgetTester tester) async {
      String? routedPhone;
      final mockAuth = MockLoginAuthService()..phoneRegistered = true;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            '/auth/pin': (context) {
              final args = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
              routedPhone = args?['phone'] as String?;
              return const Scaffold(body: Text('Login PIN Screen Mock'));
            },
          },
          home: AuthScreen(authService: mockAuth),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '0912345678');
      // Await debounce timer
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(routedPhone, '+251912345678');
      expect(find.text('Login PIN Screen Mock'), findsOneWidget);
    });

    testWidgets('LoginForm disables continue and shows alert when phone is not registered',
        (WidgetTester tester) async {
      final mockAuth = MockLoginAuthService()..phoneRegistered = false;
      bool registerSwitched = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            '/onboarding': (context) {
              registerSwitched = true;
              return const Scaffold(body: Text('Onboarding Screen Mock'));
            },
          },
          home: AuthScreen(authService: mockAuth),
        ),
      );
      await tester.pumpAndSettle();

      // Enter unregistered phone
      await tester.enterText(find.byType(TextField), '0912345678');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Should show the unregistered alert
      expect(find.text('This phone number is not registered yet.'), findsOneWidget);
      expect(find.text('Tap here to create an account'), findsOneWidget);

      // Tap the create account link in the alert
      await tester.tap(find.text('Tap here to create an account'));
      await tester.pumpAndSettle();

      expect(registerSwitched, isTrue);
    });

    testWidgets('LoginPinScreen executes login via custom NumericKeypad without virtual keyboard',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockAuth = MockLoginAuthService();
      bool homeReached = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            '/home': (context) {
              homeReached = true;
              return const Scaffold(body: Text('Home Dashboard Mock'));
            },
          },
          home: LoginPinScreen(
            phone: '+251912345678',
            authService: mockAuth,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enter your PIN'), findsOneWidget);
      expect(find.text('+251 91 123 4567'), findsNothing); // format is +251 91 123 4567 or similar
      expect(find.byType(NumericKeypad), findsOneWidget);
      // Ensure zero editable system text fields exist (virtual keyboard blocked)
      expect(find.byType(TextField), findsNothing);

      // Enter 6 digits on the keypad: 6 5 4 3 2 1
      for (final digit in ['6', '5', '4', '3', '2', '1']) {
        await tester.tap(find.text(digit));
        await tester.pump(const Duration(milliseconds: 30));
      }
      await tester.pumpAndSettle();

      expect(mockAuth.loginCalled, isTrue);
      expect(mockAuth.loginPhone, '+251912345678');
      expect(mockAuth.loginPin, '654321');
      expect(homeReached, isTrue);
    });
  });
}
