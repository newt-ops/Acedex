'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { Modal } from '../ui/Modal';
import { SUBJECTS, GRADES } from '../../lib/constants';
import { api } from '../../lib/api';
import { QuickNoteData } from '../../types/notes-collector';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  Download01Icon,
  Copy01Icon,
  Tick02Icon,
  BookOpen01Icon,
  FileCodeIcon,
  CheckmarkCircle02Icon,
  AlertCircleIcon,
  Loading01Icon,
  ArrowDown01Icon,
} from '@hugeicons/core-free-icons';

interface GradeNotesExportModalProps {
  isOpen: boolean;
  onClose: () => void;
  initialSubject?: string;
  initialGrade?: number;
}

export function GradeNotesExportModal({
  isOpen,
  onClose,
  initialSubject,
  initialGrade,
}: GradeNotesExportModalProps) {
  const [subjectCode, setSubjectCode] = useState<string>(
    initialSubject && initialSubject !== 'ALL' ? initialSubject : 'PHY'
  );
  const [grade, setGrade] = useState<number>(
    initialGrade && initialGrade !== ('ALL' as any) ? Number(initialGrade) : 9
  );
  const [statusScope, setStatusScope] = useState<'all' | 'approved'>('all');

  const [loading, setLoading] = useState<boolean>(false);
  const [exportData, setExportData] = useState<{
    subjectCode: string;
    subjectName: string;
    grade: number;
    totalUnits: number;
    notes: QuickNoteData[];
  } | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [copied, setCopied] = useState<boolean>(false);
  const [downloadSuccess, setDownloadSuccess] = useState<boolean>(false);

  // Sync initial props when opened
  useEffect(() => {
    if (isOpen) {
      if (initialSubject && initialSubject !== 'ALL') {
        setSubjectCode(initialSubject);
      }
      if (initialGrade && typeof initialGrade === 'number') {
        setGrade(initialGrade);
      }
      setDownloadSuccess(false);
      setCopied(false);
    }
  }, [isOpen, initialSubject, initialGrade]);

  // Fetch preview count whenever subject, grade, or status changes
  const loadPreviewData = useCallback(async () => {
    if (!isOpen) return;
    setLoading(true);
    setError(null);
    try {
      const data = await api.exportGradeNotes(subjectCode, grade, statusScope);
      setExportData(data);
    } catch (err: any) {
      setError(err.message || 'Failed to query grade notes');
      setExportData(null);
    } finally {
      setLoading(false);
    }
  }, [isOpen, subjectCode, grade, statusScope]);

  useEffect(() => {
    loadPreviewData();
  }, [loadPreviewData]);

  const subjectName = SUBJECTS[subjectCode] || subjectCode;
  const gradePad = grade.toString().padStart(2, '0');
  const totalUnits = exportData?.totalUnits || 0;

  // Handle Download File
  const handleDownload = () => {
    if (!exportData || !exportData.notes || exportData.notes.length === 0) return;

    const filename = `${subjectName}-Grade-${gradePad}-Notes.json`.replace(/\s+/g, '-');
    const jsonString = `data:text/json;charset=utf-8,${encodeURIComponent(
      JSON.stringify(exportData.notes, null, 2)
    )}`;

    const downloadAnchor = document.createElement('a');
    downloadAnchor.setAttribute('href', jsonString);
    downloadAnchor.setAttribute('download', filename);
    document.body.appendChild(downloadAnchor);
    downloadAnchor.click();
    downloadAnchor.remove();

    setDownloadSuccess(true);
    setTimeout(() => setDownloadSuccess(false), 3000);
  };

  // Handle Copy to Clipboard
  const handleCopyClipboard = () => {
    if (!exportData || !exportData.notes || exportData.notes.length === 0) return;
    navigator.clipboard.writeText(JSON.stringify(exportData.notes, null, 2));
    setCopied(true);
    setTimeout(() => setCopied(false), 2200);
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      maxWidth="2xl"
      title={
        <div className="flex items-center gap-2.5">
          <div className="w-8 h-8 rounded-xl bg-purple-50 dark:bg-purple-950/40 border border-purple-200/75 dark:border-purple-800/60 flex items-center justify-center text-[#7E22CE] dark:text-purple-300 shrink-0">
            <HugeiconsIcon icon={Download01Icon} size={18} strokeWidth={2} />
          </div>
          <div>
            <h2 className="font-display text-[18px] sm:text-[19px] font-extrabold tracking-[-0.02em] text-slate-900 dark:text-white">
              Download Grade Revision Notes
            </h2>
          </div>
        </div>
      }
      description={
        <span className="text-[12.5px] sm:text-[13px] text-slate-500 dark:text-slate-400">
          Download the entire revision notes for all units of a grade in a single structured JSON batch.
        </span>
      }
      footer={
        <div className="flex flex-col-reverse sm:flex-row sm:items-center sm:justify-between gap-2.5 sm:gap-3 w-full">
          <button
            type="button"
            onClick={onClose}
            className="w-full sm:w-auto min-h-[44px] sm:min-h-0 px-4 py-2.5 rounded-[12px] text-[13px] font-semibold text-slate-500 hover:text-slate-800 hover:bg-slate-100/80 dark:hover:bg-slate-800 transition-colors cursor-pointer"
          >
            Close
          </button>

          <div className="flex flex-wrap items-center gap-2.5 w-full sm:w-auto">
            {totalUnits > 0 && (
              <button
                type="button"
                onClick={handleCopyClipboard}
                className="inline-flex items-center justify-center gap-1.5 px-3.5 py-2.5 rounded-[13px] bg-white dark:bg-slate-900 hover:bg-slate-50 dark:hover:bg-slate-800 border border-slate-200/90 dark:border-slate-800 text-[12.5px] font-semibold text-slate-700 dark:text-slate-300 shadow-sm transition-all active:scale-95 cursor-pointer"
              >
                <HugeiconsIcon
                  icon={copied ? Tick02Icon : Copy01Icon}
                  size={15}
                  className={copied ? 'text-emerald-500' : 'text-slate-500'}
                  strokeWidth={2}
                />
                <span>{copied ? 'Copied JSON!' : 'Copy JSON'}</span>
              </button>
            )}

            <button
              type="button"
              onClick={handleDownload}
              disabled={loading || totalUnits === 0}
              className={`btn-emerald-solid bg-emerald-600 hover:bg-emerald-700 inline-flex items-center justify-center gap-2 min-h-[44px] sm:min-h-0 px-5 py-2.5 rounded-[13px] text-[13px] font-semibold text-white shadow-sm transition-all active:scale-95 cursor-pointer disabled:opacity-50`}
            >
              <HugeiconsIcon
                icon={downloadSuccess ? CheckmarkCircle02Icon : Download01Icon}
                size={16}
                strokeWidth={2.2}
              />
              <span>
                {downloadSuccess
                  ? 'Downloaded Successfully!'
                  : loading
                  ? 'Preparing...'
                  : totalUnits === 0
                  ? `No Notes Found for Grade ${grade}`
                  : `Download Grade ${grade} ${subjectName} Notes (${totalUnits} Units)`}
              </span>
            </button>
          </div>
        </div>
      }
    >
      <div className="space-y-5">
        {/* Subject & Grade Selection Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {/* Subject Picker */}
          <div>
            <label className="block text-[12px] font-bold uppercase tracking-[0.06em] text-slate-500 dark:text-slate-400 mb-2">
              Select Subject
            </label>
            <div className="relative">
              <div className="absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400">
                <HugeiconsIcon icon={BookOpen01Icon} size={16} strokeWidth={2} />
              </div>
              <select
                value={subjectCode}
                onChange={(e) => setSubjectCode(e.target.value)}
                className="w-full appearance-none pl-9 pr-9 py-2.5 rounded-[13px] bg-white dark:bg-slate-900 border border-slate-200/85 dark:border-slate-800 focus:border-[#7E22CE] focus:outline-none text-[13px] font-semibold text-slate-800 dark:text-slate-200 cursor-pointer shadow-sm transition-colors"
              >
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
          </div>

          {/* Grade Segmented Tabs */}
          <div>
            <label className="block text-[12px] font-bold uppercase tracking-[0.06em] text-slate-500 dark:text-slate-400 mb-2">
              Select Grade
            </label>
            <div className="grid grid-cols-4 gap-1.5 p-1 rounded-[13px] bg-[#F8F9FB] dark:bg-slate-900/60 border border-slate-200/80 dark:border-slate-800">
              {GRADES.map((g) => {
                const active = grade === g;
                return (
                  <button
                    key={g}
                    type="button"
                    onClick={() => setGrade(g)}
                    className={`py-2 rounded-[10px] text-[12.5px] font-bold transition-all cursor-pointer ${
                      active
                        ? 'bg-[#7E22CE] text-white shadow-[0_2px_8px_-1px_rgba(126,34,206,0.45)]'
                        : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
                    }`}
                  >
                    Grade {g}
                  </button>
                );
              })}
            </div>
          </div>
        </div>

        {/* Scope Radio / Toggle */}
        <div className="rounded-[16px] bg-[#FBFBFD] dark:bg-slate-900/50 border border-slate-200/75 dark:border-slate-800 p-4">
          <div className="flex items-center justify-between gap-3 mb-2">
            <span className="text-[12.5px] font-bold text-slate-700 dark:text-slate-300">
              Inclusion Scope
            </span>
            <div className="inline-flex items-center gap-1.5 p-1 rounded-[11px] bg-slate-100 dark:bg-slate-800 text-[12px]">
              <button
                type="button"
                onClick={() => setStatusScope('all')}
                className={`px-3 py-1 rounded-[8px] font-semibold transition-all cursor-pointer ${
                  statusScope === 'all'
                    ? 'bg-white dark:bg-slate-900 text-slate-900 dark:text-white shadow-sm'
                    : 'text-slate-500 hover:text-slate-800 dark:hover:text-slate-300'
                }`}
              >
                All Available Notes
              </button>
              <button
                type="button"
                onClick={() => setStatusScope('approved')}
                className={`px-3 py-1 rounded-[8px] font-semibold transition-all cursor-pointer ${
                  statusScope === 'approved'
                    ? 'bg-white dark:bg-slate-900 text-slate-900 dark:text-white shadow-sm'
                    : 'text-slate-500 hover:text-slate-800 dark:hover:text-slate-300'
                }`}
              >
                Approved Only
              </button>
            </div>
          </div>
          <p className="text-[12px] text-slate-500 dark:text-slate-400">
            {statusScope === 'all'
              ? 'Includes all submitted and approved unit revision notes for this grade.'
              : 'Filters strictly to curriculum units that have been officially reviewed and approved.'}
          </p>
        </div>

        {/* Live Status Callout Card */}
        {loading ? (
          <div className="rounded-[16px] bg-[#F8FAFC] dark:bg-slate-900/60 border border-slate-200/80 dark:border-slate-800 p-6 flex flex-col items-center justify-center text-slate-400 gap-2">
            <HugeiconsIcon icon={Loading01Icon} size={24} className="animate-spin text-[#7E22CE]" strokeWidth={2} />
            <span className="text-[12.5px] font-medium">Scanning notes for Grade {grade} {subjectName}...</span>
          </div>
        ) : error ? (
          <div className="rounded-[16px] bg-rose-50 dark:bg-rose-950/30 border border-rose-200 dark:border-rose-800/60 p-4 text-xs sm:text-[13px] text-rose-600 dark:text-rose-400 flex items-center gap-2">
            <HugeiconsIcon icon={AlertCircleIcon} size={18} className="shrink-0 text-rose-500" strokeWidth={2} />
            <span>{error}</span>
          </div>
        ) : totalUnits > 0 ? (
          <div className="rounded-[18px] bg-purple-50/70 dark:bg-purple-950/30 border border-purple-200/80 dark:border-purple-800/60 p-4 sm:p-5">
            <div className="flex items-start sm:items-center justify-between gap-3 mb-3">
              <div className="flex items-center gap-2.5">
                <div className="w-7 h-7 rounded-lg bg-emerald-500 text-white flex items-center justify-center shrink-0">
                  <HugeiconsIcon icon={CheckmarkCircle02Icon} size={16} strokeWidth={2.4} />
                </div>
                <div>
                  <h4 className="text-[14px] font-bold text-slate-900 dark:text-white">
                    {totalUnits} Units Ready for Download
                  </h4>
                  <p className="text-[12px] text-slate-500 dark:text-slate-400">
                    Grade {grade} {subjectName} &bull; Output file: <code className="font-mono text-purple-700 dark:text-purple-300 font-semibold">{subjectName}-Grade-{gradePad}-Notes.json</code>
                  </p>
                </div>
              </div>
              <span className="px-2.5 py-1 rounded-full bg-purple-100 dark:bg-purple-900/50 text-[#7E22CE] dark:text-purple-300 font-mono text-[11.5px] font-bold">
                Grade {grade}
              </span>
            </div>

            {/* Units preview list */}
            <div className="max-h-[160px] overflow-y-auto rounded-[12px] bg-white dark:bg-slate-900 border border-purple-100 dark:border-slate-800 divide-y divide-slate-100 dark:divide-slate-800 text-[12px]">
              {exportData?.notes.map((n) => (
                <div key={n.unitCode} className="px-3 py-2 flex items-center justify-between gap-2">
                  <div className="flex items-center gap-2 min-w-0">
                    <span className="font-mono font-bold text-purple-600 dark:text-purple-400 shrink-0">
                      U{n.unitNumber.toString().padStart(2, '0')}
                    </span>
                    <span className="truncate text-slate-700 dark:text-slate-300 font-medium">
                      {n.unitTitle}
                    </span>
                  </div>
                  <div className="flex items-center gap-2 text-[11px] font-mono text-slate-400 shrink-0">
                    <span>{n.summaryPoints?.length || 0} pts</span>
                    <span>&bull;</span>
                    <span>{n.formulas?.length || 0} fx</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ) : (
          <div className="rounded-[16px] bg-[#FBFBFD] dark:bg-slate-900/50 border border-slate-200/80 dark:border-slate-800 p-6 text-center">
            <div className="w-10 h-10 rounded-xl bg-slate-100 dark:bg-slate-800 text-slate-400 flex items-center justify-center mx-auto mb-2.5">
              <HugeiconsIcon icon={FileCodeIcon} size={20} strokeWidth={1.8} />
            </div>
            <h4 className="text-[13.5px] font-bold text-slate-800 dark:text-slate-200">
              No Notes Found for Grade {grade} {subjectName}
            </h4>
            <p className="mt-1 text-[12px] text-slate-500 dark:text-slate-400 max-w-sm mx-auto">
              No revision notes have been submitted or approved for Grade {grade} in this subject yet.
            </p>
          </div>
        )}
      </div>
    </Modal>
  );
}
