import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:drift/native.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/core/theme/theme_provider.dart';
import 'package:acedex/core/database/database.dart';
import 'package:acedex/core/database/database_provider.dart';
import 'package:acedex/features/curriculum/screens/curriculum_screen.dart';

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase(NativeDatabase.memory());

    // Seed test student
    await db.into(db.students).insert(
          StudentsCompanion.insert(
            id: 'test_student_1',
            email: 'abebe@acedex.app',
            name: 'Abebe Bikila',
            grade: 9,
            stream: 'natural',
            gender: 'male',
            dailyGoalMinutes: const Value(120),
          ),
        );

    // Seed test subject
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 'PHYS_G9',
            name: 'Physics',
            code: 'PHYS_G9',
            grade: 9,
            stream: 'natural',
            totalUnits: 1,
            sortOrder: const Value(1),
          ),
        );

    // Seed test chapter
    await db.into(db.chapters).insert(
          ChaptersCompanion.insert(
            id: 'PHYS_G9_U1',
            subjectId: 'PHYS_G9',
            chapterNumber: 1,
            title: 'Physics and Human Society',
            sortOrder: const Value(1),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CurriculumScreen(),
      ),
    );
  }

  testWidgets('CurriculumScreen renders grade selector and subject card',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Curriculum & Units'), findsOneWidget);
    expect(find.text('Grade 9'), findsOneWidget);
    expect(find.text('Grade 10'), findsOneWidget);
    expect(find.text('Grade 11'), findsOneWidget);
    expect(find.text('Grade 12'), findsOneWidget);

    // Subject card is displayed
    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('0 of 1 units completed'), findsOneWidget);
  });

  testWidgets('Expanding subject reveals unit and allows toggling studied status',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Tap on Physics to expand
    await tester.tap(find.text('Physics'));
    await tester.pumpAndSettle();

    // Unit details are now visible
    expect(find.text('Unit 1'), findsOneWidget);
    expect(find.text('Physics and Human Society'), findsOneWidget);
    expect(find.text('Mark Studied'), findsOneWidget);
    expect(find.text('Study to unlock assessment'), findsOneWidget);

    // Tap 'Mark Studied'
    await tester.tap(find.text('Mark Studied'));
    await tester.pumpAndSettle();

    // Verify it changed to Studied and unlocked assessment
    expect(find.text('Studied'), findsOneWidget);
    expect(find.text('Take Assessment'), findsOneWidget);
    expect(find.text('1 of 1 units completed'), findsOneWidget);
  });
}
