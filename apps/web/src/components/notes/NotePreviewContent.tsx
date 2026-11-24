'use client';

import React, { useState } from 'react';
import { QuickNoteData } from '../../types/notes-collector';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  SparklesIcon,
  BookOpen01Icon,
  Idea01Icon,
  Copy01Icon,
  Tick02Icon,
  Tag01Icon,
} from '@hugeicons/core-free-icons';

interface NotePreviewContentProps {
  note: QuickNoteData;
}

export function NotePreviewContent({ note }: NotePreviewContentProps) {
  const [copiedFormulaIdx, setCopiedFormulaIdx] = useState<number | null>(null);

  const handleCopyFormula = (expr: string, idx: number) => {
    navigator.clipboard.writeText(expr);
    setCopiedFormulaIdx(idx);
    setTimeout(() => {
      setCopiedFormulaIdx((current) => (current === idx ? null : current));
    }, 2000);
  };

  return (
    <div className="space-y-6">
      {/* Top Unit Banner */}
      <div className="p-4 sm:p-5 rounded-2xl bg-gradient-to-br from-violet-500/10 via-acedex-card to-indigo-500/10 border border-violet-500/20 shadow-md">
        <div className="flex flex-wrap items-center justify-between gap-2.5 mb-2">
          <div className="flex items-center gap-2">
            <span className="px-2.5 py-1 rounded-lg text-xs font-mono font-bold bg-acedex-bg border border-acedex-border text-acedex-primary">
              {note.unitCode}
            </span>
            <span className="text-xs text-acedex-muted">
              Grade {note.grade} • {note.subject}
            </span>
          </div>
          {note.examWeight && (
            <span className="px-2.5 py-1 rounded-full text-xs font-semibold bg-violet-500/15 text-violet-300 border border-violet-500/30 flex items-center gap-1.5 shadow-sm">
              <HugeiconsIcon icon={SparklesIcon} size={13} strokeWidth={2} />
              <span>{note.examWeight}</span>
            </span>
          )}
        </div>
        <h2 className="text-lg sm:text-xl font-bold text-acedex-text tracking-tight">
          Unit {note.unitNumber}: {note.unitTitle}
        </h2>
      </div>

      {/* Summary Points */}
      <div className="space-y-3">
        <div className="flex items-center gap-2 text-sm font-bold text-acedex-text">
          <span className="w-2 h-2 rounded-full bg-violet-500 shadow-sm shadow-violet-500/50" />
          <span>Core Summary Points ({note.summaryPoints.length})</span>
        </div>
        <div className="grid grid-cols-1 gap-2.5">
          {note.summaryPoints.map((point, idx) => (
            <div
              key={idx}
              className="p-3.5 rounded-xl bg-acedex-card/90 border border-acedex-border/70 hover:border-violet-500/30 transition-colors flex items-start gap-3"
            >
              <span className="w-5 h-5 rounded-full bg-violet-500/15 text-violet-400 border border-violet-500/30 text-xs font-bold flex items-center justify-center shrink-0 mt-0.5">
                {idx + 1}
              </span>
              <p className="text-xs sm:text-sm text-acedex-text/90 leading-relaxed">
                {point}
              </p>
            </div>
          ))}
        </div>
      </div>

      {/* Formulas & Syntactic Rules */}
      {note.formulas && note.formulas.length > 0 && (
        <div className="space-y-3">
          <div className="flex items-center gap-2 text-sm font-bold text-acedex-text">
            <span className="w-2 h-2 rounded-full bg-indigo-500 shadow-sm shadow-indigo-500/50" />
            <span>Key Formulas & Syntactic Rules ({note.formulas.length})</span>
          </div>
          <div className="grid grid-cols-1 gap-3">
            {note.formulas.map((f, idx) => {
              const isCopied = copiedFormulaIdx === idx;
              return (
                <div
                  key={idx}
                  className="p-4 rounded-xl bg-acedex-bg border border-acedex-border/80 hover:border-indigo-500/40 transition-all flex flex-col sm:flex-row sm:items-center justify-between gap-3 group"
                >
                  <div className="space-y-1.5 flex-1 min-w-0">
                    <span className="text-xs font-semibold text-acedex-muted block">
                      {f.label}
                    </span>
                    <code className="text-xs sm:text-sm font-mono text-indigo-300 bg-indigo-950/40 px-2.5 py-1.5 rounded-lg border border-indigo-800/40 block break-words">
                      {f.expr}
                    </code>
                  </div>
                  <button
                    onClick={() => handleCopyFormula(f.expr, idx)}
                    className={`inline-flex items-center justify-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold shrink-0 transition-all ${
                      isCopied
                        ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/40'
                        : 'bg-acedex-card text-acedex-muted hover:text-acedex-text hover:bg-acedex-card-hover border border-acedex-border'
                    }`}
                    title="Copy formula expression"
                  >
                    <HugeiconsIcon
                      icon={isCopied ? Tick02Icon : Copy01Icon}
                      size={13}
                      strokeWidth={2}
                    />
                    <span>{isCopied ? 'Copied ✓' : 'Copy'}</span>
                  </button>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* EUEE Exam Tip */}
      {note.examTip && (
        <div className="p-4 sm:p-5 rounded-2xl bg-amber-500/10 border border-amber-500/25 shadow-md shadow-amber-500/5 relative overflow-hidden">
          <div className="flex items-start gap-3">
            <div className="w-8 h-8 rounded-xl bg-amber-500/20 border border-amber-500/30 flex items-center justify-center shrink-0 text-amber-400 mt-0.5">
              <HugeiconsIcon icon={Idea01Icon} size={18} strokeWidth={2} />
            </div>
            <div className="space-y-1">
              <span className="text-xs font-bold uppercase tracking-wider text-amber-400 block">
                EUEE High-Yield Exam Tip
              </span>
              <p className="text-xs sm:text-sm text-amber-200/90 leading-relaxed font-medium">
                {note.examTip}
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Key Definitions */}
      {note.keyDefinitions && note.keyDefinitions.length > 0 && (
        <div className="space-y-3">
          <div className="flex items-center gap-2 text-sm font-bold text-acedex-text">
            <span className="w-2 h-2 rounded-full bg-teal-500 shadow-sm shadow-teal-500/50" />
            <span>Key Definitions & Glossary ({note.keyDefinitions.length})</span>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {note.keyDefinitions.map((def, idx) => (
              <div
                key={idx}
                className="p-3.5 rounded-xl bg-acedex-card border border-acedex-border/70 hover:border-teal-500/30 transition-colors space-y-1.5"
              >
                <div className="inline-block px-2 py-0.5 rounded-md text-xs font-bold font-mono bg-teal-500/15 text-teal-300 border border-teal-500/30">
                  {def.term}
                </div>
                <p className="text-xs text-acedex-muted leading-relaxed">
                  {def.definition}
                </p>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Focus Topics */}
      {note.eueeFocusTopics && note.eueeFocusTopics.length > 0 && (
        <div className="space-y-2.5 pt-2 border-t border-acedex-border/60">
          <span className="text-xs font-semibold text-acedex-muted uppercase tracking-wider block">
            EUEE Exam Focus Topics
          </span>
          <div className="flex flex-wrap gap-2">
            {note.eueeFocusTopics.map((topic, idx) => (
              <span
                key={idx}
                className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-medium bg-acedex-card border border-acedex-border text-acedex-text"
              >
                <span className="w-1.5 h-1.5 rounded-full bg-violet-400" />
                <span>{topic}</span>
              </span>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
