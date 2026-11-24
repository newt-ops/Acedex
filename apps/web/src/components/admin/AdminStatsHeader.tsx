'use client';

import React from 'react';
import { SubmissionSummary } from '../../types/collector';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  LayersIcon,
  Clock01Icon,
  CheckmarkCircle02Icon,
  TrendingUpIcon,
} from '@hugeicons/core-free-icons';

interface AdminStatsHeaderProps {
  submissions: SubmissionSummary[];
}

export function AdminStatsHeader({ submissions }: AdminStatsHeaderProps) {
  const total = submissions.length;
  const approved = submissions.filter((s) => s.status === 'approved').length;
  const pending = submissions.filter((s) => s.status === 'submitted').length;
  const totalQuestions = submissions.reduce((acc, s) => acc + (s.questionCount || 0), 0);

  return (
    <section className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4 sm:gap-5">
      {/* Card 1: Total Submissions */}
      <div className="admin-surface kpi-card p-5 sm:p-6 flex items-center justify-between gap-4">
        <div>
          <div className="text-[11px] font-bold tracking-[0.06em] uppercase text-slate-400">
            Total Submissions
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span className="font-display text-[28px] font-extrabold tabular-nums text-slate-900 leading-none">
              {total}
            </span>
            <span className="text-[12.5px] font-medium text-slate-400">units</span>
          </div>
        </div>
        <div className="w-11 h-11 rounded-[14px] bg-purple-50 border border-purple-200/70 flex items-center justify-center text-[#7E22CE] shrink-0">
          <HugeiconsIcon icon={LayersIcon} size={20} strokeWidth={1.8} />
        </div>
      </div>

      {/* Card 2: Pending Review */}
      <div className="admin-surface kpi-card p-5 sm:p-6 flex items-center justify-between gap-4 border-amber-200/70">
        <div>
          <div className="text-[11px] font-bold tracking-[0.06em] uppercase text-amber-500">
            Pending Review
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span className="font-display text-[28px] font-extrabold tabular-nums text-amber-500 leading-none">
              {pending}
            </span>
            <span className="text-[12.5px] font-medium text-amber-500/80">queued</span>
          </div>
        </div>
        <div className="w-11 h-11 rounded-[14px] bg-amber-50 border border-amber-200/75 flex items-center justify-center text-amber-500 shrink-0">
          <HugeiconsIcon icon={Clock01Icon} size={20} strokeWidth={1.8} />
        </div>
      </div>

      {/* Card 3: Approved Units */}
      <div className="admin-surface kpi-card p-5 sm:p-6 flex items-center justify-between gap-4 border-emerald-200/70">
        <div>
          <div className="text-[11px] font-bold tracking-[0.06em] uppercase text-emerald-500">
            Approved Units
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span className="font-display text-[28px] font-extrabold tabular-nums text-emerald-500 leading-none">
              {approved}
            </span>
            <span className="text-[12.5px] font-medium text-emerald-500/80">units</span>
          </div>
        </div>
        <div className="w-11 h-11 rounded-[14px] bg-emerald-50 border border-emerald-200/75 flex items-center justify-center text-emerald-500 shrink-0">
          <HugeiconsIcon icon={CheckmarkCircle02Icon} size={20} strokeWidth={2} />
        </div>
      </div>

      {/* Card 4: Total Questions Ingested */}
      <div className="admin-surface kpi-card p-5 sm:p-6 flex items-center justify-between gap-4">
        <div>
          <div className="text-[11px] font-bold tracking-[0.06em] uppercase text-[#7E22CE]">
            Total Ingested
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span className="font-display text-[28px] font-extrabold tabular-nums text-slate-900 leading-none">
              {totalQuestions}
            </span>
            <span className="text-[12.5px] font-medium text-slate-400">questions</span>
          </div>
        </div>
        <div className="w-11 h-11 rounded-[14px] bg-purple-50 border border-purple-200/75 flex items-center justify-center text-[#7E22CE] shrink-0">
          <HugeiconsIcon icon={TrendingUpIcon} size={20} strokeWidth={1.8} />
        </div>
      </div>
    </section>
  );
}
