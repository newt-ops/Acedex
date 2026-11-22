import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/features/progress/screens/progress_screen.dart';

void main() {
  const dummyUser = UserProfile(
    id: 'usr_test_1',
    acedexId: 'ACX-2026-88912',
    displayName: 'Abebe Bikila',
    phone: '+251912345678',
    grade: 12,
    stream: 'natural',
    role: 'student',
    status: 'active',
  );

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: ProgressScreen(user: dummyUser),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders all core inside components of ProgressScreen', (tester) async {
    await pumpScreen(tester);

    // 1. Top Section Header
    expect(find.text('PERFORMANCE & ANALYTICS'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('G12 • Natural Science'), findsOneWidget);
    expect(find.text('7 Days'), findsOneWidget);
    expect(find.text('30 Days'), findsOneWidget);
    expect(find.text('All Term'), findsOneWidget);

    // 2. Card 1: EUEE Readiness Hero Card
    expect(find.text('EUEE READINESS'), findsOneWidget);
    expect(find.text('+4.2%'), findsOneWidget);
    expect(find.text('Est. 468 / 600 • Top 5%'), findsOneWidget);
    expect(find.text('Syllabus Coverage'), findsOneWidget);
    expect(find.text('Mock Accuracy'), findsOneWidget);
    expect(find.text('Consistency'), findsOneWidget);
    expect(find.text('Simulate EUEE Score'), findsOneWidget);

    // 3. Card 2: Study & Accuracy Analytics Chart Card
    expect(find.text('Study & Accuracy Trend'), findsOneWidget);
    expect(find.text('Study Hours'), findsOneWidget);
    expect(find.text('Quiz Accuracy'), findsOneWidget);
    expect(find.text('TOTAL STUDY'), findsOneWidget);
    expect(find.text('18.4 hrs'), findsOneWidget);
    expect(find.text('AVG ACCURACY'), findsOneWidget);
    expect(find.text('83.4%'), findsOneWidget);
    expect(find.text('QUESTIONS'), findsOneWidget);
    expect(find.text('268 Qs'), findsOneWidget);

    // 4. Card 3: 28-Day Consistency Heatmap Card
    expect(find.text('28-Day Consistency'), findsOneWidget);
    expect(find.text('12d Streak'), findsOneWidget);
    expect(find.text('Best 19d'), findsOneWidget);

    // 5. Card 4: Subject Mastery Section
    expect(find.text('Subject Mastery'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Needs Focus'), findsOneWidget);
    expect(find.text('Exam Ready'), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Biology'), findsOneWidget);
    expect(find.text('Chemistry'), findsOneWidget);
  });

  testWidgets('timeframe switcher dynamically updates hero metrics and chart footer', (tester) async {
    await pumpScreen(tester);

    // Default 7 Days: 18.4 hrs
    expect(find.text('18.4 hrs'), findsOneWidget);
    expect(find.text('Est. 468 / 600 • Top 5%'), findsOneWidget);

    // Tap 30 Days
    await tester.tap(find.text('30 Days'));
    await tester.pumpAndSettle();

    expect(find.text('76.5 hrs'), findsOneWidget);
    expect(find.text('Est. 486 / 600 • Top 3%'), findsOneWidget);
    expect(find.text('+6.8%'), findsOneWidget);

    // Tap All Term
    await tester.tap(find.text('All Term'));
    await tester.pumpAndSettle();

    expect(find.text('214.0 hrs'), findsOneWidget);
    expect(find.text('Est. 456 / 600 • Top 7%'), findsOneWidget);
    expect(find.text('+9.4%'), findsOneWidget);
  });

  testWidgets('tapping pillars updates explanation note in hero card', (tester) async {
    await pumpScreen(tester);

    // Default pillar: Syllabus Coverage
    expect(find.textContaining('19 of 24 Grade 12 Natural Science units completed'), findsOneWidget);

    // Tap Mock Accuracy pillar
    await tester.tap(find.text('Mock Accuracy'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Weighted average score across timed EUEE past papers'), findsOneWidget);

    // Tap Consistency pillar
    await tester.tap(find.text('Consistency'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tracks daily study target adherence'), findsOneWidget);
  });

  testWidgets('chart metric toggle switches between Study Hours and Quiz Accuracy', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Dashed line: 2.5h daily target'), findsOneWidget);

    // Tap Quiz Accuracy toggle
    await tester.tap(find.text('Quiz Accuracy'));
    await tester.pumpAndSettle();

    expect(find.text('Dashed line: 80% EUEE accuracy goal'), findsOneWidget);
  });

  testWidgets('subject filter tabs filter subjects by mastery benchmark', (tester) async {
    await pumpScreen(tester);

    // All shows all 4
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Chemistry'), findsOneWidget);

    // Needs Focus (< 80%) shows Biology (79%) and Chemistry (71%)
    await tester.tap(find.text('Needs Focus'));
    await tester.pumpAndSettle();

    expect(find.text('Chemistry'), findsOneWidget);
    expect(find.text('Biology'), findsOneWidget);
    expect(find.text('Mathematics'), findsNothing);
    expect(find.text('Physics'), findsNothing);

    // Exam Ready (>= 80%) shows Mathematics (88%) and Physics (82%)
    await tester.tap(find.text('Exam Ready'));
    await tester.pumpAndSettle();

    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Chemistry'), findsNothing);
  });

  testWidgets('simulate EUEE score opens simulator sheet and apply target updates hero card', (tester) async {
    await pumpScreen(tester);

    // Tap Simulate EUEE Score button
    await tester.tap(find.text('Simulate EUEE Score'));
    // Wait for the 650ms loading animation
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify sheet opened
    expect(find.text('What-If Score Simulator'), findsOneWidget);
    expect(find.text('PROJECTED TOTAL SCORE'), findsOneWidget);
    expect(find.text('English + Aptitude Baseline'), findsOneWidget);
    expect(find.text('Apply Target'), findsOneWidget);

    // Tap Apply Target
    await tester.tap(find.text('Apply Target'));
    await tester.pumpAndSettle();

    // Sheet dismissed, Hero card updated
    expect(find.text('What-If Score Simulator'), findsNothing);
    expect(find.text('Est. 468 / 600 • Top 5%'), findsOneWidget);
  });

  testWidgets('subject card opens breakdown sheet and runs 2-question booster drill', (tester) async {
    await pumpScreen(tester);

    // Tap Chemistry card
    await tester.tap(find.text('Chemistry'));
    await tester.pumpAndSettle();

    // Mode A: Breakdown View
    expect(find.text('Chemistry Mastery'), findsOneWidget);
    expect(find.text('CURRENT MASTERY'), findsOneWidget);
    expect(find.text('AVG PACING / Q'), findsOneWidget);
    expect(find.text('Unit-by-Unit Progress'), findsOneWidget);
    expect(find.text('Boost Galvanic Cell Potential'), findsOneWidget);

    // Tap Boost button
    await tester.tap(find.text('Boost Galvanic Cell Potential'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Mode B: Booster Question 1 of 2
    expect(find.text('Booster Question 1 of 2'), findsOneWidget);
    expect(find.textContaining('Given Ag⁺/Ag'), findsOneWidget);

    // Next button disabled before answering
    expect(find.text('Select an Answer'), findsOneWidget);

    // Tap Option C (+1.24 V - index 2)
    await tester.tap(find.text('+1.24 V'));
    await tester.pumpAndSettle();

    // EUEE solution displayed and button becomes Next Question
    expect(find.textContaining('EUEE Solution:'), findsOneWidget);
    expect(find.text('Next Question'), findsOneWidget);

    // Tap Next Question -> Question 2
    await tester.tap(find.text('Next Question'));
    await tester.pumpAndSettle();

    expect(find.text('Booster Question 2 of 2'), findsOneWidget);
    expect(find.textContaining('At which electrode does oxidation always occur'), findsOneWidget);

    // Tap Option B (Anode - index 1)
    await tester.tap(find.text('Anode'));
    await tester.pumpAndSettle();

    expect(find.text('Complete Booster'), findsOneWidget);

    // Tap Complete Booster -> Celebratory Summary
    await tester.tap(find.text('Complete Booster'));
    await tester.pumpAndSettle();

    expect(find.text('MASTERY BOOSTED'), findsOneWidget);
    expect(find.text('Chemistry +4% Mastery!'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Tap Done -> dismisses sheet
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Chemistry Mastery'), findsNothing);
    // Chemistry mastery was 71%, boosted by 4% to 75%
    expect(find.text('75%'), findsOneWidget);
  });
}
