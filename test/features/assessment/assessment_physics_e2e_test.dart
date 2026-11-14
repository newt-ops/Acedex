import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:acedex/core/database/database.dart';
import 'package:acedex/core/database/curriculum_seeder.dart';
import 'package:acedex/features/assessment/models/assessment_models.dart';
import 'package:acedex/features/assessment/services/local_assessment_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late LocalAssessmentService localService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    localService = LocalAssessmentService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Grade 9 Physics Unit 1 & 2 Question Bank Feeding & Evaluation Tests', () {
    test(
      'PHY-G09-U01.json and PHY-G09-U02.json exist and contain 30 questions each',
      () {
        final fileU1 = File('assets/data/PHY-G09-U01.json');
        final fileU2 = File('assets/data/PHY-G09-U02.json');

        expect(fileU1.existsSync(), isTrue);
        expect(fileU2.existsSync(), isTrue);

        final dataU1 =
            jsonDecode(fileU1.readAsStringSync()) as Map<String, dynamic>;
        final dataU2 =
            jsonDecode(fileU2.readAsStringSync()) as Map<String, dynamic>;

        expect(dataU1['grade'], 9);
        expect(dataU1['subject'], 'Physics');
        expect(dataU1['unitNumber'], 1);
        expect((dataU1['questions'] as List).length, 30);

        expect(dataU2['grade'], 9);
        expect(dataU2['subject'], 'Physics');
        expect(dataU2['unitNumber'], 2);
        expect((dataU2['questions'] as List).length, 30);
      },
    );

    test(
      'Drift cache and offline grading works seamlessly for Unit 1 and Unit 2',
      () async {
        // 1. Manually parse and cache Unit 1 & Unit 2
        for (final filename in [
          'assets/data/PHY-G09-U01.json',
          'assets/data/PHY-G09-U02.json',
        ]) {
          final file = File(filename);
          final data =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          final unitNum = data['unitNumber'] as int;
          final unitTitle = data['unitTitle'] as String;
          final questionsList = data['questions'] as List<dynamic>;

          final assessmentId = 'a0000000-0000-0000-0000-00000000000$unitNum';
          final versionId = 'v0000000-0000-0000-0000-00000000000$unitNum';
          final chapterId = 'PHYS_G9_U$unitNum';

          final List<Question> questions = [];
          for (final rawQ in questionsList) {
            final q = rawQ as Map<String, dynamic>;
            final qId = q['id'] as String;
            final optionsList = q['options'] as List<dynamic>;

            final options = optionsList.map((opt) {
              final o = opt as Map<String, dynamic>;
              return QuestionOption(
                id: '${qId}_OPT_${o['id']}',
                questionId: qId,
                optionLetter: o['id'] as String,
                optionText: o['text'] as String,
                sortOrder: 1,
              );
            }).toList();

            questions.add(
              Question(
                id: qId,
                assessmentVersionId: versionId,
                chapterId: chapterId,
                questionText: q['question'] as String,
                sortOrder: 1,
                options: options,
              ),
            );
          }

          final assessment = Assessment(
            id: assessmentId,
            code: 'PHYS_G9_U0${unitNum}_TEST',
            title: '$unitTitle Assessment',
            description: 'Comprehensive 30-question test',
            assessmentType: AssessmentType.unit,
            currentVersionId: versionId,
            subjectId: 'PHYS_G9',
            grade: 9,
            stream: 'natural',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentVersion: AssessmentVersion(
              id: versionId,
              assessmentId: assessmentId,
              versionNumber: 1,
              status: 'published',
              totalQuestions: 30,
              totalPoints: 30.0,
              timeLimitMinutes: 45,
              passingPercentage: 60.0,
              publishedAt: DateTime.now(),
              coveredChapterIds: [chapterId, 'PHYS_G9_U0$unitNum'],
              questions: questions,
            ),
          );

          await localService.cacheAssessment(assessment);
        }

        // 2. Verify both assessments are retrievable by chapter from Drift SQLite
        final cachedU1 = await localService.getCachedAssessmentForChapter(
          'PHYS_G9_U1',
        );
        expect(cachedU1, isNotNull);
        expect(cachedU1!.title, contains('Physics and Human Society'));
        expect(cachedU1.currentVersion!.questions.length, 30);

        final cachedU2 = await localService.getCachedAssessmentForChapter(
          'PHYS_G9_U2',
        );
        expect(cachedU2, isNotNull);
        expect(cachedU2!.title, contains('Physical Quantities'));
        expect(cachedU2.currentVersion!.questions.length, 30);

        // 3. Verify student answers selection can be stored in SQLite
        await localService.saveLocalAttemptAnswers(
          attemptId: 'local_att_u1',
          studentId: 'student_123',
          assessmentVersionId: cachedU1.currentVersion!.id,
          idempotencyKey: 'key_u1',
          startedAt: DateTime.now(),
          answers: {
            'PHY-G09-U01-Q001': 'PHY-G09-U01-Q001_OPT_A',
            'PHY-G09-U01-Q002': 'PHY-G09-U01-Q002_OPT_A',
          },
        );

        final attempts = await db.select(db.localAssessmentAttempts).get();
        expect(attempts.length, 1);
        expect(attempts.first.id, 'local_att_u1');
        expect(attempts.first.answersJson, contains('PHY-G09-U01-Q001_OPT_A'));
      },
    );

    test(
      'CurriculumSeeder.seedSampleAssessmentIfEmpty seeds both Unit 1 and Unit 2 directly',
      () async {
        await CurriculumSeeder.seedSampleAssessmentIfEmpty(db);

        final cachedU1 = await localService.getCachedAssessmentForChapter(
          'PHYS_G9_U1',
        );
        expect(cachedU1, isNotNull, reason: 'PHYS_G9_U1 should be seeded');
        expect(cachedU1!.currentVersion!.questions.length, 30);

        final cachedU2 = await localService.getCachedAssessmentForChapter(
          'PHYS_G9_U2',
        );
        expect(cachedU2, isNotNull, reason: 'PHYS_G9_U2 should be seeded');
        expect(cachedU2!.currentVersion!.questions.length, 30);
      },
    );
  });
}
