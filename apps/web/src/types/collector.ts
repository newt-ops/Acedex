export type ContributorRole = 'student' | 'admin';

export type SubmissionStatus = 'not_started' | 'submitted' | 'approved' | 'rejected';

export interface ContributorProfile {
  contributorId: string;
  name: string;
  subjectCode: string;
  subjectName: string;
  role: ContributorRole;
}

export interface UnitProgressItem {
  unitCode: string;
  grade: number;
  unitNumber: number;
  unitTitle: string;
  status: SubmissionStatus;
  questionCount?: number;
  submittedAt?: string;
  approvedAt?: string;
  reviewNotes?: string;
}

export interface SubjectUnitsResponse {
  subjectCode: string;
  subjectName: string;
  contributorId: string;
  totalUnits: number;
  approvedUnits: number;
  submittedUnits: number;
  grades: {
    grade: number;
    units: UnitProgressItem[];
  }[];
}

export interface QuestionOption {
  id: string;
  text: string;
}

export interface QuestionItem {
  id: string;
  type: string;
  difficulty: string;
  question: string;
  options: QuestionOption[];
  correctOptionId: string;
  explanation: string;
  sourceReference?: string;
}

export interface SubmissionSummary {
  _id: string;
  unitCode: string;
  subjectCode: string;
  grade: number;
  unitNumber: number;
  unitTitle: string;
  contributorId: string;
  questionCount: number;
  status: SubmissionStatus;
  submittedAt: string;
  reviewedAt?: string;
  reviewNotes?: string;
}

export interface SubmissionDetail extends SubmissionSummary {
  questions: QuestionItem[];
  rawPastedText?: string;
}

export interface SanitizeResult {
  success: boolean;
  questionCount?: number;
  errors?: string[];
  warnings?: string[];
  fixesApplied?: string[];
  autoFixedIssues?: string[];
  questions?: QuestionItem[];
  parsedQuestions?: QuestionItem[];
}
