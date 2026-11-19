'use client';

import React from 'react';
import { SUBJECTS, GRADES } from '../../lib/constants';
import { HugeiconsIcon } from '@hugeicons/react';
import { FilterIcon, Refresh01Icon } from '@hugeicons/core-free-icons';
import { Button } from '../ui/Button';

interface SubmissionFilterBarProps {
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
  subjectFilter,
  onSubjectChange,
  gradeFilter,
  onGradeChange,
  statusFilter,
  onStatusChange,
  onRefresh,
  loading = false,
}: SubmissionFilterBarProps) {
  return (
    <div className="bg-acedex-card border border-acedex-border rounded-xl p-3 sm:p-4 mb-6 space-y-3">
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
        {/* Filter controls */}
        <div className="flex flex-wrap items-center gap-2 flex-1">
          <div className="flex items-center gap-1.5 text-xs font-semibold text-acedex-muted mr-1">
            <HugeiconsIcon icon={FilterIcon} size={15} className="text-acedex-primary" strokeWidth={1.5} /> Filters:
          </div>

          {/* Subject Dropdown */}
          <select
            value={subjectFilter}
            onChange={(e) => onSubjectChange(e.target.value)}
            className="h-9 px-2.5 rounded-lg bg-acedex-bg border border-acedex-border text-xs text-acedex-text focus:outline-none focus:border-acedex-primary min-h-[36px]"
          >
            <option value="ALL">All Subjects</option>
            {Object.entries(SUBJECTS).map(([code, name]) => (
              <option key={code} value={code}>
                {name} ({code})
              </option>
            ))}
          </select>

          {/* Grade Dropdown */}
          <select
            value={gradeFilter}
            onChange={(e) =>
              onGradeChange(e.target.value === 'ALL' ? 'ALL' : Number(e.target.value))
            }
            className="h-9 px-2.5 rounded-lg bg-acedex-bg border border-acedex-border text-xs text-acedex-text focus:outline-none focus:border-acedex-primary min-h-[36px]"
          >
            <option value="ALL">All Grades</option>
            {GRADES.map((g) => (
              <option key={g} value={g}>
                Grade {g}
              </option>
            ))}
          </select>

          {/* Status Dropdown */}
          <select
            value={statusFilter}
            onChange={(e) => onStatusChange(e.target.value)}
            className="h-9 px-2.5 rounded-lg bg-acedex-bg border border-acedex-border text-xs text-acedex-text focus:outline-none focus:border-acedex-primary min-h-[36px]"
          >
            <option value="ALL">All Statuses</option>
            <option value="submitted">Under Review</option>
            <option value="approved">Approved</option>
            <option value="rejected">Rejected</option>
          </select>
        </div>

        {/* Refresh button */}
        <Button
          size="sm"
          variant="secondary"
          onClick={onRefresh}
          loading={loading}
          icon={<HugeiconsIcon icon={Refresh01Icon} size={14} strokeWidth={1.5} />}
          className="shrink-0"
        >
          Refresh Queue
        </Button>
      </div>
    </div>
  );
}
