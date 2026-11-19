'use client';

import React from 'react';
import { GRADES } from '../../lib/constants';
import { HugeiconsIcon } from '@hugeicons/react';
import { GraduationCapIcon } from '@hugeicons/core-free-icons';

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
    <div className="w-full border-b border-acedex-border/80 bg-acedex-bg/60 backdrop-blur-sm sticky top-16 z-30">
      <div className="flex items-center gap-2 overflow-x-auto no-scrollbar py-3 px-1 sm:px-0">
        {GRADES.map((grade) => {
          const isActive = activeGrade === grade;
          const stats = gradeStats?.[grade];

          return (
            <button
              key={grade}
              onClick={() => onSelectGrade(grade)}
              className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold transition-all whitespace-nowrap min-h-[44px] shrink-0 ${
                isActive
                  ? 'bg-acedex-primary text-white shadow-md shadow-blue-500/20'
                  : 'bg-acedex-card hover:bg-acedex-card-hover text-acedex-muted hover:text-acedex-text border border-acedex-border/80'
              }`}
            >
              <HugeiconsIcon
                icon={GraduationCapIcon}
                size={16}
                className={isActive ? 'text-white' : 'text-acedex-muted'}
                strokeWidth={1.5}
              />
              <span>Grade {grade}</span>
              {stats && (
                <span
                  className={`text-xs px-2 py-0.5 rounded-full font-mono ${
                    isActive
                      ? 'bg-white/20 text-white'
                      : 'bg-acedex-bg text-acedex-muted border border-acedex-border/60'
                  }`}
                >
                  {stats.approved}/{stats.total}
                </span>
              )}
            </button>
          );
        })}
      </div>
    </div>
  );
}
