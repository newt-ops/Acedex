'use client';

import React from 'react';
import { Card } from '../ui/Card';
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
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4 mb-6">
      {/* Total Submissions */}
      <Card className="p-4 sm:p-5 flex items-center justify-between">
        <div>
          <div className="text-xs sm:text-sm text-acedex-muted font-medium">
            Total Submissions
          </div>
          <div className="text-xl sm:text-2xl font-bold text-acedex-text mt-1">
            {total} <span className="text-xs text-acedex-muted font-normal">units</span>
          </div>
        </div>
        <div className="w-10 h-10 rounded-xl bg-acedex-primary/10 border border-acedex-primary/20 flex items-center justify-center text-acedex-primary shrink-0">
          <HugeiconsIcon icon={LayersIcon} size={20} strokeWidth={1.5} />
        </div>
      </Card>

      {/* Pending Review */}
      <Card className="p-4 sm:p-5 flex items-center justify-between">
        <div>
          <div className="text-xs sm:text-sm text-amber-500 font-medium">
            Pending Review
          </div>
          <div className="text-xl sm:text-2xl font-bold text-amber-500 mt-1">
            {pending} <span className="text-xs text-amber-500/70 font-normal">queued</span>
          </div>
        </div>
        <div className="w-10 h-10 rounded-xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-500 shrink-0">
          <HugeiconsIcon icon={Clock01Icon} size={20} strokeWidth={1.5} />
        </div>
      </Card>

      {/* Approved Units */}
      <Card className="p-4 sm:p-5 flex items-center justify-between">
        <div>
          <div className="text-xs sm:text-sm text-emerald-500 font-medium">
            Approved Units
          </div>
          <div className="text-xl sm:text-2xl font-bold text-emerald-500 mt-1">
            {approved} <span className="text-xs text-emerald-500/70 font-normal">units</span>
          </div>
        </div>
        <div className="w-10 h-10 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-500 shrink-0">
          <HugeiconsIcon icon={CheckmarkCircle02Icon} size={20} strokeWidth={1.75} />
        </div>
      </Card>

      {/* Total Questions Verified */}
      <Card className="p-4 sm:p-5 flex items-center justify-between">
        <div>
          <div className="text-xs sm:text-sm text-acedex-accent font-medium">
            Total Ingested
          </div>
          <div className="text-xl sm:text-2xl font-bold text-acedex-text mt-1">
            {totalQuestions} <span className="text-xs text-acedex-muted font-normal">questions</span>
          </div>
        </div>
        <div className="w-10 h-10 rounded-xl bg-acedex-accent/10 border border-acedex-accent/20 flex items-center justify-center text-acedex-accent shrink-0">
          <HugeiconsIcon icon={TrendingUpIcon} size={20} strokeWidth={1.5} />
        </div>
      </Card>
    </div>
  );
}
