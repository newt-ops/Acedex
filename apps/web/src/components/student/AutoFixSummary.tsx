'use client';

import React from 'react';
import { SanitizeResult } from '../../types/collector';
import { CheckCircle2, AlertTriangle, XCircle, Sparkles } from 'lucide-react';

interface AutoFixSummaryProps {
  report: SanitizeResult;
}

export function AutoFixSummary({ report }: AutoFixSummaryProps) {
  const fixes = report?.fixesApplied || report?.autoFixedIssues || [];
  const warnings = report?.warnings || [];
  const errors = report?.errors || [];
  const questionCount =
    report?.questionCount ??
    report?.questions?.length ??
    report?.parsedQuestions?.length ??
    0;

  return (
    <div className="space-y-3 my-3">
      {/* Status banner */}
      <div
        className={`p-3.5 rounded-xl border flex items-center gap-3 ${
          report.success
            ? 'bg-emerald-500/10 border-emerald-500/30 text-emerald-400'
            : 'bg-rose-500/10 border-rose-500/30 text-rose-400'
        }`}
      >
        {report.success ? (
          <CheckCircle2 className="w-5 h-5 shrink-0 text-emerald-400" />
        ) : (
          <XCircle className="w-5 h-5 shrink-0 text-rose-400" />
        )}
        <div className="text-xs sm:text-sm">
          <div className="font-semibold">
            {report.success
              ? `Successfully Parsed ${questionCount} Questions`
              : 'Syntax Issues Found in Pasted JSON'}
          </div>
          <div className="text-xs opacity-90 mt-0.5">
            {report.success
              ? 'Pasted content was automatically normalized and verified ready for submission.'
              : 'Please check the formatting errors below or ensure full JSON was copied.'}
          </div>
        </div>
      </div>

      {/* Applied Fixes */}
      {fixes.length > 0 && (
        <div className="p-3 bg-acedex-bg border border-acedex-border/60 rounded-xl text-xs space-y-1.5">
          <div className="font-semibold text-acedex-primary flex items-center gap-1.5">
            <Sparkles className="w-3.5 h-3.5" /> Auto-Fixes Applied:
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
          <div className="font-semibold text-amber-400 flex items-center gap-1.5">
            <AlertTriangle className="w-3.5 h-3.5" /> Warnings:
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
          <div className="font-semibold text-rose-400 flex items-center gap-1.5">
            <XCircle className="w-3.5 h-3.5" /> Errors:
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
