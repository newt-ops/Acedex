'use client';

import React from 'react';
import { SUBJECTS, GRADES } from '../../lib/constants';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  Search01Icon,
  Cancel01Icon,
  FilterIcon,
  Refresh01Icon,
  ArrowDown01Icon,
} from '@hugeicons/core-free-icons';

interface SubmissionFilterBarProps {
  searchQuery: string;
  onSearchChange: (q: string) => void;
  subjectFilter: string;
  onSubjectChange: (subject: string) => void;
  gradeFilter: number | 'ALL';
  onGradeChange: (grade: number | 'ALL') => void;
  statusFilter: string;
  onStatusChange: (status: string) => void;
  onRefresh: () => void;
  loading?: boolean;
}

export function SubmissionFilterBar({
  searchQuery,
  onSearchChange,
  subjectFilter,
  onSubjectChange,
  gradeFilter,
  onGradeChange,
  statusFilter,
  onStatusChange,
  onRefresh,
  loading = false,
}: SubmissionFilterBarProps) {
  const gradeOptions: { val: number | 'ALL'; label: string }[] = [
    { val: 'ALL', label: 'All Grades' },
    { val: 9, label: 'G9' },
    { val: 10, label: 'G10' },
    { val: 11, label: 'G11' },
    { val: 12, label: 'G12' },
  ];

  const statusOptions: { val: string; label: string }[] = [
    { val: 'ALL', label: 'All Statuses' },
    { val: 'submitted', label: 'Pending' },
    { val: 'approved', label: 'Approved' },
    { val: 'rejected', label: 'Rejected' },
  ];

  return (
    <section className="admin-surface p-4 sm:px-6 sm:py-4 flex flex-col xl:flex-row xl:items-center xl:justify-between gap-3.5">
      {/* Left: Search + Subject Dropdown + Segmented Grade Pills */}
      <div className="flex flex-wrap items-center gap-3">
        {/* Instant Search Input */}
        <div className="relative w-full sm:w-[250px] lg:w-[280px]">
          <div className="absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400">
            <HugeiconsIcon icon={Search01Icon} size={16} strokeWidth={2} />
          </div>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            placeholder="Search unit code, title, ID..."
            className="w-full pl-9 pr-8 py-2 rounded-[13px] bg-[#F8F9FB] hover:bg-slate-100/80 focus:bg-white border border-slate-200/85 focus:border-[#7E22CE] focus:ring-4 focus:ring-purple-600/10 text-[13px] text-slate-800 placeholder:text-slate-400 focus:outline-none transition-all"
          />
          {searchQuery && (
            <button
              type="button"
              onClick={() => onSearchChange('')}
              aria-label="Clear search"
              className="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 p-0.5 cursor-pointer"
            >
              <HugeiconsIcon icon={Cancel01Icon} size={14} strokeWidth={2} />
            </button>
          )}
        </div>

        {/* Subject Select Pill */}
        <div className="relative">
          <div className="absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400">
            <HugeiconsIcon icon={FilterIcon} size={14} strokeWidth={2} />
          </div>
          <select
            value={subjectFilter}
            onChange={(e) => onSubjectChange(e.target.value)}
            className="appearance-none pl-9 pr-9 py-2 rounded-[13px] bg-white hover:bg-slate-50 border border-slate-200/85 focus:border-[#7E22CE] focus:outline-none text-[13px] font-semibold text-slate-700 cursor-pointer transition-colors"
          >
            <option value="ALL">All Subjects</option>
            {Object.entries(SUBJECTS).map(([code, name]) => (
              <option key={code} value={code}>
                {name} ({code})
              </option>
            ))}
          </select>
          <div className="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400">
            <HugeiconsIcon icon={ArrowDown01Icon} size={14} strokeWidth={2} />
          </div>
        </div>

        {/* Segmented Grade Pills (All Grades | G9 | G10 | G11 | G12) */}
        <div className="inline-flex items-center p-1 rounded-[14px] bg-[#F8F9FB] border border-slate-200/80">
          {gradeOptions.map((g) => {
            const active = gradeFilter === g.val;
            return (
              <button
                key={String(g.val)}
                type="button"
                onClick={() => onGradeChange(g.val)}
                className={`px-3 py-1.5 rounded-[10px] text-[12px] font-semibold transition-all cursor-pointer ${
                  active
                    ? 'bg-[#7E22CE] text-white shadow-[0_2px_8px_-1px_rgba(126,34,206,0.45)]'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                {g.label}
              </button>
            );
          })}
        </div>
      </div>

      {/* Right: Status Pills + Refresh Button */}
      <div className="flex flex-wrap items-center justify-between xl:justify-end gap-3">
        {/* Segmented Status Pills */}
        <div className="inline-flex items-center p-1 rounded-[14px] bg-[#F8F9FB] border border-slate-200/80">
          {statusOptions.map((s) => {
            const active = statusFilter === s.val;
            return (
              <button
                key={s.val}
                type="button"
                onClick={() => onStatusChange(s.val)}
                className={`px-3 py-1.5 rounded-[10px] text-[12px] font-semibold transition-all cursor-pointer ${
                  active
                    ? 'bg-white text-slate-900 shadow-[0_1px_4px_rgba(15,23,42,0.08)] border border-slate-200/70'
                    : 'text-slate-500 hover:text-slate-800'
                }`}
              >
                {s.label}
              </button>
            );
          })}
        </div>

        {/* Refresh Queue Button */}
        <button
          type="button"
          onClick={onRefresh}
          disabled={loading}
          className="inline-flex items-center gap-2 px-3.5 py-2 rounded-[13px] bg-white hover:bg-slate-50 border border-slate-200/90 text-[13px] font-semibold text-slate-700 hover:text-slate-900 shadow-[0_1px_2px_rgba(15,23,42,0.03)] transition-all active:scale-95 cursor-pointer disabled:opacity-60"
        >
          <HugeiconsIcon
            icon={Refresh01Icon}
            size={14}
            strokeWidth={2}
            className={`text-slate-500 ${loading ? 'animate-spin' : ''}`}
          />
          <span>Refresh Queue</span>
        </button>
      </div>
    </section>
  );
}
