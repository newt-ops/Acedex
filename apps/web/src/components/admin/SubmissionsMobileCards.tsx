'use client';

import React from 'react';
import { SubmissionSummary } from '../../types/collector';
import { Card } from '../ui/Card';
import { Badge } from '../ui/Badge';
import { Button } from '../ui/Button';
import { formatDate } from '../../lib/utils';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  EyeIcon,
  CheckmarkCircle02Icon,
  Download01Icon,
  UserIcon,
  Calendar01Icon,
} from '@hugeicons/core-free-icons';

interface SubmissionsMobileCardsProps {
  submissions: SubmissionSummary[];
  onInspect: (submission: SubmissionSummary) => void;
  onApprove: (submission: SubmissionSummary) => void;
  onExport: (unitCode: string) => void;
  approvingId?: string | null;
}

export function SubmissionsMobileCards({
  submissions,
  onInspect,
  onApprove,
  onExport,
  approvingId,
}: SubmissionsMobileCardsProps) {
  if (submissions.length === 0) {
    return (
      <div className="md:hidden p-6 text-center text-acedex-muted bg-acedex-card border border-acedex-border rounded-xl text-sm">
        No submissions match the current filters.
      </div>
    );
  }

  return (
    <div className="md:hidden space-y-3">
      {submissions.map((sub) => {
        const isApproved = sub.status === 'approved';
        const isApproving = approvingId === sub._id;

        return (
          <Card
            key={sub._id}
            className={`p-4 border transition-all ${
              isApproved
                ? 'border-emerald-500/30'
                : 'border-acedex-border'
            }`}
          >
            {/* Top row: Unit code & status */}
            <div className="flex items-center justify-between gap-2 mb-2">
              <span className="font-mono text-xs px-2 py-0.5 rounded bg-acedex-bg border border-acedex-border text-acedex-primary font-bold">
                {sub.unitCode}
              </span>
              <Badge status={sub.status} />
            </div>

            {/* Title */}
            <h4 className="font-semibold text-sm text-acedex-text line-clamp-2 mb-2">
              Grade {sub.grade} Unit {sub.unitNumber}: {sub.unitTitle}
            </h4>

            {/* Meta row */}
            <div className="flex items-center justify-between text-xs text-acedex-muted mb-3 pt-2 border-t border-acedex-border/40">
              <div className="flex items-center gap-1">
                <HugeiconsIcon icon={UserIcon} size={14} className="text-acedex-muted shrink-0" strokeWidth={1.5} />
                <span className="font-mono">{sub.contributorId}</span>
              </div>
              <div className="flex items-center gap-1">
                <HugeiconsIcon icon={Calendar01Icon} size={14} className="text-acedex-muted shrink-0" strokeWidth={1.5} />
                <span>{formatDate(sub.submittedAt)}</span>
              </div>
            </div>

            {/* Action buttons (Touch targets >= 44px) */}
            <div className="grid grid-cols-2 gap-2 pt-2 border-t border-acedex-border/50">
              <Button
                size="sm"
                variant="secondary"
                className="w-full text-xs px-2 truncate min-h-[40px]"
                icon={
                  <HugeiconsIcon
                    icon={EyeIcon}
                    size={14}
                    className="text-acedex-primary shrink-0"
                    strokeWidth={1.5}
                  />
                }
                onClick={() => onInspect(sub)}
              >
                Inspect ({sub.questionCount})
              </Button>

              {!isApproved ? (
                <Button
                  size="sm"
                  variant="success"
                  className="w-full text-xs px-2 min-h-[40px]"
                  icon={
                    <HugeiconsIcon
                      icon={CheckmarkCircle02Icon}
                      size={14}
                      strokeWidth={1.75}
                      className="shrink-0"
                    />
                  }
                  onClick={() => onApprove(sub)}
                  loading={isApproving}
                >
                  Approve
                </Button>
              ) : (
                <Button
                  size="sm"
                  variant="outline"
                  className="w-full text-xs px-2 text-emerald-500 border-emerald-500/30 hover:bg-emerald-500/10 min-h-[40px]"
                  icon={
                    <HugeiconsIcon
                      icon={Download01Icon}
                      size={14}
                      strokeWidth={1.5}
                      className="shrink-0"
                    />
                  }
                  onClick={() => onExport(sub.unitCode)}
                >
                  Export JSON
                </Button>
              )}
            </div>
          </Card>
        );
      })}
    </div>
  );
}
