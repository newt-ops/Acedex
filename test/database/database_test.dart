import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:acedex/core/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift Database Unit Tests', () {
    test('Can insert and retrieve a student', () async {
      await db.into(db.students).insert(
            StudentsCompanion.insert(
              id: 'user_1',
              email: 'student@example.com',
              name: 'Aymen Newton',
              grade: 12,
              gender: 'Male',
              stream: 'natural',
            ),
          );

      final student = await (db.select(db.students)..where((tbl) => tbl.id.equals('user_1'))).getSingle();
      expect(student.name, 'Aymen Newton');
      expect(student.grade, 12);
      expect(student.stream, 'natural');
      expect(student.streakCount, 0);
      expect(student.dailyGoalMinutes, 120);
    });

    test('Can track chapter progress states (not_started -> completed -> mastered)', () async {
      await db.into(db.subjects).insert(
            SubjectsCompanion.insert(
              id: 'BIO_G9',
              name: 'Biology',
              code: 'BIO_G9',
              grade: 9,
              stream: 'common',
              totalUnits: 6,
            ),
          );

      await db.into(db.chapters).insert(
            ChaptersCompanion.insert(
              id: 'BIO_G9_U1',
              subjectId: 'BIO_G9',
              chapterNumber: 1,
              title: 'Introduction to Biology',
            ),
          );

      // Insert progress
      await db.into(db.chapterProgress).insert(
            ChapterProgressCompanion.insert(
              id: 'prog_1',
              studentId: 'user_1',
              chapterId: 'BIO_G9_U1',
              status: const Value('completed'),
            ),
          );

      var progress = await (db.select(db.chapterProgress)..where((t) => t.id.equals('prog_1'))).getSingle();
      expect(progress.status, 'completed');

      // Update to mastered
      await (db.update(db.chapterProgress)..where((t) => t.id.equals('prog_1'))).write(
            const ChapterProgressCompanion(
              status: Value('mastered'),
            ),
          );

      progress = await (db.select(db.chapterProgress)..where((t) => t.id.equals('prog_1'))).getSingle();
      expect(progress.status, 'mastered');
    });

    test('Can record study sessions', () async {
      final now = DateTime.now();
      await db.into(db.studySessions).insert(
            StudySessionsCompanion.insert(
              id: 'session_1',
              studentId: 'user_1',
              durationSeconds: 1500, // 25 min pomodoro
              startedAt: now.subtract(const Duration(minutes: 25)),
              endedAt: now,
              mode: 'pomodoro',
            ),
          );

      final sessions = await db.select(db.studySessions).get();
      expect(sessions.length, 1);
      expect(sessions.first.durationSeconds, 1500);
      expect(sessions.first.mode, 'pomodoro');
    });
  });
}
