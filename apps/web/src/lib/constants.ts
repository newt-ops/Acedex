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
    bg: 'bg-emerald-500/15',
    text: 'text-emerald-400',
    border: 'border-emerald-500/30',
  },
  submitted: {
    bg: 'bg-amber-500/15',
    text: 'text-amber-400',
    border: 'border-amber-500/30',
  },
  not_started: {
    bg: 'bg-slate-800',
    text: 'text-slate-400',
    border: 'border-slate-700',
  },
  rejected: {
    bg: 'bg-rose-500/15',
    text: 'text-rose-400',
    border: 'border-rose-500/30',
  },
};
