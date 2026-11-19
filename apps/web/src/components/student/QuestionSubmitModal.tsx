'use client';

import React, { useState } from 'react';
import { UnitProgressItem, SanitizeResult } from '../../types/collector';
import { Modal } from '../ui/Modal';
import { Button } from '../ui/Button';
import { AutoFixSummary } from './AutoFixSummary';
import { api } from '../../lib/api';
import { useAuth } from '../../context/AuthContext';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  SparklesIcon,
  SentIcon,
  FileCodeIcon,
  CheckmarkCircle02Icon,
  AlertCircleIcon,
  Idea01Icon,
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

  if (!unit) return null;

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
      // First sanitize to get validated questions
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
      title={
        <div className="flex items-center gap-2">
          <HugeiconsIcon icon={FileCodeIcon} size={20} className="text-acedex-primary" strokeWidth={1.5} />
          <span>Submit Questions</span>
        </div>
      }
      description={
        <span>
          Target: <strong className="text-acedex-primary">{unit.unitCode}</strong> — Unit {unit.unitNumber}: {unit.unitTitle}
        </span>
      }
      maxWidth="2xl"
      footer={
        <div className="flex items-center justify-between w-full">
          <Button
            variant="ghost"
            size="sm"
            onClick={handleReset}
            disabled={submitting}
          >
            Cancel
          </Button>

          <div className="flex items-center gap-2">
            <Button
              variant="secondary"
              size="sm"
              onClick={handleTestAutoFix}
              loading={sanitizing}
              disabled={!rawText.trim() || submitting || submitSuccess}
            >
              <HugeiconsIcon icon={SparklesIcon} size={15} className="mr-1 text-acedex-accent" strokeWidth={1.5} /> Test Auto-Fix
            </Button>

            <Button
              variant="primary"
              size="sm"
              onClick={handleSubmit}
              loading={submitting}
              disabled={!rawText.trim() || sanitizing || submitSuccess}
            >
              {submitSuccess ? (
                <>
                  <HugeiconsIcon icon={CheckmarkCircle02Icon} size={15} className="mr-1" strokeWidth={1.75} /> Submitted!
                </>
              ) : (
                <>
                  <HugeiconsIcon icon={SentIcon} size={15} className="mr-1" strokeWidth={1.5} /> Submit to Review
                </>
              )}
            </Button>
          </div>
        </div>
      }
    >
      <div className="space-y-4">
        {/* Instructions banner */}
        <div className="p-3 rounded-xl bg-acedex-bg border border-acedex-border/70 text-xs text-acedex-muted leading-relaxed flex items-start gap-2">
          <HugeiconsIcon icon={Idea01Icon} size={16} className="text-amber-500 shrink-0 mt-0.5" strokeWidth={1.5} />
          <span>
            <strong className="text-acedex-text">Direct Copy-Paste:</strong> Paste the exact JSON output generated by NotebookLM. The auto-fixer will automatically strip markdown fences (` ```json `), convert smart quotes, and remove trailing commas.
          </span>
        </div>

        {/* Text Area */}
        <div className="space-y-1.5">
          <div className="flex items-center justify-between text-xs font-semibold text-acedex-muted">
            <span>Pasted Question JSON Text</span>
            <span>{rawText.length > 0 ? `${rawText.length} characters` : 'Empty'}</span>
          </div>
          <textarea
            value={rawText}
            onChange={(e) => {
              setRawText(e.target.value);
              setReport(null);
              setSubmitError(null);
            }}
            rows={10}
            placeholder={`[\n  {\n    "id": "${unit.unitCode}-Q01",\n    "type": "multiple_choice",\n    "difficulty": "medium",\n    "question": "What is...",\n    "options": [\n      {"id": "A", "text": "Option A"},\n      {"id": "B", "text": "Option B"}\n    ],\n    "correctOptionId": "A",\n    "explanation": "..." \n  }\n]`}
            className="w-full font-mono text-xs sm:text-sm p-3.5 rounded-xl bg-acedex-bg border border-acedex-border focus:border-acedex-primary focus:ring-1 focus:ring-acedex-primary text-acedex-text placeholder:text-acedex-muted/40 transition-colors resize-y min-h-[180px]"
          />
        </div>

        {/* Error alert */}
        {submitError && (
          <div className="p-3 bg-rose-500/15 border border-rose-500/30 rounded-xl text-xs text-rose-400 flex items-center gap-2">
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
