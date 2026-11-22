import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/features/dashboard/screens/dashboard_screen.dart';
import 'package:acedex/features/dashboard/widgets/curriculum_bento_grid.dart';
import 'package:acedex/features/dashboard/widgets/formula_flashcards_carousel.dart';
import 'package:acedex/features/dashboard/widgets/hero_countdown_card.dart';
import 'package:acedex/features/dashboard/widgets/mini_drill_sheet.dart';
import 'package:acedex/features/dashboard/widgets/quick_study_sheet.dart';
import 'package:acedex/features/dashboard/widgets/study_plan_section.dart';
import 'package:acedex/features/dashboard/widgets/subject_mastery_section.dart';

void main() {
  const testUser = UserProfile(
    id: 'usr_test_1',
    acedexId: 'ACX-26-0001',
    displayName: 'Abebe Kebede',
    phone: '+251911223344',
    gender: 'male',
    grade: 12,
    stream: 'natural',
    role: 'student',
    status: 'active',
  );

  Widget createDashboardHarness({UserProfile? user}) {
    return MaterialApp(
      home: Scaffold(
        body: DashboardScreen(user: user ?? testUser),
      ),
    );
  }

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('DashboardScreen Full Inside UI Showcase Tests', () {
    testWidgets('renders all 5 canonical inside sections', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      // Section 1: Hero Countdown & Readiness Card
      expect(find.byType(HeroCountdownCard), findsOneWidget);
      expect(find.text('G12 • NATURAL SCIENCE'), findsOneWidget);
      expect(find.text('Countdown'), findsOneWidget);
      expect(find.text('Readiness'), findsOneWidget);
      expect(find.text('Continue Unit 4'), findsOneWidget);

      // Section 2: Live Curriculum Bento Grid (2x2)
      expect(find.byType(CurriculumBentoGrid), findsOneWidget);
      expect(find.text('Curriculum Pulse'), findsOneWidget);
      expect(find.text('18 / 24'), findsOneWidget);
      expect(find.text('83.4%'), findsOneWidget);
      expect(find.text('45 / 60m'), findsOneWidget);
      expect(find.text('+15m'), findsOneWidget);
      expect(find.text('Top 5%'), findsOneWidget);

      // Section 3: Today's Study Plan
      expect(find.byType(StudyPlanSection), findsOneWidget);
      expect(find.text("Today's Study Plan"), findsOneWidget);
      expect(find.text('2 of 4 done'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      // Section 4: Subject Mastery
      expect(find.byType(SubjectMasterySection), findsOneWidget);
      expect(find.text('Subject Mastery'), findsOneWidget);
      expect(find.text('Needs Focus'), findsOneWidget);
      expect(find.text('Strong'), findsOneWidget);

      // Section 5: Formula Flashcards
      expect(find.byType(FormulaFlashcardsCarousel), findsOneWidget);
      expect(find.text('Formula Flashcards'), findsOneWidget);
    });

    testWidgets('Hero card toggles between Countdown and Readiness views', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      // Initially on Countdown view: Days / Hours / Mins tiles visible
      expect(find.text('DAYS'), findsOneWidget);
      expect(find.text('HOURS'), findsOneWidget);
      expect(find.text('MINS'), findsOneWidget);

      // Switch to Readiness view
      await tester.tap(find.text('Readiness'));
      await tester.pumpAndSettle();

      expect(find.text('Exam Readiness'), findsOneWidget);
      expect(find.text('+4.2% wk'), findsOneWidget);
      expect(find.textContaining('545+ EUEE'), findsOneWidget);

      // Switch back to Countdown view
      await tester.tap(find.text('Countdown'));
      await tester.pumpAndSettle();

      expect(find.text('DAYS'), findsOneWidget);
    });

    testWidgets('Bento grid: +15m increments focus time and Standing toggles period',
        (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      expect(find.text('45 / 60m'), findsOneWidget);

      // Tap +15m button
      await tester.tap(find.text('+15m'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('60 / 60m'), findsOneWidget);

      // Tap Stream Standing card to toggle Weekly -> All-Time
      expect(find.text('WEEKLY'), findsOneWidget);
      expect(find.text('Top 5%'), findsOneWidget);
      expect(find.text('2,480 XP'), findsOneWidget);

      await tester.tap(find.text('Top 5%'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('ALL-TIME'), findsOneWidget);
      expect(find.text('Top 3%'), findsOneWidget);
      expect(find.text('18,940 XP'), findsOneWidget);
    });

    testWidgets('Study plan: toggling a task updates progress badge and celebration',
        (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      expect(find.text('2 of 4 done'), findsOneWidget);

      // Tap 3rd task (Chemistry: Galvanic Cells & Nernst Drill)
      await tester.tap(find.text('Chemistry: Galvanic Cells & Nernst Drill'));
      await tester.pumpAndSettle();

      expect(find.text('3 of 4 done'), findsOneWidget);

      // Tap 4th task to complete all 4
      await tester.tap(find.text('Biology: Molecular Genetics Enzymes Check'));
      await tester.pumpAndSettle();

      expect(find.text('4 of 4 done'), findsOneWidget);
      expect(find.text('All daily goals complete! +50 XP'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(StudyPlanSection),
          matching: find.text('100%'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Study plan: inline Add task drawer creates a new task', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      expect(find.text('2 of 4 done'), findsOneWidget);

      // Tap Add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Enter task title
      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);
      await tester.enterText(inputFinder, 'Physics: Wave Optics Drill');
      await tester.pump();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Physics: Wave Optics Drill'), findsOneWidget);
      expect(find.text('2 of 5 done'), findsOneWidget);
    });

    testWidgets('Subject mastery: filter pills filter subjects correctly', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      final masterySection = find.byType(SubjectMasterySection);

      // All 4 subjects initially present in SubjectMasterySection
      expect(find.descendant(of: masterySection, matching: find.text('Physics')), findsOneWidget);
      expect(find.descendant(of: masterySection, matching: find.text('Mathematics')), findsOneWidget);
      expect(find.descendant(of: masterySection, matching: find.text('Chemistry')), findsOneWidget);
      expect(find.descendant(of: masterySection, matching: find.text('Biology')), findsOneWidget);

      // Filter by "Needs Focus" (<80% mastery): Chemistry (71%), Biology (79%)
      await tester.tap(find.text('Needs Focus'));
      await tester.pumpAndSettle();

      expect(find.descendant(of: masterySection, matching: find.text('Physics')), findsNothing);
      expect(find.descendant(of: masterySection, matching: find.text('Mathematics')), findsNothing);
      expect(find.descendant(of: masterySection, matching: find.text('Chemistry')), findsOneWidget);
      expect(find.descendant(of: masterySection, matching: find.text('Biology')), findsOneWidget);

      // Filter by "Strong" (>=80% mastery): Physics (82%), Mathematics (88%)
      await tester.tap(find.text('Strong'));
      await tester.pumpAndSettle();

      expect(find.descendant(of: masterySection, matching: find.text('Physics')), findsOneWidget);
      expect(find.descendant(of: masterySection, matching: find.text('Mathematics')), findsOneWidget);
      expect(find.descendant(of: masterySection, matching: find.text('Chemistry')), findsNothing);
      expect(find.descendant(of: masterySection, matching: find.text('Biology')), findsNothing);

      // Restore "All"
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.descendant(of: masterySection, matching: find.text('Physics')), findsOneWidget);
      expect(find.descendant(of: masterySection, matching: find.text('Mathematics')), findsOneWidget);
    });

    testWidgets('Subject mastery: tapping subject card body expands syllabus drawer',
        (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      final masterySection = find.byType(SubjectMasterySection);

      // Initially syllabus units are collapsed
      expect(find.text('GRADE 12 SYLLABUS UNITS'), findsNothing);

      // Tap on Physics card inside SubjectMasterySection
      await tester.tap(find.descendant(of: masterySection, matching: find.text('Physics')));
      await tester.pumpAndSettle();

      expect(find.text('GRADE 12 SYLLABUS UNITS'), findsOneWidget);
      expect(find.text('Unit 3: Fluid Mechanics'), findsOneWidget);
      expect(find.text('Unit 4: Electromagnetism'), findsOneWidget);
    });

    testWidgets('Formula flashcard: tap flips card 180 degrees to show formula and tip',
        (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      expect(find.text("Faraday's Law"), findsOneWidget);
      expect(find.text('Tap to reveal formula →'), findsWidgets);

      // Tap on Faraday's Law card to flip
      await tester.tap(find.text("Faraday's Law"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('ε = −N · (ΔΦ / Δt)'), findsOneWidget);
      expect(find.text('Tap to flip back'), findsOneWidget);
    });

    testWidgets('Hero card Continue Unit 4 button opens QuickStudySheet', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      // Tap "Continue Unit 4" CTA
      await tester.tap(find.text('Continue Unit 4'));
      // Advance past loading delay
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.byType(QuickStudySheet), findsOneWidget);
      expect(
        find.descendant(of: find.byType(QuickStudySheet), matching: find.text('PHYSICS • UNIT 4')),
        findsOneWidget,
      );
      expect(find.text('Electromagnetism'), findsOneWidget);
      expect(find.text('KEY EUEE FORMULAS'), findsOneWidget);
      expect(find.text('1-QUESTION WARM-UP CHECK'), findsOneWidget);

      // Tap Option A (Correct answer)
      await tester.tap(find.text('0 N, because sin(0°) = 0'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Correct! F = qvB·sin(0°) = 0 N'), findsOneWidget);
    });

    testWidgets('Drill button opens MiniDrillSheet and advances through questions',
        (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      // Tap first Drill button (Physics)
      final drillButtonFinder = find.text('Drill').first;
      await tester.tap(drillButtonFinder);
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();

      expect(find.byType(MiniDrillSheet), findsOneWidget);
      expect(find.text('PHYSICS • EUEE DRILL'), findsOneWidget);
      expect(find.text('1 of 3'), findsOneWidget);
      expect(find.text('Electromagnetic Induction'), findsOneWidget);

      // Select Option B (20 V - correct answer for Q1)
      await tester.tap(find.text('20 V'));
      await tester.pumpAndSettle();

      expect(find.text('Correct Answer!'), findsOneWidget);
      expect(find.text('Next Question'), findsOneWidget);

      // Tap Next Question to advance to Q2
      await tester.tap(find.text('Next Question'));
      await tester.pumpAndSettle();

      expect(find.text('2 of 3'), findsOneWidget);
      expect(find.text('Lorentz Force'), findsOneWidget);
    });
  });
}
