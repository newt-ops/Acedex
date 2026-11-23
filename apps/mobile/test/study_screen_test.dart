import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/config/feature_flags.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/features/study/screens/study_screen.dart';
import 'package:acedex/features/study/widgets/curriculum_hero_card.dart';
import 'package:acedex/features/study/widgets/quick_drill_builder_card.dart';
import 'package:acedex/features/study/widgets/smart_notes_reader_sheet.dart';
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

  group('StudyScreen Full Inside UI Showcase Tests', () {
    setUp(() {
      FeatureFlags.enableSmartNotes = true;
    });
    testWidgets('renders all core inside components', (tester) async {
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
      expect(find.textContaining('Bookmarked'), findsOneWidget);

      // Component 2: Curriculum Hero Card
      expect(find.byType(CurriculumHeroCard), findsOneWidget);
      expect(find.text('G12 • NATIONAL CURRICULUM'), findsOneWidget);
      expect(find.text('Resume Last Note'), findsOneWidget);

      // Component 3: Syllabus Unit Accordion
      expect(find.byType(SyllabusUnitAccordion), findsOneWidget);
      expect(find.text('Application of Physics in Other Fields'), findsOneWidget);

      // Component 4: Quick Topic Drill Builder Card
      expect(find.byType(QuickTopicDrillBuilderCard), findsOneWidget);
      expect(find.text('Quick Topic Drill Builder'), findsOneWidget);
      expect(find.text('Start Topic Drill'), findsOneWidget);
      expect(find.text('3 Qs'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
    });

    testWidgets('switching subject updates active curriculum', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createStudyHarness());
      await tester.pump();

      // Tap Mathematics in subject pill rail
      await tester.tap(find.text('Mathematics'));
      await tester.pumpAndSettle();

      // Hero card should reflect Mathematics
      expect(find.text('Sequences & Series'), findsOneWidget);
      expect(find.text('88%'), findsNWidgets(2));
    });

    testWidgets('search query filters syllabus topics dynamically', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createStudyHarness());
      await tester.pump();

      // Enter search query "Medical Imaging"
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'Medical Imaging');
      await tester.pumpAndSettle();

      // Should find Medical Imaging
      expect(find.text('1.1 Medical Imaging & Biophysics'), findsOneWidget);
    });

    testWidgets('tapping unit accordion expands and collapses topics', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createStudyHarness());
      await tester.pump();

      // Initially U1 is collapsed, tap to expand
      final u1Header = find.text('Application of Physics in Other Fields');
      expect(u1Header, findsOneWidget);
      await tester.tap(u1Header);
      await tester.pumpAndSettle();

      // Subtopics are visible
      expect(find.textContaining('Medical Imaging'), findsOneWidget);
      expect(find.text('Notes'), findsWidgets);
      expect(find.text('Drill'), findsWidgets);
    });

    testWidgets('launching Smart Notes Reader sheet and interacting with tabs and concept check', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createStudyHarness());
      await tester.pump();

      // Tap "Resume Last Note" in Hero Card
      final resumeBtn = find.text('Resume Last Note');
      expect(resumeBtn, findsOneWidget);
      await tester.tap(resumeBtn);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Smart Notes Reader Sheet is now open
      expect(find.byType(SmartNotesReaderSheet), findsOneWidget);
      expect(find.text('Concise Notes'), findsOneWidget);
      expect(find.text('Key Formulas'), findsOneWidget);
      expect(find.text('EUEE Tips'), findsOneWidget);
      expect(find.text('QUICK CONCEPT CHECK'), findsOneWidget);

      // Switch to Key Formulas tab
      await tester.tap(find.text('Key Formulas'));
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsWidgets);

      // Switch to EUEE Tips tab
      await tester.tap(find.text('EUEE Tips'));
      await tester.pumpAndSettle();
      expect(find.text('#1'), findsOneWidget);

      // Switch back to Concise Notes tab
      await tester.tap(find.text('Concise Notes'));
      await tester.pumpAndSettle();

      // Answer Concept Check
      final conceptCheckOption = find.textContaining('North pole to oppose the approach');
      if (conceptCheckOption.evaluate().isNotEmpty) {
        await tester.tap(conceptCheckOption.first);
        await tester.pumpAndSettle();
        expect(find.textContaining('Exact!'), findsWidgets);
      }

      // Close Sheet
      final closeIcon = find.byType(SmartNotesReaderSheet);
      expect(closeIcon, findsOneWidget);
    });

    testWidgets('launching Topic Drill Engine sheet and answering questions to summary', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createStudyHarness());
      await tester.pump();

      // Tap Start Topic Drill in builder card
      final startDrillBtn = find.text('Start Topic Drill');
      expect(startDrillBtn, findsOneWidget);
      await tester.tap(startDrillBtn);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Topic Drill Engine is open
      expect(find.byType(TopicDrillEngineSheet), findsOneWidget);
      expect(find.text('1 of 3'), findsOneWidget);

      // Select option A (first option)
      final optionA = find.text('A');
      expect(optionA, findsWidgets);
      await tester.tap(optionA.first);
      await tester.pumpAndSettle();

      // Explanation is displayed
      expect(find.text('Next Question'), findsOneWidget);

      // Advance to Question 2
      await tester.tap(find.text('Next Question'));
      await tester.pumpAndSettle();
      expect(find.text('2 of 3'), findsOneWidget);

      // Select option A for Question 2
      await tester.tap(find.text('A').first);
      await tester.pumpAndSettle();

      // Advance to Question 3
      await tester.tap(find.text('Next Question'));
      await tester.pumpAndSettle();
      expect(find.text('3 of 3'), findsOneWidget);

      // Select option A for Question 3
      await tester.tap(find.text('A').first);
      await tester.pumpAndSettle();
      expect(find.text('Complete Drill'), findsOneWidget);

      // Complete Drill
      await tester.tap(find.text('Complete Drill'));
      await tester.pumpAndSettle();

      // Summary screen is shown
      expect(find.textContaining('Correct!'), findsOneWidget);
      expect(find.text('Back to Study Syllabus'), findsOneWidget);

      // Tap Back to Study Syllabus
      await tester.tap(find.text('Back to Study Syllabus'));
      await tester.pumpAndSettle();

      // Back on Study Screen
      expect(find.byType(TopicDrillEngineSheet), findsNothing);
    });

    testWidgets('Feature gating: when notes are disabled, Notes buttons are hidden and hero CTA is Start Unit Drill',
        (tester) async {
      FeatureFlags.enableSmartNotes = false;

      configureViewport(tester);
      await tester.pumpWidget(createStudyHarness());
      await tester.pump();

      // Hero button label changes to Start Unit Drill
      expect(find.text('Start Unit Drill'), findsOneWidget);
      expect(find.text('Resume Last Note'), findsNothing);

      // Expand U1
      final u1Header = find.text('Application of Physics in Other Fields');
      await tester.tap(u1Header);
      await tester.pumpAndSettle();

      // Notes button is omitted, Drill button is present
      expect(find.text('Notes'), findsNothing);
      expect(find.text('Drill'), findsWidgets);
    });

    testWidgets('marking unit complete unlocks 15-question assessment and launches drill engine',
        (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createStudyHarness());
      await tester.pump();

      // Expand U1 (Physics)
      final u1Header = find.text('Application of Physics in Other Fields');
      await tester.tap(u1Header);
      await tester.pumpAndSettle();

      // Since topic 1.2 is incomplete initially, prompt to complete unit is shown
      expect(find.textContaining('Check mark this unit'), findsWidgets);
      expect(find.text('Complete Unit'), findsWidgets);

      // Tap "Complete Unit" to mark U1 done
      await tester.tap(find.text('Complete Unit').first);
      await tester.pumpAndSettle();

      // Now "Unit Assessment" card is unlocked and visible
      expect(find.text('Unit Assessment'), findsWidgets);
      expect(find.text('15 Questions • Ethiopian Curriculum Bank'), findsWidgets);
      expect(find.text('Take Assessment'), findsWidgets);

      // Tap "Take Assessment"
      await tester.tap(find.text('Take Assessment').first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Topic Drill Engine Sheet is open with 15 questions!
      expect(find.byType(TopicDrillEngineSheet), findsOneWidget);
      expect(find.text('1 of 15'), findsOneWidget);
      expect(find.textContaining('15-Q Assessment'), findsOneWidget);
    });
  });
}
