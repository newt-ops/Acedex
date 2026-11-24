'use client';

import React from 'react';
import { UnitProgressItem } from '../../types/collector';

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
              <svg className="w-3.5 h-3.5 text-emerald-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.1" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="12" cy="12" r="9" />
                <path d="M8.5 12.2L10.8 14.5L15.5 9.8" />
              </svg>
              <span>Approved</span>
            </span>
          ) : (
            <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11.5px] font-semibold bg-slate-100 text-slate-600 border border-slate-200/70">
              <svg className="w-3.5 h-3.5 text-slate-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="12" cy="12" r="9" />
                <path d="M12 8V12" />
                <circle cx="12" cy="16" r="0.6" fill="currentColor" />
              </svg>
              <span>{unit.status === 'submitted' ? 'In Review' : 'Not Started'}</span>
            </span>
          )}
        </div>

        {/* Unit Title */}
        <div className="flex items-start gap-2.5 min-h-[50px]">
          <svg className="w-4 h-4 text-slate-400 mt-1 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">
            <path d="M2 6C2 4.89543 2.89543 4 4 4H9C10.6569 4 12 5.34315 12 7V20C12 18.8954 11.1046 18 10 18H4C2.89543 18 2 17.1046 2 16V6Z" />
            <path d="M22 6C22 4.89543 21.1046 4 20 4H15C13.3431 4 12 5.34315 12 7V20C12 18.8954 12.8954 18 14 18H20C21.1046 18 22 17.1046 22 16V6Z" />
          </svg>
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
              <svg className="w-4 h-4 text-emerald-500 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.1" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="12" cy="12" r="9" />
                <path d="M8.5 12.2L10.8 14.5L15.5 9.8" />
              </svg>
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
            <svg className="w-4 h-4 text-emerald-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.1" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="12" cy="12" r="9" />
              <path d="M8.5 12.2L10.8 14.5L15.5 9.8" />
            </svg>
            <span>View / Replace</span>
          </button>
        ) : (
          <button
            type="button"
            onClick={() => onOpenSubmit(unit)}
            className="btn-acedex-primary w-full min-h-[44px] rounded-[13px] text-white font-semibold text-[13px] inline-flex items-center justify-center gap-2 cursor-pointer"
          >
            <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M17.5 19H9C6.23858 19 4 16.7614 4 14C4 11.425 5.94534 9.30541 8.44702 9.03071C9.24709 6.13556 11.8944 4 15 4C18.866 4 22 7.13401 22 11C22 11.5193 21.9434 12.0254 21.8361 12.5124" />
              <path d="M17 16L19.5 13.5L22 16" />
              <path d="M19.5 13.5V20" />
            </svg>
            <span>Submit Questions</span>
          </button>
        )}
      </div>
    </article>
  );
}
