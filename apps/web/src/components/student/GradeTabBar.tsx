'use client';

import React from 'react';
import { GRADES } from '../../lib/constants';

interface GradeTabBarProps {
  activeGrade: number;
  onSelectGrade: (grade: number) => void;
  gradeStats?: Record<number, { approved: number; total: number }>;
}

export function GradeTabBar({
  activeGrade,
  onSelectGrade,
  gradeStats,
}: GradeTabBarProps) {
  return (
    <div className="-mx-4 px-4 sm:mx-0 sm:px-0 mb-5 sm:mb-6 overflow-x-auto no-scrollbar snap-x snap-mandatory" style={{ WebkitOverflowScrolling: 'touch' }}>
      <div className="flex items-center gap-2.5 w-max sm:w-auto sm:flex-wrap">
        {GRADES.map((grade) => {
          const isActive = activeGrade === grade;
          const stats = gradeStats?.[grade] || { approved: 0, total: 8 };

          if (isActive) {
            return (
              <button
                key={grade}
                type="button"
                onClick={() => onSelectGrade(grade)}
                className="snap-start shrink-0 inline-flex items-center gap-2 sm:gap-2.5 min-h-[44px] px-4 py-2.5 rounded-[15px] bg-[#7E22CE] text-white font-semibold text-[13px] shadow-[0_6px_16px_-3px_rgba(126,34,206,0.42)] transition-all duration-250 cursor-pointer"
              >
                <svg className="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M22 10L12 5L2 10L12 15L22 10Z" />
                  <path d="M6 12.5V17C6 18.5 8.7 20 12 20C15.3 20 18 18.5 18 17V12.5" />
                </svg>
                <span>Grade {grade}</span>
                <span className="px-2 py-0.5 rounded-full text-[11px] font-bold tabular-nums bg-white/20 text-white">
                  {stats.approved}/{stats.total}
                </span>
              </button>
            );
          }

          return (
            <button
              key={grade}
              type="button"
              onClick={() => onSelectGrade(grade)}
              className="snap-start shrink-0 inline-flex items-center gap-2 sm:gap-2.5 min-h-[44px] px-4 py-2.5 rounded-[15px] bg-[#F4F5F7] hover:bg-slate-200/75 text-slate-600 hover:text-slate-900 font-semibold text-[13px] border border-slate-200/70 transition-all duration-200 active:scale-95 cursor-pointer"
            >
              <svg className="w-4 h-4 text-slate-500 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">
                <path d="M22 10L12 5L2 10L12 15L22 10Z" />
                <path d="M6 12.5V17C6 18.5 8.7 20 12 20C15.3 20 18 18.5 18 17V12.5" />
              </svg>
              <span>Grade {grade}</span>
              <span className="px-2 py-0.5 rounded-full text-[11px] font-bold tabular-nums bg-white text-slate-600 border border-slate-200/70">
                {stats.approved}/{stats.total}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
