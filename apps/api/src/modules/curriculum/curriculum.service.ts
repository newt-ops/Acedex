import { Types } from 'mongoose';
import {
  PublicQuestionItem,
  StudentStream,
  OfflinePackBundle,
} from '@acedex/contracts';
import { SubjectModel, ISubject } from './models/subject.model';
import { UnitModel, IUnit } from './models/unit.model';
import { QuestionModel } from './models/question.model';
import { StudentProgressModel } from '../progress/models/student-progress.model';
import { ProgressService } from '../progress/progress.service';
import { ContentCacheService } from '../../common/services/cache.service';
import { NotFoundError, ForbiddenError } from '../../common/errors/app-error';

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
    };
  }
}
