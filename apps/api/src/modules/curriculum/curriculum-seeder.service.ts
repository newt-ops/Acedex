import fs from 'fs';
import path from 'path';
import {
  QuestionBankFileSchema,
  SubjectStreamCategory,
} from '@acedex/contracts';
import { SubjectModel } from './models/subject.model';
import { UnitModel } from './models/unit.model';
import { QuestionModel } from './models/question.model';
import { AnswerKeyModel } from './models/answer-key.model';
import { logger } from '../../common/utils/logger';

export interface SeederReport {
  totalFilesScanned: number;
  subjectsUpserted: number;
  unitsUpserted: number;
  publishedUnits: number;
  draftUnits: number;
  questionsUpserted: number;
  answerKeysUpserted: number;
}

export const EUEE_SUBJECTS: Array<{
  code: string;
  name: string;
  slug: string;
  streamCategory: SubjectStreamCategory;
  order: number;
}> = [
  { code: 'PHY', name: 'Physics', slug: 'physics', streamCategory: 'natural', order: 1 },
  { code: 'CHE', name: 'Chemistry', slug: 'chemistry', streamCategory: 'natural', order: 2 },
  { code: 'BIO', name: 'Biology', slug: 'biology', streamCategory: 'natural', order: 3 },
  { code: 'MAT', name: 'Mathematics', slug: 'mathematics', streamCategory: 'common', order: 4 },
  { code: 'ENG', name: 'English', slug: 'english', streamCategory: 'common', order: 5 },
  { code: 'ECO', name: 'Economics', slug: 'economics', streamCategory: 'social', order: 6 },
  { code: 'GEO', name: 'Geography', slug: 'geography', streamCategory: 'social', order: 7 },
  { code: 'HIS', name: 'History', slug: 'history', streamCategory: 'social', order: 8 },
];

export class CurriculumSeederService {
  /**
   * Seeds the 8 standard EUEE subjects in a single bulk operation
   */
  public static async seedSubjects(): Promise<number> {
    const subjectOps = EUEE_SUBJECTS.map((sub) => ({
      updateOne: {
        filter: { code: sub.code },
        update: {
          $set: {
            name: sub.name,
            slug: sub.slug,
            order: sub.order,
            streamCategory: sub.streamCategory,
            grades: [9, 10, 11, 12],
            isActive: true,
          },
        },
        upsert: true,
      },
    }));

    await SubjectModel.bulkWrite(subjectOps);
    logger.info({ subjectsCount: EUEE_SUBJECTS.length }, 'Seeded EUEE subjects successfully');
    return EUEE_SUBJECTS.length;
  }

  /**
   * Scans and seeds all question bank files in content/question-bank using high-performance bulk operations
   */
  public static async seedCurriculum(contentDir?: string): Promise<SeederReport> {
    const baseDir =
      contentDir ||
      path.resolve(__dirname, '../../../../../content/question-bank');

    logger.info({ baseDir }, 'Starting curriculum & question bank ingestion');

    // 1. Ensure subjects exist
    const subjectsCount = await this.seedSubjects();

    const subjectDocMap = new Map<string, any>();
    const allSubjects = await SubjectModel.find({});
    for (const s of allSubjects) {
      subjectDocMap.set(s.code, s);
      subjectDocMap.set(s.name.toLowerCase(), s);
    }

    // 2. Discover all json files
    const jsonFiles = this.findJsonFiles(baseDir);

    const report: SeederReport = {
      totalFilesScanned: jsonFiles.length,
      subjectsUpserted: subjectsCount,
      unitsUpserted: 0,
      publishedUnits: 0,
      draftUnits: 0,
      questionsUpserted: 0,
      answerKeysUpserted: 0,
    };

    interface ParsedUnitItem {
      grade: number;
      subjectCode: string;
      subjectId: any;
      unitNumber: number;
      unitTitle: string;
      unitCode: string;
      hasQuestions: boolean;
      questions?: any[];
    }

    const parsedUnits: ParsedUnitItem[] = [];

    for (const filePath of jsonFiles) {
      try {
        const fileContent = fs.readFileSync(filePath, 'utf-8');
        const rawJson = JSON.parse(fileContent);

        const grade = rawJson.grade;
        const subjectName = rawJson.subject;
        const unitNumber = rawJson.unitNumber;
        const unitTitle = rawJson.unitTitle;

        if (!grade || !subjectName || !unitNumber || !unitTitle) {
          logger.warn({ filePath }, 'Skipping file with missing metadata headers');
          continue;
        }

        const subjectDoc =
          subjectDocMap.get(subjectName.toLowerCase()) ||
          subjectDocMap.get(subjectName);

        if (!subjectDoc) {
          logger.warn({ subjectName, filePath }, 'Subject not recognized');
          continue;
        }

        const subjectCode = subjectDoc.code;
        const unitCode = `${subjectCode}-G${String(grade).padStart(2, '0')}-U${String(
          unitNumber
        ).padStart(2, '0')}`;

        const hasQuestions =
          Array.isArray(rawJson.questions) && rawJson.questions.length === 15;

        let validatedQuestions: any[] | undefined;
        if (hasQuestions) {
          const parsed = QuestionBankFileSchema.safeParse(rawJson);
          if (parsed.success) {
            validatedQuestions = parsed.data.questions;
          } else {
            logger.error(
              { unitCode, errors: parsed.error.issues },
              'Question bank failed contract validation'
            );
          }
        }

        parsedUnits.push({
          grade,
          subjectCode,
          subjectId: subjectDoc._id,
          unitNumber,
          unitTitle,
          unitCode,
          hasQuestions: Boolean(validatedQuestions && validatedQuestions.length === 15),
          questions: validatedQuestions,
        });
      } catch (err: any) {
        logger.error({ filePath, error: err.message }, 'Failed processing question bank file');
      }
    }

    // 3. Bulk upsert units
    const unitOps = parsedUnits.map((item) => ({
      updateOne: {
        filter: { grade: item.grade, subjectCode: item.subjectCode, unitNumber: item.unitNumber },
        update: {
          $set: {
            subjectId: item.subjectId,
            title: item.unitTitle.trim(),
            code: item.unitCode,
            status: item.hasQuestions ? 'published' : 'draft',
            isPublished: item.hasQuestions,
            questionCount: item.hasQuestions ? 15 : 0,
          },
        },
        upsert: true,
      },
    }));

    if (unitOps.length > 0) {
      await UnitModel.bulkWrite(unitOps);
    }

    // 4. Retrieve saved units for accurate ObjectIds
    const savedUnits = await UnitModel.find({
      code: { $in: parsedUnits.map((u) => u.unitCode) },
    });
    const unitMapByCode = new Map(savedUnits.map((u) => [u.code, u._id]));

    // 5. Bulk upsert questions
    const questionOps: any[] = [];
    const publishedItems = parsedUnits.filter((u) => u.hasQuestions && u.questions);

    for (const item of publishedItems) {
      report.publishedUnits++;
      const unitId = unitMapByCode.get(item.unitCode);

      for (const q of item.questions!) {
        questionOps.push({
          updateOne: {
            filter: { externalId: q.id },
            update: {
              $set: {
                unitId,
                unitCode: item.unitCode,
                type: 'multiple_choice',
                difficulty: q.difficulty,
                question: q.question.trim(),
                options: q.options,
                sourceReference: q.sourceReference,
                isPublished: true,
              },
            },
            upsert: true,
          },
        });
      }
    }

    report.draftUnits = parsedUnits.length - report.publishedUnits;
    report.unitsUpserted = parsedUnits.length;

    if (questionOps.length > 0) {
      await QuestionModel.bulkWrite(questionOps);
      report.questionsUpserted = questionOps.length;
    }

    // 6. Bulk upsert answer keys (isolated storage)
    const savedQuestions = await QuestionModel.find({
      isPublished: true,
    });
    const questionMapByExtId = new Map(savedQuestions.map((q) => [q.externalId, q._id]));

    const answerKeyOps: any[] = [];
    for (const item of publishedItems) {
      for (const q of item.questions!) {
        const questionDocId = questionMapByExtId.get(q.id);
        answerKeyOps.push({
          updateOne: {
            filter: { externalId: q.id },
            update: {
              $set: {
                questionId: questionDocId,
                correctOptionId: q.correctOptionId,
                explanation: q.explanation.trim(),
              },
            },
            upsert: true,
          },
        });
      }
    }

    if (answerKeyOps.length > 0) {
      await AnswerKeyModel.bulkWrite(answerKeyOps);
      report.answerKeysUpserted = answerKeyOps.length;
    }

    logger.info(report, 'Curriculum & question bank ingestion completed');
    return report;
  }

  private static findJsonFiles(dir: string): string[] {
    const results: string[] = [];
    if (!fs.existsSync(dir)) {
      return results;
    }

    const entries = fs.readdirSync(dir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        results.push(...this.findJsonFiles(fullPath));
      } else if (entry.isFile() && entry.name.endsWith('.json')) {
        results.push(fullPath);
      }
    }
    return results;
  }
}
