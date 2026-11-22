import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/features/dashboard/widgets/subject_mastery_section.dart';
import 'package:acedex/features/practice/screens/practice_screen.dart';
import 'package:acedex/features/practice/widgets/answer_review_view.dart';
import 'package:acedex/features/practice/widgets/completed_sessions_list.dart';
import 'package:acedex/features/practice/widgets/custom_mock_builder_card.dart';
import 'package:acedex/features/practice/widgets/past_papers_list.dart';
import 'package:acedex/features/practice/widgets/practice_subject_filter_rail.dart';
import 'package:acedex/features/practice/widgets/quiz_session_view.dart';

void main() {
  const testUser = UserProfile(
    id: 'usr_test_practice',
    acedexId: 'ACX-26-0003',
    displayName: 'Abebe Bikila',
    phone: '+251911334455',
    gender: 'male',
    grade: 12,
    stream: 'natural',
    role: 'student',
    status: 'active',
  );

  Widget createPracticeHarness({UserProfile? user}) {
    return MaterialApp(
      home: Scaffold(
        body: PracticeScreen(user: user ?? testUser),
      ),
    );
  }

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('PracticeScreen Full Inside UI Showcase Tests', () {
    testWidgets('renders View 1 (Practice Hub) with all core components', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createPracticeHarness());
      await tester.pump();

      // Top Eyebrow & Headline
      expect(find.text('EUEE EXAM BANK'), findsOneWidget);
      expect(find.text('Practice'), findsWidgets);
      expect(find.text('Official Ethiopian Grade 12 past papers & timed mocks'), findsOneWidget);

      // Subject Filter Rail
      expect(find.byType(PracticeSubjectFilterRail), findsOneWidget);
      expect(find.text('All'), findsWidgets);
      expect(find.text('Physics'), findsWidgets);
      expect(find.text('Mathematics'), findsWidgets);
      expect(find.text('Chemistry'), findsWidgets);
      expect(find.text('Biology'), findsWidgets);

      // Gliding Mode Segmented Bar
      expect(find.text('Past Papers'), findsOneWidget);
      expect(find.text('Custom Mock'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);

      // Custom Mock Builder Card
      expect(find.byType(CustomMockBuilderCard), findsOneWidget);
      expect(find.text('QUICK MOCK BUILDER'), findsOneWidget);
      expect(find.text('Custom EUEE Session'), findsOneWidget);
      expect(find.text('Study Mode'), findsWidgets);
      expect(find.text('Exam Mode'), findsWidgets);
      expect(find.text('3 Qs'), findsOneWidget);
      expect(find.text('5 Qs'), findsOneWidget);
      expect(find.text('Start EUEE Session'), findsOneWidget);

      // Past Papers Section
      expect(find.byType(PastPapersList), findsOneWidget);
      expect(find.text('Official EUEE Past Papers'), findsOneWidget);
      expect(find.text('Physics — EUEE 2017 E.C. (2025)'), findsOneWidget);

      // Completed Sessions Section
      expect(find.byType(CompletedSessionsList), findsOneWidget);
      expect(find.text('Recent Completed Sessions'), findsOneWidget);
      expect(find.text('Review Answers'), findsWidgets);

      // Subject Mastery Section moved to Practice screen
      expect(find.byType(SubjectMasterySection), findsOneWidget);
      expect(find.text('Subject Mastery'), findsOneWidget);
      expect(find.text('Tap card for syllabus'), findsOneWidget);
    });

    testWidgets('subject filter rail updates visible past papers', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createPracticeHarness());
      await tester.pump();

      // Tap Mathematics in subject filter rail
      final mathPill = find.text('Mathematics').first;
      await tester.tap(mathPill);
      await tester.pumpAndSettle();

      // Only Mathematics paper should be visible in past papers
      expect(find.text('Mathematics — EUEE 2017 E.C. (2025)'), findsOneWidget);
      expect(find.text('Physics — EUEE 2017 E.C. (2025)'), findsNothing);
    });

    testWidgets('toggling hub mode hides/shows respective sections', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createPracticeHarness());
      await tester.pump();

      // Tap Completed mode tab
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      // Past papers section is hidden, completed sessions are shown
      expect(find.byType(PastPapersList), findsNothing);
      expect(find.byType(CompletedSessionsList), findsOneWidget);

      // Tap Custom Mock mode tab
      await tester.tap(find.text('Custom Mock'));
      await tester.pumpAndSettle();

      // Builder card shown, past papers and completed sessions hidden
      expect(find.byType(CustomMockBuilderCard), findsOneWidget);
      expect(find.byType(PastPapersList), findsNothing);
      expect(find.byType(CompletedSessionsList), findsNothing);
    });

    testWidgets('launches Quiz Session View and verifies interactive features', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createPracticeHarness());
      await tester.pump();

      // Tap Start EUEE Session
      final startBtn = find.text('Start EUEE Session');
      expect(startBtn, findsOneWidget);
      await tester.tap(startBtn);
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();

      // View 2 (QuizSessionView) is active
      expect(find.byType(QuizSessionView), findsOneWidget);
      expect(find.text('Q 1 / 3'), findsOneWidget);
      expect(find.text('Flag'), findsOneWidget);
      expect(find.text('Study Mode'), findsWidgets);

      // Open Question Navigator Grid
      await tester.tap(find.text('Q 1 / 3'));
      await tester.pumpAndSettle();
      expect(find.text('Question Navigator'), findsOneWidget);

      // Close Navigator Grid
      await tester.tap(find.text('Q 1 / 3'));
      await tester.pumpAndSettle();

      // Toggle Flag
      await tester.tap(find.text('Flag'));
      await tester.pumpAndSettle();

      // Toggle Hint
      final hintBtn = find.text('Hint');
      expect(hintBtn, findsOneWidget);
      await tester.tap(hintBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining('EUEE Hint:'), findsOneWidget);

      // Select an option (A) in Study Mode
      final optionA = find.text('A').first;
      await tester.tap(optionA);
      await tester.pumpAndSettle();

      // Solution card appears in Study Mode
      expect(find.text('EUEE Solution'), findsOneWidget);

      // Advance to Question 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Q 2 / 3'), findsOneWidget);

      // Select an option for Q2
      await tester.tap(find.text('A').first);
      await tester.pumpAndSettle();

      // Advance to Question 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Q 3 / 3'), findsOneWidget);
      expect(find.text('Submit Paper'), findsOneWidget);

      // Select an option for Q3
      await tester.tap(find.text('A').first);
      await tester.pumpAndSettle();

      // Tap Submit Paper
      await tester.tap(find.text('Submit Paper'));
      await tester.pump(const Duration(milliseconds: 1050));
      await tester.pumpAndSettle();

      // View 3 (AnswerReviewView) is now active!
      expect(find.byType(AnswerReviewView), findsOneWidget);
      expect(find.textContaining('Correct'), findsWidgets);
      expect(find.text('Retake Paper'), findsOneWidget);
      expect(find.text('All Papers'), findsOneWidget);
      expect(find.text('Back to Practice Hub'), findsOneWidget);

      // Tap Back to Practice Hub
      await tester.tap(find.text('Back to Practice Hub'));
      await tester.pumpAndSettle();

      // Back in View 1 (Practice Hub)
      expect(find.byType(QuizSessionView), findsNothing);
      expect(find.byType(AnswerReviewView), findsNothing);
      expect(find.text('EUEE EXAM BANK'), findsOneWidget);
    });

    testWidgets('tapping Review Answers opens Answer Review View with filter tabs', (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createPracticeHarness());
      await tester.pump();

      // Tap Review Answers in Completed Sessions
      final reviewBtn = find.text('Review Answers').first;
      await tester.tap(reviewBtn);
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();

      // Answer Review View is shown
      expect(find.byType(AnswerReviewView), findsOneWidget);
      expect(find.text('All (5)'), findsOneWidget);
      expect(find.text('Incorrect (1)'), findsOneWidget);
      expect(find.text('Flagged (1)'), findsOneWidget);

      // Switch to Incorrect filter
      await tester.tap(find.text('Incorrect (1)'));
      await tester.pumpAndSettle();

      // Switch to Flagged filter
      await tester.tap(find.text('Flagged (1)'));
      await tester.pumpAndSettle();

      // Tap All Papers
      await tester.tap(find.text('All Papers'));
      await tester.pumpAndSettle();

      // Back to Practice Hub
      expect(find.byType(AnswerReviewView), findsNothing);
      expect(find.text('EUEE EXAM BANK'), findsOneWidget);
    });
  });
}
