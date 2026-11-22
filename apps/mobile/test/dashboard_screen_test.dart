import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:acedex/core/config/feature_flags.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/features/dashboard/models/dashboard_data.dart';
import 'package:acedex/features/dashboard/screens/dashboard_screen.dart';
import 'package:acedex/features/dashboard/widgets/add_study_plan_sheet.dart';
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

  final sampleTasks = [
    const StudyTaskItem(
      id: 'sample-1',
      title: 'Physics: Electromagnetism Formula Review',
      subject: 'Physics',
      duration: '15m',
      completed: true,
    ),
    const StudyTaskItem(
      id: 'sample-2',
      title: 'Mathematics: Definite Integrals Past Set',
      subject: 'Math',
      duration: '20m',
      completed: true,
    ),
    const StudyTaskItem(
      id: 'sample-3',
      title: 'Chemistry: Galvanic Cells & Nernst Drill',
      subject: 'Chemistry',
      duration: '25m',
      completed: false,
    ),
    const StudyTaskItem(
      id: 'sample-4',
      title: 'Biology: Molecular Genetics Enzymes Check',
      subject: 'Biology',
      duration: '15m',
      completed: false,
    ),
  ];

  Widget createDashboardHarness({UserProfile? user, List<StudyTaskItem>? tasks}) {
    return MaterialApp(
      home: Scaffold(
        body: DashboardScreen(
          user: user ?? testUser,
          initialTasks: tasks,
          initialUnitsMastered: 0,
          initialTotalUnits: 237,
          initialAccuracyPct: 0.0,
          initialExamDate: DateTime(2026, 6, 8, 9, 0),
        ),
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
    setUp(() {
      FeatureFlags.enableFlashcards = true;
      FeatureFlags.enableSmartNotes = true;
    });

    testWidgets('renders all canonical inside dashboard sections with live DB metrics', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      // Section 1: Hero Countdown & Readiness Card (No glow)
      expect(find.byType(HeroCountdownCard), findsOneWidget);
      expect(find.text('G12 • NATURAL SCIENCE'), findsOneWidget);
      expect(find.text('Countdown'), findsOneWidget);
      expect(find.text('Readiness'), findsOneWidget);
      expect(find.text('Continue Unit 4'), findsOneWidget);

      // Section 2: Live Curriculum Bento Grid (Real 237 Units from DB)
      expect(find.byType(CurriculumBentoGrid), findsOneWidget);
      expect(find.text('Curriculum Pulse'), findsOneWidget);
      expect(find.text('0 / 237'), findsOneWidget);
      expect(find.text('0.0%'), findsOneWidget);
      expect(find.text('45 / 60m'), findsOneWidget);
      expect(find.text('+15m'), findsOneWidget);
      expect(find.text('Top 5%'), findsOneWidget);

      // Section 3: Today's Study Plan (Empty by default)
      expect(find.byType(StudyPlanSection), findsOneWidget);
      expect(find.text("Today's Study Plan"), findsOneWidget);
      expect(find.text('0 planned'), findsOneWidget);
      expect(find.text('No Tasks Planned Yet'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      // Section 4: Subject Mastery moved to Practice screen (not on Dashboard)
      expect(find.byType(SubjectMasterySection), findsNothing);

      // Section 5: Formula Flashcards (When enabled)
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
      await tester.pumpWidget(createDashboardHarness(tasks: sampleTasks));
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

    testWidgets('Study plan: tapping Add opens AddStudyPlanSheet and adds a new task', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      expect(find.text('0 planned'), findsOneWidget);

      // Tap Add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // AddStudyPlanSheet is displayed
      expect(find.byType(AddStudyPlanSheet), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AddStudyPlanSheet),
          matching: find.text('Add Study Plan'),
        ),
        findsOneWidget,
      );

      // Enter custom topic
      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);
      await tester.enterText(inputFinder, 'Physics: Wave Optics Drill');
      await tester.pump();

      // Tap "Add to Today's Plan"
      await tester.tap(find.text("Add to Today's Plan"));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Sheet dismissed, task added!
      expect(find.byType(AddStudyPlanSheet), findsNothing);
      expect(find.text('Physics: Wave Optics Drill'), findsOneWidget);
      expect(find.text('0 of 1 done'), findsOneWidget);
    });

    testWidgets('Study plan: tasks can be deleted with the delete icon', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness(tasks: sampleTasks));
      await tester.pump();

      expect(find.text('2 of 4 done'), findsOneWidget);
      expect(find.text('Physics: Electromagnetism Formula Review'), findsOneWidget);

      // Tap first delete icon
      final deleteButtons = find.byType(GestureDetector);
      expect(deleteButtons, findsWidgets);

      // Delete the first task
      final deleteIconFinder = find.byWidgetPredicate(
        (widget) => widget is HugeIcon && widget.icon == HugeIcons.strokeRoundedDelete02,
      );
      expect(deleteIconFinder, findsNWidgets(4));

      await tester.tap(deleteIconFinder.first);
      await tester.pumpAndSettle();

      // Task is removed, remaining 3 tasks
      expect(find.text('Physics: Electromagnetism Formula Review'), findsNothing);
      expect(find.text('1 of 3 done'), findsOneWidget);
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

    testWidgets('Feature gating: when disabled, flashcards carousel is omitted and Hero opens drill',
        (tester) async {
      FeatureFlags.enableFlashcards = false;
      FeatureFlags.enableSmartNotes = false;

      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      // Carousel is not present
      expect(find.byType(FormulaFlashcardsCarousel), findsNothing);

      // Tap Continue Unit 4 opens MiniDrillSheet instead of QuickStudySheet
      await tester.tap(find.text('Continue Unit 4'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.byType(QuickStudySheet), findsNothing);
      expect(find.byType(MiniDrillSheet), findsOneWidget);
      expect(find.text('PHYSICS • EUEE DRILL'), findsOneWidget);
    });
  });
}
