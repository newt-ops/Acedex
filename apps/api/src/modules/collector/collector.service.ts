import fs from 'fs';
import path from 'path';
import {
  CollectorSubjectUnitsResponse,
  CollectorUnitProgressItem,
  ContributorProfile,
  RawQuestionItem,
  UnitSubmissionStatus,
} from '@acedex/contracts';
import { ContributorModel, ICollectorContributorDoc } from './models/collector-contributor.model';
import { UnitSubmissionModel, ICollectorSubmissionDoc } from './models/collector-submission.model';
import { CollectorAuditModel, CollectorAuditAction } from './models/collector-audit.model';
import { UnitModel } from '../curriculum/models/unit.model';
import { SubjectModel } from '../curriculum/models/subject.model';
import { UnauthorizedError, NotFoundError, BadRequestError } from '../../common/errors/app-error';
import { logger } from '../../common/utils/logger';

export const DEFAULT_CONTRIBUTORS: Array<{
  contributorId: string;
  name: string;
  subjectCode: string;
  subjectName: string;
  role?: 'student' | 'admin';
}> = [
  { contributorId: 'ADM#15', name: 'Master Administrator', subjectCode: 'ADMIN', subjectName: 'Admin Review Hub', role: 'admin' },
  { contributorId: 'GEO#982', name: 'Geography Lead', subjectCode: 'GEO', subjectName: 'Geography', role: 'student' },
  { contributorId: 'PHY#101', name: 'Physics Lead', subjectCode: 'PHY', subjectName: 'Physics', role: 'student' },
  { contributorId: 'CHE#202', name: 'Chemistry Lead', subjectCode: 'CHE', subjectName: 'Chemistry', role: 'student' },
  { contributorId: 'BIO#303', name: 'Biology Lead', subjectCode: 'BIO', subjectName: 'Biology', role: 'student' },
  { contributorId: 'MAT#404', name: 'Mathematics Lead', subjectCode: 'MAT', subjectName: 'Mathematics', role: 'student' },
  { contributorId: 'ENG#505', name: 'English Lead', subjectCode: 'ENG', subjectName: 'English', role: 'student' },
  { contributorId: 'ECO#606', name: 'Economics Lead', subjectCode: 'ECO', subjectName: 'Economics', role: 'student' },
  { contributorId: 'HIS#808', name: 'History Lead', subjectCode: 'HIS', subjectName: 'History', role: 'student' },
];

export class CollectorService {
  /**
   * Records an immutable audit log entry in acedex_collector.audit_logs
   */
  public static async logAudit(entry: {
    action: CollectorAuditAction;
    actorId: string;
    actorRole: 'student' | 'admin';
    targetUnitCode?: string;
    metadata?: Record<string, any>;
    ipAddress?: string;
  }): Promise<void> {
    try {
      await CollectorAuditModel.create({
        action: entry.action,
        actorId: entry.actorId.toUpperCase(),
        actorRole: entry.actorRole,
        targetUnitCode: entry.targetUnitCode ? entry.targetUnitCode.toUpperCase() : undefined,
        metadata: entry.metadata,
        ipAddress: entry.ipAddress,
        timestamp: new Date(),
      });
    } catch (err) {
      logger.warn({ err, action: entry.action }, 'Failed to record collector audit log');
    }
  }

  /**
   * Initializes default subject contributor accounts in acedex_collector if they do not exist
   */
  public static async seedDefaultContributors(): Promise<void> {
    for (const c of DEFAULT_CONTRIBUTORS) {
      await ContributorModel.findOneAndUpdate(
        { contributorId: c.contributorId.toUpperCase() },
        {
          $set: {
            name: c.name,
            subjectCode: c.subjectCode.toUpperCase(),
            subjectName: c.subjectName,
            role: c.role || 'student',
            isActive: true,
          },
          $setOnInsert: {
            lastActiveAt: new Date(),
            stats: {
              totalUnits: 0,
              submittedUnits: 0,
              approvedUnits: 0,
              rejectedUnits: 0,
            },
          },
        },
        { upsert: true, new: true }
      );
    }
    logger.info('Default subject contributor IDs initialized in acedex_collector');
  }

  /**
   * Contributor login with ID only (e.g. GEO#982, ADM#15)
   */
  public static async login(contributorId: string, ipAddress?: string): Promise<ContributorProfile> {
    const cleanId = contributorId.trim().toUpperCase();

    // Ensure defaults exist
    await this.seedDefaultContributors();

    const contributor = await ContributorModel.findOne({ contributorId: cleanId });

    if (!contributor) {
      throw new UnauthorizedError(`Contributor ID '${contributorId}' not recognized`);
    }

    contributor.lastActiveAt = new Date();
    await contributor.save();

    const role = contributor.role || (cleanId === 'ADM#15' ? 'admin' : 'student');

    // Audit log login
    await this.logAudit({
      action: 'LOGIN',
      actorId: cleanId,
      actorRole: role,
      ipAddress,
    });

    return {
      contributorId: contributor.contributorId,
      name: contributor.name,
      subjectCode: contributor.subjectCode,
      subjectName: contributor.subjectName,
      role,
    };
  }

  /**
   * Retrieves contributor profile by ID
   */
  public static async getProfile(contributorId: string): Promise<ContributorProfile> {
    const cleanId = contributorId.trim().toUpperCase();
    const contributor = await ContributorModel.findOne({ contributorId: cleanId });

    if (!contributor) {
      throw new NotFoundError(`Contributor '${contributorId}' not found`);
    }

    return {
      contributorId: contributor.contributorId,
      name: contributor.name,
      subjectCode: contributor.subjectCode,
      subjectName: contributor.subjectName,
      role: contributor.role,
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

    if (!unitDocs || unitDocs.length === 0) {
      unitDocs = await this.readUnitsFromDisk(code, subjectName);
    }

    // 2. Fetch existing submissions for this subject from acedex_collector.unit_submissions
    const submissions = await UnitSubmissionModel.find({ subjectCode: code });
    const subMap = new Map<string, ICollectorSubmissionDoc>();
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
    rawPastedText?: string,
    ipAddress?: string
  ): Promise<ICollectorSubmissionDoc> {
    if (!questions || questions.length !== 15) {
      throw new BadRequestError('Submission must contain exactly 15 questions');
    }

    const cleanCode = unitCode.trim().toUpperCase();
    const cleanContributor = contributorId.trim().toUpperCase();

    // Parse grade, subjectCode, and unitNumber from unitCode (e.g. GEO-G10-U02)
    const match = cleanCode.match(/^([A-Z]{3})-G(09|10|11|12)-U(\d{2})$/);
    if (!match) {
      throw new BadRequestError(`Invalid unitCode format: '${unitCode}'. Expected pattern: AAA-Gxx-Uxx`);
    }

    const subjectCode = match[1];
    const grade = parseInt(match[2], 10);
    const unitNumber = parseInt(match[3], 10);

    // Resolve title from unit model or disk fallback
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

    // Find existing submission to handle versioning & history
    const existing = await UnitSubmissionModel.findOne({ unitCode: cleanCode });
    const currentVersion = existing ? (existing.version || 1) + 1 : 1;
    const history = existing ? existing.history || [] : [];

    if (existing) {
      history.push({
        version: existing.version || 1,
        submittedAt: existing.submittedAt,
        contributorId: existing.contributorId,
        questionsCount: existing.questions.length,
        status: existing.status,
        notes: existing.reviewNotes,
      });
    }

    // Upsert into acedex_collector.unit_submissions
    const submission = await UnitSubmissionModel.findOneAndUpdate(
      { unitCode: cleanCode },
      {
        $set: {
          subjectCode,
          grade,
          unitNumber,
          unitTitle,
          contributorId: cleanContributor,
          questions: canonQuestions,
          rawPastedText,
          status: 'submitted',
          version: currentVersion,
          history,
          submittedAt: new Date(),
        },
        $unset: {
          reviewNotes: 1,
          reviewedAt: 1,
          reviewedBy: 1,
        },
      },
      { upsert: true, new: true }
    );

    // Audit log submission
    await this.logAudit({
      action: 'SUBMIT',
      actorId: cleanContributor,
      actorRole: 'student',
      targetUnitCode: cleanCode,
      metadata: { version: currentVersion, questionCount: canonQuestions.length },
      ipAddress,
    });

    logger.info(
      { unitCode: cleanCode, contributorId: cleanContributor, version: currentVersion },
      'Unit questions submitted to acedex_collector'
    );

    return submission;
  }

  /**
   * Admin: Lists all submissions in staging with rich filtering
   */
  public static async listAdminSubmissions(query?: {
    subjectCode?: string;
    status?: string;
    grade?: number;
    contributorId?: string;
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
    if (query?.contributorId) {
      filter.contributorId = query.contributorId.toUpperCase();
    }

    const list = await UnitSubmissionModel.find(filter).sort({ submittedAt: -1 });

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
      version: s.version || 1,
      submittedAt: s.submittedAt.toISOString(),
      reviewedAt: s.reviewedAt ? s.reviewedAt.toISOString() : undefined,
      reviewedBy: s.reviewedBy,
      reviewNotes: s.reviewNotes,
    }));
  }

  /**
   * Admin or Contributor: Gets full submission detail with all 15 questions
   */
  public static async getSubmissionDetail(idOrUnitCode: string) {
    const query = idOrUnitCode.includes('-')
      ? { unitCode: idOrUnitCode.toUpperCase() }
      : { _id: idOrUnitCode };

    const submission = await UnitSubmissionModel.findOne(query);

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
      version: submission.version || 1,
      questions: submission.questions,
      rawPastedText: submission.rawPastedText,
      history: submission.history || [],
      submittedAt: submission.submittedAt.toISOString(),
      reviewedAt: submission.reviewedAt ? submission.reviewedAt.toISOString() : undefined,
      reviewedBy: submission.reviewedBy,
      reviewNotes: submission.reviewNotes,
    };
  }

  /**
   * Admin: In-place edit of questions in a unit
   */
  public static async updateSubmissionQuestions(
    idOrUnitCode: string,
    adminUserId: string,
    questions: RawQuestionItem[],
    ipAddress?: string
  ): Promise<ICollectorSubmissionDoc> {
    if (!questions || questions.length !== 15) {
      throw new BadRequestError('Updated questions must contain exactly 15 questions');
    }

    const query = idOrUnitCode.includes('-')
      ? { unitCode: idOrUnitCode.toUpperCase() }
      : { _id: idOrUnitCode };

    const submission = await UnitSubmissionModel.findOne(query);
    if (!submission) {
      throw new NotFoundError(`Submission '${idOrUnitCode}' not found`);
    }

    submission.questions = questions;
    await submission.save();

    await this.logAudit({
      action: 'EDIT_QUESTION',
      actorId: adminUserId,
      actorRole: 'admin',
      targetUnitCode: submission.unitCode,
      metadata: { questionCount: questions.length },
      ipAddress,
    });

    logger.info({ unitCode: submission.unitCode, adminUserId }, 'Questions modified in-place by admin');
    return submission;
  }

  /**
   * Admin: Approves a unit submission
   */
  public static async approveSubmission(
    idOrUnitCode: string,
    adminUserId: string,
    ipAddress?: string
  ): Promise<ICollectorSubmissionDoc> {
    const query = idOrUnitCode.includes('-')
      ? { unitCode: idOrUnitCode.toUpperCase() }
      : { _id: idOrUnitCode };

    const submission = await UnitSubmissionModel.findOne(query);

    if (!submission) {
      throw new NotFoundError(`Submission '${idOrUnitCode}' not found`);
    }

    submission.status = 'approved';
    submission.reviewedAt = new Date();
    submission.reviewedBy = adminUserId;
    await submission.save();

    await this.logAudit({
      action: 'APPROVE',
      actorId: adminUserId,
      actorRole: 'admin',
      targetUnitCode: submission.unitCode,
      ipAddress,
    });

    logger.info({ unitCode: submission.unitCode, adminUserId }, 'Unit submission approved by admin');
    return submission;
  }

  /**
   * Admin: Rejects a unit submission with revision notes
   */
  public static async rejectSubmission(
    idOrUnitCode: string,
    adminUserId: string,
    notes?: string,
    ipAddress?: string
  ): Promise<ICollectorSubmissionDoc> {
    const query = idOrUnitCode.includes('-')
      ? { unitCode: idOrUnitCode.toUpperCase() }
      : { _id: idOrUnitCode };

    const submission = await UnitSubmissionModel.findOne(query);

    if (!submission) {
      throw new NotFoundError(`Submission '${idOrUnitCode}' not found`);
    }

    submission.status = 'rejected';
    submission.reviewNotes = notes || 'Revision requested. Please review your questions and resubmit.';
    submission.reviewedAt = new Date();
    submission.reviewedBy = adminUserId;
    await submission.save();

    await this.logAudit({
      action: 'REJECT',
      actorId: adminUserId,
      actorRole: 'admin',
      targetUnitCode: submission.unitCode,
      metadata: { reason: submission.reviewNotes },
      ipAddress,
    });

    logger.info({ unitCode: submission.unitCode, adminUserId, notes }, 'Unit submission rejected by admin');
    return submission;
  }

  /**
   * Admin: Exports approved/submitted unit as canonical QuestionBankFile JSON
   */
  public static async exportUnitJson(idOrUnitCode: string, actorId = 'admin', ipAddress?: string) {
    const submission = await this.getSubmissionDetail(idOrUnitCode);

    // Resolve full subject name
    const subject = await SubjectModel.findOne({ code: submission.subjectCode });
    const subjectName = subject ? subject.name : DEFAULT_CONTRIBUTORS.find((c) => c.subjectCode === submission.subjectCode)?.subjectName || submission.subjectCode;

    await this.logAudit({
      action: 'EXPORT_JSON',
      actorId,
      actorRole: 'admin',
      targetUnitCode: submission.unitCode,
      ipAddress,
    });

    return {
      grade: submission.grade,
      subject: subjectName,
      unitNumber: submission.unitNumber,
      unitTitle: submission.unitTitle,
      questions: submission.questions,
    };
  }

  /**
   * Admin: Exports all approved units for a subject bundled together
   */
  public static async exportSubjectUnits(subjectCode: string, actorId = 'admin') {
    const code = subjectCode.trim().toUpperCase();
    const submissions = await UnitSubmissionModel.find({
      subjectCode: code,
      status: 'approved',
    }).sort({ grade: 1, unitNumber: 1 });

    const subject = await SubjectModel.findOne({ code });
    const subjectName = subject ? subject.name : DEFAULT_CONTRIBUTORS.find((c) => c.subjectCode === code)?.subjectName || code;

    await this.logAudit({
      action: 'EXPORT_JSON',
      actorId,
      actorRole: 'admin',
      metadata: { subjectCode: code, exportedUnitsCount: submissions.length },
    });

    return {
      subjectCode: code,
      subjectName,
      approvedUnitsCount: submissions.length,
      units: submissions.map((s) => ({
        grade: s.grade,
        unitNumber: s.unitNumber,
        unitTitle: s.unitTitle,
        unitCode: s.unitCode,
        questions: s.questions,
      })),
    };
  }

  /**
   * Admin: System-wide collection dashboard statistics
   */
  public static async getAdminStats() {
    const [totalContributors, submissions] = await Promise.all([
      ContributorModel.countDocuments({ isActive: true }),
      UnitSubmissionModel.find({}, { unitCode: 1, subjectCode: 1, status: 1, grade: 1 }),
    ]);

    let submittedCount = 0;
    let approvedCount = 0;
    let rejectedCount = 0;

    const subjectMap: Record<string, { total: number; submitted: number; approved: number; rejected: number }> = {};

    for (const s of submissions) {
      if (s.status === 'submitted') submittedCount++;
      if (s.status === 'approved') approvedCount++;
      if (s.status === 'rejected') rejectedCount++;

      if (!subjectMap[s.subjectCode]) {
        subjectMap[s.subjectCode] = { total: 0, submitted: 0, approved: 0, rejected: 0 };
      }
      subjectMap[s.subjectCode].total++;
      if (s.status === 'submitted') subjectMap[s.subjectCode].submitted++;
      if (s.status === 'approved') subjectMap[s.subjectCode].approved++;
      if (s.status === 'rejected') subjectMap[s.subjectCode].rejected++;
    }

    return {
      totalContributors,
      submissionsCount: submissions.length,
      submittedUnits: submittedCount,
      approvedUnits: approvedCount,
      rejectedUnits: rejectedCount,
      pendingReview: submittedCount,
      subjectStats: subjectMap,
    };
  }

  /**
   * Admin: Lists immutable audit trail
   */
  public static async listAuditLogs(limit = 50, offset = 0) {
    const [total, logs] = await Promise.all([
      CollectorAuditModel.countDocuments(),
      CollectorAuditModel.find().sort({ timestamp: -1 }).skip(offset).limit(limit),
    ]);

    return {
      total,
      limit,
      offset,
      logs: logs.map((l) => ({
        id: l._id.toString(),
        action: l.action,
        actorId: l.actorId,
        actorRole: l.actorRole,
        targetUnitCode: l.targetUnitCode,
        metadata: l.metadata,
        ipAddress: l.ipAddress,
        timestamp: l.timestamp.toISOString(),
      })),
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
          (subjectCode === 'GEO' && sDir.toLowerCase() === 'geography') ||
          (subjectCode === 'PHY' && sDir.toLowerCase() === 'physics') ||
          (subjectCode === 'CHE' && sDir.toLowerCase() === 'chemistry') ||
          (subjectCode === 'BIO' && sDir.toLowerCase() === 'biology') ||
          (subjectCode === 'MAT' && sDir.toLowerCase() === 'mathematics') ||
          (subjectCode === 'ENG' && sDir.toLowerCase() === 'english') ||
          (subjectCode === 'ECO' && sDir.toLowerCase() === 'economics') ||
          (subjectCode === 'HIS' && sDir.toLowerCase() === 'history');

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
