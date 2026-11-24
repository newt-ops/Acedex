'use client';

import React from 'react';
import { NoteUnitProgressItem } from '../../types/notes-collector';
import { Card, CardContent } from '../ui/Card';
import { Button } from '../ui/Button';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  BookOpen01Icon,
  CheckmarkCircle02Icon,
  ArrowRight01Icon,
  Upload01Icon,
  Clock01Icon,
} from '@hugeicons/core-free-icons';

interface GradeNoteCardProps {
  grade: number;
  subjectName: string;
  units: NoteUnitProgressItem[];
  isSelected: boolean;
  onSelectGrade: (grade: number) => void;
  onSubmitGradeClick: (grade: number) => void;
}

export function GradeNoteCard({
  grade,
  subjectName,
  units,
  isSelected,
  onSelectGrade,
  onSubmitGradeClick,
}: GradeNoteCardProps) {
  const totalUnits = units.length;
  const approvedUnits = units.filter((u) => u.status === 'approved').length;
  const submittedUnits = units.filter((u) => u.status === 'submitted').length;
  const percent = totalUnits > 0 ? Math.round((approvedUnits / totalUnits) * 100) : 0;
  const isAllApproved = totalUnits > 0 && approvedUnits === totalUnits;

  return (
    <Card
      onClick={() => onSelectGrade(grade)}
      className={`group cursor-pointer transition-all duration-300 ease-out bg-acedex-card/90 backdrop-blur-sm border shadow-sm hover:shadow-lg flex flex-col justify-between hover:-translate-y-1 ${
        isSelected
          ? 'border-acedex-primary ring-2 ring-acedex-primary/20 shadow-acedex-primary/10'
          : 'border-acedex-border/80 hover:border-acedex-primary/50'
      }`}
    >
      <CardContent className="p-5 sm:p-6 flex-1 flex flex-col justify-between space-y-4">
        <div>
          {/* Top Bar: Grade Badge & Coverage Tag */}
          <div className="flex items-center justify-between gap-2 mb-3">
            <span
              className={`px-3 py-1 rounded-xl text-xs font-bold font-mono transition-colors ${
                isSelected
                  ? 'bg-acedex-primary text-white shadow-sm'
                  : 'bg-acedex-primary/10 text-acedex-primary border border-acedex-primary/20'
              }`}
            >
              Grade {grade}
            </span>

            {isAllApproved ? (
              <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
                <HugeiconsIcon icon={CheckmarkCircle02Icon} size={12} strokeWidth={2} />
                <span>All Complete</span>
              </span>
            ) : submittedUnits > 0 ? (
              <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-500/15 text-amber-400 border border-amber-500/30">
                <HugeiconsIcon icon={Clock01Icon} size={12} strokeWidth={2} />
                <span>In Review</span>
              </span>
            ) : (
              <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-acedex-bg border border-acedex-border text-acedex-muted">
                <span>{percent}% Covered</span>
              </span>
            )}
          </div>

          {/* Title */}
          <h3 className="text-base sm:text-lg font-bold text-acedex-text group-hover:text-acedex-primary transition-colors">
            Grade {grade} {subjectName}
          </h3>
          <p className="text-xs text-acedex-muted mt-1">
            {totalUnits} Curriculum Units • Full Textbook Notes
          </p>
        </div>

        {/* Progress & Metrics */}
        <div className="space-y-2.5 pt-2 border-t border-acedex-border/60">
          <div className="flex items-center justify-between text-xs">
            <span className="text-acedex-muted">Coverage</span>
            <span className="font-bold text-acedex-text font-mono">
              {approvedUnits}/{totalUnits} Units ({percent}%)
            </span>
          </div>

          {/* Progress track */}
          <div className="w-full h-2 rounded-full bg-acedex-bg border border-acedex-border/60 overflow-hidden">
            <div
              className="h-full bg-acedex-primary rounded-full transition-all duration-500"
              style={{ width: `${percent}%` }}
            />
          </div>

          <div className="grid grid-cols-3 gap-2 text-center pt-1">
            <div className="p-2 rounded-xl bg-acedex-bg/70 border border-acedex-border/50">
              <span className="block text-xs font-bold text-acedex-text font-mono">
                {totalUnits}
              </span>
              <span className="text-[10px] text-acedex-muted uppercase">Units</span>
            </div>
            <div className="p-2 rounded-xl bg-acedex-bg/70 border border-acedex-border/50">
              <span className="block text-xs font-bold text-emerald-400 font-mono">
                {approvedUnits}
              </span>
              <span className="text-[10px] text-acedex-muted uppercase">Approved</span>
            </div>
            <div className="p-2 rounded-xl bg-acedex-bg/70 border border-acedex-border/50">
              <span className="block text-xs font-bold text-amber-400 font-mono">
                {submittedUnits}
              </span>
              <span className="text-[10px] text-acedex-muted uppercase">In Review</span>
            </div>
          </div>
        </div>

        {/* Action Button: Submit Whole Grade Notes */}
        <Button
          onClick={(e) => {
            e.stopPropagation();
            onSubmitGradeClick(grade);
          }}
          variant="primary"
          size="sm"
          className="w-full justify-between bg-acedex-primary hover:bg-acedex-primary-hover text-white shadow-sm shadow-purple-500/20"
        >
          <span className="flex items-center gap-1.5">
            <HugeiconsIcon icon={Upload01Icon} size={14} strokeWidth={2} />
            <span>Submit Grade {grade} Notes</span>
          </span>
          <HugeiconsIcon icon={ArrowRight01Icon} size={15} />
        </Button>
      </CardContent>
    </Card>
  );
}
