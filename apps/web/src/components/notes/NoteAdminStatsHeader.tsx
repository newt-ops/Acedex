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
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
      {/* Total Submissions */}
      <div className="p-4 sm:p-5 rounded-2xl bg-acedex-card/90 border border-acedex-border/80 shadow-sm flex items-center justify-between">
        <div className="space-y-1">
          <span className="text-xs font-semibold text-acedex-muted uppercase tracking-wider block">
            Total Submitted
          </span>
          <span className="text-2xl sm:text-3xl font-black text-acedex-text tracking-tight">
            {total}
          </span>
          <span className="text-[11px] text-acedex-muted block">across curriculum</span>
        </div>
        <div className="w-10 h-10 rounded-xl bg-acedex-primary/10 text-acedex-primary border border-acedex-primary/20 flex items-center justify-center shrink-0">
          <HugeiconsIcon icon={BookOpen01Icon} size={20} strokeWidth={2} />
        </div>
      </div>

      {/* Pending Review */}
      <div className="p-4 sm:p-5 rounded-2xl bg-acedex-card/90 border border-amber-500/30 shadow-sm flex items-center justify-between">
        <div className="space-y-1">
          <span className="text-xs font-semibold text-amber-400 uppercase tracking-wider block">
            Pending Review
          </span>
          <span className="text-2xl sm:text-3xl font-black text-amber-300 tracking-tight">
            {pending}
          </span>
          <span className="text-[11px] text-amber-400/80 block">awaiting verification</span>
        </div>
        <div className="w-10 h-10 rounded-xl bg-amber-500/10 text-amber-400 border border-amber-500/20 flex items-center justify-center shrink-0">
          <HugeiconsIcon icon={Clock01Icon} size={20} strokeWidth={2} />
        </div>
      </div>

      {/* Approved */}
      <div className="p-4 sm:p-5 rounded-2xl bg-acedex-card/90 border border-emerald-500/30 shadow-sm flex items-center justify-between">
        <div className="space-y-1">
          <span className="text-xs font-semibold text-emerald-400 uppercase tracking-wider block">
            Approved Notes
          </span>
          <span className="text-2xl sm:text-3xl font-black text-emerald-300 tracking-tight">
            {approved}
          </span>
          <span className="text-[11px] text-emerald-400/80 block">ready for study</span>
        </div>
        <div className="w-10 h-10 rounded-xl bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 flex items-center justify-center shrink-0">
          <HugeiconsIcon icon={CheckmarkCircle02Icon} size={20} strokeWidth={2} />
        </div>
      </div>

      {/* Revisions Needed */}
      <div className="p-4 sm:p-5 rounded-2xl bg-acedex-card/90 border border-rose-500/30 shadow-sm flex items-center justify-between">
        <div className="space-y-1">
          <span className="text-xs font-semibold text-rose-400 uppercase tracking-wider block">
            Revisions Needed
          </span>
          <span className="text-2xl sm:text-3xl font-black text-rose-300 tracking-tight">
            {rejected}
          </span>
          <span className="text-[11px] text-rose-400/80 block">feedback sent back</span>
        </div>
        <div className="w-10 h-10 rounded-xl bg-rose-500/10 text-rose-400 border border-rose-500/20 flex items-center justify-center shrink-0">
          <HugeiconsIcon icon={AlertCircleIcon} size={20} strokeWidth={2} />
        </div>
      </div>
    </div>
  );
}
