'use client';

import React from 'react';
import { SubmissionSummary } from '../../types/collector';
import { Badge } from '../ui/Badge';
import { Button } from '../ui/Button';
import { formatDate } from '../../lib/utils';
import { HugeiconsIcon } from '@hugeicons/react';
import { EyeIcon, CheckmarkCircle02Icon, Download01Icon } from '@hugeicons/core-free-icons';

interface SubmissionsTableProps {
  submissions: SubmissionSummary[];
  onInspect: (submission: SubmissionSummary) => void;
  onApprove: (submission: SubmissionSummary) => void;
  onExport: (unitCode: string) => void;
  approvingId?: string | null;
}

export function SubmissionsTable({
  submissions,
  onInspect,
  onApprove,
  onExport,
  approvingId,
}: SubmissionsTableProps) {
  if (submissions.length === 0) {
    return (
      <div className="p-8 text-center text-acedex-muted bg-acedex-card border border-acedex-border rounded-xl">
        No unit submissions match the selected filters.
      </div>
    );
  }

  return (
    <div className="hidden md:block overflow-x-auto rounded-xl border border-acedex-border bg-acedex-card shadow-sm">
      <table className="w-full text-left text-sm text-acedex-text border-collapse">
        <thead className="bg-acedex-bg/80 text-xs font-semibold uppercase text-acedex-muted border-b border-acedex-border">
          <tr>
            <th className="py-3.5 px-4">Unit Code</th>
            <th className="py-3.5 px-4">Unit Title</th>
            <th className="py-3.5 px-4">Contributor</th>
            <th className="py-3.5 px-4">Items</th>
            <th className="py-3.5 px-4">Submitted At</th>
            <th className="py-3.5 px-4">Status</th>
            <th className="py-3.5 px-4 text-right">Actions</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-acedex-border/60">
          {submissions.map((sub) => {
            const isApproved = sub.status === 'approved';
            const isApproving = approvingId === sub._id;

            return (
              <tr
                key={sub._id}
                className="hover:bg-acedex-card-hover/60 transition-colors"
              >
                <td className="py-3.5 px-4 font-mono font-semibold text-acedex-primary text-xs">
                  {sub.unitCode}
                </td>
                <td className="py-3.5 px-4 font-medium max-w-xs truncate">
                  <span className="text-xs text-acedex-muted mr-1.5 font-normal">
                    G{sub.grade} U{sub.unitNumber}:
                  </span>
                  {sub.unitTitle}
                </td>
                <td className="py-3.5 px-4 font-mono text-xs text-acedex-muted">
                  {sub.contributorId}
                </td>
                <td className="py-3.5 px-4 text-xs font-semibold">
                  {sub.questionCount} Qs
                </td>
                <td className="py-3.5 px-4 text-xs text-acedex-muted whitespace-nowrap">
                  {formatDate(sub.submittedAt)}
                </td>
                <td className="py-3.5 px-4">
                  <Badge status={sub.status} />
                </td>
                <td className="py-3.5 px-4 text-right whitespace-nowrap">
                  <div className="flex items-center justify-end gap-1.5">
                    <Button
                      size="sm"
                      variant="secondary"
                      className="h-8 text-xs px-2.5"
                      onClick={() => onInspect(sub)}
                      title="Inspect questions"
                    >
                      <HugeiconsIcon icon={EyeIcon} size={15} className="mr-1 text-acedex-primary" strokeWidth={1.5} /> Inspect
                    </Button>

                    {!isApproved && (
                      <Button
                        size="sm"
                        variant="success"
                        className="h-8 text-xs px-2.5"
                        onClick={() => onApprove(sub)}
                        loading={isApproving}
                        title="Approve Unit"
                      >
                        <HugeiconsIcon icon={CheckmarkCircle02Icon} size={15} className="mr-1" strokeWidth={1.75} /> Approve
                      </Button>
                    )}

                    {isApproved && (
                      <Button
                        size="sm"
                        variant="outline"
                        className="h-8 text-xs px-2.5 text-emerald-400 border-emerald-500/30 hover:bg-emerald-500/10"
                        onClick={() => onExport(sub.unitCode)}
                        title="Export canonical JSON"
                      >
                        <HugeiconsIcon icon={Download01Icon} size={15} className="mr-1" strokeWidth={1.5} /> Export
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
