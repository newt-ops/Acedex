'use client';

import React from 'react';
import { NoteUnitProgressItem } from '../../types/notes-collector';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  Upload01Icon,
  Refresh01Icon,
  ArrowRight01Icon,
  Clock01Icon,
  CheckmarkCircle02Icon,
  AlertCircleIcon,
} from '@hugeicons/core-free-icons';

interface GradeNoteCardProps {
  grade: number;
  subjectName: string;
  units: NoteUnitProgressItem[];
  onSubmitGradeClick: (grade: number) => void;
}

export function GradeNoteCard({
  grade,
  subjectName,
  units,
  onSubmitGradeClick,
}: GradeNoteCardProps) {
  const totalUnits = units.length || 8;
  const approvedUnits = units.filter((u) => u.status === 'approved').length;
  const inReviewUnits = units.filter((u) => u.status === 'submitted').length;
  const rejectedUnits = units.filter((u) => u.status === 'rejected').length;

  const isAllApproved = totalUnits > 0 && approvedUnits === totalUnits;
  const hasInReview = inReviewUnits > 0;
  const hasRejected = rejectedUnits > 0 && inReviewUnits === 0;
  const isSubmitted = inReviewUnits > 0 || approvedUnits > 0;

  const percent = totalUnits > 0 ? Math.round((approvedUnits / totalUnits) * 100) : 0;
  const progressPercent =
    totalUnits > 0 ? Math.min(100, Math.round(((approvedUnits + inReviewUnits) / totalUnits) * 100)) : 0;

  return (
    <article
      onClick={() => onSubmitGradeClick(grade)}
      className="stagger-card apple-card apple-card-hover p-5 sm:p-6 flex flex-col justify-between cursor-pointer group"
    >
      <div>
        {/* Top Badges Row */}
        <div className="flex items-center justify-between gap-2 mb-5">
          <span className="px-3 py-1 rounded-full bg-purple-50/90 dark:bg-purple-950/40 border border-purple-200/70 dark:border-purple-800/50 font-mono text-[11.5px] font-bold text-[#7E22CE] dark:text-purple-300">
            Grade {grade}
          </span>

          {isAllApproved ? (
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/25 text-[11.5px] font-bold text-emerald-600 dark:text-emerald-400">
              <HugeiconsIcon icon={CheckmarkCircle02Icon} size={13} strokeWidth={2.2} />
              <span>100% Approved</span>
            </span>
          ) : hasInReview ? (
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-500/10 border border-amber-500/30 text-[11.5px] font-bold text-amber-600 dark:text-amber-400">
              <HugeiconsIcon icon={Clock01Icon} size={13} strokeWidth={2.2} className="animate-spin text-amber-500" />
              <span>In Review ({inReviewUnits}/{totalUnits})</span>
            </span>
          ) : hasRejected ? (
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-rose-500/10 border border-rose-500/30 text-[11.5px] font-bold text-rose-600 dark:text-rose-400">
              <HugeiconsIcon icon={AlertCircleIcon} size={13} strokeWidth={2.2} />
              <span>Revision Needed ({rejectedUnits})</span>
            </span>
          ) : (
            <span className="px-3 py-1 rounded-full bg-slate-100/90 dark:bg-slate-800 border border-slate-200/70 dark:border-slate-700 text-[11.5px] font-semibold tabular-nums text-slate-500 dark:text-slate-400">
              Not Started
            </span>
          )}
        </div>

        {/* Title & Subtitle */}
        <h3 className="font-display text-[17.5px] font-extrabold tracking-[-0.02em] text-slate-900 dark:text-white group-hover:text-[#7E22CE] dark:group-hover:text-purple-400 transition-colors">
          Grade {grade} {subjectName}
        </h3>
        <p className="mt-1 text-[12.5px] text-slate-500 dark:text-slate-400">
          {totalUnits} Curriculum Units &bull; Full Textbook Notes
        </p>

        {/* Dynamic Coverage / In Review Progress Bar */}
        <div className="mt-5 mb-5">
          <div className="flex items-center justify-between text-[12px] mb-2">
            <span className="text-slate-500 dark:text-slate-400 font-medium">
              {isAllApproved
                ? 'Status'
                : hasInReview && approvedUnits === 0
                ? 'Review Status'
                : 'Coverage'}
            </span>
            <span
              className={`font-mono font-bold tabular-nums ${
                isAllApproved
                  ? 'text-emerald-600 dark:text-emerald-400'
                  : hasInReview
                  ? 'text-amber-600 dark:text-amber-400'
                  : 'text-slate-800 dark:text-slate-200'
              }`}
            >
              {isAllApproved
                ? `All ${totalUnits} Units Approved`
                : hasInReview && approvedUnits === 0
                ? `${inReviewUnits}/${totalUnits} Units Pending Review`
                : hasInReview && approvedUnits > 0
                ? `${approvedUnits} Approved • ${inReviewUnits} In Review`
                : `0/${totalUnits} Units (${percent}%)`}
            </span>
          </div>

          <div className="w-full h-2 rounded-full bg-slate-100 dark:bg-slate-800 overflow-hidden">
            <div
              style={{ width: `${isAllApproved ? 100 : progressPercent}%` }}
              className={`h-full rounded-full transition-all duration-700 ease-spring ${
                isAllApproved
                  ? 'bg-emerald-500'
                  : hasInReview && approvedUnits === 0
                  ? 'bg-gradient-to-r from-[#7E22CE] to-amber-500'
                  : 'bg-gradient-to-r from-[#7E22CE] to-[#10B981]'
              }`}
            />
          </div>
        </div>

        {/* 3 Stat Mini-Boxes */}
        <div className="grid grid-cols-3 gap-2.5 mb-5">
          <div className="rounded-[14px] bg-[#FBFBFD] dark:bg-slate-900/60 border border-slate-200/70 dark:border-slate-800 py-3 px-2 text-center transition-colors">
            <div className="text-[15px] font-extrabold tabular-nums text-slate-900 dark:text-white">
              {totalUnits}
            </div>
            <div className="mt-0.5 text-[9.5px] font-bold tracking-[0.06em] uppercase text-slate-400">
              UNITS
            </div>
          </div>

          <div
            className={`rounded-[14px] py-3 px-2 text-center border transition-all ${
              approvedUnits > 0
                ? 'bg-emerald-50/70 dark:bg-emerald-950/25 border-emerald-300 dark:border-emerald-800/60'
                : 'bg-[#FBFBFD] dark:bg-slate-900/60 border-slate-200/70 dark:border-slate-800'
            }`}
          >
            <div className="text-[15px] font-extrabold tabular-nums text-emerald-500">
              {approvedUnits}
            </div>
            <div className="mt-0.5 text-[9.5px] font-bold tracking-[0.06em] uppercase text-slate-400">
              APPROVED
            </div>
          </div>

          <div
            className={`rounded-[14px] py-3 px-2 text-center border transition-all ${
              inReviewUnits > 0
                ? 'bg-amber-50/80 dark:bg-amber-950/30 border-amber-300 dark:border-amber-700/60 shadow-[0_2px_8px_rgba(245,158,11,0.12)]'
                : 'bg-[#FBFBFD] dark:bg-slate-900/60 border-slate-200/70 dark:border-slate-800'
            }`}
          >
            <div className="text-[15px] font-extrabold tabular-nums text-amber-500">
              {inReviewUnits}
            </div>
            <div className="mt-0.5 text-[9.5px] font-bold tracking-[0.06em] uppercase text-slate-400">
              IN REVIEW
            </div>
          </div>
        </div>
      </div>

      {/* Submit / Resubmit Grade Notes CTA */}
      <div>
        <button
          type="button"
          onClick={(e) => {
            e.stopPropagation();
            onSubmitGradeClick(grade);
          }}
          className={`group w-full min-h-[44px] rounded-[13px] text-white font-semibold text-[13px] inline-flex items-center justify-center gap-2 cursor-pointer transition-all duration-200 ${
            isAllApproved
              ? 'bg-emerald-600 hover:bg-emerald-700 shadow-[0_4px_14px_rgba(16,185,129,0.3)]'
              : hasInReview
              ? 'btn-acedex-primary shadow-[0_4px_14px_rgba(126,34,206,0.3)]'
              : hasRejected
              ? 'bg-rose-600 hover:bg-rose-700 shadow-[0_4px_14px_rgba(225,29,72,0.3)]'
              : 'btn-acedex-primary'
          }`}
        >
          <HugeiconsIcon
            icon={isSubmitted ? Refresh01Icon : Upload01Icon}
            size={16}
            strokeWidth={2}
            className="shrink-0"
          />
          <span>
            {isAllApproved
              ? `Resubmit Grade ${grade} Notes`
              : hasInReview
              ? `Resubmit Grade ${grade} Notes`
              : hasRejected
              ? `Revise Grade ${grade} Notes`
              : `Submit Grade ${grade} Notes`}
          </span>
          <HugeiconsIcon
            icon={ArrowRight01Icon}
            size={14}
            strokeWidth={2.2}
            className="transition-transform duration-250 ease-spring group-hover:translate-x-1 shrink-0"
          />
        </button>

        {/* Reassuring Status Helper Line */}
        {hasInReview && (
          <p className="mt-2 text-center text-[11px] text-amber-600 dark:text-amber-400 font-medium">
            &bull; {inReviewUnits} unit{inReviewUnits > 1 ? 's' : ''} submitted &amp; in review. Resubmit anytime to update.
          </p>
        )}
        {isAllApproved && (
          <p className="mt-2 text-center text-[11px] text-emerald-600 dark:text-emerald-400 font-medium">
            &bull; All curriculum units verified &amp; approved.
          </p>
        )}
        {!isSubmitted && (
          <p className="mt-2 text-center text-[11px] text-slate-400 dark:text-slate-500 font-medium">
            &bull; Full textbook revision notes for all {totalUnits} units.
          </p>
        )}
      </div>
    </article>
  );
}
