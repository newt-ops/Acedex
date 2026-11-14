import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/curriculum_seeder.dart';
import '../../profile/student_provider.dart';

class ChapterWithProgress {
  final Chapter chapter;
  final ChapterProgressData? progress;

  const ChapterWithProgress({
    required this.chapter,
    this.progress,
  });

  bool get isStudied =>
      progress != null && progress!.status != 'not_started';

  bool get isMastered =>
      progress != null && progress!.status == 'mastered';
}

class SubjectWithProgress {
  final Subject subject;
  final int totalUnits;
  final int studiedUnits;

  const SubjectWithProgress({
    required this.subject,
    required this.totalUnits,
    required this.studiedUnits,
  });

  double get progressPercentage =>
      totalUnits > 0 ? (studiedUnits / totalUnits) : 0.0;
}

/// Selected Grade Filter for Curriculum screen (defaults to student's enrolled grade)
final selectedGradeProvider = StateProvider<int>((ref) {
  final studentAsync = ref.watch(studentStateProvider);
  final grade = studentAsync.value?.grade ?? 9;
  return grade > 0 ? grade : 9;
});

/// Fetches subjects with their studied progress for the currently selected grade
final gradeSubjectsWithProgressProvider =
    FutureProvider<List<SubjectWithProgress>>((ref) async {
  final db = ref.watch(databaseProvider);
  final grade = ref.watch(selectedGradeProvider);
  final studentAsync = ref.watch(studentStateProvider);
  final studentId = studentAsync.value?.id ?? 'default_student';

  var subjects = await (db.select(db.subjects)
        ..where((tbl) => tbl.grade.equals(grade))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .get();

  if (subjects.isEmpty) {
    try {
      await CurriculumSeeder.seedIfEmpty(db);
      subjects = await (db.select(db.subjects)
            ..where((tbl) => tbl.grade.equals(grade))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();
    } catch (_) {}
  }

  final List<SubjectWithProgress> results = [];

  for (final subj in subjects) {
    final chapters = await (db.select(db.chapters)
          ..where((tbl) => tbl.subjectId.equals(subj.id)))
        .get();

    final totalUnits = chapters.length;
    int studiedCount = 0;

    if (chapters.isNotEmpty) {
      final chapterIds = chapters.map((c) => c.id).toList();
      final progresses = await (db.select(db.chapterProgress)
            ..where((tbl) =>
                tbl.studentId.equals(studentId) &
                tbl.chapterId.isIn(chapterIds) &
                tbl.status.isNotIn(const ['not_started'])))
          .get();
      studiedCount = progresses.length;
    }

    results.add(SubjectWithProgress(
      subject: subj,
      totalUnits: totalUnits,
      studiedUnits: studiedCount,
    ));
  }

  return results;
});

/// Fetches all chapters (units) and their progress for a specific subject
final subjectUnitsProvider =
    FutureProvider.family<List<ChapterWithProgress>, String>(
        (ref, subjectId) async {
  final db = ref.watch(databaseProvider);
  final studentAsync = ref.watch(studentStateProvider);
  final studentId = studentAsync.value?.id ?? 'default_student';

  final chapters = await (db.select(db.chapters)
        ..where((tbl) => tbl.subjectId.equals(subjectId))
        ..orderBy([(t) => OrderingTerm.asc(t.chapterNumber)]))
      .get();

  final List<ChapterWithProgress> units = [];

  for (final ch in chapters) {
    final progressList = await (db.select(db.chapterProgress)
          ..where((tbl) =>
              tbl.chapterId.equals(ch.id) &
              tbl.studentId.equals(studentId)))
          .get();

    final progress = progressList.isNotEmpty ? progressList.first : null;
    units.add(ChapterWithProgress(chapter: ch, progress: progress));
  }

  return units;
});

/// Service to toggle chapter study status
class CurriculumService {
  final AppDatabase _db;
  final String _studentId;

  CurriculumService(this._db, this._studentId);

  Future<void> toggleChapterStudied(String chapterId, bool currentlyStudied) async {
    final now = DateTime.now();

    if (currentlyStudied) {
      // Revert to not_started
      await (_db.update(_db.chapterProgress)
            ..where((tbl) =>
                tbl.chapterId.equals(chapterId) &
                tbl.studentId.equals(_studentId)))
          .write(ChapterProgressCompanion(
        status: const Value('not_started'),
        completedAt: const Value(null),
        updatedAt: Value(now),
      ));
    } else {
      // Mark as studied (completed)
      final existing = await (_db.select(_db.chapterProgress)
            ..where((tbl) =>
                tbl.chapterId.equals(chapterId) &
                tbl.studentId.equals(_studentId)))
          .get();

      if (existing.isEmpty) {
        await _db.into(_db.chapterProgress).insert(
              ChapterProgressCompanion.insert(
                id: 'prog_${DateTime.now().millisecondsSinceEpoch}_$chapterId',
                studentId: _studentId,
                chapterId: chapterId,
                status: const Value('studied'),
                completedAt: Value(now),
                updatedAt: Value(now),
              ),
            );
      } else {
        await (_db.update(_db.chapterProgress)
              ..where((tbl) =>
                  tbl.chapterId.equals(chapterId) &
                  tbl.studentId.equals(_studentId)))
            .write(ChapterProgressCompanion(
          status: const Value('studied'),
          completedAt: Value(now),
          updatedAt: Value(now),
        ));
      }
    }
  }
}

final curriculumServiceProvider = Provider<CurriculumService>((ref) {
  final db = ref.watch(databaseProvider);
  final studentAsync = ref.watch(studentStateProvider);
  final studentId = studentAsync.value?.id ?? 'default_student';
  return CurriculumService(db, studentId);
});
