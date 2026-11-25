import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acedex/core/config/feature_flags.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/core/storage/auth_storage.dart';
import 'package:acedex/features/dashboard/models/dashboard_data.dart';
import 'package:acedex/features/dashboard/screens/dashboard_screen.dart';
import 'package:acedex/features/dashboard/widgets/add_study_plan_sheet.dart';
import 'package:acedex/features/dashboard/widgets/curriculum_bento_grid.dart';
import 'package:acedex/features/dashboard/widgets/formula_flashcards_carousel.dart';
import 'package:acedex/features/dashboard/widgets/hero_countdown_card.dart';
import 'package:acedex/features/dashboard/widgets/study_plan_section.dart';

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
      title: 'Chemistry: Galvanic Cells & Electrochemistry',
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
      SharedPreferences.setMockInitialValues({});
      AuthStorage.instance.dailyFocusGoalMinutesNotifier.value = 0;
      AuthStorage.instance.dailyFocusCompletedMinutesNotifier.value = 0;
      FeatureFlags.enableFlashcards = true;
      FeatureFlags.enableSmartNotes = true;
    });

    testWidgets('renders all canonical inside dashboard sections starting at 0 focus time and no Continue button', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      // Section 1: Hero Countdown & Readiness Card (No Continue button, no grade badge)
      expect(find.byType(HeroCountdownCard), findsOneWidget);
      expect(find.text('G12 • NATURAL SCIENCE'), findsNothing);
      expect(find.text('Countdown'), findsOneWidget);
      expect(find.text('Readiness'), findsOneWidget);
      expect(find.text('Continue Unit 4'), findsNothing);

      // Section 2: Live Curriculum Bento Grid starts at 0 / 0m
      expect(find.byType(CurriculumBentoGrid), findsOneWidget);
      expect(find.text('Curriculum Pulse'), findsOneWidget);
      expect(find.text('0 / 237'), findsOneWidget);
      expect(find.text('0.0%'), findsOneWidget);
      expect(find.text('0 / 0m'), findsOneWidget);
      expect(find.text('+15m'), findsNothing);
      expect(find.text('Top 5%'), findsOneWidget);

      // Section 3: Today's Study Plan (Empty by default)
      expect(find.byType(StudyPlanSection), findsOneWidget);
      expect(find.text("Today's Study Plan"), findsOneWidget);
      expect(find.text('0 planned'), findsOneWidget);
      expect(find.text('No Tasks Planned Yet'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      // Section 5: Formula Flashcards (When enabled)
      expect(find.byType(FormulaFlashcardsCarousel), findsOneWidget);
      expect(find.text('Formula Flashcards'), findsOneWidget);
    });

    testWidgets('Hero card toggles between Countdown and Readiness views', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      expect(find.text('DAYS'), findsOneWidget);
      expect(find.text('HOURS'), findsOneWidget);
      expect(find.text('MINS'), findsOneWidget);

      await tester.tap(find.text('Readiness'));
      await tester.pumpAndSettle();

      expect(find.text('Exam Readiness'), findsOneWidget);
      expect(find.text('+4.2% wk'), findsOneWidget);
      expect(find.textContaining('545+ EUEE'), findsOneWidget);

      await tester.tap(find.text('Countdown'));
      await tester.pumpAndSettle();

      expect(find.text('DAYS'), findsOneWidget);
    });

    testWidgets('Bento grid: Daily Focus uses calibrated onboarding goal and updates when tasks complete',
        (tester) async {
      await AuthStorage.instance.setDailyFocusGoalMinutes(90);
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness(tasks: sampleTasks));
      await tester.pumpAndSettle();

      // Initially 2 completed sample tasks (15m + 20m = 35m) out of 90m onboarding goal
      expect(find.text('35 / 90m'), findsOneWidget);

      // Completing 25m task advances Daily Focus to 60 / 90m
      await tester.tap(find.text('Chemistry: Galvanic Cells & Electrochemistry'));
      await tester.pumpAndSettle();
      expect(find.text('60 / 90m'), findsOneWidget);

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

      await tester.tap(find.text('Chemistry: Galvanic Cells & Electrochemistry'));
      await tester.pumpAndSettle();
      expect(find.text('3 of 4 done'), findsOneWidget);

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

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.byType(AddStudyPlanSheet), findsOneWidget);
      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);
      await tester.enterText(inputFinder, 'Physics: Wave Optics Review');
      await tester.pump();

      await tester.tap(find.text("Add to Today's Plan"));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.byType(AddStudyPlanSheet), findsNothing);
      expect(find.text('Physics: Wave Optics Review'), findsOneWidget);
      expect(find.text('0 of 1 done'), findsOneWidget);
    });

    testWidgets('Study plan: tasks can be deleted with the delete icon', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness(tasks: sampleTasks));
      await tester.pump();

      expect(find.text('2 of 4 done'), findsOneWidget);
      final deleteIconFinder = find.byWidgetPredicate(
        (widget) => widget is HugeIcon && widget.icon == HugeIcons.strokeRoundedDelete02,
      );
      expect(deleteIconFinder, findsNWidgets(4));

      await tester.tap(deleteIconFinder.first);
      await tester.pumpAndSettle();

      expect(find.text('Delete Task'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Physics: Electromagnetism Formula Review'), findsNothing);
      expect(find.text('1 of 3 done'), findsOneWidget);
    });

    testWidgets('Formula flashcard: tap flips card 180 degrees to show formula and tip',
        (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createDashboardHarness());
      await tester.pump();

      expect(find.text("Faraday's Law"), findsOneWidget);
      await tester.tap(find.text("Faraday's Law"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('ε = −N · (ΔΦ / Δt)'), findsOneWidget);
      expect(find.text('Tap to flip back'), findsOneWidget);
    });
  });
}
