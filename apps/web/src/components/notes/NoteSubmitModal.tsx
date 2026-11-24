'use client';

import React, { useState } from 'react';
import { NoteUnitProgressItem, NoteSanitizeResult } from '../../types/notes-collector';
import { Modal } from '../ui/Modal';
import { Button } from '../ui/Button';
import { NoteAutoFixSummary } from './NoteAutoFixSummary';
import { NotePreviewContent } from './NotePreviewContent';
import { api } from '../../lib/api';
import { useAuth } from '../../context/AuthContext';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  SparklesIcon,
  SentIcon,
  BookOpen01Icon,
  Copy01Icon,
  Tick02Icon,
  FileCodeIcon,
  EyeIcon,
  HelpCircleIcon,
} from '@hugeicons/core-free-icons';

interface NoteSubmitModalProps {
  unit: NoteUnitProgressItem | null;
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export function NoteSubmitModal({
  unit,
  isOpen,
  onClose,
  onSuccess,
}: NoteSubmitModalProps) {
  const { profile } = useAuth();
  const [rawText, setRawText] = useState<string>('');
  const [sanitizing, setSanitizing] = useState<boolean>(false);
  const [submitting, setSubmitting] = useState<boolean>(false);
  const [report, setReport] = useState<NoteSanitizeResult | null>(null);
  const [activeTab, setActiveTab] = useState<'input' | 'preview'>('input');
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [submitSuccess, setSubmitSuccess] = useState<boolean>(false);
  const [promptCopied, setPromptCopied] = useState<boolean>(false);

  if (!unit) return null;

  // Generate customized prompt for NotebookLM
  const notebookLmPrompt = `You are an expert Ethiopian National Curriculum and EUEE (Ethiopian University Entrance Examination) textbook analyst.
Generate an exhaustive, high-yield Quick Revision Note for Grade ${unit.grade} ${profile?.subjectName || 'Subject'}, Unit ${unit.unitNumber}: "${unit.unitTitle}".

Strict Requirement: Return ONLY a valid JSON object (or JSON wrapped in markdown \`\`\`json block) with no conversational filler.
Exact JSON Schema:
{
  "grade": ${unit.grade},
  "subject": "${profile?.subjectName || 'Subject'}",
  "subjectCode": "${profile?.subjectCode || 'ENG'}",
  "unitNumber": ${unit.unitNumber},
  "unitCode": "${unit.unitCode}",
  "unitTitle": "${unit.unitTitle}",
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
}`;

  const handleCopyPrompt = () => {
    navigator.clipboard.writeText(notebookLmPrompt);
    setPromptCopied(true);
    setTimeout(() => setPromptCopied(false), 2500);
  };

  const handleTestAutoFix = async () => {
    if (!rawText.trim()) return;
    setSanitizing(true);
    setSubmitError(null);
    try {
      const result = await api.sanitizeNote(rawText, unit.unitCode);
      setReport(result);
      if (result.success && result.note) {
        setActiveTab('preview');
      }
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
        activeReport = await api.sanitizeNote(rawText, unit.unitCode);
        setReport(activeReport);
      }

      if (!activeReport.success || !activeReport.note) {
        const errorMsg =
          activeReport.errors && activeReport.errors.length > 0
            ? activeReport.errors.join('; ')
            : 'Pasted note content failed validation';
        throw new Error(errorMsg);
      }

      await api.submitUnitNote(
        unit.unitCode,
        profile.contributorId,
        rawText,
        activeReport.note
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
      setSubmitError(err.message || 'Failed to submit quick note');
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
    onClose();
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleReset}
      title={
        <div className="flex items-center gap-2">
          <HugeiconsIcon
            icon={BookOpen01Icon}
            size={20}
            className="text-violet-400 shrink-0"
            strokeWidth={2}
          />
          <span>Submit Quick Revision Note</span>
        </div>
      }
      description={
        <span>
          Target: <strong className="text-violet-400 font-mono">{unit.unitCode}</strong> — Unit {unit.unitNumber}: {unit.unitTitle}
        </span>
      }
      maxWidth="4xl"
      footer={
        <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between w-full gap-2.5">
          <Button
            variant="ghost"
            size="sm"
            onClick={handleReset}
            disabled={submitting}
          >
            Cancel
          </Button>

          <div className="flex items-center gap-2 justify-end">
            <Button
              variant="secondary"
              size="sm"
              onClick={handleTestAutoFix}
              loading={sanitizing}
              disabled={!rawText.trim() || submitting || submitSuccess}
              icon={
                <HugeiconsIcon
                  icon={SparklesIcon}
                  size={15}
                  className="text-violet-400 shrink-0"
                  strokeWidth={2}
                />
              }
            >
              Auto-Fix & Preview
            </Button>

            <Button
              variant="primary"
              size="sm"
              onClick={handleSubmit}
              loading={submitting}
              disabled={!rawText.trim() || submitting || submitSuccess}
              className="bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white shadow-md shadow-indigo-500/20"
              icon={
                <HugeiconsIcon
                  icon={SentIcon}
                  size={15}
                  className="shrink-0"
                  strokeWidth={2}
                />
              }
            >
              {submitSuccess ? 'Submitted Successfully!' : 'Submit Quick Note'}
            </Button>
          </div>
        </div>
      }
    >
      <div className="space-y-4">
        {/* NotebookLM Assistant Prompt Pill */}
        <div className="p-3.5 rounded-2xl bg-gradient-to-r from-violet-500/10 via-acedex-card to-indigo-500/10 border border-violet-500/20 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div className="flex items-center gap-2.5">
            <div className="w-7 h-7 rounded-lg bg-violet-500/20 text-violet-300 flex items-center justify-center shrink-0">
              <HugeiconsIcon icon={SparklesIcon} size={15} strokeWidth={2} />
            </div>
            <div className="text-xs">
              <span className="font-bold text-acedex-text block">
                Using Google NotebookLM?
              </span>
              <span className="text-acedex-muted">
                One-click copy the optimal prompt tuned for this unit.
              </span>
            </div>
          </div>
          <button
            onClick={handleCopyPrompt}
            className={`inline-flex items-center justify-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold shrink-0 transition-all ${
              promptCopied
                ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/40'
                : 'bg-violet-600/20 text-violet-300 hover:bg-violet-600/30 border border-violet-500/30'
            }`}
          >
            <HugeiconsIcon
              icon={promptCopied ? Tick02Icon : Copy01Icon}
              size={13}
              strokeWidth={2}
            />
            <span>{promptCopied ? 'Prompt Copied ✓' : 'Copy NotebookLM Prompt'}</span>
          </button>
        </div>

        {/* View Switcher Tabs */}
        <div className="flex items-center justify-between border-b border-acedex-border/60 pb-2">
          <div className="flex items-center gap-2">
            <button
              onClick={() => setActiveTab('input')}
              className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-all flex items-center gap-1.5 ${
                activeTab === 'input'
                  ? 'bg-acedex-card border border-acedex-border text-acedex-text shadow-sm'
                  : 'text-acedex-muted hover:text-acedex-text'
              }`}
            >
              <HugeiconsIcon icon={FileCodeIcon} size={14} strokeWidth={2} />
              <span>Paste Raw Output</span>
            </button>
            <button
              onClick={() => setActiveTab('preview')}
              disabled={!report?.note}
              className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-all flex items-center gap-1.5 ${
                activeTab === 'preview'
                  ? 'bg-violet-600 text-white shadow-md shadow-violet-500/20'
                  : report?.note
                  ? 'text-acedex-muted hover:text-acedex-text'
                  : 'opacity-40 cursor-not-allowed text-acedex-muted'
              }`}
            >
              <HugeiconsIcon icon={EyeIcon} size={14} strokeWidth={2} />
              <span>Live Visual Preview</span>
              {report?.note && (
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400" />
              )}
            </button>
          </div>

          {report?.success && (
            <span className="text-xs text-emerald-400 font-medium hidden sm:inline-block">
              ✓ Ready for submission
            </span>
          )}
        </div>

        {/* Tab 1: Raw Text Input */}
        {activeTab === 'input' && (
          <div className="space-y-3">
            <div className="relative">
              <textarea
                value={rawText}
                onChange={(e) => setRawText(e.target.value)}
                placeholder="Paste the NotebookLM JSON output here (raw JSON or ```json markdown code block)..."
                rows={12}
                className="w-full p-4 rounded-2xl bg-acedex-bg border border-acedex-border/80 text-acedex-text font-mono text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-violet-500/50 resize-y leading-relaxed"
              />
              {rawText && (
                <button
                  onClick={() => setRawText('')}
                  className="absolute top-3 right-3 text-xs text-acedex-muted hover:text-rose-400 bg-acedex-card px-2 py-1 rounded-lg border border-acedex-border"
                >
                  Clear
                </button>
              )}
            </div>

            {/* Auto-fix report if generated */}
            {report && <NoteAutoFixSummary report={report} />}
          </div>
        )}

        {/* Tab 2: Live Note Preview */}
        {activeTab === 'preview' && report?.note && (
          <div className="space-y-4">
            <NoteAutoFixSummary report={report} />
            <div className="p-1 rounded-2xl">
              <NotePreviewContent note={report.note} />
            </div>
          </div>
        )}

        {/* Submit Error Alert */}
        {submitError && (
          <div className="p-3.5 rounded-xl bg-rose-500/15 border border-rose-500/30 text-xs sm:text-sm text-rose-300">
            <strong>Submission Error:</strong> {submitError}
          </div>
        )}
      </div>
    </Modal>
  );
}
