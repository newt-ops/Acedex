import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/core/theme/theme_provider.dart';
import 'package:acedex/core/database/database.dart';
import 'package:acedex/core/database/database_provider.dart';
import 'package:acedex/features/onboarding/models/onboarding_data.dart';
import 'package:acedex/features/onboarding/screens/onboarding_screen.dart';
import 'package:acedex/features/profile/student_provider.dart';

void main() {
  test('OnboardingData defaults and immutability', () {
    const data = OnboardingData();
    expect(data.name, '');
    expect(data.gender, 'male');
    expect(data.grade, 11);
    expect(data.stream, 'natural');
    expect(data.dailyGoalMinutes, 120);

    final modified = data.copyWith(
      name: 'Abebe Bikila',
      grade: 12,
      stream: 'social',
      dailyGoalMinutes: 180,
    );

    expect(modified.name, 'Abebe Bikila');
    expect(modified.grade, 12);
    expect(modified.stream, 'social');
    expect(modified.dailyGoalMinutes, 180);
    expect(modified.gender, 'male');
  });

  testWidgets('StudentNotifier saves profile to SQLite and marks onboarding complete',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final testDb = AppDatabase(NativeDatabase.memory());

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(testDb),
      ],
    );

    final notifier = container.read(studentStateProvider.notifier);
    await notifier.loadStudent();
    expect(container.read(studentStateProvider).value, isNull);

    const onboardingData = OnboardingData(
      name: 'Tirunesh Dibaba',
      gender: 'female',
      grade: 12,
      stream: 'natural',
      dailyGoalMinutes: 180,
    );

    final success = await notifier.saveStudentProfile(
      onboardingData: onboardingData,
      userId: 'test_uuid_123',
      email: 'tirunesh@test.com',
    );

    expect(success, isTrue);
    expect(prefs.getBool('acedex_onboarding_completed'), isTrue);

    final savedStudent = container.read(studentStateProvider).value;
    expect(savedStudent, isNotNull);
    expect(savedStudent!.name, 'Tirunesh Dibaba');
    expect(savedStudent.grade, 12);
    expect(savedStudent.stream, 'natural');
    expect(savedStudent.dailyGoalMinutes, 180);
    expect(savedStudent.streakFreezes, 1);

    container.dispose();
    await testDb.close();
  });

  testWidgets('OnboardingScreen navigates through 5 steps',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final testDb = AppDatabase(NativeDatabase.memory());

    bool completed = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(testDb),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: OnboardingScreen(
            onCompleted: () => completed = true,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Step 1: Welcome
    expect(find.text('Master Ethiopian Curriculum'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Tap Continue to go to Step 2
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 2: Name & Gender
    expect(find.text('What should we call you?'), findsOneWidget);

    // Enter name
    await tester.enterText(find.byType(TextField), 'Kenenisa Bekele');
    await tester.pump();

    // Tap Continue to Step 3
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 3: Grade Selection
    expect(find.text('Select your Grade'), findsOneWidget);
    expect(find.text('Grade 9'), findsOneWidget);
    expect(find.text('Grade 12'), findsOneWidget);

    // Select Grade 12
    await tester.tap(find.text('Grade 12'), warnIfMissed: false);
    await tester.pump();

    // Tap Continue to Step 4
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 4: Stream Selection
    expect(find.text('Choose your Stream'), findsOneWidget);
    expect(find.text('Natural Science'), findsOneWidget);
    expect(find.text('Social Science'), findsOneWidget);

    // Tap Continue to Step 5
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 5: Daily Target
    expect(find.text('Set your Daily Target'), findsOneWidget);
    expect(find.text('Launch Acedex'), findsOneWidget);

    // Tap Launch Acedex
    await tester.tap(find.text('Launch Acedex'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);

    await testDb.close();
  });
}
