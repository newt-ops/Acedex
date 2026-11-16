import {
  PublicQuestionItem,
  StudentStream,
} from '@acedex/contracts';
import { SubjectModel, ISubject } from './models/subject.model';
import { UnitModel, IUnit } from './models/unit.model';
import { QuestionModel } from './models/question.model';
import { NotFoundError } from '../../common/errors/app-error';

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

    return SubjectModel.find(filter).sort({ order: 1 });
  }

  /**
   * Retrieves units for a specific subject and grade.
   */
  public static async getUnits(
    grade: number,
    subjectCode: string,
    studentOnly = true
  ): Promise<IUnit[]> {
    const filter: Record<string, any> = {
      grade,
      subjectCode: subjectCode.toUpperCase().trim(),
    };

    if (studentOnly) {
      filter.isPublished = true;
      filter.status = 'published';
    }

    return UnitModel.find(filter).sort({ unitNumber: 1 });
  }

  /**
   * Retrieves a single unit by ID
   */
  public static async getUnitById(unitId: string): Promise<IUnit> {
    const unit = await UnitModel.findById(unitId);
    if (!unit) {
      throw new NotFoundError('Curriculum unit not found');
    }
    return unit;
  }

  /**
   * Delivers sanitized questions for a unit (omitting correct answer & explanation)
   */
  public static async getQuestionsForUnit(
    unitId: string,
    studentOnly = true
  ): Promise<PublicQuestionItem[]> {
    const unit = await this.getUnitById(unitId);

    if (studentOnly && (!unit.isPublished || unit.status !== 'published')) {
      throw new NotFoundError('This unit is not yet published for practice');
    }

    const questions = await QuestionModel.find({
      unitId: unit._id,
      isPublished: true,
    }).sort({ externalId: 1 });

    // Sanitize to PublicQuestionItem format (ZERO answer keys or explanations)
    return questions.map((q) => ({
      id: q.externalId,
      type: 'multiple_choice',
      difficulty: q.difficulty,
      question: q.question,
      options: q.options,
    }));
  }
}
