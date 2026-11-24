'use client';

import React, { useState, useMemo } from 'react';
import { UnitProgressItem, SanitizeResult } from '../../types/collector';
import { Modal } from '../ui/Modal';
import { AutoFixSummary } from './AutoFixSummary';
import { api } from '../../lib/api';
import { useAuth } from '../../context/AuthContext';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  SparklesIcon,
  SentIcon,
  CheckmarkCircle02Icon,
  AlertCircleIcon,
  Idea01Icon,
  Copy01Icon,
  Tick02Icon,
  FileCodeIcon,
} from '@hugeicons/core-free-icons';

interface QuestionSubmitModalProps {
  unit: UnitProgressItem | null;
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export function QuestionSubmitModal({
  unit,
  isOpen,
  onClose,
  onSuccess,
}: QuestionSubmitModalProps) {
  const { profile } = useAuth();
  const [rawText, setRawText] = useState<string>('');
  const [sanitizing, setSanitizing] = useState<boolean>(false);
  const [submitting, setSubmitting] = useState<boolean>(false);
  const [report, setReport] = useState<SanitizeResult | null>(null);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [submitSuccess, setSubmitSuccess] = useState<boolean>(false);
  const [promptCopied, setPromptCopied] = useState<boolean>(false);

  // Live evaluation of JSON text
  const jsonStatus = useMemo(() => {
    const raw = rawText.trim();
    if (!raw) return { label: 'Empty', color: 'text-slate-400' };
    try {
      const parsed = JSON.parse(raw);
      const count = Array.isArray(parsed) ? parsed.length : 1;
      return {
        label: `Valid JSON • ${count} ${count === 1 ? 'item' : 'items'}`,
        color: 'text-emerald-600 font-semibold',
      };
    } catch {
      // Check if it has markdown fences or smart quotes
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

  if (!unit) return null;

  const subjectName = profile?.subjectName || 'Geography';

  const notebookLmUnitPrompt = `You are an Ethiopian Secondary School Assessment Specialist for Grade ${unit.grade} ${subjectName}.
Using the uploaded Grade ${unit.grade} ${subjectName} textbook source, generate exactly 15 high-quality multiple-choice questions for ${unit.unitCode} (Unit ${unit.unitNumber}: ${unit.unitTitle}).

Output Requirements:
1. Return ONLY a valid JSON array of 15 question objects.
2. Mix difficulty levels (5 easy, 7 medium, 3 hard) aligned with Ethiopian national exam standards.
3. Each object must follow this exact schema:
[
  {
    "id": "${unit.unitCode}-Q01",
    "type": "multiple_choice",
    "difficulty": "medium",
    "question": "Question text...",
    "options": [
      {"id": "A", "text": "Option A"},
      {"id": "B", "text": "Option B"},
      {"id": "C", "text": "Option C"},
      {"id": "D", "text": "Option D"}
    ],
    "correctOptionId": "A",
    "explanation": "Concise textbook-backed explanation"
  }
]`;

  const handleCopyPrompt = () => {
    navigator.clipboard.writeText(notebookLmUnitPrompt);
    setPromptCopied(true);
    setTimeout(() => setPromptCopied(false), 2200);
  };

  const handleTestAutoFix = async () => {
    if (!rawText.trim()) return;
    setSanitizing(true);
    setSubmitError(null);
    try {
      const result = await api.sanitize(rawText, unit.unitCode);
      setReport(result);
    } catch (err: any) {
      setSubmitError(err.message || 'Auto-fix service failed');
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
        activeReport = await api.sanitize(rawText, unit.unitCode);
        setReport(activeReport);
      }

      if (!activeReport.success) {
        const errorMsg =
          activeReport.errors && activeReport.errors.length > 0
            ? activeReport.errors.join('; ')
            : 'Pasted content failed syntax validation';
        throw new Error(errorMsg);
      }

      const questionsToSubmit =
        activeReport.questions || activeReport.parsedQuestions || [];

      await api.submitUnit(
        unit.unitCode,
        profile.contributorId,
        rawText,
        questionsToSubmit
      );

      setSubmitSuccess(true);
      setTimeout(() => {
        setSubmitSuccess(false);
        setRawText('');
        setReport(null);
        onSuccess();
        onClose();
      }, 1500);
    } catch (err: any) {
      setSubmitError(err.message || 'Failed to submit questions');
    } finally {
      setSubmitting(false);
    }
  };

  const handleReset = () => {
    setRawText('');
    setReport(null);
    setSubmitError(null);
    setSubmitSuccess(false);
    onClose();
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleReset}
      maxWidth="2xl"
      title={
        <div className="flex items-center gap-2.5">
          <div className="w-7 h-7 rounded-lg bg-purple-50 border border-purple-200/70 flex items-center justify-center text-[#7E22CE] shrink-0">
            <HugeiconsIcon icon={FileCodeIcon} size={16} strokeWidth={2} />
          </div>
          <span className="font-display text-[18px] sm:text-[19px] font-extrabold tracking-[-0.02em] text-slate-900 truncate">
            {unit.status === 'approved' ? 'View / Replace Questions' : 'Submit Questions'}
          </span>
        </div>
      }
      description={
        <span className="text-[12.5px] sm:text-[13px] text-slate-500">
          Target:{' '}
          <span className="font-mono font-bold text-[#7E22CE]">{unit.unitCode}</span>
          <span className="text-slate-600"> — Unit {unit.unitNumber}: {unit.unitTitle}</span>
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
              <span>{sanitizing ? 'Fixing...' : 'Test Auto-Fix'}</span>
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
                  <span>Submitted!</span>
                </span>
              ) : (
                <span className="inline-flex items-center gap-1.5 sm:gap-2">
                  <HugeiconsIcon icon={SentIcon} size={15} className="text-white shrink-0" strokeWidth={1.8} />
                  <span>Submit to Review</span>
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
                {unit.unitCode} Textbook Assistant Prompt
              </h4>
              <p className="text-[12px] sm:text-[12.5px] text-slate-500 mt-0.5">
                Copy the prompt to generate 15 curriculum-aligned questions for Unit {unit.unitNumber}.
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
            <span>{promptCopied ? 'Copied!' : `Copy Unit ${unit.unitNumber} Prompt`}</span>
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

        {/* Text Area Header */}
        <div className="flex items-center justify-between gap-2">
          <label htmlFor="unitQuestionJson" className="text-[13px] font-semibold text-slate-800">
            Pasted Question JSON Text
          </label>
          <span className={`text-[12px] tabular-nums ${jsonStatus.color}`}>
            {jsonStatus.label}
          </span>
        </div>

        {/* Monospace JSON Code Editor */}
        <div className="relative rounded-[16px] border border-slate-200/90 focus-within:border-[#7E22CE] focus-within:ring-4 focus-within:ring-purple-600/10 bg-white transition-all duration-200 overflow-hidden">
          <textarea
            id="unitQuestionJson"
            value={rawText}
            onChange={(e) => {
              setRawText(e.target.value);
              setReport(null);
              setSubmitError(null);
            }}
            spellCheck="false"
            rows={10}
            placeholder={`[\n  {\n    "id": "${unit.unitCode}-Q01",\n    "type": "multiple_choice",\n    "difficulty": "medium",\n    "question": "What is...",\n    "options": [\n      {"id": "A", "text": "Option A"},\n      {"id": "B", "text": "Option B"}\n    ],\n    "correctOptionId": "A",\n    "explanation": "Concise rationale..."\n  }\n]`}
            className="w-full h-[200px] sm:h-[240px] p-3.5 sm:p-4 bg-transparent font-mono text-[12px] sm:text-[12.5px] leading-[1.6] text-slate-800 placeholder:text-slate-400 focus:outline-none resize-y"
          />
        </div>

        {/* Error alert */}
        {submitError && (
          <div className="p-3 bg-rose-500/15 border border-rose-500/30 rounded-xl text-xs text-rose-500 flex items-center gap-2">
            <HugeiconsIcon icon={AlertCircleIcon} size={16} className="shrink-0 text-rose-500" strokeWidth={1.5} />
            <span>{submitError}</span>
          </div>
        )}

        {/* Auto-fix summary report */}
        {report && <AutoFixSummary report={report} />}
      </div>
    </Modal>
  );
}
