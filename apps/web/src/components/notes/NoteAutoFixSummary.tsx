'use client';

import React from 'react';
import { NoteSanitizeResult } from '../../types/notes-collector';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  CheckmarkCircle02Icon,
  AlertCircleIcon,
  CancelCircleIcon,
  SparklesIcon,
} from '@hugeicons/core-free-icons';

interface NoteAutoFixSummaryProps {
  report: NoteSanitizeResult;
}

export function NoteAutoFixSummary({ report }: NoteAutoFixSummaryProps) {
  const fixes = report?.fixesApplied || report?.autoFixedIssues || [];
  const warnings = report?.warnings || [];
  const errors = report?.errors || [];
  const note = report?.note;

  return (
    <div className="space-y-3 my-3">
      {/* Primary status banner */}
      <div
        className={`p-3.5 rounded-2xl border flex items-center gap-3 shadow-sm ${
          report.success
            ? 'bg-emerald-500/10 border-emerald-500/30 text-emerald-400'
            : 'bg-rose-500/10 border-rose-500/30 text-rose-400'
        }`}
      >
        {report.success ? (
          <HugeiconsIcon
            icon={CheckmarkCircle02Icon}
            size={22}
            className="shrink-0 text-emerald-400"
            strokeWidth={2}
          />
        ) : (
          <HugeiconsIcon
            icon={CancelCircleIcon}
            size={22}
            className="shrink-0 text-rose-400"
            strokeWidth={2}
          />
        )}
        <div className="text-xs sm:text-sm">
          <div className="font-bold">
            {report.success
              ? 'Note Content Verified & Ready'
              : 'Formatting Issues Found in Note Content'}
          </div>
          <div className="text-xs opacity-90 mt-0.5">
            {report.success
              ? `Ready for submission: ${note?.summaryPoints.length || 0} summary points, ${note?.formulas.length || 0} formulas, and ${note?.keyDefinitions.length || 0} definitions detected.`
              : 'Please check the notes below or re-copy the generated note from your assistant.'}
          </div>
        </div>
      </div>

      {/* Auto-fixes applied banner */}
      {fixes.length > 0 && (
        <div className="p-3.5 bg-acedex-card border border-acedex-border/80 rounded-2xl text-xs space-y-2 shadow-sm">
          <div className="font-bold text-acedex-primary flex items-center gap-1.5">
            <HugeiconsIcon icon={SparklesIcon} size={15} strokeWidth={2} />
            <span>Format Improvements Applied:</span>
          </div>
          <ul className="list-disc list-inside space-y-1 text-acedex-muted pl-1">
            {fixes.map((fix, idx) => (
              <li key={idx} className="text-acedex-text/90">
                {fix}
              </li>
            ))}
          </ul>
        </div>
      )}

      {/* Warnings */}
      {warnings.length > 0 && (
        <div className="p-3 bg-amber-500/10 border border-amber-500/20 rounded-xl text-xs space-y-1">
          <div className="font-bold text-amber-400 flex items-center gap-1.5">
            <HugeiconsIcon
              icon={AlertCircleIcon}
              size={15}
              className="text-amber-500 shrink-0"
              strokeWidth={2}
            />
            <span>Warnings:</span>
          </div>
          <ul className="list-disc list-inside space-y-0.5 text-amber-300/90 pl-1">
            {warnings.map((warn, idx) => (
              <li key={idx}>{warn}</li>
            ))}
          </ul>
        </div>
      )}

      {/* Errors */}
      {errors.length > 0 && (
        <div className="p-3 bg-rose-500/10 border border-rose-500/20 rounded-xl text-xs space-y-1">
          <div className="font-bold text-rose-400 flex items-center gap-1.5">
            <HugeiconsIcon
              icon={CancelCircleIcon}
              size={15}
              className="text-rose-500 shrink-0"
              strokeWidth={2}
            />
            <span>Validation Errors:</span>
          </div>
          <ul className="list-disc list-inside space-y-0.5 text-rose-300 pl-1">
            {errors.map((err, idx) => (
              <li key={idx}>{err}</li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
