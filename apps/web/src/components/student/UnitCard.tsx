'use client';

import React from 'react';
import { UnitProgressItem } from '../../types/collector';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  CheckmarkCircle02Icon,
  Clock01Icon,
  BookOpen01Icon,
  Upload01Icon,
  EyeIcon,
} from '@hugeicons/core-free-icons';

interface UnitCardProps {
  unit: UnitProgressItem;
  onOpenSubmit: (unit: UnitProgressItem) => void;
}

export function UnitCard({ unit, onOpenSubmit }: UnitCardProps) {
  const isApproved = unit.status === 'approved';
  const isNotStarted = unit.status === 'not_started';

  return (
    <article
      className={`apple-card apple-card-hover p-5 sm:p-6 flex flex-col justify-between ${
        isNotStarted ? 'bg-[#F9FAFB]/90' : 'bg-white'
      }`}
    >
      <div>
        {/* Top Code & Status Pill */}
        <div className="flex items-center justify-between gap-2 mb-4">
          <span className="px-2.5 py-1 rounded-lg bg-purple-50/90 border border-purple-200/70 font-mono text-[11px] font-bold text-[#7E22CE]">
            {unit.unitCode}
          </span>

          {isApproved ? (
            <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11.5px] font-semibold bg-emerald-50/90 text-emerald-700 border border-emerald-200/80">
              <HugeiconsIcon icon={CheckmarkCircle02Icon} size={14} className="text-emerald-500 shrink-0" strokeWidth={2.2} />
              <span>Approved</span>
            </span>
          ) : (
            <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11.5px] font-semibold bg-slate-100 text-slate-600 border border-slate-200/70">
              <HugeiconsIcon icon={Clock01Icon} size={14} className="text-slate-500 shrink-0" strokeWidth={2} />
              <span>{unit.status === 'submitted' ? 'In Review' : 'Not Started'}</span>
            </span>
          )}
        </div>

        {/* Unit Title */}
        <div className="flex items-start gap-2.5 min-h-[50px]">
          <HugeiconsIcon icon={BookOpen01Icon} size={16} strokeWidth={2} className="text-slate-400 mt-1 shrink-0" />
          <h3 className="text-[15.5px] font-bold tracking-[-0.015em] text-slate-900 leading-snug">
            Unit {unit.unitNumber}: {unit.unitTitle}
          </h3>
        </div>

        {/* Hairline Divider */}
        <div className="my-4 border-t border-slate-100"></div>

        {/* Submission Summary */}
        <div className="mb-5">
          {isApproved ? (
            <div className="inline-flex items-center gap-1.5 text-[12.5px] font-semibold text-emerald-600">
              <HugeiconsIcon icon={CheckmarkCircle02Icon} size={16} className="text-emerald-500 shrink-0" strokeWidth={2.2} />
              <span>Approved ({unit.questionCount || 15} questions)</span>
            </div>
          ) : unit.status === 'submitted' ? (
            <p className="text-[12.5px] font-medium text-amber-600">
              Submitted for review (15 questions).
            </p>
          ) : (
            <p className="text-[12.5px] italic text-slate-400">
              No questions submitted yet. (Target: 15 items)
            </p>
          )}

          {unit.reviewNotes && (
            <p className="mt-2 text-xs text-amber-700 bg-amber-50 p-2 rounded-xl border border-amber-200">
              Admin Note: {unit.reviewNotes}
            </p>
          )}
        </div>
      </div>

      {/* Card Footer CTA */}
      <div>
        {isApproved ? (
          <button
            type="button"
            onClick={() => onOpenSubmit(unit)}
            className="btn-emerald-outline w-full min-h-[44px] rounded-[13px] font-semibold text-[13px] inline-flex items-center justify-center gap-2 cursor-pointer"
          >
            <HugeiconsIcon icon={EyeIcon} size={16} className="text-emerald-500 shrink-0" strokeWidth={2} />
            <span>View / Replace</span>
          </button>
        ) : (
          <button
            type="button"
            onClick={() => onOpenSubmit(unit)}
            className="btn-acedex-primary w-full min-h-[44px] rounded-[13px] text-white font-semibold text-[13px] inline-flex items-center justify-center gap-2 cursor-pointer"
          >
            <HugeiconsIcon icon={Upload01Icon} size={16} strokeWidth={2} className="shrink-0" />
            <span>Submit Questions</span>
          </button>
        )}
      </div>
    </article>
  );
}
