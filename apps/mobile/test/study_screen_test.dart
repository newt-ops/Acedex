import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/config/feature_flags.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/features/study/screens/study_screen.dart';
import 'package:acedex/features/study/widgets/curriculum_hero_card.dart';
import 'package:acedex/features/study/widgets/subject_pill_rail_and_search.dart';
import 'package:acedex/features/study/widgets/syllabus_unit_accordion.dart';
import 'package:acedex/features/study/widgets/topic_drill_engine_sheet.dart';

void main() {
  const testUser = UserProfile(
    id: 'usr_test_study',
    acedexId: 'ACX-26-0002',
    displayName: 'Selamawit Tadesse',
    phone: '+251911998877',
    gender: 'female',
    grade: 12,
    stream: 'natural',
    role: 'student',
    status: 'active',
  );

  Widget createStudyHarness({UserProfile? user}) {
    return MaterialApp(
      home: Scaffold(
        body: StudyScreen(user: user ?? testUser),
      ),
    );
  }

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('StudyScreen Live Curriculum & 15-Question Assessment Tests', () {
    setUp(() {
      FeatureFlags.enableSmartNotes = true;
    });

    testWidgets('renders all core inside components and authentic units', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createStudyHarness());
      await tester.pump();

      // Component 1: Subject Pill Rail & Search / Filter
      expect(find.byType(SubjectPillRailAndSearch), findsOneWidget);
      expect(find.text('Physics'), findsWidgets);
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('Chemistry'), findsOneWidget);
      expect(find.text('Biology'), findsOneWidget);
      expect(find.text('All Units'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);

      // Component 2: Curriculum Hero Card
      expect(find.byType(CurriculumHeroCard), findsOneWidget);
      expect(find.text('G12 • NATIONAL CURRICULUM'), findsOneWidget);

      // Component 3: Syllabus Unit Accordion with authentic units
      expect(find.byType(SyllabusUnitAccordion), findsOneWidget);
      expect(find.text('Application of Physics in Other Fields'), findsOneWidget);
    });

    testWidgets('switching to Mathematics shows authentic 5 Grade 12 units', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createStudyHarness());
      await tester.pump();

      // Tap Mathematics in subject pill rail
      await tester.tap(find.text('Mathematics'));
      await tester.pumpAndSettle();

      // Hero card and syllabus reflect Mathematics with real unit titles
      expect(find.text('Sequences and Series'), findsWidgets);
      expect(find.text('Introductions to Calculus'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Introduction to Linear Programming'), findsOneWidget);
      expect(find.text('Mathematical Applications in Business'), findsOneWidget);
    });

    testWidgets('search query filters syllabus units dynamically', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createStudyHarness());
      await tester.pump();

      // Enter search query "Fluid"
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'Fluid');
      await tester.pumpAndSettle();

      // Should find Fluid Mechanics
      expect(find.text('Fluid Mechanics'), findsOneWidget);
    });

    testWidgets('marking unit complete unlocks 15-question assessment and launches assessment engine',
        (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createStudyHarness());
      await tester.pump();

      // Expand U1 (Physics)
      final u1Header = find.text('Application of Physics in Other Fields');
      await tester.tap(u1Header);
      await tester.pumpAndSettle();

      // Complete prompt shown
      expect(find.textContaining('Check mark this unit'), findsWidgets);
      expect(find.text('Complete Unit'), findsWidgets);

      // Tap "Complete Unit" to mark U1 done
      await tester.tap(find.text('Complete Unit').first);
      await tester.pumpAndSettle();

      // Now "Unit Assessment" card is unlocked and visible
      expect(find.text('Unit Assessment'), findsWidgets);
      expect(find.text('15 Questions • Ethiopian Curriculum Bank'), findsWidgets);
      expect(find.text('Take Assessment'), findsWidgets);
    });

    testWidgets('Math G12 Unit 1 launches authentic 15-question assessment',
        (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createStudyHarness());
      await tester.pump();

      // Switch to Mathematics
      await tester.tap(find.text('Mathematics'));
      await tester.pumpAndSettle();

      // Expand Unit 1: Sequences and Series
      final u1Math = find.text('Sequences and Series').first;
      await tester.tap(u1Math);
      await tester.pumpAndSettle();

      // Complete Unit 1 to unlock assessment
      await tester.tap(find.text('Complete Unit').first);
      await tester.pumpAndSettle();

      // Tap Take Assessment
      await tester.tap(find.text('Take Assessment').first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Assessment sheet opens with 15 questions
      expect(find.byType(TopicDrillEngineSheet), findsOneWidget);
      expect(find.text('1 of 15'), findsOneWidget);
      expect(find.textContaining('15-Q Assessment'), findsOneWidget);

      // Verify authentic question text (Arithmetic sequence common difference)
      expect(find.textContaining('common difference, d'), findsOneWidget);
    });
  });
}
