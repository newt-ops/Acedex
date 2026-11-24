'use client';

import React, { useState, useMemo } from 'react';
import { NoteUnitProgressItem, NoteSanitizeResult, QuickNoteData } from '../../types/notes-collector';
import { Modal } from '../ui/Modal';
import { NoteAutoFixSummary } from './NoteAutoFixSummary';
import { NotePreviewContent } from './NotePreviewContent';
import { api } from '../../lib/api';
import { useAuth } from '../../context/AuthContext';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  SparklesIcon,
  SentIcon,
  Copy01Icon,
  Tick02Icon,
  FileCodeIcon,
  EyeIcon,
  Idea01Icon,
  CheckmarkCircle02Icon,
  AlertCircleIcon,
} from '@hugeicons/core-free-icons';

interface GradeNoteSubmitModalProps {
  grade: number;
  subjectCode: string;
  subjectName: string;
  units: NoteUnitProgressItem[];
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export function GradeNoteSubmitModal({
  grade,
  subjectCode,
  subjectName,
  units,
  isOpen,
  onClose,
  onSuccess,
}: GradeNoteSubmitModalProps) {
  const { profile } = useAuth();
  const [rawText, setRawText] = useState<string>('');
  const [sanitizing, setSanitizing] = useState<boolean>(false);
  const [submitting, setSubmitting] = useState<boolean>(false);
  const [report, setReport] = useState<NoteSanitizeResult | null>(null);
  const [activeTab, setActiveTab] = useState<'input' | 'preview'>('input');
  const [selectedPreviewUnitIdx, setSelectedPreviewUnitIdx] = useState<number>(0);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [submitSuccess, setSubmitSuccess] = useState<boolean>(false);
  const [promptCopied, setPromptCopied] = useState<boolean>(false);

  // Generate customized multi-unit prompt for NotebookLM for the whole grade
  const gradePad = grade.toString().padStart(2, '0');
  const unitListStr = units.map((u) => `Unit ${u.unitNumber}: "${u.unitTitle}" (${u.unitCode})`).join('\n');

  const notebookLmGradePrompt = `You are an expert Ethiopian National Curriculum and EUEE (Ethiopian University Entrance Examination) textbook analyst.
Generate an exhaustive, high-yield Quick Revision Note for ALL units of Grade ${grade} ${subjectName}.

Units in Grade ${grade} curriculum:
${unitListStr}

Strict Requirement: Return ONLY a valid JSON array containing one revision note object for each unit above.
Exact JSON Schema:
[
  {
    "grade": ${grade},
    "subject": "${subjectName}",
    "subjectCode": "${subjectCode}",
    "unitNumber": 1,
    "unitCode": "${subjectCode}-G${gradePad}-U01",
    "unitTitle": "${units[0]?.unitTitle || 'Unit Title'}",
    "examWeight": "10% EUEE",
    "summaryPoints": [
      "4 to 6 concise, high-yield bullet points summarizing the core concepts directly tested in EUEE."
    ],
    "formulas": [
      {
        "label": "Rule or Formula Name",
        "expr": "Exact formula, syntax rule, or equation"
      }
    ],
    "examTip": "A focused warning or trap regarding common misconceptions tested in the national exam.",
    "keyDefinitions": [
      {
        "term": "Essential Terminology",
        "definition": "Precise curriculum definition"
      }
    ],
    "eueeFocusTopics": [
      "High-probability topic 1",
      "High-probability topic 2"
    ]
  }
]`;

  const handleCopyPrompt = () => {
    navigator.clipboard.writeText(notebookLmGradePrompt);
    setPromptCopied(true);
    setTimeout(() => setPromptCopied(false), 2200);
  };

  // Live evaluation of JSON text
  const jsonStatus = useMemo(() => {
    const raw = rawText.trim();
    if (!raw) return { label: 'Empty', color: 'text-slate-400' };
    try {
      const parsed = JSON.parse(raw);
      const count = Array.isArray(parsed) ? parsed.length : 1;
      return {
        label: `Valid JSON • ${count} ${count === 1 ? 'unit' : 'units'}`,
        color: 'text-emerald-600 font-semibold',
      };
    } catch {
      if (raw.includes('```') || /[\u201C\u201D\u2018\u2019]/.test(raw)) {
        return {
          label: 'Needs Auto-Fix (Markdown / Quotes)',
          color: 'text-amber-600 font-semibold',
        };
      }
      return {
        label: 'Syntax Issue Detected',
        color: 'text-rose-500 font-semibold',
      };
    }
  }, [rawText]);

  const handleTestAutoFix = async () => {
    if (!rawText.trim()) return;
    setSanitizing(true);
    setSubmitError(null);
    try {
      const result = await api.sanitizeNote(rawText);
      setReport(result);
      if (result.success && (result.notes?.length || result.note)) {
        setActiveTab('preview');
        setSelectedPreviewUnitIdx(0);
      }
    } catch (err: any) {
      setSubmitError(err.message || 'Verification service failed');
    } finally {
      setSanitizing(false);
    }
  };

  const handleSubmit = async () => {
    if (!profile) return;
    setSubmitting(true);
    setSubmitError(null);

    try {
      let activeReport = report;
      if (!activeReport || !activeReport.success) {
        activeReport = await api.sanitizeNote(rawText);
        setReport(activeReport);
      }

      const notesToSubmit: QuickNoteData[] =
        activeReport.notes && activeReport.notes.length > 0
          ? activeReport.notes
          : activeReport.note
          ? [activeReport.note]
          : [];

      if (!activeReport.success || notesToSubmit.length === 0) {
        const errorMsg =
          activeReport.errors && activeReport.errors.length > 0
            ? activeReport.errors.join('; ')
            : 'Pasted notes content failed validation';
        throw new Error(errorMsg);
      }

      await api.submitGradeNotes(
        grade,
        subjectCode,
        profile.contributorId,
        rawText,
        notesToSubmit
      );

      setSubmitSuccess(true);
      setTimeout(() => {
        setSubmitSuccess(false);
        setRawText('');
        setReport(null);
        setActiveTab('input');
        onSuccess();
        onClose();
      }, 1500);
    } catch (err: any) {
      setSubmitError(err.message || 'Failed to submit grade notes');
    } finally {
      setSubmitting(false);
    }
  };

  const handleReset = () => {
    setRawText('');
    setReport(null);
    setSubmitError(null);
    setSubmitSuccess(false);
    setActiveTab('input');
    setSelectedPreviewUnitIdx(0);
    onClose();
  };

  const parsedNotes: QuickNoteData[] =
    report?.notes && report.notes.length > 0
      ? report.notes
      : report?.note
      ? [report.note]
      : [];

  const currentPreviewNote = parsedNotes[selectedPreviewUnitIdx] || parsedNotes[0];

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleReset}
      maxWidth="4xl"
      title={
        <div className="flex items-center gap-2.5">
          <div className="w-7 h-7 rounded-lg bg-purple-50 border border-purple-200/70 flex items-center justify-center text-[#7E22CE] shrink-0">
            <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M21 15V19C21 20.1046 20.1046 21 19 21H5C3.89543 21 3 20.1046 3 19V15" />
              <path d="M17 8L12 3L7 8" />
              <path d="M12 3V15" />
            </svg>
          </div>
          <span className="font-display text-[18px] sm:text-[19px] font-extrabold tracking-[-0.02em] text-slate-900 truncate">
            Submit Grade {grade} Notes
          </span>
        </div>
      }
      description={
        <span className="text-[12.5px] sm:text-[13px] text-slate-500">
          Target:{' '}
          <span className="font-mono font-bold text-[#7E22CE]">Grade {grade} {subjectName}</span>
          <span className="text-slate-600"> — Full Textbook Notes ({units.length} Units)</span>
        </span>
      }
      footer={
        <div className="mt-5 sm:mt-6 flex flex-col-reverse sm:flex-row sm:items-center sm:justify-between gap-2.5 sm:gap-3 w-full">
          <button
            type="button"
            onClick={handleReset}
            disabled={submitting}
            className="w-full sm:w-auto min-h-[44px] sm:min-h-0 px-4 py-2.5 rounded-[12px] text-[13px] font-semibold text-slate-500 hover:text-slate-800 hover:bg-slate-100/80 transition-colors cursor-pointer"
          >
            Cancel
          </button>

          <div className="grid grid-cols-2 sm:flex items-center gap-2.5 w-full sm:w-auto">
            <button
              type="button"
              onClick={handleTestAutoFix}
              disabled={!rawText.trim() || sanitizing || submitting || submitSuccess}
              className="inline-flex items-center justify-center gap-1.5 sm:gap-2 min-h-[44px] sm:min-h-0 px-3.5 sm:px-4 py-2.5 rounded-[13px] bg-white hover:bg-purple-50/60 border border-slate-200/90 hover:border-purple-300 text-[12.5px] sm:text-[13px] font-semibold text-slate-700 hover:text-[#7E22CE] shadow-[0_1px_2px_rgba(15,23,42,0.03)] transition-all duration-200 active:scale-95 disabled:opacity-50 cursor-pointer"
            >
              <HugeiconsIcon icon={SparklesIcon} size={15} className="text-[#7E22CE] shrink-0" strokeWidth={1.5} />
              <span>{sanitizing ? 'Verifying...' : 'Verify & Preview'}</span>
            </button>

            <button
              type="button"
              onClick={handleSubmit}
              disabled={!rawText.trim() || sanitizing || submitting || submitSuccess}
              className="btn-acedex-primary inline-flex items-center justify-center gap-1.5 sm:gap-2 min-h-[44px] sm:min-h-0 sm:min-w-[162px] px-4 sm:px-5 py-2.5 rounded-[13px] text-[12.5px] sm:text-[13px] font-semibold text-white disabled:opacity-50 cursor-pointer"
            >
              {submitting ? (
                <span className="inline-flex items-center gap-1.5 py-1">
                  <span className="loading-dot w-1.5 h-1.5 rounded-full bg-white" />
                  <span className="loading-dot w-1.5 h-1.5 rounded-full bg-white" />
                  <span className="loading-dot w-1.5 h-1.5 rounded-full bg-white" />
                </span>
              ) : submitSuccess ? (
                <span className="inline-flex items-center gap-1.5">
                  <HugeiconsIcon icon={CheckmarkCircle02Icon} size={15} className="text-white shrink-0" strokeWidth={2} />
                  <span>All Units Submitted!</span>
                </span>
              ) : (
                <span className="inline-flex items-center gap-1.5 sm:gap-2">
                  <HugeiconsIcon icon={SentIcon} size={15} className="text-white shrink-0" strokeWidth={1.8} />
                  <span>
                    {parsedNotes.length > 0 ? `Submit All ${parsedNotes.length} Units` : `Submit Grade ${grade} Notes`}
                  </span>
                </span>
              )}
            </button>
          </div>
        </div>
      }
    >
      <div className="space-y-4">
        {/* Textbook Assistant Prompt Banner Card */}
        <div className="rounded-[18px] bg-[#F8FAFC] border border-slate-200/80 p-4 sm:px-5 sm:py-3.5 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 transition-colors hover:border-purple-200/80">
          <div className="flex items-start sm:items-center gap-3">
            <div className="text-[#7E22CE] shrink-0 mt-0.5 sm:mt-0">
              <HugeiconsIcon icon={SparklesIcon} size={20} strokeWidth={1.8} />
            </div>
            <div>
              <h4 className="text-[13.5px] sm:text-[14px] font-bold tracking-[-0.01em] text-slate-900 leading-snug">
                Grade {grade} Textbook Assistant Prompt
              </h4>
              <p className="text-[12px] sm:text-[12.5px] text-slate-500 mt-0.5">
                Copy the prompt to generate notes for all {units.length} units at once.
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={handleCopyPrompt}
            className={`w-full sm:w-auto justify-center shrink-0 inline-flex items-center gap-2 min-h-[40px] sm:min-h-0 px-4 py-2 rounded-full border text-[12.5px] font-semibold shadow-[0_1px_2px_rgba(15,23,42,0.03)] transition-all duration-200 active:scale-95 cursor-pointer ${
              promptCopied
                ? 'bg-emerald-50 border-emerald-300 text-emerald-700'
                : 'bg-white hover:bg-purple-50/70 border-slate-200/90 hover:border-purple-300 text-[#7E22CE]'
            }`}
          >
            <HugeiconsIcon
              icon={promptCopied ? Tick02Icon : Copy01Icon}
              size={14}
              strokeWidth={2}
              className="shrink-0"
            />
            <span>{promptCopied ? 'Copied!' : `Copy Grade ${grade} Prompt`}</span>
          </button>
        </div>

        {/* Direct Copy-Paste Callout Box */}
        <div className="rounded-[16px] bg-[#FBFBFD] border border-slate-200/80 p-3.5 sm:p-4 flex items-start gap-3">
          <div className="mt-0.5 text-amber-500 shrink-0">
            <HugeiconsIcon icon={Idea01Icon} size={18} strokeWidth={1.8} />
          </div>
          <p className="text-[12px] sm:text-[12.5px] leading-relaxed text-slate-600">
            <strong className="font-semibold text-slate-900">Direct Copy-Paste:</strong> Paste the exact JSON output generated by NotebookLM. The auto-fixer will automatically strip markdown fences (<code className="font-mono text-[11px] sm:text-[11.5px] px-1 py-0.5 rounded bg-slate-100 text-slate-700">```json</code>), convert smart quotes, and remove trailing commas.
          </p>
        </div>

        {/* View Switcher Tabs (Input vs Unit Preview) */}
        <div className="flex items-center justify-between border-b border-slate-200/70 pb-2">
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => setActiveTab('input')}
              className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-all flex items-center gap-1.5 cursor-pointer ${
                activeTab === 'input'
                  ? 'bg-white border border-slate-200/90 text-slate-900 shadow-sm'
                  : 'text-slate-500 hover:text-slate-900'
              }`}
            >
              <HugeiconsIcon icon={FileCodeIcon} size={14} strokeWidth={2} />
              <span>Paste Grade Notes</span>
            </button>
            <button
              type="button"
              onClick={() => setActiveTab('preview')}
              disabled={parsedNotes.length === 0}
              className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-all flex items-center gap-1.5 cursor-pointer ${
                activeTab === 'preview'
                  ? 'bg-[#7E22CE] text-white shadow-md shadow-purple-500/20'
                  : parsedNotes.length > 0
                  ? 'text-slate-500 hover:text-slate-900'
                  : 'opacity-40 cursor-not-allowed text-slate-400'
              }`}
            >
              <HugeiconsIcon icon={EyeIcon} size={14} strokeWidth={2} />
              <span>Preview Units ({parsedNotes.length})</span>
              {parsedNotes.length > 0 && <span className="w-1.5 h-1.5 rounded-full bg-emerald-400" />}
            </button>
          </div>

          <div className="flex items-center gap-2">
            <span className={`text-[12px] tabular-nums ${jsonStatus.color}`}>
              {jsonStatus.label}
            </span>
          </div>
        </div>

        {/* Tab 1: Raw Text Input */}
        {activeTab === 'input' && (
          <div className="space-y-3">
            <div className="relative rounded-[16px] border border-slate-200/90 focus-within:border-[#7E22CE] focus-within:ring-4 focus-within:ring-purple-600/10 bg-white transition-all duration-200 overflow-hidden">
              <textarea
                value={rawText}
                onChange={(e) => setRawText(e.target.value)}
                placeholder={`Paste the NotebookLM JSON output for Grade ${grade} here (array of all units [...])...`}
                rows={12}
                spellCheck="false"
                className="w-full h-[220px] sm:h-[260px] p-3.5 sm:p-4 bg-transparent font-mono text-[12px] sm:text-[12.5px] leading-[1.6] text-slate-800 placeholder:text-slate-400 focus:outline-none resize-y"
              />
            </div>

            {report && <NoteAutoFixSummary report={report} />}
          </div>
        )}

        {/* Tab 2: Validated Units Preview */}
        {activeTab === 'preview' && parsedNotes.length > 0 && (
          <div className="space-y-4">
            {/* Unit Selector Pills */}
            <div className="flex items-center gap-1.5 overflow-x-auto no-scrollbar py-1">
              {parsedNotes.map((note, idx) => (
                <button
                  key={idx}
                  type="button"
                  onClick={() => setSelectedPreviewUnitIdx(idx)}
                  className={`px-3 py-1.5 rounded-xl text-xs font-semibold whitespace-nowrap transition-all cursor-pointer ${
                    selectedPreviewUnitIdx === idx
                      ? 'bg-[#7E22CE] text-white shadow-sm'
                      : 'bg-slate-100 hover:bg-slate-200/80 text-slate-700'
                  }`}
                >
                  Unit {note.unitNumber || idx + 1}: {note.unitCode || `U0${idx + 1}`}
                </button>
              ))}
            </div>

            {/* Note Detail Preview Card */}
            {currentPreviewNote && (
              <div className="p-4 sm:p-5 rounded-2xl bg-[#FBFBFD] border border-slate-200/80 max-h-[380px] overflow-y-auto">
                <NotePreviewContent note={currentPreviewNote} />
              </div>
            )}
          </div>
        )}

        {/* Error Alert */}
        {submitError && (
          <div className="p-3 bg-rose-500/15 border border-rose-500/30 rounded-xl text-xs text-rose-500 flex items-center gap-2">
            <HugeiconsIcon icon={AlertCircleIcon} size={16} className="shrink-0 text-rose-500" strokeWidth={1.5} />
            <span>{submitError}</span>
          </div>
        )}
      </div>
    </Modal>
  );
}
