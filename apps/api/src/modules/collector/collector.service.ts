import fs from 'fs';
import path from 'path';
import {
  CollectorSubjectUnitsResponse,
  CollectorUnitProgressItem,
  ContributorProfile,
  RawQuestionItem,
  UnitSubmissionStatus,
} from '@acedex/contracts';
import { ContributorModel } from './models/contributor.model';
import { TempUnitSubmissionModel } from './models/unit-submission.model';
import { UnitModel } from '../curriculum/models/unit.model';
import { SubjectModel } from '../curriculum/models/subject.model';
import { UnauthorizedError, NotFoundError, BadRequestError } from '../../common/errors/app-error';
import { logger } from '../../common/utils/logger';

export const DEFAULT_CONTRIBUTORS: Array<{
  contributorId: string;
  name: string;
  subjectCode: string;
  subjectName: string;
}> = [
  { contributorId: 'GEO#982', name: 'Geography Lead', subjectCode: 'GEO', subjectName: 'Geography' },
  { contributorId: 'PHY#101', name: 'Physics Lead', subjectCode: 'PHY', subjectName: 'Physics' },
  { contributorId: 'CHE#202', name: 'Chemistry Lead', subjectCode: 'CHE', subjectName: 'Chemistry' },
  { contributorId: 'BIO#303', name: 'Biology Lead', subjectCode: 'BIO', subjectName: 'Biology' },
  { contributorId: 'MAT#404', name: 'Mathematics Lead', subjectCode: 'MAT', subjectName: 'Mathematics' },
  { contributorId: 'ENG#505', name: 'English Lead', subjectCode: 'ENG', subjectName: 'English' },
  { contributorId: 'ECO#606', name: 'Economics Lead', subjectCode: 'ECO', subjectName: 'Economics' },
  { contributorId: 'HIS#808', name: 'History Lead', subjectCode: 'HIS', subjectName: 'History' },
];

export class CollectorService {
  /**
   * Initializes default subject contributor accounts if they do not exist
   */
  public static async seedDefaultContributors(): Promise<void> {
    for (const c of DEFAULT_CONTRIBUTORS) {
      await ContributorModel.findOneAndUpdate(
        { contributorId: c.contributorId.toUpperCase() },
        {
          $setOnInsert: {
            name: c.name,
            subjectCode: c.subjectCode.toUpperCase(),
            subjectName: c.subjectName,
            lastActiveAt: new Date(),
          },
        },
        { upsert: true, new: true }
      );
    }
    logger.info('Default subject contributor IDs initialized');
  }

  /**
   * Contributor login with ID only (e.g. GEO#982)
   */
  public static async login(contributorId: string): Promise<ContributorProfile> {
    const cleanId = contributorId.trim().toUpperCase();

    // Ensure defaults exist
    await this.seedDefaultContributors();

    const contributor = await ContributorModel.findOne({ contributorId: cleanId });

    if (!contributor) {
      throw new UnauthorizedError(`Contributor ID '${contributorId}' not recognized`);
    }

    contributor.lastActiveAt = new Date();
    await contributor.save();

    return {
      contributorId: contributor.contributorId,
      name: contributor.name,
      subjectCode: contributor.subjectCode,
      subjectName: contributor.subjectName,
    };
  }

  /**
   * Loads all 4 grades (9-12) for a subject, with unit titles and their submission statuses
   */
  public static async getSubjectUnitTree(
    subjectCode: string,
    contributorId?: string
  ): Promise<CollectorSubjectUnitsResponse> {
    const code = subjectCode.trim().toUpperCase();

    // Resolve subject name
    const subject = await SubjectModel.findOne({ code });
    const subjectName = subject ? subject.name : DEFAULT_CONTRIBUTORS.find((c) => c.subjectCode === code)?.subjectName || code;

    // 1. Fetch all units for this subject from UnitModel (or fallback to question-bank folder)
    let unitDocs = await UnitModel.find({ subjectCode: code }).sort({ grade: 1, unitNumber: 1 });

    // Fallback if DB was not fully seeded: read from question-bank directory
    if (!unitDocs || unitDocs.length === 0) {
      unitDocs = await this.readUnitsFromDisk(code, subjectName);
    }

    // 2. Fetch existing temporary submissions for this subject
    const submissions = await TempUnitSubmissionModel.find({ subjectCode: code });
    const subMap = new Map<string, typeof submissions[0]>();
    for (const s of submissions) {
      subMap.set(s.unitCode, s);
    }

    // 3. Group units by grade (9, 10, 11, 12)
    const gradeGroups: Record<number, CollectorUnitProgressItem[]> = {
      9: [],
      10: [],
      11: [],
      12: [],
    };

    let totalUnits = 0;
    let approvedUnits = 0;
    let submittedUnits = 0;

    for (const u of unitDocs) {
      const g = u.grade;
      if (!gradeGroups[g]) gradeGroups[g] = [];

      const submission = subMap.get(u.code);
      let status: UnitSubmissionStatus = 'not_started';
      let submittedAt: string | undefined;
      let approvedAt: string | undefined;
      let reviewNotes: string | undefined;
      let qCount: number | undefined;

      if (submission) {
        status = submission.status;
        submittedAt = submission.submittedAt ? submission.submittedAt.toISOString() : undefined;
        approvedAt = submission.reviewedAt ? submission.reviewedAt.toISOString() : undefined;
        reviewNotes = submission.reviewNotes;
        qCount = submission.questions?.length;
      }

      if (status === 'approved') approvedUnits++;
      if (status === 'submitted') submittedUnits++;
      totalUnits++;

      gradeGroups[g].push({
        unitCode: u.code,
        grade: u.grade,
        unitNumber: u.unitNumber,
        unitTitle: u.title,
        status,
        questionCount: qCount,
        submittedAt,
        approvedAt,
        reviewNotes,
      });
    }

    const grades = [9, 10, 11, 12].map((g) => ({
      grade: g,
      units: gradeGroups[g] || [],
    }));

    return {
      subjectCode: code,
      subjectName,
      contributorId: contributorId || '',
      totalUnits,
      approvedUnits,
      submittedUnits,
      grades,
    };
  }

  /**
   * Contributor submits 15 questions for a specific unit
   */
  public static async submitUnitQuestions(
    unitCode: string,
    contributorId: string,
    questions: RawQuestionItem[],
    rawPastedText?: string
  ) {
    if (!questions || questions.length !== 15) {
      throw new BadRequestError('Submission must contain exactly 15 questions');
    }

    const cleanCode = unitCode.trim().toUpperCase();

    // Parse grade, subjectCode, and unitNumber from unitCode (e.g. GEO-G10-U02)
    const match = cleanCode.match(/^([A-Z]{3})-G(09|10|11|12)-U(\d{2})$/);
    if (!match) {
      throw new BadRequestError(`Invalid unitCode format: '${unitCode}'. Expected pattern: AAA-Gxx-Uxx`);
    }

    const subjectCode = match[1];
    const grade = parseInt(match[2], 10);
    const unitNumber = parseInt(match[3], 10);

    // Resolve title from unit model or fallback
    let unitTitle = `Unit ${unitNumber}`;
    const unitDoc = await UnitModel.findOne({ code: cleanCode });
    if (unitDoc && unitDoc.title) {
      unitTitle = unitDoc.title;
    } else {
      const diskUnits = await this.readUnitsFromDisk(subjectCode);
      const found = diskUnits.find((d) => d.code === cleanCode);
      if (found) unitTitle = found.title;
    }

    // Ensure question IDs match canonical convention
    const canonQuestions = questions.map((q, idx) => ({
      ...q,
      id: `${cleanCode}-Q${String(idx + 1).padStart(3, '0')}`,
    }));

    // Upsert into temp_unit_submissions
    const submission = await TempUnitSubmissionModel.findOneAndUpdate(
      { unitCode: cleanCode },
      {
        $set: {
          subjectCode,
          grade,
          unitNumber,
          unitTitle,
          contributorId: contributorId.trim().toUpperCase(),
          questions: canonQuestions,
          rawPastedText,
          status: 'submitted',
          submittedAt: new Date(),
        },
        $unset: {
          reviewNotes: 1,
        },
      },
      { upsert: true, new: true }
    );

    logger.info(
      { unitCode: cleanCode, contributorId, questionsCount: questions.length },
      'Unit questions submitted to collector staging'
    );

    return submission;
  }

  /**
   * Admin: Lists all submissions in staging
   */
  public static async listAdminSubmissions(query?: {
    subjectCode?: string;
    status?: string;
    grade?: number;
  }) {
    const filter: Record<string, any> = {};

    if (query?.subjectCode) {
      filter.subjectCode = query.subjectCode.toUpperCase();
    }
    if (query?.status) {
      filter.status = query.status;
    }
    if (query?.grade) {
      filter.grade = Number(query.grade);
    }

    const list = await TempUnitSubmissionModel.find(filter).sort({ submittedAt: -1 });

    return list.map((s) => ({
      _id: s._id.toString(),
      unitCode: s.unitCode,
      subjectCode: s.subjectCode,
      grade: s.grade,
      unitNumber: s.unitNumber,
      unitTitle: s.unitTitle,
      contributorId: s.contributorId,
      questionCount: s.questions.length,
      status: s.status,
      submittedAt: s.submittedAt.toISOString(),
      reviewedAt: s.reviewedAt ? s.reviewedAt.toISOString() : undefined,
      reviewNotes: s.reviewNotes,
    }));
  }

  /**
   * Admin: Gets full submission detail with all 15 questions
   */
  public static async getSubmissionDetail(idOrUnitCode: string) {
    const query = idOrUnitCode.includes('-')
      ? { unitCode: idOrUnitCode.toUpperCase() }
      : { _id: idOrUnitCode };

    const submission = await TempUnitSubmissionModel.findOne(query);

    if (!submission) {
      throw new NotFoundError(`Submission '${idOrUnitCode}' not found`);
    }

    return {
      _id: submission._id.toString(),
      unitCode: submission.unitCode,
      subjectCode: submission.subjectCode,
      grade: submission.grade,
      unitNumber: submission.unitNumber,
      unitTitle: submission.unitTitle,
      contributorId: submission.contributorId,
      questionCount: submission.questions.length,
      status: submission.status,
      questions: submission.questions,
      rawPastedText: submission.rawPastedText,
      submittedAt: submission.submittedAt.toISOString(),
      reviewedAt: submission.reviewedAt ? submission.reviewedAt.toISOString() : undefined,
      reviewNotes: submission.reviewNotes,
    };
  }

  /**
   * Admin: Approves a unit submission
   */
  public static async approveSubmission(idOrUnitCode: string, adminUserId: string) {
    const query = idOrUnitCode.includes('-')
      ? { unitCode: idOrUnitCode.toUpperCase() }
      : { _id: idOrUnitCode };

    const submission = await TempUnitSubmissionModel.findOne(query);

    if (!submission) {
      throw new NotFoundError(`Submission '${idOrUnitCode}' not found`);
    }

    submission.status = 'approved';
    submission.reviewedAt = new Date();
    submission.reviewedBy = adminUserId;
    await submission.save();

    logger.info({ unitCode: submission.unitCode, adminUserId }, 'Unit submission approved by admin');

    return submission;
  }

  /**
   * Admin: Rejects a unit submission with revision notes
   */
  public static async rejectSubmission(idOrUnitCode: string, adminUserId: string, notes?: string) {
    const query = idOrUnitCode.includes('-')
      ? { unitCode: idOrUnitCode.toUpperCase() }
      : { _id: idOrUnitCode };

    const submission = await TempUnitSubmissionModel.findOne(query);

    if (!submission) {
      throw new NotFoundError(`Submission '${idOrUnitCode}' not found`);
    }

    submission.status = 'rejected';
    submission.reviewNotes = notes || 'Revision requested. Please review your questions and resubmit.';
    submission.reviewedAt = new Date();
    submission.reviewedBy = adminUserId;
    await submission.save();

    logger.info({ unitCode: submission.unitCode, adminUserId, notes }, 'Unit submission rejected by admin');

    return submission;
  }

  /**
   * Admin: Exports approved/submitted unit as canonical QuestionBankFile JSON
   */
  public static async exportUnitJson(idOrUnitCode: string) {
    const submission = await this.getSubmissionDetail(idOrUnitCode);

    // Resolve full subject name
    const subject = await SubjectModel.findOne({ code: submission.subjectCode });
    const subjectName = subject ? subject.name : DEFAULT_CONTRIBUTORS.find((c) => c.subjectCode === submission.subjectCode)?.subjectName || submission.subjectCode;

    return {
      grade: submission.grade,
      subject: subjectName,
      unitNumber: submission.unitNumber,
      unitTitle: submission.unitTitle,
      questions: submission.questions,
    };
  }

  /**
   * Fallback helper to discover unit codes and titles from content/question-bank/ directory
   */
  private static async readUnitsFromDisk(subjectCode: string, subjectName?: string): Promise<any[]> {
    const units: any[] = [];
    const baseDir = path.resolve(process.cwd(), 'content/question-bank');
    if (!fs.existsSync(baseDir)) return units;

    const grades = [9, 10, 11, 12];
    for (const g of grades) {
      const gPad = String(g).padStart(2, '0');
      const gDir = path.join(baseDir, `Grade-${gPad}`);
      if (!fs.existsSync(gDir)) continue;

      const subDirs = fs.readdirSync(gDir);
      for (const sDir of subDirs) {
        const fullSubDir = path.join(gDir, sDir);
        if (!fs.statSync(fullSubDir).isDirectory()) continue;

        // Check if folder matches subject
        const matchesSubject =
          (subjectName && sDir.toLowerCase() === subjectName.toLowerCase()) ||
          sDir.toUpperCase().startsWith(subjectCode) ||
          subjectCode === 'GEO' && sDir.toLowerCase() === 'geography' ||
          subjectCode === 'PHY' && sDir.toLowerCase() === 'physics' ||
          subjectCode === 'CHE' && sDir.toLowerCase() === 'chemistry' ||
          subjectCode === 'BIO' && sDir.toLowerCase() === 'biology' ||
          subjectCode === 'MAT' && sDir.toLowerCase() === 'mathematics' ||
          subjectCode === 'ENG' && sDir.toLowerCase() === 'english' ||
          subjectCode === 'ECO' && sDir.toLowerCase() === 'economics' ||
          subjectCode === 'HIS' && sDir.toLowerCase() === 'history';

        if (!matchesSubject) continue;

        const files = fs.readdirSync(fullSubDir).filter((f) => f.endsWith('.json'));
        for (const f of files) {
          try {
            const content = JSON.parse(fs.readFileSync(path.join(fullSubDir, f), 'utf-8'));
            const code = f.replace('.json', '');
            units.push({
              code,
              grade: content.grade || g,
              unitNumber: content.unitNumber || parseInt(code.split('-U')[1], 10),
              title: content.unitTitle || `Unit ${content.unitNumber || ''}`,
              subjectCode,
            });
          } catch {
            // Ignore corrupted local file
          }
        }
      }
    }

    units.sort((a, b) => a.grade - b.grade || a.unitNumber - b.unitNumber);
    return units;
  }
}
