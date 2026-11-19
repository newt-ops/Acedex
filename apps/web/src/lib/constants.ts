export const DEFAULT_API_URL =
  process.env.NEXT_PUBLIC_API_URL || 'https://acedex-api.onrender.com';

export const GRADES = [9, 10, 11, 12] as const;

export const SUBJECTS: Record<string, string> = {
  GEO: 'Geography',
  PHY: 'Physics',
  CHE: 'Chemistry',
  BIO: 'Biology',
  MAT: 'Mathematics',
  ENG: 'English',
  ECO: 'Economics',
  HIS: 'History',
};

export const STATUS_LABELS: Record<string, string> = {
  not_started: 'Not Started',
  submitted: 'Under Review',
  approved: 'Approved',
  rejected: 'Rejected',
};

export const STATUS_BADGE_STYLES: Record<string, { bg: string; text: string; border: string }> = {
  approved: {
    bg: 'bg-emerald-50 dark:bg-emerald-950/40',
    text: 'text-emerald-800 dark:text-emerald-300',
    border: 'border-emerald-300 dark:border-emerald-800',
  },
  submitted: {
    bg: 'bg-amber-50 dark:bg-amber-950/40',
    text: 'text-amber-800 dark:text-amber-300',
    border: 'border-amber-300 dark:border-amber-800',
  },
  not_started: {
    bg: 'bg-acedex-card-hover',
    text: 'text-acedex-muted',
    border: 'border-acedex-border',
  },
  rejected: {
    bg: 'bg-rose-50 dark:bg-rose-950/40',
    text: 'text-rose-700 dark:text-rose-300',
    border: 'border-rose-300 dark:border-rose-800',
  },
};
