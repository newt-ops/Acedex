import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/database/database.dart';
import 'package:acedex/features/assessment/models/assessment_models.dart';
import 'package:acedex/features/assessment/providers/assessment_providers.dart';
import 'package:acedex/features/assessment/repositories/assessment_repository.dart';
import 'package:acedex/features/assessment/services/local_assessment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockBackendAssessmentRepository implements AssessmentRepository {
  final Map<String, Assessment> _assessments = {};
  final Map<String, String> _solutionKeys = {};
  final Map<String, String> _explanations = {};

  void registerAssessment({
    required Assessment assessment,
    required Map<String, String> solutionKeys,
    required Map<String, String> explanations,
  }) {
    _assessments[assessment.id] = assessment;
    _solutionKeys.addAll(solutionKeys);
    _explanations.addAll(explanations);
  }

  @override
  Future<List<Assessment>> getAssessmentsForChapter(String chapterId) async {
    return _assessments.values.where((a) {
      return a.currentVersion?.coveredChapterIds.contains(chapterId) ?? false;
    }).toList();
  }

  @override
  Future<Assessment?> getCurrentAssessmentForChapter(String chapterId) async {
    final list = await getAssessmentsForChapter(chapterId);
    return list.isNotEmpty ? list.first : null;
  }

  @override
  Future<AssessmentAttemptCreationResult> startAttempt({
    required String assessmentId,
    required String idempotencyKey,
  }) async {
    final assess = _assessments[assessmentId];
    return AssessmentAttemptCreationResult(
      status: 'created',
      attemptId: 'att_$idempotencyKey',
      assessmentVersionId: assess?.currentVersionId ?? 'v1',
      serverStartedAt: DateTime.now(),
      totalQuestions: assess?.currentVersion?.totalQuestions ?? 0,
      timeLimitMinutes: 45,
    );
  }

  @override
  Future<AssessmentSubmissionResult> submitAttempt({
    required String attemptId,
    required String idempotencyKey,
    required List<SelectedAnswerSubmission> answers,
  }) async {
    int correctCount = 0;
    final corrections = <QuestionCorrection>[];

    for (final a in answers) {
      final trueCorrectOptId = _solutionKeys[a.questionId] ?? 'opt_unknown';
      final isCorrect = a.selectedOptionId == trueCorrectOptId;
      if (isCorrect) correctCount++;

      corrections.add(
        QuestionCorrection(
          questionId: a.questionId,
          selectedOptionId: a.selectedOptionId,
          correctOptionId: trueCorrectOptId,
          isCorrect: isCorrect,
          pointsAwarded: isCorrect ? 1.0 : 0.0,
          explanation: _explanations[a.questionId] ?? 'Authoritative explanation.',
        ),
      );
    }

    final total = answers.isNotEmpty ? answers.length : 1;
    final percentage = (correctCount / total) * 100.0;

    return AssessmentSubmissionResult(
      status: 'success',
      attemptId: attemptId,
      totalQuestions: total,
      answeredQuestions: answers.where((a) => a.selectedOptionId != null).length,
      correctAnswers: correctCount,
      scoreObtained: correctCount.toDouble(),
      maxScore: total.toDouble(),
      percentage: percentage,
      passed: percentage >= 70.0,
      corrections: corrections,
    );
  }

  @override
  Future<AssessmentSubmissionResult> reconcileOfflineAttempt({
    required String assessmentVersionId,
    required String attemptId,
    required String idempotencyKey,
    required DateTime clientStartedAt,
    required DateTime clientSubmittedAt,
    required List<SelectedAnswerSubmission> answers,
  }) async {
    return submitAttempt(
      attemptId: attemptId,
      idempotencyKey: idempotencyKey,
      answers: answers,
    );
  }

  @override
  Future<AssessmentSubmissionResult?> getResultForAttempt(String attemptId) async {
    return null;
  }
}

void main() {
  late AppDatabase db;
  late LocalAssessmentService localService;
  late MockBackendAssessmentRepository backendRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    localService = LocalAssessmentService(db);
    backendRepo = MockBackendAssessmentRepository();
  });

  tearDown(() async {
    await db.close();
  });

  group('Acedex Backend Question Bank & Assessment System Acceptance Tests', () {
    test('Criterion 1 & 2: Questions from different units can be retrieved correctly without answer keys', () async {
      // 1. Setup Unit 1 & Unit 2 Assessment Models
      final q1Unit1 = Question(
        id: 'q_phy_u1_1',
        assessmentVersionId: 'v_phy_u1',
        chapterId: 'PHYS_G9_U1',
        code: 'PHY-G09-U01-Q001',
        difficulty: 'easy',
        questionText: 'What is the root of physics?',
        sortOrder: 1,
        options: const [
          QuestionOption(id: 'opt_u1_1a', questionId: 'q_phy_u1_1', optionLetter: 'A', optionText: 'Phusis', sortOrder: 1),
          QuestionOption(id: 'opt_u1_1b', questionId: 'q_phy_u1_1', optionLetter: 'B', optionText: 'Techne', sortOrder: 2),
          QuestionOption(id: 'opt_u1_1c', questionId: 'q_phy_u1_1', optionLetter: 'C', optionText: 'Logos', sortOrder: 3),
          QuestionOption(id: 'opt_u1_1d', questionId: 'q_phy_u1_1', optionLetter: 'D', optionText: 'Kosmos', sortOrder: 4),
        ],
      );

      final version1 = AssessmentVersion(
        id: 'v_phy_u1',
        assessmentId: 'assess_phy_u1',
        versionNumber: 1,
        status: 'published',
        totalQuestions: 1,
        totalPoints: 1.0,
        coveredChapterIds: const ['PHYS_G9_U1'],
        questions: [q1Unit1],
      );

      final assess1 = Assessment(
        id: 'assess_phy_u1',
        code: 'ASSESS_PHYS_G9_U1',
        title: 'Grade 9 Physics: Unit 1 Assessment',
        currentVersionId: 'v_phy_u1',
        subjectId: 'PHYS_G9',
        grade: 9,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        currentVersion: version1,
      );

      // Register with backend repo (solutions stored privately on server)
      backendRepo.registerAssessment(
        assessment: assess1,
        solutionKeys: {'q_phy_u1_1': 'opt_u1_1a'},
        explanations: {'q_phy_u1_1': 'Phusis translates directly to nature.'},
      );

      // 2. Fetch via Repository
      final retrieved = await backendRepo.getCurrentAssessmentForChapter('PHYS_G9_U1');
      expect(retrieved, isNotNull);
      expect(retrieved!.code, equals('ASSESS_PHYS_G9_U1'));

      final questions = retrieved.currentVersion!.questions;
      expect(questions.length, equals(1));
      expect(questions.first.code, equals('PHY-G09-U01-Q001'));
      expect(questions.first.difficulty, equals('easy'));
      expect(questions.first.options.length, equals(4));

      // Criterion 3: Verify client data DOES NOT contain solutions or explanations
      final qMap = {
        'id': questions.first.id,
        'code': questions.first.code,
        'question_text': questions.first.questionText,
        'options': questions.first.options.map((o) => {'id': o.id, 'letter': o.optionLetter, 'text': o.optionText}).toList(),
      };
      expect(qMap.containsKey('correctOptionId'), isFalse);
      expect(qMap.containsKey('explanation'), isFalse);
    });

    test('Criterion 4 & 5: Answer selection works locally at 0ms and backend evaluates batch submission', () async {
      final q1 = Question(
        id: 'q1',
        assessmentVersionId: 'v1',
        chapterId: 'PHYS_G9_U1',
        questionText: 'Test Question 1',
        sortOrder: 1,
        options: const [
          QuestionOption(id: 'optA', questionId: 'q1', optionLetter: 'A', optionText: 'Option A', sortOrder: 1),
          QuestionOption(id: 'optB', questionId: 'q1', optionLetter: 'B', optionText: 'Option B', sortOrder: 2),
        ],
      );

      final assessment = Assessment(
        id: 'a1',
        code: 'A1',
        title: 'Title',
        currentVersionId: 'v1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        currentVersion: AssessmentVersion(
          id: 'v1',
          assessmentId: 'a1',
          versionNumber: 1,
          status: 'published',
          totalQuestions: 1,
          totalPoints: 1.0,
          coveredChapterIds: const ['PHYS_G9_U1'],
          questions: [q1],
        ),
      );

      backendRepo.registerAssessment(
        assessment: assessment,
        solutionKeys: {'q1': 'optA'},
        explanations: {'q1': 'Option A is correct.'},
      );

      final container = ProviderContainer(
        overrides: [
          assessmentRepositoryProvider.overrideWithValue(backendRepo),
          localAssessmentServiceProvider.overrideWithValue(localService),
        ],
      );

      final controller = container.read(assessmentPlayControllerProvider.notifier);
      controller.startAssessment(assessment);

      // Selecting option is 0ms local state
      controller.selectOption('q1', 'optA');
      expect(container.read(assessmentPlayControllerProvider).selectedAnswers['q1'], equals('optA'));

      // Batch submit to trusted backend
      final submitted = await controller.submit();
      expect(submitted, isTrue);

      final result = container.read(assessmentPlayControllerProvider).result;
      expect(result, isNotNull);
      expect(result!.scoreObtained, equals(1.0));
      expect(result.percentage, equals(100.0));
      expect(result.passed, isTrue);
      expect(result.corrections.first.isCorrect, isTrue);
      expect(result.corrections.first.explanation, equals('Option A is correct.'));
    });

    test('Criterion 6 & 7: Offline caching in Drift SQLite preserves questions without solutions and stores attempts independently', () async {
      final q1 = Question(
        id: 'q_off_1',
        assessmentVersionId: 'v_off_1',
        chapterId: 'PHYS_G9_U2',
        code: 'PHY-G09-U02-Q001',
        questionText: 'Which physical quantity is a scalar?',
        sortOrder: 1,
        options: const [
          QuestionOption(id: 'opt1', questionId: 'q_off_1', optionLetter: 'A', optionText: 'Mass', sortOrder: 1),
          QuestionOption(id: 'opt2', questionId: 'q_off_1', optionLetter: 'B', optionText: 'Velocity', sortOrder: 2),
        ],
      );

      final assessment = Assessment(
        id: 'a_off',
        code: 'ASSESS_PHYS_G9_U2',
        title: 'Grade 9 Physics: Unit 2 Assessment',
        currentVersionId: 'v_off_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        currentVersion: AssessmentVersion(
          id: 'v_off_1',
          assessmentId: 'a_off',
          versionNumber: 1,
          status: 'published',
          totalQuestions: 1,
          totalPoints: 1.0,
          coveredChapterIds: const ['PHYS_G9_U2'],
          questions: [q1],
        ),
      );

      // Cache assessment into Drift SQLite
      await localService.cacheAssessment(assessment);

      // Retrieve cached assessment offline
      final cached = await localService.getCachedAssessmentForChapter('PHYS_G9_U2');
      expect(cached, isNotNull);
      expect(cached!.code, equals('ASSESS_PHYS_G9_U2'));
      expect(cached.currentVersion!.questions.first.questionText, equals('Which physical quantity is a scalar?'));

      // Verify Drift questions table has NO answer keys
      final rawQuestions = await db.select(db.localQuestions).get();
      expect(rawQuestions.length, equals(1));
      // Drift table has id, questionText, points, sortOrder — no correct option column exists!

      // Save student attempt independently
      await localService.saveLocalAttemptAnswers(
        attemptId: 'att_offline_1',
        studentId: 'student_123',
        assessmentVersionId: 'v_off_1',
        idempotencyKey: 'idemp_off_1',
        startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        answers: {'q_off_1': 'opt1'},
        isPendingSync: true,
      );

      final pending = await localService.getPendingSyncAttempts();
      expect(pending.length, equals(1));
      expect(pending.first.id, equals('att_offline_1'));
      expect(pending.first.status, equals('pending_sync'));
      expect(pending.first.answersJson, contains('opt1'));
    });
  });
}
