import { Types } from 'mongoose';
import {
  PublicQuestionItem,
  StudentStream,
  OfflinePackBundle,
  OfflineAnswerKeyItem,
  BookmarkedQuestionItem,
  BookmarkListResponse,
  ModelExamSessionResponse,
  ModelExamQuestionItem,
} from '@acedex/contracts';
import { SubjectModel, ISubject } from './models/subject.model';
import { UnitModel, IUnit } from './models/unit.model';
import { QuestionModel } from './models/question.model';
import { AnswerKeyModel } from './models/answer-key.model';
import { BookmarkModel } from './models/bookmark.model';
import { StudentProgressModel } from '../progress/models/student-progress.model';
import { ProgressService } from '../progress/progress.service';
import { ContentCacheService } from '../../common/services/cache.service';
import { NotFoundError, ForbiddenError, BadRequestError } from '../../common/errors/app-error';

export class CurriculumService {
  /**
   * Supported grades in the Ethiopian curriculum
   */
  public static getGrades(): number[] {
    return [9, 10, 11, 12];
  }

  /**
   * Retrieves subjects filtered by grade and student stream.
   * - Grades 9 & 10: Returns all 8 common subjects.
   * - Grades 11 & 12 (Natural): Physics, Chemistry, Biology, Mathematics, English.
   * - Grades 11 & 12 (Social): Economics, Geography, History, Mathematics, English.
   */
  public static async getSubjects(
    grade?: number,
    stream?: StudentStream | null
  ): Promise<ISubject[]> {
    const cacheKey = `subjects:${grade || 'all'}:${stream || 'all'}`;
    const cached = ContentCacheService.get<ISubject[]>(cacheKey);
    if (cached) return cached;

    const filter: Record<string, any> = { isActive: true };

    if (grade) {
      filter.grades = grade;

      // Stream specialization applies only to Grades 11 & 12
      if (grade === 11 || grade === 12) {
        if (stream === 'natural') {
          filter.streamCategory = { $in: ['natural', 'common'] };
        } else if (stream === 'social') {
          filter.streamCategory = { $in: ['social', 'common'] };
        }
      }
    }

    const subjects = (await SubjectModel.find(filter)
      .sort({ order: 1 })
      .read('secondaryPreferred')
      .lean()) as unknown as ISubject[];

    ContentCacheService.set(cacheKey, subjects, 3600);
    return subjects;
  }

  /**
   * Retrieves units for a specific subject and grade.
   */
  public static async getUnits(
    grade: number,
    subjectCode: string,
    studentOnly = true
  ): Promise<IUnit[]> {
    const cacheKey = `units:${grade}:${subjectCode.toUpperCase().trim()}:${studentOnly}`;
    const cached = ContentCacheService.get<IUnit[]>(cacheKey);
    if (cached) return cached;

    const filter: Record<string, any> = {
      grade,
      subjectCode: subjectCode.toUpperCase().trim(),
    };

    if (studentOnly) {
      filter.isPublished = true;
      filter.status = 'published';
    }

    const units = (await UnitModel.find(filter)
      .sort({ unitNumber: 1 })
      .read('secondaryPreferred')
      .lean()) as unknown as IUnit[];

    ContentCacheService.set(cacheKey, units, 3600);
    return units;
  }

  /**
   * Retrieves a single unit by ID
   */
  public static async getUnitById(unitId: string): Promise<IUnit> {
    const cacheKey = `unit_summary:${unitId}`;
    const cached = ContentCacheService.get<IUnit>(cacheKey);
    if (cached) return cached;

    const unit = await UnitModel.findById(unitId).read('secondaryPreferred').lean();
    if (!unit) {
      throw new NotFoundError('Curriculum unit not found');
    }
    ContentCacheService.set(cacheKey, unit as unknown as IUnit, 3600);
    return unit as unknown as IUnit;
  }

  /**
   * Delivers sanitized questions for a unit (omitting correct answer & explanation)
   */
  public static async getQuestionsForUnit(
    unitId: string,
    studentOnly = true
  ): Promise<PublicQuestionItem[]> {
    if (studentOnly) {
      const cached = ContentCacheService.getUnitQuestions(unitId);
      if (cached) return cached;
    }

    const unit = await this.getUnitById(unitId);

    if (studentOnly && (!unit.isPublished || unit.status !== 'published')) {
      throw new NotFoundError('This unit is not yet published for practice');
    }

    const questions = await QuestionModel.find({
      unitId: unit._id,
      isPublished: true,
    })
      .select('externalId difficulty question options')
      .sort({ externalId: 1 })
      .read('secondaryPreferred')
      .lean();

    // Sanitize to PublicQuestionItem format (ZERO answer keys or explanations)
    const sanitized: PublicQuestionItem[] = questions.map((q) => ({
      id: q.externalId,
      type: 'multiple_choice',
      difficulty: q.difficulty,
      question: q.question,
      options: q.options,
    }));

    if (studentOnly) {
      ContentCacheService.setUnitQuestions(unitId, sanitized);
    }

    return sanitized;
  }

  /**
   * Generates a 24-hour downloadable offline study pack for a student
   * who has unlocked access by watching a rewarded ad.
   */
  public static async getOfflinePack(
    userId: string,
    unitId: string
  ): Promise<OfflinePackBundle> {
    const unit = await this.getUnitById(unitId);

    const hasAccess = await ProgressService.hasOfflineAccess(userId, unit._id);
    if (!hasAccess) {
      throw new ForbiddenError(
        'Offline study pass required for this unit. Please watch a rewarded ad to unlock 24-hour offline access.'
      );
    }

    const progress = await StudentProgressModel.findOne({ userId: new Types.ObjectId(userId) });
    const unlockRecord = progress?.offlineAccess?.unlockedUnits?.find(
      (u) => u.unitId.toString() === unit._id.toString()
    );

    const expiresAt = unlockRecord?.expiresAt
      ? unlockRecord.expiresAt.toISOString()
      : new Date(Date.now() + 24 * 3600 * 1000).toISOString();

    const questions = await this.getQuestionsForUnit(unit._id.toString(), true);

    const questionIds = questions.map((q) => q.id);
    const keys = await AnswerKeyModel.find({ externalId: { $in: questionIds } }).lean();
    const offlineAnswerKeys: OfflineAnswerKeyItem[] = keys.map((k) => ({
      questionId: k.questionId ? k.questionId.toString() : k.externalId,
      externalId: k.externalId,
      correctOptionId: k.correctOptionId as 'A' | 'B' | 'C' | 'D',
      explanation: k.explanation,
    }));

    return {
      unitId: unit._id.toString(),
      unitCode: unit.code,
      subjectCode: unit.subjectCode,
      grade: unit.grade,
      title: unit.title,
      unitNumber: unit.unitNumber,
      questionCount: questions.length,
      downloadedAt: new Date().toISOString(),
      expiresAt,
      questions,
      offlineAnswerKeys,
    };
  }

  /**
   * Adds or updates a bookmark for a question
   */
  public static async bookmarkQuestion(
    userId: string,
    questionIdOrExtId: string,
    notes?: string
  ): Promise<BookmarkedQuestionItem> {
    const userObjectId = new Types.ObjectId(userId);

    const query = Types.ObjectId.isValid(questionIdOrExtId)
      ? { _id: new Types.ObjectId(questionIdOrExtId) }
      : { externalId: questionIdOrExtId };

    const question = await QuestionModel.findOne(query);
    if (!question) {
      throw new NotFoundError('Question not found');
    }

    const unit = await UnitModel.findById(question.unitId);
    if (!unit) {
      throw new NotFoundError('Associated curriculum unit not found');
    }

    const bookmark = await BookmarkModel.findOneAndUpdate(
      { userId: userObjectId, questionId: question._id },
      {
        $set: {
          externalId: question.externalId,
          unitId: unit._id,
          unitCode: unit.code,
          subjectCode: unit.subjectCode,
          grade: unit.grade,
          notes: notes?.trim() || undefined,
        },
      },
      { upsert: true, new: true }
    );

    const key = await AnswerKeyModel.findOne({ externalId: question.externalId });

    return {
      bookmarkId: bookmark._id.toString(),
      questionId: question._id.toString(),
      externalId: question.externalId,
      unitId: unit._id.toString(),
      unitCode: unit.code,
      subjectCode: unit.subjectCode,
      grade: unit.grade,
      question: question.question,
      difficulty: question.difficulty,
      options: question.options,
      correctOptionId: key ? (key.correctOptionId as 'A' | 'B' | 'C' | 'D') : undefined,
      explanation: key ? key.explanation : undefined,
      notes: bookmark.notes,
      bookmarkedAt: bookmark.createdAt.toISOString(),
    };
  }

  /**
   * Removes a bookmark for a question
   */
  public static async removeBookmark(userId: string, questionIdOrExtId: string): Promise<boolean> {
    const userObjectId = new Types.ObjectId(userId);
    const query: Record<string, any> = { userId: userObjectId };

    if (Types.ObjectId.isValid(questionIdOrExtId)) {
      query.$or = [
        { questionId: new Types.ObjectId(questionIdOrExtId) },
        { externalId: questionIdOrExtId },
        { _id: new Types.ObjectId(questionIdOrExtId) },
      ];
    } else {
      query.externalId = questionIdOrExtId;
    }

    const result = await BookmarkModel.deleteOne(query);
    return result.deletedCount > 0;
  }

  /**
   * Lists all bookmarked questions for a student with optional filters
   */
  public static async listBookmarks(
    userId: string,
    filter?: { subjectCode?: string; grade?: number }
  ): Promise<BookmarkListResponse> {
    const userObjectId = new Types.ObjectId(userId);
    const query: Record<string, any> = { userId: userObjectId };

    if (filter?.subjectCode) {
      query.subjectCode = filter.subjectCode.toUpperCase().trim();
    }
    if (filter?.grade) {
      query.grade = filter.grade;
    }

    const bookmarks = await BookmarkModel.find(query).sort({ createdAt: -1 });
    if (bookmarks.length === 0) {
      return { total: 0, bookmarks: [] };
    }

    const questionIds = bookmarks.map((b) => b.questionId);
    const questions = await QuestionModel.find({ _id: { $in: questionIds } }).lean();
    const qMap = new Map(questions.map((q) => [q._id.toString(), q]));

    const extIds = bookmarks.map((b) => b.externalId);
    const keys = await AnswerKeyModel.find({ externalId: { $in: extIds } }).lean();
    const keyMap = new Map(keys.map((k) => [k.externalId, k]));

    const items: BookmarkedQuestionItem[] = [];
    for (const b of bookmarks) {
      const q = qMap.get(b.questionId.toString());
      if (!q) continue;
      const k = keyMap.get(b.externalId);

      items.push({
        bookmarkId: b._id.toString(),
        questionId: q._id.toString(),
        externalId: q.externalId,
        unitId: b.unitId.toString(),
        unitCode: b.unitCode,
        subjectCode: b.subjectCode,
        grade: b.grade,
        question: q.question,
        difficulty: q.difficulty,
        options: q.options,
        correctOptionId: k ? (k.correctOptionId as 'A' | 'B' | 'C' | 'D') : undefined,
        explanation: k ? k.explanation : undefined,
        notes: b.notes,
        bookmarkedAt: b.createdAt.toISOString(),
      });
    }

    return { total: items.length, bookmarks: items };
  }

  /**
   * Generates a balanced, timed multi-unit Model Exam session
   */
  public static async generateModelExam(
    subjectCode: string,
    grade = 12,
    count = 50
  ): Promise<ModelExamSessionResponse> {
    const code = subjectCode.toUpperCase().trim();
    const subject = await SubjectModel.findOne({ code });
    if (!subject) {
      throw new NotFoundError(`Subject '${code}' not found`);
    }

    const targetGrades = grade === 12 ? [11, 12] : [grade];
    const publishedUnits = await UnitModel.find({
      subjectCode: code,
      grade: { $in: targetGrades },
      isPublished: true,
    }).sort({ grade: 1, unitNumber: 1 });

    if (publishedUnits.length === 0) {
      throw new BadRequestError(`No published question curriculum found for ${subject.name} to generate a model exam.`);
    }

    const unitCodes = publishedUnits.map((u) => u.code);
    const unitMap = new Map(publishedUnits.map((u) => [u.code, u]));

    const allQuestions = await QuestionModel.find({
      unitCode: { $in: unitCodes },
      isPublished: true,
    }).lean();

    if (allQuestions.length === 0) {
      throw new BadRequestError(`No active questions available for ${subject.name} model exam.`);
    }

    const shuffled = [...allQuestions].sort(() => 0.5 - Math.random());
    const selected = shuffled.slice(0, Math.min(count, allQuestions.length));

    const examQuestions: ModelExamQuestionItem[] = selected.map((q) => {
      const u = unitMap.get(q.unitCode);
      return {
        id: q.externalId,
        type: 'multiple_choice',
        difficulty: q.difficulty,
        question: q.question,
        options: q.options,
        unitCode: q.unitCode,
        unitTitle: u ? u.title : q.unitCode,
        unitNumber: u ? u.unitNumber : 1,
      };
    });

    const examSessionId = `MODEL-${code}-${Date.now().toString(36).toUpperCase()}`;

    return {
      examSessionId,
      subjectCode: code,
      subjectName: subject.name,
      grade,
      totalQuestions: examQuestions.length,
      timeLimitMinutes: Math.round(examQuestions.length * 1.5),
      questions: examQuestions,
    };
  }
}
