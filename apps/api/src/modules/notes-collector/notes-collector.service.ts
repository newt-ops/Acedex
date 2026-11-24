import fs from 'fs';
import path from 'path';
import {
  CollectorNoteSubjectUnitsResponse,
  CollectorNoteUnitProgressItem,
  CollectorNoteItem,
  CollectorNoteSubmissionSummary,
  CollectorNoteSubmissionDetail,
} from '@acedex/contracts';
import { getNoteSubmissionModel, INoteSubmission } from './models/note-submission.model';
import { getNoteAuditModel } from './models/note-audit.model';
import { NoteSanitizerService } from './services/note-sanitizer.service';
import { logger } from '../../common/utils/logger';

const SUBJECT_CODE_MAP: Record<string, string> = {
  BIO: 'Biology',
  CHE: 'Chemistry',
  ECO: 'Economics',
  ENG: 'English',
  GEO: 'Geography',
  HIS: 'History',
  MAT: 'Mathematics',
  PHY: 'Physics',
};

export class NotesCollectorService {
  private static getQuestionBankDir(): string {
    const candidates = [
      path.resolve(process.cwd(), 'content/question-bank'),
      path.resolve(process.cwd(), '../../content/question-bank'),
      path.resolve(__dirname, '../../../../../content/question-bank'),
      path.resolve(__dirname, '../../../../content/question-bank'),
    ];
    for (const cand of candidates) {
      if (fs.existsSync(cand)) return cand;
    }
    return candidates[0];
  }

  private static getQuickNotesDir(): string {
    const candidates = [
      path.resolve(process.cwd(), 'content/quick-notes'),
      path.resolve(process.cwd(), '../../content/quick-notes'),
      path.resolve(__dirname, '../../../../../content/quick-notes'),
      path.resolve(__dirname, '../../../../content/quick-notes'),
    ];
    for (const cand of candidates) {
      if (fs.existsSync(cand)) return cand;
    }
    return candidates[0];
  }

  /**
   * Returns categorized 4-grade unit curriculum tree with note submission statuses
   */
  public static async getUnits(
    subjectCode: string,
    contributorId: string
  ): Promise<CollectorNoteSubjectUnitsResponse> {
    const cleanSubjCode = subjectCode.toUpperCase().trim();
    const subjectName = SUBJECT_CODE_MAP[cleanSubjCode] || cleanSubjCode;

    const grades = [9, 10, 11, 12];
    const gradeUnitsMap: Record<number, CollectorNoteUnitProgressItem[]> = {
      9: [],
      10: [],
      11: [],
      12: [],
    };

    const qbBaseDir = this.getQuestionBankDir();
    const notesBaseDir = this.getQuickNotesDir();

    // 1. Scan filesystem question-bank to get all canonical units
    for (const g of grades) {
      const gStr = `Grade-${g.toString().padStart(2, '0')}`;
      const subjDir = path.join(qbBaseDir, gStr, subjectName);

      if (fs.existsSync(subjDir)) {
        const files = fs.readdirSync(subjDir).filter((f) => f.endsWith('.json'));

        for (const f of files) {
          try {
            const content = JSON.parse(fs.readFileSync(path.join(subjDir, f), 'utf-8'));
            const unitCode = f.replace('.json', '');

            gradeUnitsMap[g].push({
              unitCode,
              grade: g,
              unitNumber: content.unitNumber || parseInt(unitCode.replace(/.*-U0?/, ''), 10) || 1,
              unitTitle: content.unitTitle || 'Untitled Unit',
              status: 'not_started',
            });
          } catch (readErr: any) {
            logger.warn({ f, err: readErr.message }, 'Failed to parse question bank unit file');
          }
        }
      }

      // Sort units by unitNumber
      gradeUnitsMap[g].sort((a, b) => a.unitNumber - b.unitNumber);
    }

    // 2. Query MongoDB note_submissions for saved status
    const NoteSubmission = getNoteSubmissionModel();
    const existingSubmissions = await NoteSubmission.find({
      subjectCode: cleanSubjCode,
    }).lean();

    const submissionMap = new Map<string, any>();
    for (const sub of existingSubmissions) {
      submissionMap.set(sub.unitCode.toUpperCase(), sub);
    }

    let totalUnits = 0;
    let approvedUnits = 0;
    let submittedUnits = 0;

    // 3. Merge status & check local files
    for (const g of grades) {
      const gStr = `Grade-${g.toString().padStart(2, '0')}`;
      const localNotesDir = path.join(notesBaseDir, gStr, subjectName);

      for (const item of gradeUnitsMap[g]) {
        totalUnits++;
        const sub = submissionMap.get(item.unitCode.toUpperCase());

        if (sub) {
          item.status = sub.status;
          item.summaryPointCount = sub.summaryPoints?.length || 0;
          item.formulaCount = sub.formulas?.length || 0;
          item.definitionCount = sub.keyDefinitions?.length || 0;
          item.submittedAt = sub.submittedAt ? sub.submittedAt.toISOString() : undefined;
          item.approvedAt = sub.reviewedAt ? sub.reviewedAt.toISOString() : undefined;
          item.reviewNotes = sub.reviewNotes;
        } else {
          // Check if local file exists on disk
          const localFilePath = path.join(localNotesDir, `${item.unitCode}.json`);
          if (fs.existsSync(localFilePath)) {
            try {
              const localData = JSON.parse(fs.readFileSync(localFilePath, 'utf-8'));
              item.status = 'approved';
              item.summaryPointCount = localData.summaryPoints?.length || 0;
              item.formulaCount = localData.formulas?.length || 0;
              item.definitionCount = localData.keyDefinitions?.length || 0;
            } catch {
              // Ignore read error
            }
          }
        }

        if (item.status === 'approved') approvedUnits++;
        if (item.status === 'submitted') submittedUnits++;
      }
    }

    return {
      subjectCode: cleanSubjCode,
      subjectName,
      contributorId,
      totalUnits,
      approvedUnits,
      submittedUnits,
      grades: grades.map((g) => ({
        grade: g,
        units: gradeUnitsMap[g],
      })),
    };
  }

  /**
   * Get single unit note detail
   */
  public static async getUnitDetail(unitCode: string): Promise<CollectorNoteSubmissionDetail | null> {
    const NoteSubmission = getNoteSubmissionModel();
    const cleanCode = unitCode.toUpperCase().trim();

    const sub = await NoteSubmission.findOne({ unitCode: cleanCode }).lean();
    if (sub) {
      return {
        _id: sub._id.toString(),
        unitCode: sub.unitCode,
        subjectCode: sub.subjectCode,
        grade: sub.grade,
        unitNumber: sub.unitNumber,
        unitTitle: sub.unitTitle,
        contributorId: sub.contributorId,
        status: sub.status,
        summaryPointCount: sub.summaryPoints?.length || 0,
        formulaCount: sub.formulas?.length || 0,
        definitionCount: sub.keyDefinitions?.length || 0,
        submittedAt: sub.submittedAt ? sub.submittedAt.toISOString() : new Date().toISOString(),
        reviewedAt: sub.reviewedAt ? sub.reviewedAt.toISOString() : undefined,
        reviewNotes: sub.reviewNotes,
        rawPastedText: sub.rawPastedText,
        note: {
          grade: sub.grade,
          subject: sub.subject,
          subjectCode: sub.subjectCode,
          unitNumber: sub.unitNumber,
          unitCode: sub.unitCode,
          unitTitle: sub.unitTitle,
          examWeight: sub.examWeight,
          summaryPoints: sub.summaryPoints || [],
          formulas: sub.formulas || [],
          examTip: sub.examTip || '',
          keyDefinitions: sub.keyDefinitions || [],
          eueeFocusTopics: sub.eueeFocusTopics || [],
        },
      };
    }

    return null;
  }

  /**
   * Submits or updates a unit quick note
   */
  public static async submitUnitNote(
    unitCode: string,
    contributorId: string,
    rawPastedText?: string,
    noteData?: CollectorNoteItem
  ): Promise<INoteSubmission> {
    const cleanCode = unitCode.toUpperCase().trim();

    let finalNote = noteData;
    if (!finalNote && rawPastedText) {
      const sanitized = NoteSanitizerService.sanitize(rawPastedText, cleanCode);
      if (!sanitized.success || !sanitized.note) {
        throw new Error(sanitized.errors?.join('; ') || 'Failed to parse notes content');
      }
      finalNote = sanitized.note;
    }

    if (!finalNote) {
      throw new Error('Neither structured note data nor raw pasted text was provided');
    }

    const NoteSubmission = getNoteSubmissionModel();
    const submission = await NoteSubmission.findOneAndUpdate(
      { unitCode: cleanCode },
      {
        grade: finalNote.grade,
        subject: finalNote.subject,
        subjectCode: finalNote.subjectCode.toUpperCase(),
        unitNumber: finalNote.unitNumber,
        unitCode: cleanCode,
        unitTitle: finalNote.unitTitle,
        examWeight: finalNote.examWeight,
        summaryPoints: finalNote.summaryPoints,
        formulas: finalNote.formulas,
        examTip: finalNote.examTip,
        keyDefinitions: finalNote.keyDefinitions,
        eueeFocusTopics: finalNote.eueeFocusTopics,
        status: 'submitted',
        contributorId,
        rawPastedText: rawPastedText || JSON.stringify(finalNote, null, 2),
        submittedAt: new Date(),
        reviewNotes: undefined,
      },
      { upsert: true, new: true }
    );

    // Audit log
    const NoteAudit = getNoteAuditModel();
    await NoteAudit.create({
      unitCode: cleanCode,
      action: 'submit',
      actorId: contributorId,
      metadata: {
        summaryCount: finalNote.summaryPoints.length,
        formulaCount: finalNote.formulas.length,
        definitionCount: finalNote.keyDefinitions.length,
      },
    });

    return submission;
  }

  /**
   * Submits or updates an entire grade's revision notes at once.
   * Organizes each unit into acedex_notes individually!
   */
  public static async submitGradeNotes(
    grade: number,
    subjectCode: string,
    contributorId: string,
    rawPastedText?: string,
    notesList?: CollectorNoteItem[]
  ): Promise<{ submittedCount: number; units: string[] }> {
    let finalUnits = notesList;

    if (!finalUnits && rawPastedText) {
      const sanitized = NoteSanitizerService.sanitize(rawPastedText);
      if (!sanitized.success || !sanitized.notes || sanitized.notes.length === 0) {
        throw new Error(sanitized.errors?.join('; ') || 'Failed to parse notes content for grade');
      }
      finalUnits = sanitized.notes;
    }

    if (!finalUnits || finalUnits.length === 0) {
      throw new Error('No structured note data or raw text provided for grade submission');
    }

    const submittedUnitCodes: string[] = [];

    for (const unit of finalUnits) {
      const cleanSubj = (unit.subjectCode || subjectCode).toUpperCase().trim();
      const unitGrade = unit.grade || grade;
      const uNum = unit.unitNumber;
      const cleanCode = unit.unitCode || `${cleanSubj}-G${unitGrade.toString().padStart(2, '0')}-U${uNum.toString().padStart(2, '0')}`;

      await this.submitUnitNote(cleanCode, contributorId, undefined, {
        ...unit,
        unitCode: cleanCode,
        grade: unitGrade,
        subjectCode: cleanSubj,
      });

      submittedUnitCodes.push(cleanCode);
    }

    logger.info(
      { grade, subjectCode, contributorId, count: submittedUnitCodes.length },
      'Grade notes submitted and organized per unit'
    );

    return {
      submittedCount: submittedUnitCodes.length,
      units: submittedUnitCodes,
    };
  }

  /**
   * Admin: List submissions with status/subject filters
   */
  public static async getAdminSubmissions(filters: {
    status?: string;
    subjectCode?: string;
    grade?: number;
  }): Promise<CollectorNoteSubmissionSummary[]> {
    const NoteSubmission = getNoteSubmissionModel();
    const query: any = {};

    if (filters.status && filters.status !== 'all') {
      query.status = filters.status;
    }
    if (filters.subjectCode && filters.subjectCode !== 'all') {
      query.subjectCode = filters.subjectCode.toUpperCase();
    }
    if (filters.grade) {
      query.grade = filters.grade;
    }

    const submissions = await NoteSubmission.find(query).sort({ updatedAt: -1 }).lean();

    return submissions.map((s) => ({
      _id: s._id.toString(),
      unitCode: s.unitCode,
      subjectCode: s.subjectCode,
      grade: s.grade,
      unitNumber: s.unitNumber,
      unitTitle: s.unitTitle,
      contributorId: s.contributorId,
      status: s.status,
      summaryPointCount: s.summaryPoints?.length || 0,
      formulaCount: s.formulas?.length || 0,
      definitionCount: s.keyDefinitions?.length || 0,
      submittedAt: s.submittedAt ? s.submittedAt.toISOString() : new Date().toISOString(),
      reviewedAt: s.reviewedAt ? s.reviewedAt.toISOString() : undefined,
      reviewNotes: s.reviewNotes,
    }));
  }

  /**
   * Admin: Review (Approve / Reject) a submission
   */
  public static async reviewSubmission(
    id: string,
    adminUserId: string,
    action: 'approve' | 'reject',
    notes?: string
  ): Promise<INoteSubmission> {
    const NoteSubmission = getNoteSubmissionModel();
    const submission = await NoteSubmission.findById(id);

    if (!submission) {
      throw new Error(`Submission ${id} not found`);
    }

    submission.status = action === 'approve' ? 'approved' : 'rejected';
    submission.reviewedAt = new Date();
    submission.reviewNotes = notes || (action === 'approve' ? 'Approved by Admin' : 'Revision requested');

    await submission.save();

    // If approved, automatically sync and write to local filesystem file
    if (action === 'approve') {
      await this.writeSubmissionToFile(submission);
    }

    // Audit log
    const NoteAudit = getNoteAuditModel();
    await NoteAudit.create({
      unitCode: submission.unitCode,
      action: action === 'approve' ? 'approve' : 'reject',
      actorId: adminUserId,
      metadata: { reviewNotes: submission.reviewNotes },
    });

    return submission;
  }

  /**
   * Writes an approved submission to content/quick-notes/
   */
  public static async writeSubmissionToFile(sub: INoteSubmission): Promise<string> {
    const notesBaseDir = this.getQuickNotesDir();
    const gStr = `Grade-${sub.grade.toString().padStart(2, '0')}`;
    const subjectName = SUBJECT_CODE_MAP[sub.subjectCode] || sub.subject;
    const targetDir = path.join(notesBaseDir, gStr, subjectName);

    fs.mkdirSync(targetDir, { recursive: true });

    const payload: CollectorNoteItem = {
      grade: sub.grade,
      subject: sub.subject,
      subjectCode: sub.subjectCode,
      unitNumber: sub.unitNumber,
      unitCode: sub.unitCode,
      unitTitle: sub.unitTitle,
      examWeight: sub.examWeight,
      summaryPoints: sub.summaryPoints,
      formulas: sub.formulas,
      examTip: sub.examTip,
      keyDefinitions: sub.keyDefinitions,
      eueeFocusTopics: sub.eueeFocusTopics,
    };

    const filePath = path.join(targetDir, `${sub.unitCode}.json`);
    fs.writeFileSync(filePath, JSON.stringify(payload, null, 2), 'utf-8');
    logger.info({ filePath }, 'Exported approved note to local JSON file');
    return filePath;
  }

  /**
   * Bi-directional synchronization between database and local filesystem
   */
  public static async syncLocalFiles(): Promise<{ exportedCount: number; importedCount: number }> {
    const NoteSubmission = getNoteSubmissionModel();
    const notesBaseDir = this.getQuickNotesDir();

    let exportedCount = 0;
    let importedCount = 0;

    // 1. Export all approved DB submissions to disk
    const approvedSubmissions = await NoteSubmission.find({ status: 'approved' });
    for (const sub of approvedSubmissions) {
      await this.writeSubmissionToFile(sub);
      exportedCount++;
    }

    // 2. Import any existing disk files into DB if not present
    if (fs.existsSync(notesBaseDir)) {
      const grades = fs.readdirSync(notesBaseDir).filter((d) => d.startsWith('Grade-'));

      for (const gDir of grades) {
        const gradePath = path.join(notesBaseDir, gDir);
        const subjects = fs.readdirSync(gradePath).filter((s) => fs.statSync(path.join(gradePath, s)).isDirectory());

        for (const sDir of subjects) {
          const subjPath = path.join(gradePath, sDir);
          const files = fs.readdirSync(subjPath).filter((f) => f.endsWith('.json'));

          for (const f of files) {
            try {
              const fileContent = JSON.parse(fs.readFileSync(path.join(subjPath, f), 'utf-8'));
              const unitCode = f.replace('.json', '');

              const existing = await NoteSubmission.findOne({ unitCode });
              if (!existing) {
                await NoteSubmission.create({
                  grade: fileContent.grade,
                  subject: fileContent.subject,
                  subjectCode: fileContent.subjectCode,
                  unitNumber: fileContent.unitNumber,
                  unitCode,
                  unitTitle: fileContent.unitTitle,
                  examWeight: fileContent.examWeight,
                  summaryPoints: fileContent.summaryPoints || [],
                  formulas: fileContent.formulas || [],
                  examTip: fileContent.examTip || '',
                  keyDefinitions: fileContent.keyDefinitions || [],
                  eueeFocusTopics: fileContent.eueeFocusTopics || [],
                  status: 'approved',
                  contributorId: 'SYSTEM_FILE_SYNC',
                  submittedAt: new Date(),
                  reviewedAt: new Date(),
                  reviewNotes: 'Imported from local filesystem JSON',
                  rawPastedText: JSON.stringify(fileContent, null, 2),
                });
                importedCount++;
              }
            } catch (err: any) {
              logger.warn({ f, err: err.message }, 'Failed to parse local file during sync');
            }
          }
        }
      }
    }

    return { exportedCount, importedCount };
  }
}
