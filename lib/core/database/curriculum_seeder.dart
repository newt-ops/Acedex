import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'database.dart';

class CurriculumSeeder {
  const CurriculumSeeder._();

  static Future<void> seedIfEmpty(AppDatabase db) async {
    final existingSubjects = await db.select(db.subjects).get();
    if (existingSubjects.isNotEmpty) {
      return;
    }

    final rawJson = await rootBundle.loadString('assets/data/ethiopian_curriculum.json');
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
              subtopicsJson: Value(subtopics != null ? jsonEncode(subtopics) : null),
              sortOrder: Value(chapterSortOrder++),
            ),
          );
        }
      }
    });
  }
}

