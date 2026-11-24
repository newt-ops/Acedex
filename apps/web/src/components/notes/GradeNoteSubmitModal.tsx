'use client';

import React, { useState } from 'react';
import { NoteUnitProgressItem, NoteSanitizeResult, QuickNoteData } from '../../types/notes-collector';
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
  Layers01Icon,
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
    setTimeout(() => setPromptCopied(false), 2500);
  };

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
      title={
        <div className="flex items-center gap-2">
          <HugeiconsIcon
            icon={BookOpen01Icon}
            size={20}
            className="text-acedex-primary shrink-0"
            strokeWidth={2}
          />
          <span>Submit Grade {grade} Revision Notes (All Units)</span>
        </div>
      }
      description={
        <span>
          Target: <strong className="text-acedex-primary font-mono">Grade {grade} {subjectName}</strong> — {units.length} Curriculum Units
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
                  className="text-acedex-primary shrink-0"
                  strokeWidth={2}
                />
              }
            >
              Verify & Preview Units
            </Button>

            <Button
              variant="primary"
              size="sm"
              onClick={handleSubmit}
              loading={submitting}
              disabled={!rawText.trim() || submitting || submitSuccess}
              className="bg-acedex-primary hover:bg-acedex-primary-hover text-white shadow-md shadow-purple-500/20"
              icon={
                <HugeiconsIcon
                  icon={SentIcon}
                  size={15}
                  className="shrink-0"
                  strokeWidth={2}
                />
              }
            >
              {submitSuccess
                ? 'All Units Submitted Successfully!'
                : parsedNotes.length > 0
                ? `Submit All ${parsedNotes.length} Units`
                : `Submit Grade ${grade} Notes`}
            </Button>
          </div>
        </div>
      }
    >
      <div className="space-y-4">
        {/* NotebookLM Assistant Prompt Pill for Whole Grade */}
        <div className="p-3.5 rounded-2xl bg-gradient-to-r from-acedex-primary/10 via-acedex-card to-acedex-primary/5 border border-acedex-primary/20 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div className="flex items-center gap-2.5">
            <div className="w-7 h-7 rounded-lg bg-acedex-primary/20 text-acedex-primary flex items-center justify-center shrink-0">
              <HugeiconsIcon icon={SparklesIcon} size={15} strokeWidth={2} />
            </div>
            <div className="text-xs">
              <span className="font-bold text-acedex-text block">
                Grade {grade} Textbook Assistant Prompt
              </span>
              <span className="text-acedex-muted">
                Copy the prompt to generate notes for all {units.length} units at once.
              </span>
            </div>
          </div>
          <button
            onClick={handleCopyPrompt}
            className={`inline-flex items-center justify-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold shrink-0 transition-all ${
              promptCopied
                ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/40'
                : 'bg-acedex-primary/15 text-acedex-primary hover:bg-acedex-primary/25 border border-acedex-primary/30'
            }`}
          >
            <HugeiconsIcon
              icon={promptCopied ? Tick02Icon : Copy01Icon}
              size={13}
              strokeWidth={2}
            />
            <span>{promptCopied ? 'Prompt Copied ✓' : `Copy Grade ${grade} Prompt`}</span>
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
              <span>Paste Grade Notes</span>
            </button>
            <button
              onClick={() => setActiveTab('preview')}
              disabled={parsedNotes.length === 0}
              className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-all flex items-center gap-1.5 ${
                activeTab === 'preview'
                  ? 'bg-acedex-primary text-white shadow-md shadow-purple-500/20'
                  : parsedNotes.length > 0
                  ? 'text-acedex-muted hover:text-acedex-text'
                  : 'opacity-40 cursor-not-allowed text-acedex-muted'
              }`}
            >
              <HugeiconsIcon icon={EyeIcon} size={14} strokeWidth={2} />
              <span>Preview Units ({parsedNotes.length})</span>
              {parsedNotes.length > 0 && (
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400" />
              )}
            </button>
          </div>

          {report?.success && (
            <span className="text-xs text-emerald-400 font-medium hidden sm:inline-block">
              ✓ {parsedNotes.length} Units Validated
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
                placeholder={`Paste the NotebookLM JSON output for Grade ${grade} here (array of all units [...])...`}
                rows={13}
                className="w-full p-4 rounded-2xl bg-acedex-bg border border-acedex-border/80 text-acedex-text font-mono text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-acedex-primary/50 resize-y leading-relaxed"
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

            {report && <NoteAutoFixSummary report={report} />}
          </div>
        )}

        {/* Tab 2: Multi-Unit Live Preview */}
        {activeTab === 'preview' && parsedNotes.length > 0 && (
          <div className="space-y-4">
            <NoteAutoFixSummary report={report!} />

            {/* Unit Selector Strip */}
            <div className="space-y-1.5">
              <span className="text-xs font-semibold text-acedex-muted block">
                Select Unit to Preview:
              </span>
              <div className="flex items-center gap-1.5 overflow-x-auto pb-1">
                {parsedNotes.map((n, idx) => (
                  <button
                    key={idx}
                    onClick={() => setSelectedPreviewUnitIdx(idx)}
                    className={`px-3 py-1 rounded-xl text-xs font-bold transition-all shrink-0 ${
                      selectedPreviewUnitIdx === idx
                        ? 'bg-acedex-primary text-white shadow-sm'
                        : 'bg-acedex-card border border-acedex-border text-acedex-muted hover:text-acedex-text'
                    }`}
                  >
                    <span>Unit {n.unitNumber}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Current Unit Preview */}
            {currentPreviewNote && (
              <div className="p-1 rounded-2xl">
                <NotePreviewContent note={currentPreviewNote} />
              </div>
            )}
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
