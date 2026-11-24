'use client';

import React from 'react';
import { NoteSubmissionSummary } from '../../types/notes-collector';
import { Button } from '../ui/Button';
import { formatDate } from '../../lib/utils';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  CheckmarkCircle02Icon,
  EyeIcon,
  Clock01Icon,
  AlertCircleIcon,
} from '@hugeicons/core-free-icons';

interface NoteSubmissionsMobileCardsProps {
  submissions: NoteSubmissionSummary[];
  onInspect: (submission: NoteSubmissionSummary) => void;
  onApprove: (submission: NoteSubmissionSummary) => void;
  approvingId: string | null;
}

export function NoteSubmissionsMobileCards({
  submissions,
  onInspect,
  onApprove,
  approvingId,
}: NoteSubmissionsMobileCardsProps) {
  if (submissions.length === 0) {
    return (
      <div className="md:hidden p-8 text-center rounded-2xl bg-acedex-card/50 border border-acedex-border/60 text-acedex-muted text-xs">
        No quick note submissions match the selected filters.
      </div>
    );
  }

  return (
    <div className="md:hidden space-y-3">
      {submissions.map((sub) => {
        const isApproving = approvingId === sub._id;
        return (
          <div
            key={sub._id}
            onClick={() => onInspect(sub)}
            className="p-4 rounded-2xl bg-acedex-card/90 border border-acedex-border/80 shadow-sm space-y-3 cursor-pointer hover:border-acedex-primary/40 transition-all"
          >
            {/* Top Bar: Code & Status */}
            <div className="flex items-center justify-between gap-2">
              <span className="px-2.5 py-0.5 rounded-lg text-xs font-mono font-bold bg-acedex-bg border border-acedex-border text-acedex-primary">
                {sub.unitCode}
              </span>
              <div>
                {sub.status === 'approved' && (
                  <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
                    <HugeiconsIcon icon={CheckmarkCircle02Icon} size={12} strokeWidth={2} />
                    <span>Approved</span>
                  </span>
                )}
                {sub.status === 'submitted' && (
                  <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-500/15 text-amber-400 border border-amber-500/30">
                    <HugeiconsIcon icon={Clock01Icon} size={12} strokeWidth={2} />
                    <span>Pending</span>
                  </span>
                )}
                {sub.status === 'rejected' && (
                  <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-rose-500/15 text-rose-400 border border-rose-500/30">
                    <HugeiconsIcon icon={AlertCircleIcon} size={12} strokeWidth={2} />
                    <span>Revision</span>
                  </span>
                )}
              </div>
            </div>

            {/* Title & Metadata */}
            <div>
              <h4 className="text-sm font-bold text-acedex-text line-clamp-2">
                Unit {sub.unitNumber}: {sub.unitTitle}
              </h4>
              <p className="text-xs text-acedex-muted mt-1">
                Grade {sub.grade} • {sub.subjectCode} • By {sub.contributorId}
              </p>
            </div>

            {/* Metrics Chips */}
            <div className="flex items-center gap-2 text-xs font-mono">
              <span className="px-2 py-1 rounded-lg bg-acedex-bg border border-acedex-border text-acedex-text">
                {sub.summaryPointCount} points
              </span>
              <span className="px-2 py-1 rounded-lg bg-acedex-bg border border-acedex-border text-acedex-accent">
                {sub.formulaCount} formulas
              </span>
              <span className="px-2 py-1 rounded-lg bg-acedex-bg border border-acedex-border text-teal-400">
                {sub.definitionCount} terms
              </span>
            </div>

            {/* Actions */}
            <div
              className="flex items-center justify-between gap-2 pt-2 border-t border-acedex-border/60"
              onClick={(e) => e.stopPropagation()}
            >
              <button
                onClick={() => onInspect(sub)}
                className="text-xs text-acedex-muted hover:text-acedex-text font-semibold flex items-center gap-1"
              >
                <HugeiconsIcon icon={EyeIcon} size={14} strokeWidth={2} />
                <span>View Full Note</span>
              </button>

              {sub.status !== 'approved' && (
                <Button
                  size="sm"
                  variant="primary"
                  onClick={() => onApprove(sub)}
                  loading={isApproving}
                  className="bg-emerald-600 hover:bg-emerald-500 text-white h-8 text-xs px-3"
                >
                  Approve
                </Button>
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
}
