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
  Loading01Icon,
} from '@hugeicons/core-free-icons';

interface NoteSubmissionsTableProps {
  submissions: NoteSubmissionSummary[];
  onInspect: (submission: NoteSubmissionSummary) => void;
  onApprove: (submission: NoteSubmissionSummary) => void;
  approvingId: string | null;
}

export function NoteSubmissionsTable({
  submissions,
  onInspect,
  onApprove,
  approvingId,
}: NoteSubmissionsTableProps) {
  if (submissions.length === 0) {
    return (
      <div className="hidden md:block p-12 text-center rounded-3xl bg-acedex-card/50 border border-acedex-border/60 text-acedex-muted">
        No quick note submissions match the selected filters.
      </div>
    );
  }

  return (
    <div className="hidden md:block overflow-hidden rounded-3xl border border-acedex-border/80 bg-acedex-card/90 shadow-md">
      <table className="w-full text-left text-xs">
        <thead className="bg-acedex-bg/80 border-b border-acedex-border/70 text-acedex-muted font-bold uppercase tracking-wider">
          <tr>
            <th className="py-3.5 px-4">Unit Code</th>
            <th className="py-3.5 px-4">Grade & Subject</th>
            <th className="py-3.5 px-4">Title</th>
            <th className="py-3.5 px-4 text-center">Payload Breakdown</th>
            <th className="py-3.5 px-4">Contributor</th>
            <th className="py-3.5 px-4">Status</th>
            <th className="py-3.5 px-4 text-right">Actions</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-acedex-border/60">
          {submissions.map((sub) => {
            const isApproving = approvingId === sub._id;
            return (
              <tr
                key={sub._id}
                className="hover:bg-acedex-card-hover/50 transition-colors cursor-pointer group"
                onClick={() => onInspect(sub)}
              >
                {/* Unit Code */}
                <td className="py-3.5 px-4 font-mono font-bold text-violet-400">
                  {sub.unitCode}
                </td>

                {/* Grade & Subject */}
                <td className="py-3.5 px-4 text-acedex-text font-medium">
                  Grade {sub.grade} • {sub.subjectCode}
                </td>

                {/* Title */}
                <td className="py-3.5 px-4 text-acedex-text font-semibold max-w-xs truncate">
                  Unit {sub.unitNumber}: {sub.unitTitle}
                </td>

                {/* Payload Breakdown */}
                <td className="py-3.5 px-4 text-center">
                  <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-xl bg-acedex-bg border border-acedex-border/60 text-[11px] font-mono">
                    <span title="Summary points" className="text-acedex-text">
                      {sub.summaryPointCount} pts
                    </span>
                    <span className="text-acedex-border">•</span>
                    <span title="Formulas" className="text-indigo-400">
                      {sub.formulaCount} fx
                    </span>
                    <span className="text-acedex-border">•</span>
                    <span title="Definitions" className="text-teal-400">
                      {sub.definitionCount} defs
                    </span>
                  </div>
                </td>

                {/* Contributor */}
                <td className="py-3.5 px-4 text-acedex-muted font-mono">
                  {sub.contributorId}
                </td>

                {/* Status */}
                <td className="py-3.5 px-4">
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
                </td>

                {/* Actions */}
                <td className="py-3.5 px-4 text-right" onClick={(e) => e.stopPropagation()}>
                  <div className="flex items-center justify-end gap-2">
                    <button
                      onClick={() => onInspect(sub)}
                      className="p-1.5 rounded-lg bg-acedex-bg hover:bg-acedex-card-hover text-acedex-muted hover:text-acedex-text border border-acedex-border transition-colors"
                      title="Inspect Note"
                    >
                      <HugeiconsIcon icon={EyeIcon} size={14} strokeWidth={2} />
                    </button>
                    {sub.status !== 'approved' && (
                      <Button
                        size="sm"
                        variant="primary"
                        onClick={() => onApprove(sub)}
                        loading={isApproving}
                        className="bg-emerald-600 hover:bg-emerald-500 text-white h-7 text-xs px-2.5"
                      >
                        Approve
                      </Button>
                    )}
                  </div>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
