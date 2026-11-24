'use client';

import React from 'react';
import { NoteUnitProgressItem } from '../../types/notes-collector';

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
  const percent = totalUnits > 0 ? Math.round((approvedUnits / totalUnits) * 100) : 0;
  const barWidth = totalUnits > 0 ? ((approvedUnits + inReviewUnits * 0.5) / totalUnits) * 100 : 0;

  return (
    <article
      onClick={() => onSubmitGradeClick(grade)}
      className="stagger-card apple-card apple-card-hover p-5 sm:p-6 flex flex-col justify-between cursor-pointer group"
    >
      <div>
        {/* Top Badges Row */}
        <div className="flex items-center justify-between gap-2 mb-5">
          <span className="px-3 py-1 rounded-full bg-purple-50/90 border border-purple-200/70 font-mono text-[11.5px] font-bold text-[#7E22CE]">
            Grade {grade}
          </span>
          <span className="px-3 py-1 rounded-full bg-slate-100/90 border border-slate-200/70 text-[11.5px] font-semibold tabular-nums text-slate-500">
            {percent}% Covered
          </span>
        </div>

        {/* Title & Subtitle */}
        <h3 className="font-display text-[17.5px] font-extrabold tracking-[-0.02em] text-slate-900 group-hover:text-[#7E22CE] transition-colors">
          Grade {grade} {subjectName}
        </h3>
        <p className="mt-1 text-[12.5px] text-slate-500">
          {totalUnits} Curriculum Units &bull; Full Textbook Notes
        </p>

        {/* Coverage Progress Bar */}
        <div className="mt-5 mb-5">
          <div className="flex items-center justify-between text-[12px] mb-2">
            <span className="text-slate-500 font-medium">Coverage</span>
            <span className="font-mono font-bold tabular-nums text-slate-800">
              {approvedUnits}/{totalUnits} Units ({percent}%)
            </span>
          </div>
          <div className="w-full h-2 rounded-full bg-slate-100 overflow-hidden">
            <div
              style={{ width: `${barWidth}%` }}
              className="h-full rounded-full bg-gradient-to-r from-[#7E22CE] to-[#10B981] transition-all duration-700 ease-spring"
            />
          </div>
        </div>

        {/* 3 Stat Mini-Boxes */}
        <div className="grid grid-cols-3 gap-2.5 mb-5">
          <div className="rounded-[14px] bg-[#FBFBFD] border border-slate-200/70 py-3 px-2 text-center">
            <div className="text-[15px] font-extrabold tabular-nums text-slate-900">{totalUnits}</div>
            <div className="mt-0.5 text-[9.5px] font-bold tracking-[0.06em] uppercase text-slate-400">UNITS</div>
          </div>
          <div className="rounded-[14px] bg-[#FBFBFD] border border-slate-200/70 py-3 px-2 text-center">
            <div className="text-[15px] font-extrabold tabular-nums text-emerald-500">{approvedUnits}</div>
            <div className="mt-0.5 text-[9.5px] font-bold tracking-[0.06em] uppercase text-slate-400">APPROVED</div>
          </div>
          <div className="rounded-[14px] bg-[#FBFBFD] border border-slate-200/70 py-3 px-2 text-center">
            <div className="text-[15px] font-extrabold tabular-nums text-amber-500">{inReviewUnits}</div>
            <div className="mt-0.5 text-[9.5px] font-bold tracking-[0.06em] uppercase text-slate-400">IN REVIEW</div>
          </div>
        </div>
      </div>

      {/* Submit Grade Notes CTA */}
      <button
        type="button"
        onClick={(e) => {
          e.stopPropagation();
          onSubmitGradeClick(grade);
        }}
        className="btn-acedex-primary group w-full min-h-[44px] rounded-[13px] text-white font-semibold text-[13px] inline-flex items-center justify-center gap-2 cursor-pointer"
      >
        <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M21 15V19C21 20.1046 20.1046 21 19 21H5C3.89543 21 3 20.1046 3 19V15" />
          <path d="M17 8L12 3L7 8" />
          <path d="M12 3V15" />
        </svg>
        <span>Submit Grade {grade} Notes</span>
        <svg className="w-3.5 h-3.5 transition-transform duration-250 ease-spring group-hover:translate-x-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M9 6L15 12L9 18" />
        </svg>
      </button>
    </article>
  );
}
