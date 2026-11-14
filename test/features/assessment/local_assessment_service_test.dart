import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:acedex/core/database/database.dart';
import 'package:acedex/features/assessment/models/assessment_models.dart';
import 'package:acedex/features/assessment/services/local_assessment_service.dart';

void main() {
  late AppDatabase db;
  late LocalAssessmentService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = LocalAssessmentService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('LocalAssessmentService Offline Drift Tests', () {
    final mockAssessment = Assessment(
      id: 'a1000000-0000-0000-0000-000000000001',
      code: 'G09_PHY_U01_TEST',
      title: 'Physics and Human Society',
      description: 'Unit 1 comprehensive assessment',
      assessmentType: AssessmentType.unit,
      currentVersionId: 'v1000000-0000-0000-0000-000000000001',
      subjectId: 'PHY_G09',
      grade: 9,
      stream: 'natural',
      createdAt: DateTime.parse('2026-11-14T00:00:00Z'),
      updatedAt: DateTime.parse('2026-11-14T00:00:00Z'),
      currentVersion: AssessmentVersion(
        id: 'v1000000-0000-0000-0000-000000000001',
        assessmentId: 'a1000000-0000-0000-0000-000000000001',
        versionNumber: 1,
        status: 'published',
        totalQuestions: 2,
        totalPoints: 2,
        timeLimitMinutes: 30,
        passingPercentage: 60.0,
        publishedAt: DateTime.parse('2026-11-14T00:00:00Z'),
        coveredChapterIds: ['PHY_G09_U01'],
        questions: [
          const Question(
            id: 'q1000000-0000-0000-0000-000000000001',
            assessmentVersionId: 'v1000000-0000-0000-0000-000000000001',
            chapterId: 'PHY_G09_U01',
            questionText: 'Which branch of physics deals with heat and temperature?',
            questionType: 'multiple_choice',
            points: 1,
            sortOrder: 1,
            options: [
              QuestionOption(
                id: 'o1000000-0000-0000-0000-000000000001',
                questionId: 'q1000000-0000-0000-0000-000000000001',
                optionLetter: 'A',
                optionText: 'Thermodynamics',
                sortOrder: 1,
              ),
              QuestionOption(
                id: 'o1000000-0000-0000-0000-000000000002',
                questionId: 'q1000000-0000-0000-0000-000000000001',
                optionLetter: 'B',
                optionText: 'Optics',
                sortOrder: 2,
              ),
            ],
          ),
          const Question(
            id: 'q1000000-0000-0000-0000-000000000002',
            assessmentVersionId: 'v1000000-0000-0000-0000-000000000001',
            chapterId: 'PHY_G09_U01',
            questionText: 'What is the SI unit of electric current?',
            questionType: 'multiple_choice',
            points: 1,
            sortOrder: 2,
            options: [
              QuestionOption(
                id: 'o1000000-0000-0000-0000-000000000003',
                questionId: 'q1000000-0000-0000-0000-000000000002',
                optionLetter: 'A',
                optionText: 'Ampere',
                sortOrder: 1,
              ),
              QuestionOption(
                id: 'o1000000-0000-0000-0000-000000000004',
                questionId: 'q1000000-0000-0000-0000-000000000002',
                optionLetter: 'B',
                optionText: 'Volt',
                sortOrder: 2,
              ),
            ],
          ),
        ],
      ),
    );

    test('cacheAssessment saves complete assessment hierarchy and retrieves by chapter', () async {
      await service.cacheAssessment(mockAssessment);

      final cached = await service.getCachedAssessmentForChapter('PHY_G09_U01');
      expect(cached, isNotNull);
      expect(cached!.id, mockAssessment.id);
      expect(cached.code, mockAssessment.code);
      expect(cached.title, mockAssessment.title);
      expect(cached.assessmentType, AssessmentType.unit);

      final version = cached.currentVersion;
      expect(version, isNotNull);
      expect(version!.id, 'v1000000-0000-0000-0000-000000000001');
      expect(version.coveredChapterIds, contains('PHY_G09_U01'));
      expect(version.questions.length, 2);

      // Verify question order and options
      expect(version.questions[0].questionText, 'Which branch of physics deals with heat and temperature?');
      expect(version.questions[0].options.length, 2);
      expect(version.questions[0].options[0].optionLetter, 'A');
      expect(version.questions[0].options[0].optionText, 'Thermodynamics');

      expect(version.questions[1].questionText, 'What is the SI unit of electric current?');
      expect(version.questions[1].options[0].optionLetter, 'A');
      expect(version.questions[1].options[0].optionText, 'Ampere');
    });

    test('saveLocalAttemptAnswers persists in-progress and pending sync attempts', () async {
      final startedAt = DateTime.now();
      await service.saveLocalAttemptAnswers(
        attemptId: 'att_test_123',
        studentId: 'stud_456',
        assessmentVersionId: 'v1000000-0000-0000-0000-000000000001',
        idempotencyKey: 'idemp_key_789',
        startedAt: startedAt,
        answers: {
          'q1000000-0000-0000-0000-000000000001': 'o1000000-0000-0000-0000-000000000001',
        },
        isPendingSync: true,
      );

      final pending = await service.getPendingSyncAttempts();
      expect(pending.length, 1);
      expect(pending.first.id, 'att_test_123');
      expect(pending.first.status, 'pending_sync');
      expect(pending.first.idempotencyKey, 'idemp_key_789');
      expect(pending.first.answersJson, contains('o1000000-0000-0000-0000-000000000001'));
    });

    test('saveGradedResult caches results locally', () async {
      final mockResult = AssessmentSubmissionResult(
        status: 'success',
        attemptId: 'att_test_123',
        totalQuestions: 2,
        answeredQuestions: 2,
        correctAnswers: 2,
        scoreObtained: 2.0,
        maxScore: 2.0,
        percentage: 100.0,
        passed: true,
        isOverdue: false,
        timingVerified: true,
        durationSeconds: 120,
        corrections: const [
          QuestionCorrection(
            questionId: 'q1000000-0000-0000-0000-000000000001',
            selectedOptionId: 'o1000000-0000-0000-0000-000000000001',
            correctOptionId: 'o1000000-0000-0000-0000-000000000001',
            isCorrect: true,
            pointsAwarded: 1.0,
            explanation: 'Thermodynamics is the study of heat and temperature.',
          ),
        ],
      );

      await service.saveGradedResult(
        resultId: 'res_001',
        attemptId: 'att_test_123',
        studentId: 'stud_456',
        assessmentVersionId: 'v1000000-0000-0000-0000-000000000001',
        result: mockResult,
      );

      final results = await db.select(db.localAssessmentResults).get();
      expect(results.length, 1);
      expect(results.first.id, 'res_001');
      expect(results.first.percentage, 100.0);
      expect(results.first.passed, true);
      expect(results.first.correctionsJson, contains('Thermodynamics is the study of heat'));
    });
  });
}
