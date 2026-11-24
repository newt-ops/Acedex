'use client';

import React from 'react';
import { NoteSubmissionSummary } from '../../types/notes-collector';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  BookOpen01Icon,
  CheckmarkCircle02Icon,
  Clock01Icon,
  AlertCircleIcon,
} from '@hugeicons/core-free-icons';

interface NoteAdminStatsHeaderProps {
  submissions: NoteSubmissionSummary[];
}

export function NoteAdminStatsHeader({ submissions }: NoteAdminStatsHeaderProps) {
  const total = submissions.length;
  const pending = submissions.filter((s) => s.status === 'submitted').length;
  const approved = submissions.filter((s) => s.status === 'approved').length;
  const rejected = submissions.filter((s) => s.status === 'rejected').length;

  return (
    <section className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4 sm:gap-5">
      {/* Card 1: Total Submitted */}
      <div className="admin-surface kpi-card p-5 sm:p-6 flex items-center justify-between gap-4">
        <div>
          <div className="text-[11px] font-bold tracking-[0.06em] uppercase text-slate-400">
            Total Submitted
          </div>
          <div className="mt-2 font-display text-[28px] font-extrabold tabular-nums text-slate-900 leading-none">
            {total}
          </div>
          <div className="mt-1.5 text-[12px] text-slate-400">across curriculum</div>
        </div>
        <div className="w-11 h-11 rounded-[14px] bg-purple-50 border border-purple-200/70 flex items-center justify-center text-[#7E22CE] shrink-0">
          <HugeiconsIcon icon={BookOpen01Icon} size={20} strokeWidth={1.9} />
        </div>
      </div>

      {/* Card 2: Pending Review */}
      <div className="admin-surface kpi-card p-5 sm:p-6 flex items-center justify-between gap-4 border-amber-200/80">
        <div>
          <div className="text-[11px] font-bold tracking-[0.06em] uppercase text-amber-500">
            Pending Review
          </div>
          <div className="mt-2 font-display text-[28px] font-extrabold tabular-nums text-amber-500 leading-none">
            {pending}
          </div>
          <div className="mt-1.5 text-[12px] text-amber-500/80">awaiting verification</div>
        </div>
        <div className="w-11 h-11 rounded-[14px] bg-amber-50 border border-amber-200/75 flex items-center justify-center text-amber-500 shrink-0">
          <HugeiconsIcon icon={Clock01Icon} size={20} strokeWidth={1.9} />
        </div>
      </div>

      {/* Card 3: Approved Notes */}
      <div className="admin-surface kpi-card p-5 sm:p-6 flex items-center justify-between gap-4 border-emerald-200/80">
        <div>
          <div className="text-[11px] font-bold tracking-[0.06em] uppercase text-emerald-500">
            Approved Notes
          </div>
          <div className="mt-2 font-display text-[28px] font-extrabold tabular-nums text-emerald-500 leading-none">
            {approved}
          </div>
          <div className="mt-1.5 text-[12px] text-emerald-500/80">ready for study</div>
        </div>
        <div className="w-11 h-11 rounded-[14px] bg-emerald-50 border border-emerald-200/75 flex items-center justify-center text-emerald-500 shrink-0">
          <HugeiconsIcon icon={CheckmarkCircle02Icon} size={20} strokeWidth={2} />
        </div>
      </div>

      {/* Card 4: Revisions Needed */}
      <div className="admin-surface kpi-card p-5 sm:p-6 flex items-center justify-between gap-4 border-rose-200/80">
        <div>
          <div className="text-[11px] font-bold tracking-[0.06em] uppercase text-rose-500">
            Revisions Needed
          </div>
          <div className="mt-2 font-display text-[28px] font-extrabold tabular-nums text-rose-500 leading-none">
            {rejected}
          </div>
          <div className="mt-1.5 text-[12px] text-rose-400">feedback sent back</div>
        </div>
        <div className="w-11 h-11 rounded-[14px] bg-rose-50 border border-rose-200/75 flex items-center justify-center text-rose-500 shrink-0">
          <HugeiconsIcon icon={AlertCircleIcon} size={20} strokeWidth={2} />
        </div>
      </div>
    </section>
  );
}
