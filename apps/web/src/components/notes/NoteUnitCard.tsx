'use client';

import React from 'react';
import { NoteUnitProgressItem } from '../../types/notes-collector';
import { Card, CardContent } from '../ui/Card';
import { Button } from '../ui/Button';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  CheckmarkCircle02Icon,
  Clock01Icon,
  AlertCircleIcon,
  ArrowRight01Icon,
  FileCodeIcon,
  BookOpen01Icon,
  SparklesIcon,
} from '@hugeicons/core-free-icons';

interface NoteUnitCardProps {
  unit: NoteUnitProgressItem;
  onSubmitClick: (unit: NoteUnitProgressItem) => void;
}

export function NoteUnitCard({ unit, onSubmitClick }: NoteUnitCardProps) {
  const isApproved = unit.status === 'approved';
  const isSubmitted = unit.status === 'submitted';
  const isRejected = unit.status === 'rejected';

  // Status Badge Styling
  const getStatusBadge = () => {
    if (isApproved) {
      return (
        <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
          <HugeiconsIcon icon={CheckmarkCircle02Icon} size={13} strokeWidth={2} />
          <span>Approved</span>
        </span>
      );
    }
    if (isSubmitted) {
      return (
        <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-amber-500/15 text-amber-400 border border-amber-500/30">
          <HugeiconsIcon icon={Clock01Icon} size={13} strokeWidth={2} />
          <span>Submitted</span>
        </span>
      );
    }
    if (isRejected) {
      return (
        <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-rose-500/15 text-rose-400 border border-rose-500/30">
          <HugeiconsIcon icon={AlertCircleIcon} size={13} strokeWidth={2} />
          <span>Revision Needed</span>
        </span>
      );
    }
    return (
      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-slate-500/15 text-slate-400 border border-slate-500/30">
        <span>Not Started</span>
      </span>
    );
  };

  return (
    <Card className="group hover:border-acedex-primary/50 transition-all duration-300 ease-out bg-acedex-card/90 backdrop-blur-sm border-acedex-border/80 shadow-sm hover:shadow-lg hover:shadow-acedex-primary/10 flex flex-col justify-between hover:-translate-y-0.5">
      <CardContent className="p-5 flex-1 flex flex-col justify-between space-y-4">
        <div>
          {/* Top Bar: Unit Code Badge & Status */}
          <div className="flex items-center justify-between gap-2 mb-3">
            <span className="px-2.5 py-1 rounded-lg text-xs font-mono font-bold bg-acedex-card border border-acedex-border text-acedex-muted">
              {unit.unitCode}
            </span>
            {getStatusBadge()}
          </div>

          {/* Unit Number & Title */}
          <h3 className="text-base font-bold text-acedex-text group-hover:text-acedex-primary transition-colors line-clamp-2">
            Unit {unit.unitNumber}: {unit.unitTitle}
          </h3>
        </div>

        {/* Content Metrics Breakdown */}
        <div className="space-y-2.5 pt-2 border-t border-acedex-border/50">
          <div className="grid grid-cols-3 gap-2 text-center">
            <div className="p-2 rounded-xl bg-acedex-bg/60 border border-acedex-border/50">
              <span className="block text-xs font-bold text-acedex-text">
                {unit.summaryPointCount || 0}
              </span>
              <span className="text-[10px] text-acedex-muted uppercase font-medium">
                Points
              </span>
            </div>
            <div className="p-2 rounded-xl bg-acedex-bg/60 border border-acedex-border/50">
              <span className="block text-xs font-bold text-acedex-text">
                {unit.formulaCount || 0}
              </span>
              <span className="text-[10px] text-acedex-muted uppercase font-medium">
                Formulas
              </span>
            </div>
            <div className="p-2 rounded-xl bg-acedex-bg/60 border border-acedex-border/50">
              <span className="block text-xs font-bold text-acedex-text">
                {unit.definitionCount || 0}
              </span>
              <span className="text-[10px] text-acedex-muted uppercase font-medium">
                Terms
              </span>
            </div>
          </div>

          {/* Revision feedback banner if rejected */}
          {isRejected && unit.reviewNotes && (
            <div className="p-3 rounded-xl bg-rose-500/10 border border-rose-500/20 text-xs text-rose-300">
              <span className="font-semibold block mb-0.5">Admin Feedback:</span>
              <p className="line-clamp-2">{unit.reviewNotes}</p>
            </div>
          )}
        </div>

        {/* Action Button */}
        <Button
          onClick={() => onSubmitClick(unit)}
          variant={isApproved ? 'outline' : isSubmitted ? 'secondary' : 'primary'}
          size="sm"
          className="w-full justify-between group-hover:shadow-md"
        >
          <span>
            {isApproved
              ? 'View / Update Note'
              : isSubmitted
              ? 'Review Submission'
              : isRejected
              ? 'Fix & Re-Submit'
              : 'Submit Quick Note'}
          </span>
          <HugeiconsIcon icon={ArrowRight01Icon} size={15} className="transition-transform group-hover:translate-x-0.5" />
        </Button>
      </CardContent>
    </Card>
  );
}
