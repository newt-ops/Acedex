import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:acedex/core/config/feature_flags.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/features/study/models/study_models.dart';
import 'package:acedex/features/study/screens/study_screen.dart';
import 'package:acedex/features/study/widgets/curriculum_hero_card.dart';
import 'package:acedex/features/study/widgets/subject_pill_rail_and_search.dart';
import 'package:acedex/features/study/widgets/syllabus_unit_accordion.dart';

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

  final mockTestCurriculum = {
    'physics': const SubjectCurriculum(
      id: 'physics',
      name: 'Physics',
      mastery: 82,
      lastTopicId: 'PHY-G12-U01',
      iconData: HugeIcons.strokeRoundedAtom01,
      color: Color(0xFF6E39CB),
      units: [
        StudyUnit(
          id: 'PHY-G12-U01',
          code: 'U1',
          unitCode: 'PHY-G12-U01',
          title: 'Application of Physics in Other Fields',
          examWeight: '15 Questions • Ethiopian Curriculum Bank',
          expanded: false,
          topics: [],
        ),
        StudyUnit(
          id: 'PHY-G12-U03',
          code: 'U3',
          unitCode: 'PHY-G12-U03',
          title: 'Fluid Mechanics',
          examWeight: '15 Questions • Ethiopian Curriculum Bank',
          expanded: false,
          topics: [],
        ),
      ],
    ),
    'mathematics': const SubjectCurriculum(
      id: 'mathematics',
      name: 'Mathematics',
      mastery: 88,
      lastTopicId: 'MAT-G12-U01',
      iconData: HugeIcons.strokeRoundedCalculate,
      color: Color(0xFF2563EB),
      units: [
        StudyUnit(
          id: 'MAT-G12-U01',
          code: 'U1',
          unitCode: 'MAT-G12-U01',
          title: 'Sequences and Series',
          examWeight: '15 Questions • Ethiopian Curriculum Bank',
          expanded: false,
          topics: [],
        ),
        StudyUnit(
          id: 'MAT-G12-U02',
          code: 'U2',
          unitCode: 'MAT-G12-U02',
          title: 'Introductions to Calculus',
          examWeight: '15 Questions • Ethiopian Curriculum Bank',
          expanded: false,
          topics: [],
        ),
        StudyUnit(
          id: 'MAT-G12-U03',
          code: 'U3',
          unitCode: 'MAT-G12-U03',
          title: 'Statistics',
          examWeight: '15 Questions • Ethiopian Curriculum Bank',
          expanded: false,
          topics: [],
        ),
        StudyUnit(
          id: 'MAT-G12-U04',
          code: 'U4',
          unitCode: 'MAT-G12-U04',
          title: 'Introduction to Linear Programming',
          examWeight: '15 Questions • Ethiopian Curriculum Bank',
          expanded: false,
          topics: [],
        ),
        StudyUnit(
          id: 'MAT-G12-U05',
          code: 'U5',
          unitCode: 'MAT-G12-U05',
          title: 'Mathematical Applications in Business',
          examWeight: '15 Questions • Ethiopian Curriculum Bank',
          expanded: false,
          topics: [],
        ),
      ],
    ),
    'chemistry': const SubjectCurriculum(
      id: 'chemistry',
      name: 'Chemistry',
      mastery: 71,
      lastTopicId: 'CHE-G12-U01',
      iconData: HugeIcons.strokeRoundedTestTube01,
      color: Color(0xFF0D9488),
      units: [],
    ),
    'biology': const SubjectCurriculum(
      id: 'biology',
      name: 'Biology',
      mastery: 79,
      lastTopicId: 'BIO-G12-U01',
      iconData: HugeIcons.strokeRoundedDna01,
      color: Color(0xFF16A34A),
      units: [],
    ),
  };

  Widget createStudyHarness({
    UserProfile? user,
    Map<String, SubjectCurriculum>? initialCurriculum,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: StudyScreen(
          user: user ?? testUser,
          initialCurriculum: initialCurriculum ?? mockTestCurriculum,
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

  group('StudyScreen Live Curriculum & 15-Question Assessment Tests', () {
    setUp(() {
      FeatureFlags.enableSmartNotes = true;
    });

    testWidgets('renders all core inside components without hardcoded data', (tester) async {
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

      // Component 3: Syllabus Unit Accordion
      expect(find.byType(SyllabusUnitAccordion), findsOneWidget);
      expect(find.text('Application of Physics in Other Fields'), findsOneWidget);
    });

    testWidgets('switching to Mathematics shows all 5 Grade 12 units', (tester) async {
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

    testWidgets('marking unit complete unlocks 15-question assessment card', (tester) async {
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

    testWidgets('initial load without curriculum displays loading / error state gracefully',
        (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudyScreen(
              user: testUser,
              initialCurriculum: const {}, // Empty initial state to test live fetch state
            ),
          ),
        ),
      );
      await tester.pump();

      // Should display loading or error message when map is empty
      expect(find.textContaining('Curriculum'), findsWidgets);
    });
  });
}
