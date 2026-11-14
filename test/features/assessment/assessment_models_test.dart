import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/features/assessment/models/assessment_models.dart';

void main() {
  group('Assessment Domain Models Tests', () {
    test('AssessmentType parsing and db serialization', () {
      expect(AssessmentType.fromString('unit'), AssessmentType.unit);
      expect(AssessmentType.fromString('subject_mock'), AssessmentType.subjectMock);
      expect(AssessmentType.fromString('grade_cumulative'), AssessmentType.gradeCumulative);
      expect(AssessmentType.fromString('euee_mock'), AssessmentType.eueeMock);
      expect(AssessmentType.fromString('unknown'), AssessmentType.unit);

      expect(AssessmentType.unit.toDbString(), 'unit');
      expect(AssessmentType.subjectMock.toDbString(), 'subject_mock');
      expect(AssessmentType.gradeCumulative.toDbString(), 'grade_cumulative');
      expect(AssessmentType.eueeMock.toDbString(), 'euee_mock');
    });

    test('Assessment.fromMap parses hierarchical JSON with options and version', () {
      final json = {
        'id': 'assess_001',
        'code': 'BIO_G9_U1_ASSESSMENT',
        'title': 'Grade 9 Biology Unit 1 Assessment',
        'description': 'Mastery assessment covering Intro to Biology',
        'assessment_type': 'unit',
        'current_version_id': 'ver_001',
        'subject_id': 'BIO_G9',
        'grade': 9,
        'stream': 'common',
        'is_archived': false,
        'created_at': '2026-11-14T08:00:00Z',
        'updated_at': '2026-11-14T08:00:00Z',
        'current_version': {
          'id': 'ver_001',
          'assessment_id': 'assess_001',
          'version_number': 1,
          'status': 'published',
          'total_questions': 2,
          'total_points': 4.0,
          'time_limit_minutes': 30,
          'passing_percentage': 75.0,
          'published_at': '2026-11-14T08:05:00Z',
          'chapters': [
            {'chapter_id': 'BIO_G9_U1', 'sort_order': 1}
          ],
          'questions': [
            {
              'id': 'q_001',
              'assessment_version_id': 'ver_001',
              'chapter_id': 'BIO_G9_U1',
              'question_text': 'What is the powerhouse of the cell?',
              'question_type': 'single_choice',
              'points': 2.0,
              'sort_order': 1,
              'question_options': [
                {'id': 'opt_1', 'question_id': 'q_001', 'option_letter': 'A', 'option_text': 'Nucleus', 'sort_order': 1},
                {'id': 'opt_2', 'question_id': 'q_001', 'option_letter': 'B', 'option_text': 'Mitochondria', 'sort_order': 2},
                {'id': 'opt_3', 'question_id': 'q_001', 'option_letter': 'C', 'option_text': 'Ribosome', 'sort_order': 3},
                {'id': 'opt_4', 'question_id': 'q_001', 'option_letter': 'D', 'option_text': 'Cytoplasm', 'sort_order': 4},
              ],
            }
          ],
        },
      };

      final assessment = Assessment.fromMap(json);
      expect(assessment.id, 'assess_001');
      expect(assessment.code, 'BIO_G9_U1_ASSESSMENT');
      expect(assessment.assessmentType, AssessmentType.unit);
      expect(assessment.currentVersion, isNotNull);

      final version = assessment.currentVersion!;
      expect(version.versionNumber, 1);
      expect(version.coveredChapterIds, contains('BIO_G9_U1'));
      expect(version.questions.length, 1);

      final q1 = version.questions.first;
      expect(q1.questionText, 'What is the powerhouse of the cell?');
      expect(q1.options.length, 4);
      expect(q1.options[1].optionLetter, 'B');
      expect(q1.options[1].optionText, 'Mitochondria');
    });

    test('AssessmentSubmissionResult and QuestionCorrection parsing', () {
      final resultMap = {
        'status': 'success',
        'attempt_id': 'att_123',
        'total_questions': 30,
        'answered_questions': 28,
        'correct_answers': 25,
        'score_obtained': 50.0,
        'max_score': 60.0,
        'percentage': 83.33,
        'passed': true,
        'is_overdue': false,
        'timing_verified': true,
        'duration_seconds': 1420,
        'corrections': [
          {
            'question_id': 'q_001',
            'selected_option_id': 'opt_2',
            'correct_option_id': 'opt_2',
            'is_correct': true,
            'points_awarded': 2.0,
            'explanation': 'Mitochondria generate most of the cell chemical energy.',
          }
        ],
      };

      final res = AssessmentSubmissionResult.fromMap(resultMap);
      expect(res.attemptId, 'att_123');
      expect(res.totalQuestions, 30);
      expect(res.correctAnswers, 25);
      expect(res.percentage, 83.33);
      expect(res.passed, true);
      expect(res.isOverdue, false);
      expect(res.corrections.length, 1);
      expect(res.corrections.first.isCorrect, true);
      expect(res.corrections.first.explanation, contains('Mitochondria'));
    });
  });
}
