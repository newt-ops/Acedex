import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Students extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  IntColumn get grade => integer()();
  TextColumn get gender => text()();
  TextColumn get stream => text()();
  IntColumn get dailyGoalMinutes =>
      integer().withDefault(const Constant(120))();
  IntColumn get streakCount => integer().withDefault(const Constant(0))();
  IntColumn get streakFreezes => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastStudyDate => dateTime().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Subjects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get code => text()();
  IntColumn get grade => integer()();
  TextColumn get stream => text()();
  IntColumn get totalUnits => integer()();
  TextColumn get iconName => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Chapters extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId =>
      text().references(Subjects, #id, onDelete: KeyAction.cascade)();
  IntColumn get chapterNumber => integer()();
  TextColumn get title => text()();
  TextColumn get subtopicsJson => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class ChapterProgress extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text()();
  TextColumn get chapterId =>
      text().references(Chapters, #id, onDelete: KeyAction.cascade)();
  TextColumn get status => text().withDefault(const Constant('not_started'))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get masteredAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class StudySessions extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text()();
  TextColumn get chapterId => text().nullable()();
  IntColumn get durationSeconds => integer()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();
  TextColumn get mode => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get action => text()();
  TextColumn get targetTable => text()();
  TextColumn get recordId => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// -------------------------------------------------------------
// ASSESSMENT PLATFORM CACHE & OFFLINE PERSISTENCE TABLES (v2)
// -------------------------------------------------------------

class LocalAssessments extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get assessmentType => text().withDefault(const Constant('unit'))();
  TextColumn get currentVersionId => text().nullable()();
  TextColumn get subjectId => text().nullable()();
  IntColumn get grade => integer().nullable()();
  TextColumn get stream => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalAssessmentVersions extends Table {
  TextColumn get id => text()();
  TextColumn get assessmentId => text()();
  IntColumn get versionNumber => integer()();
  TextColumn get status => text().withDefault(const Constant('published'))();
  IntColumn get totalQuestions => integer().withDefault(const Constant(0))();
  RealColumn get totalPoints => real().withDefault(const Constant(0.0))();
  IntColumn get timeLimitMinutes => integer().nullable()();
  RealColumn get passingPercentage => real().nullable()();
  DateTimeColumn get publishedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalAssessmentVersionChapters extends Table {
  TextColumn get assessmentVersionId => text()();
  TextColumn get chapterId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {assessmentVersionId, chapterId};
}

class LocalQuestions extends Table {
  TextColumn get id => text()();
  TextColumn get assessmentVersionId => text()();
  TextColumn get chapterId => text()();
  TextColumn get questionText => text()();
  TextColumn get questionType =>
      text().withDefault(const Constant('single_choice'))();
  TextColumn get imageUrl => text().nullable()();
  RealColumn get points => real().withDefault(const Constant(1.0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalQuestionOptions extends Table {
  TextColumn get id => text()();
  TextColumn get questionId => text()();
  TextColumn get optionLetter => text()();
  TextColumn get optionText => text()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalAssessmentAttempts extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text()();
  TextColumn get assessmentVersionId => text()();
  TextColumn get status => text().withDefault(
    const Constant('in_progress'),
  )(); // in_progress, submitted, pending_sync
  BoolColumn get isOfflineSync =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get timingVerified =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get submittedAt => dateTime().nullable()();
  IntColumn get serverDurationSeconds => integer().nullable()();
  IntColumn get clientReportedDurationSeconds => integer().nullable()();
  TextColumn get idempotencyKey => text()();
  TextColumn get answersJson =>
      text().nullable()(); // Serialized array of choices

  @override
  Set<Column> get primaryKey => {id};
}

class LocalAssessmentResults extends Table {
  TextColumn get id => text()();
  TextColumn get attemptId => text()();
  TextColumn get studentId => text()();
  TextColumn get assessmentVersionId => text()();
  IntColumn get totalQuestions => integer()();
  IntColumn get answeredQuestions => integer().withDefault(const Constant(0))();
  IntColumn get correctAnswers => integer().withDefault(const Constant(0))();
  IntColumn get incorrectAnswers => integer().withDefault(const Constant(0))();
  IntColumn get skippedQuestions => integer().withDefault(const Constant(0))();
  RealColumn get scoreObtained => real().withDefault(const Constant(0.0))();
  RealColumn get maxScore => real()();
  RealColumn get percentage => real()();
  BoolColumn get passed => boolean().nullable()();
  BoolColumn get isOverdue => boolean().withDefault(const Constant(false))();
  TextColumn get correctionsJson => text().nullable()();
  DateTimeColumn get gradedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Students,
    Subjects,
    Chapters,
    ChapterProgress,
    StudySessions,
    SyncQueue,
    LocalAssessments,
    LocalAssessmentVersions,
    LocalAssessmentVersionChapters,
    LocalQuestions,
    LocalQuestionOptions,
    LocalAssessmentAttempts,
    LocalAssessmentResults,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(localAssessments);
        await m.createTable(localAssessmentVersions);
        await m.createTable(localAssessmentVersionChapters);
        await m.createTable(localQuestions);
        await m.createTable(localQuestionOptions);
        await m.createTable(localAssessmentAttempts);
        await m.createTable(localAssessmentResults);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'acedex.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
