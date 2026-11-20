import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/core/ui/feedback/acedex_toast.dart';
import 'package:acedex/features/auth/services/auth_service.dart';
import 'package:acedex/features/onboarding/models/student_registration_draft.dart';
import 'package:acedex/features/onboarding/screens/onboarding_screen.dart';
import 'package:acedex/features/onboarding/widgets/numeric_keypad.dart';
import 'package:acedex/features/onboarding/widgets/steps/step_phone.dart';
import 'package:acedex/features/onboarding/widgets/student_id_card.dart';

class MockAuthService extends AuthService {
  bool registerCalled = false;
  String? registeredPhone;
  String? registeredPin;
  String? registeredName;
  bool returnPhoneAlreadyRegistered = false;

  @override
  Future<bool> checkPhoneRegistered(String phone) async {
    return returnPhoneAlreadyRegistered;
  }

  @override
  Future<UserProfile> register({
    required String phone,
    required String pin,
    required String fullName,
    required String gender,
    required int grade,
    String? stream,
  }) async {
    registerCalled = true;
    registeredPhone = phone;
    registeredPin = pin;
    registeredName = fullName;

    return UserProfile(
      id: 'test_user_id',
      acedexId: 'ACX-26-8941',
      displayName: fullName,
      phone: phone,
      gender: gender,
      grade: grade,
      stream: stream,
      role: 'student',
      status: 'active',
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    AcedexToast.dismiss();
  });

  group('StudentRegistrationDraft State Model', () {
    test('Default draft requires stream for Grade 12 (7 total steps)', () {
      const draft = StudentRegistrationDraft();
      expect(draft.grade, 12);
      expect(draft.requiresStream, isTrue);
      expect(draft.totalSteps, 7);
      expect(draft.candidateId.startsWith('ACX-26-'), isTrue);
    });

    test('Draft for Grade 9/10 bypasses stream (6 total steps)', () {
      final draft = const StudentRegistrationDraft().copyWith(grade: 9);
      expect(draft.grade, 9);
      expect(draft.requiresStream, isFalse);
      expect(draft.totalSteps, 6);
      expect(draft.stream, isNull);
      expect(draft.academicSummary, 'Grade 9 • General Curriculum');
    });

    test('Academic summary accurately reflects stream specialization', () {
      final naturalDraft = const StudentRegistrationDraft(
        grade: 11,
        stream: 'natural',
      );
      expect(naturalDraft.academicSummary, 'Grade 11 • Natural Science');

      final socialDraft = const StudentRegistrationDraft(
        grade: 12,
        stream: 'social',
      );
      expect(socialDraft.academicSummary, 'Grade 12 • Social Science');
    });
  });

  group('Live Phone Registration Detector (Step 2)', () {
    testWidgets('Shows available state when phone is unrecorded',
        (WidgetTester tester) async {
      final mockAuth = MockAuthService()..returnPhoneAlreadyRegistered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StepPhone(
              initialPhone: '',
              authService: mockAuth,
              onPhoneChanged: (_) {},
              onContinue: () {},
              onBack: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '0911223344');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Phone number is available for registration'),
          findsOneWidget);
    });

    testWidgets('Shows warning banner and prevents continue when phone is already registered',
        (WidgetTester tester) async {
      final mockAuth = MockAuthService()..returnPhoneAlreadyRegistered = true;
      bool continued = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StepPhone(
              initialPhone: '',
              authService: mockAuth,
              onPhoneChanged: (_) {},
              onContinue: () => continued = true,
              onBack: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '0911223344');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('This phone number is already registered.'),
          findsOneWidget);
      expect(find.text('Sign in with this number instead'), findsOneWidget);

      // Attempt to tap Continue button
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(continued, isFalse);
    });
  });

  group('StudentIdCard Widget (Clean UI & Responsive)', () {
    testWidgets('renders official credentials and candidate ID in Light Mode',
        (WidgetTester tester) async {
      const draft = StudentRegistrationDraft(
        fullName: 'Abebe Kebede',
        phoneNumber: '+251912345678',
        gender: 'male',
        grade: 12,
        stream: 'natural',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: StudentIdCard(draft: draft),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ACEDEX NATIONAL EDUCATION'), findsOneWidget);
      expect(find.text('OFFICIAL CANDIDATE PASS'), findsOneWidget);
      expect(find.text('VERIFIED'), findsOneWidget);
      expect(find.text('Abebe Kebede'), findsOneWidget);
      expect(find.text('+251912345678'), findsOneWidget);
      expect(find.text('Grade 12'), findsWidgets);
      expect(find.text('Natural Science'), findsOneWidget);
      expect(find.text(draft.candidateId), findsOneWidget);
    });
  });

  group('Multi-Step Guided Onboarding Flow', () {
    testWidgets('Walks through multi-step onboarding and auto-advances PIN without button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockAuth = MockAuthService();

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/auth': (context) =>
                const Scaffold(body: Text('Login Gateway Screen Mock')),
          },
          home: OnboardingScreen(authService: mockAuth),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Name
      expect(find.text("What's your name?"), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Dawit Alemayehu');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 2: Phone
      expect(find.text("What's your phone number?"), findsOneWidget);

      await tester.enterText(find.byType(TextField), '911223344');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 3: Gender
      expect(find.text('Select your gender'), findsOneWidget);

      await tester.tap(find.text('Male'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 4: Grade
      expect(find.text('Which grade are you in?'), findsOneWidget);

      await tester.tap(find.text('G12'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 5: Stream (G12 requires stream)
      expect(find.text('Choose your stream'), findsOneWidget);

      await tester.tap(find.text('Natural Science'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 6: PIN Keypad (NO continue button!)
      expect(find.text('Create your PIN'), findsOneWidget);
      expect(find.byType(NumericKeypad), findsOneWidget);
      expect(find.text('Continue'), findsNothing); // STRICT REQUIREMENT: No continue button

      // Type 6 digits on the on-screen keypad: 1 2 3 4 5 6
      for (final digit in ['1', '2', '3', '4', '5', '6']) {
        await tester.tap(find.text(digit));
        await tester.pump(const Duration(milliseconds: 30));
      }
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Title automatically transitions to "Confirm your PIN"
      expect(find.text('Confirm your PIN'), findsOneWidget);

      // Re-enter the same 6 digits to verify
      for (final digit in ['1', '2', '3', '4', '5', '6']) {
        await tester.tap(find.text(digit));
        await tester.pump(const Duration(milliseconds: 30));
      }
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Step 7: Final Review & Student ID Card
      expect(find.text('Review your details'), findsOneWidget);
      expect(find.byType(StudentIdCard), findsOneWidget);
      expect(find.text('Dawit Alemayehu'), findsOneWidget);
      expect(find.text('+251911223344'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);

      // Tap Create account
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(mockAuth.registerCalled, isTrue);
      expect(mockAuth.registeredName, 'Dawit Alemayehu');
      expect(mockAuth.registeredPhone, '+251911223344');
      expect(mockAuth.registeredPin, '123456');

      // Celebratory Congratulatory Modal Dialog is presented!
      expect(find.text('Account Created!'), findsOneWidget);
      expect(find.text('Welcome to Acedex, Dawit Alemayehu!'), findsOneWidget);
      expect(find.text('Continue to Sign In'), findsOneWidget);

      // Tap Continue to Sign In to redirect to Login
      await tester.tap(find.text('Continue to Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Login Gateway Screen Mock'), findsOneWidget);
    });
  });
}
