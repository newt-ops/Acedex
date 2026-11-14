import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'database.dart';
import '../../features/assessment/models/assessment_models.dart';
import '../../features/assessment/services/local_assessment_service.dart';

class CurriculumSeeder {
  const CurriculumSeeder._();

  static Future<void> seedIfEmpty(AppDatabase db) async {
    final existingSubjects = await db.select(db.subjects).get();
    if (existingSubjects.isEmpty) {
      await _seedCurriculum(db);
    }
    await seedSampleAssessmentIfEmpty(db);
  }

  static Future<void> _seedCurriculum(AppDatabase db) async {
    final rawJson = await rootBundle.loadString(
      'assets/data/ethiopian_curriculum.json',
    );
    final List<dynamic> subjectList = jsonDecode(rawJson) as List<dynamic>;

    await db.batch((batch) {
      int subjectSortOrder = 0;
      for (final rawSubject in subjectList) {
        final map = rawSubject as Map<String, dynamic>;
        final grade = map['grade'] as int;
        final stream = map['stream'] as String;
        final subjectName = map['subject_name'] as String;
        final subjectCode = map['subject_code'] as String;
        final totalUnits = map['total_units'] as int;
        final units = map['units'] as List<dynamic>;

        batch.insert(
          db.subjects,
          SubjectsCompanion.insert(
            id: subjectCode,
            name: subjectName,
            code: subjectCode,
            grade: grade,
            stream: stream,
            totalUnits: totalUnits,
            sortOrder: Value(subjectSortOrder++),
          ),
        );

        int chapterSortOrder = 0;
        for (final rawUnit in units) {
          final unitMap = rawUnit as Map<String, dynamic>;
          final unitNumber = unitMap['unit_number'] as int;
          final title = unitMap['title'] as String;
          final subtopics = unitMap['subtopics'] as List<dynamic>?;

          final chapterId = '${subjectCode}_U$unitNumber';
          batch.insert(
            db.chapters,
            ChaptersCompanion.insert(
              id: chapterId,
              subjectId: subjectCode,
              chapterNumber: unitNumber,
              title: title,
              subtopicsJson: Value(
                subtopics != null ? jsonEncode(subtopics) : null,
              ),
              sortOrder: Value(chapterSortOrder++),
            ),
          );
        }
      }
    });
  }

  static Future<void> seedSampleAssessmentIfEmpty(AppDatabase db) async {
    final sampleFiles = [
      'assets/data/PHY-G09-U01.json',
      'assets/data/PHY-G09-U02.json',
    ];

    for (final assetPath in sampleFiles) {
      try {
        final rawJson = await rootBundle.loadString(assetPath);
        final Map<String, dynamic> data =
            jsonDecode(rawJson) as Map<String, dynamic>;

        final unitNumber = data['unitNumber'] as int? ?? 1;
        final unitTitle = data['unitTitle'] as String? ?? 'Unit $unitNumber';
        final questionsList = data['questions'] as List<dynamic>? ?? [];

        final assessmentId = 'a0000000-0000-0000-0000-00000000000$unitNumber';
        final versionId = 'v0000000-0000-0000-0000-00000000000$unitNumber';
        final primaryChapterId = 'PHYS_G9_U$unitNumber';

        // Check if already seeded with all questions
        final exists = await (db.select(
          db.localAssessments,
        )..where((tbl) => tbl.id.equals(assessmentId))).get();

        final existingQuestions = await (db.select(
          db.localQuestions,
        )..where((tbl) => tbl.assessmentVersionId.equals(versionId))).get();

        if (exists.isNotEmpty &&
            existingQuestions.length >= questionsList.length &&
            questionsList.isNotEmpty) {
          continue;
        }

        final List<Question> parsedQuestions = [];
        int qSort = 1;

        for (final rawQ in questionsList) {
          final qMap = rawQ as Map<String, dynamic>;
          final qId = qMap['id'] as String? ?? 'Q$qSort';
          final qText = qMap['question'] as String? ?? '';
          final optionsList = qMap['options'] as List<dynamic>? ?? [];

          final List<QuestionOption> parsedOptions = [];
          int optSort = 1;

          for (final rawOpt in optionsList) {
            final optMap = rawOpt as Map<String, dynamic>;
            final optLetter = optMap['id'] as String? ?? '$optSort';
            final optText = optMap['text'] as String? ?? '';

            parsedOptions.add(
              QuestionOption(
                id: '${qId}_OPT_$optLetter',
                questionId: qId,
                optionLetter: optLetter,
                optionText: optText,
                sortOrder: optSort++,
              ),
            );
          }

          parsedQuestions.add(
            Question(
              id: qId,
              assessmentVersionId: versionId,
              chapterId: primaryChapterId,
              questionText: qText,
              sortOrder: qSort++,
              options: parsedOptions,
            ),
          );
        }

        final coveredAliases = <String>{
          primaryChapterId,
          'PHYS_G9_U0$unitNumber',
          'PHYS_G9_U$unitNumber',
          'PHYS_G09_U0$unitNumber',
          'PHYS_G09_U$unitNumber',
          'PHY_G9_U0$unitNumber',
          'PHY_G9_U$unitNumber',
          'PHY_G09_U0$unitNumber',
          'PHY_G09_U$unitNumber',
          'PHY-G09-U0$unitNumber',
          'PHY-G09-U$unitNumber',
          'PHYS-G09-U0$unitNumber',
          'PHYS-G09-U$unitNumber',
          'PHYS-G9-U$unitNumber',
        };

        final assessment = Assessment(
          id: assessmentId,
          code: 'PHYS_G9_U0${unitNumber}_TEST',
          title: '$unitTitle Assessment',
          description:
              'Comprehensive 30-question diagnostic assessment for $unitTitle.',
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
            totalQuestions: parsedQuestions.length,
            totalPoints: parsedQuestions.length.toDouble(),
            timeLimitMinutes: 45,
            passingPercentage: 60.0,
            publishedAt: DateTime.now(),
            coveredChapterIds: coveredAliases.toList(),
            questions: parsedQuestions,
          ),
        );

        final service = LocalAssessmentService(db);
        await service.cacheAssessment(assessment);
      } catch (e) {
        debugPrint('CurriculumSeeder: Notice when loading $assetPath: $e');
      }
    }
  }
}
