import { SubmissionStatus } from './collector';

export interface NoteFormula {
  label: string;
  expr: string;
}

export interface NoteDefinition {
  term: string;
  definition: string;
}

export interface QuickNoteData {
  grade: number;
  subject: string;
  subjectCode: string;
  unitNumber: number;
  unitCode: string;
  unitTitle: string;
  examWeight?: string;
  summaryPoints: string[];
  formulas: NoteFormula[];
  examTip: string;
  keyDefinitions: NoteDefinition[];
  eueeFocusTopics: string[];
}

export interface NoteUnitProgressItem {
  unitCode: string;
  grade: number;
  unitNumber: number;
  unitTitle: string;
  status: SubmissionStatus;
  summaryPointCount?: number;
  formulaCount?: number;
  definitionCount?: number;
  submittedAt?: string;
  approvedAt?: string;
  reviewNotes?: string;
}

export interface NoteSubjectUnitsResponse {
  subjectCode: string;
  subjectName: string;
  contributorId: string;
  totalUnits: number;
  approvedUnits: number;
  submittedUnits: number;
  grades: {
    grade: number;
    units: NoteUnitProgressItem[];
  }[];
}

export interface NoteSanitizeResult {
  success: boolean;
  errors?: string[];
  warnings?: string[];
  fixesApplied?: string[];
  autoFixedIssues?: string[];
  note?: QuickNoteData;
  notes?: QuickNoteData[];
  unitCount?: number;
}

export interface SubmitGradeNotesResult {
  submittedCount: number;
  units: string[];
}

export interface NoteSubmissionSummary {
  _id: string;
  unitCode: string;
  subjectCode: string;
  grade: number;
  unitNumber: number;
  unitTitle: string;
  contributorId: string;
  status: SubmissionStatus;
  summaryPointCount: number;
  formulaCount: number;
  definitionCount: number;
  submittedAt: string;
  reviewedAt?: string;
  reviewNotes?: string;
}

export interface NoteSubmissionDetail extends NoteSubmissionSummary {
  note: QuickNoteData;
  rawPastedText?: string;
}
