'use client';

import React from 'react';
import { UnitProgressItem } from '../../types/collector';
import { Card } from '../ui/Card';
import { Badge } from '../ui/Badge';
import { Button } from '../ui/Button';
import { formatDate } from '../../lib/utils';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  CheckmarkCircle02Icon,
  CloudUploadIcon,
  Clock01Icon,
  PencilEdit01Icon,
  BookOpen01Icon,
} from '@hugeicons/core-free-icons';

interface UnitCardProps {
  unit: UnitProgressItem;
  onOpenSubmit: (unit: UnitProgressItem) => void;
}

export function UnitCard({ unit, onOpenSubmit }: UnitCardProps) {
  const isApproved = unit.status === 'approved';
  const isSubmitted = unit.status === 'submitted';
  const isNotStarted = unit.status === 'not_started';

  return (
    <Card
      className={`transition-all duration-200 hover:border-acedex-primary/50 flex flex-col justify-between ${
        isApproved
          ? 'border-emerald-500/30 bg-acedex-card/90'
          : isSubmitted
          ? 'border-amber-500/30 bg-acedex-card/90'
          : 'border-acedex-border'
      }`}
    >
      <div className="p-4 sm:p-5">
        {/* Header: Unit Code & Status Badge */}
        <div className="flex items-center justify-between gap-2 mb-3">
          <span className="font-mono text-xs px-2.5 py-1 rounded-md bg-acedex-bg border border-acedex-border text-acedex-primary font-semibold">
            {unit.unitCode}
          </span>
          <Badge status={unit.status} />
        </div>

        {/* Unit Title */}
        <h4 className="text-sm sm:text-base font-semibold text-acedex-text leading-snug line-clamp-2 mb-2 flex items-start gap-2">
          <HugeiconsIcon icon={BookOpen01Icon} size={16} className="text-acedex-muted shrink-0 mt-0.5" strokeWidth={1.5} />
          <span>
            Unit {unit.unitNumber}: {unit.unitTitle}
          </span>
        </h4>

        {/* Submission meta / notes */}
        <div className="text-xs text-acedex-muted space-y-1 mt-3 pt-3 border-t border-acedex-border/40">
          {isApproved && (
            <div className="flex items-center gap-1.5 text-emerald-500 font-medium">
              <HugeiconsIcon icon={CheckmarkCircle02Icon} size={15} strokeWidth={1.75} />
              <span>Approved ({unit.questionCount || 15} questions)</span>
            </div>
          )}

          {isSubmitted && (
            <div className="flex items-center gap-1.5 text-amber-500">
              <HugeiconsIcon icon={Clock01Icon} size={15} strokeWidth={1.75} />
              <span>Submitted {formatDate(unit.submittedAt)}</span>
            </div>
          )}

          {isNotStarted && (
            <div className="text-acedex-muted italic">
              No questions submitted yet. (Target: 15 items)
            </div>
          )}

          {unit.reviewNotes && (
            <p className="text-xs text-amber-300 bg-amber-500/10 p-2 rounded border border-amber-500/20 mt-1">
              Admin Note: {unit.reviewNotes}
            </p>
          )}
        </div>
      </div>

      {/* Action Footer */}
      <div className="p-3 sm:p-4 bg-acedex-card/50 border-t border-acedex-border/50 flex items-center justify-end">
        {isApproved ? (
          <Button
            size="sm"
            variant="outline"
            className="w-full text-xs text-emerald-500 border-emerald-500/30 hover:bg-emerald-500/10"
            icon={
              <HugeiconsIcon
                icon={CheckmarkCircle02Icon}
                size={15}
                strokeWidth={1.75}
                className="shrink-0"
              />
            }
            onClick={() => onOpenSubmit(unit)}
          >
            View / Replace
          </Button>
        ) : isSubmitted ? (
          <Button
            size="sm"
            variant="secondary"
            className="w-full text-xs text-amber-500 border-amber-500/30 hover:bg-amber-500/10"
            icon={
              <HugeiconsIcon
                icon={PencilEdit01Icon}
                size={15}
                strokeWidth={1.5}
                className="shrink-0"
              />
            }
            onClick={() => onOpenSubmit(unit)}
          >
            Re-paste / Update
          </Button>
        ) : (
          <Button
            size="sm"
            variant="primary"
            className="w-full text-xs"
            icon={
              <HugeiconsIcon
                icon={CloudUploadIcon}
                size={15}
                strokeWidth={1.5}
                className="shrink-0"
              />
            }
            onClick={() => onOpenSubmit(unit)}
          >
            Submit Questions
          </Button>
        )}
      </div>
    </Card>
  );
}
