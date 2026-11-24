'use client';

import React, { useState, useEffect } from 'react';
import { NoteSubmissionSummary, NoteSubmissionDetail } from '../../types/notes-collector';
import { NotePreviewContent } from './NotePreviewContent';
import { api } from '../../lib/api';
import { formatDate } from '../../lib/utils';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  CheckmarkCircle02Icon,
  CancelCircleIcon,
  BookOpen01Icon,
  FileCodeIcon,
  Loading01Icon,
  AlertCircleIcon,
  UserIcon,
  Clock01Icon,
  Cancel01Icon,
} from '@hugeicons/core-free-icons';

interface NoteReviewDrawerProps {
  submission: NoteSubmissionSummary | null;
  isOpen: boolean;
  onClose: () => void;
  onApproved: () => void;
  onRejected: () => void;
}

export function NoteReviewDrawer({
  submission,
  isOpen,
  onClose,
  onApproved,
  onRejected,
}: NoteReviewDrawerProps) {
  const [detail, setDetail] = useState<NoteSubmissionDetail | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [actionLoading, setActionLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [showRejectInput, setShowRejectInput] = useState<boolean>(false);
  const [rejectReason, setRejectReason] = useState<string>('');
  const [showRawJson, setShowRawJson] = useState<boolean>(false);

  useEffect(() => {
    if (isOpen && submission) {
      loadDetail(submission.unitCode);
    } else {
      setDetail(null);
      setError(null);
      setShowRejectInput(false);
      setRejectReason('');
      setShowRawJson(false);
    }
  }, [isOpen, submission]);

  const loadDetail = async (unitCode: string) => {
    setLoading(true);
    setError(null);
    try {
      const data = await api.getNoteUnitDetail(unitCode);
      setDetail(data);
    } catch (err: any) {
      setError(err.message || 'Failed to load quick note details');
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async () => {
    if (!submission) return;
    setActionLoading(true);
    try {
      await api.reviewNoteSubmission(submission._id, 'approve');
      onApproved();
      onClose();
    } catch (err: any) {
      setError(err.message || 'Approval failed');
    } finally {
      setActionLoading(false);
    }
  };

  const handleReject = async () => {
    if (!submission || !rejectReason.trim()) return;
    setActionLoading(true);
    try {
      await api.reviewNoteSubmission(submission._id, 'reject', rejectReason.trim());
      onRejected();
      onClose();
    } catch (err: any) {
      setError(err.message || 'Rejection failed');
    } finally {
      setActionLoading(false);
    }
  };

  if (!isOpen || !submission) return null;

  return (
    <div
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
      className="fixed inset-0 z-50 bg-slate-900/45 backdrop-blur-[6px] flex items-center justify-center p-3 sm:p-6 animate-in fade-in duration-200"
      role="dialog"
      aria-modal="true"
    >
      <div className="w-full max-w-[840px] max-h-[90vh] flex flex-col bg-white rounded-[24px] border border-slate-200/80 shadow-[0_32px_70px_-16px_rgba(15,23,42,0.28)] overflow-hidden animate-in zoom-in-95 duration-200">
        {/* Modal Header */}
        <div className="px-6 sm:px-7 py-5 border-b border-slate-100 flex items-start justify-between gap-4 shrink-0 bg-white">
          <div>
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-xl bg-purple-50 border border-purple-200/75 flex items-center justify-center text-[#7E22CE]">
                <HugeiconsIcon icon={BookOpen01Icon} size={18} strokeWidth={2} />
              </div>
              <h2 className="font-display text-[18px] sm:text-[20px] font-extrabold tracking-[-0.02em] text-slate-900">
                Review Quick Note: {submission.unitCode}
              </h2>
            </div>
            <p className="mt-1 text-[13px] text-slate-500">
              Grade {submission.grade} • Unit {submission.unitNumber}: {submission.unitTitle}
            </p>
          </div>

          <button
            type="button"
            onClick={onClose}
            aria-label="Close modal"
            className="p-2 rounded-full text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors cursor-pointer shrink-0"
          >
            <HugeiconsIcon icon={Cancel01Icon} size={18} strokeWidth={2} />
          </button>
        </div>

        {/* Scrollable Content Body */}
        <div className="px-6 sm:px-7 py-5 overflow-y-auto space-y-5 flex-1 bg-[#F8F9FB]/50">
          {/* Contributor Metadata Strip */}
          <div className="rounded-[15px] bg-[#FBFBFD] border border-slate-200/80 px-4 py-3 flex flex-wrap items-center justify-between gap-2 text-[12.5px]">
            <div className="flex flex-wrap items-center gap-4 text-slate-500">
              <span className="inline-flex items-center gap-1.5">
                <HugeiconsIcon icon={UserIcon} size={14} className="text-slate-400" strokeWidth={2} />
                <span>Contributor:</span>
                <strong className="font-mono font-bold text-slate-800">{submission.contributorId}</strong>
              </span>
              <span className="inline-flex items-center gap-1.5">
                <HugeiconsIcon icon={Clock01Icon} size={14} className="text-slate-400" strokeWidth={2} />
                <span>Submitted:</span>
                <strong className="font-semibold text-slate-700">{formatDate(submission.submittedAt)}</strong>
              </span>
            </div>

            <div>
              {submission.status === 'approved' && (
                <span className="px-3 py-1 rounded-full text-[11.5px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200/80">
                  Approved
                </span>
              )}
              {submission.status === 'submitted' && (
                <span className="px-3 py-1 rounded-full text-[11.5px] font-semibold bg-amber-50 text-amber-700 border border-amber-200/80">
                  Pending Review
                </span>
              )}
              {submission.status === 'rejected' && (
                <span className="px-3 py-1 rounded-full text-[11.5px] font-semibold bg-rose-50 text-rose-700 border border-rose-200/80">
                  Revision Requested
                </span>
              )}
            </div>
          </div>

          {/* Reject Reason Input Area */}
          {showRejectInput && (
            <div className="p-4 bg-rose-50/80 border border-rose-200 rounded-[16px] space-y-2.5">
              <label className="text-xs font-bold text-rose-700 block">
                Revision Feedback &amp; Required Changes:
              </label>
              <textarea
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                placeholder="Explain what needs to be fixed (e.g. formula syntax error, missing definitions, incorrect exam weight)..."
                rows={3}
                className="w-full text-xs p-3 rounded-[12px] bg-white border border-rose-300 text-slate-800 focus:outline-none focus:ring-2 focus:ring-rose-500/20"
              />
              <div className="flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowRejectInput(false)}
                  className="px-3 py-1.5 rounded-[10px] text-xs font-semibold text-slate-600 hover:bg-white transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={handleReject}
                  disabled={actionLoading || !rejectReason.trim()}
                  className="px-3.5 py-1.5 rounded-[10px] bg-rose-600 hover:bg-rose-700 text-white text-xs font-semibold transition-colors disabled:opacity-50"
                >
                  {actionLoading ? 'Submitting...' : 'Confirm Revision'}
                </button>
              </div>
            </div>
          )}

          {/* Error Message */}
          {error && (
            <div className="p-3.5 bg-rose-50 border border-rose-200 rounded-[14px] text-xs font-medium text-rose-600 flex items-center gap-2">
              <HugeiconsIcon icon={AlertCircleIcon} size={16} className="text-rose-500 shrink-0" strokeWidth={2} />
              <span>{error}</span>
            </div>
          )}

          {/* Loading or Content Display */}
          {loading ? (
            <div className="py-20 flex flex-col items-center justify-center text-slate-400 gap-2">
              <HugeiconsIcon icon={Loading01Icon} size={32} className="animate-spin text-[#7E22CE]" strokeWidth={2} />
              <span className="text-xs font-medium">Loading revision note...</span>
            </div>
          ) : detail?.note ? (
            showRawJson ? (
              <div className="rounded-[16px] bg-slate-900 text-slate-100 p-4 font-mono text-[12px] leading-relaxed overflow-x-auto shadow-inner">
                <pre>{JSON.stringify(detail.note, null, 2)}</pre>
              </div>
            ) : (
              <NotePreviewContent note={detail.note} />
            )
          ) : (
            <div className="py-12 text-center text-slate-400 text-xs">
              No note content available for this unit.
            </div>
          )}
        </div>

        {/* Modal Footer */}
        <div className="px-6 sm:px-7 py-4 bg-[#FBFBFD] border-t border-slate-100 flex flex-wrap items-center justify-between gap-3 shrink-0">
          <button
            type="button"
            onClick={() => setShowRawJson(!showRawJson)}
            className="inline-flex items-center gap-2 px-3.5 py-2 rounded-[12px] bg-white hover:bg-slate-50 border border-slate-200/90 text-[12.5px] font-semibold text-slate-700 transition-colors cursor-pointer shadow-sm"
          >
            <HugeiconsIcon icon={FileCodeIcon} size={15} className="text-slate-500" strokeWidth={2} />
            <span>{showRawJson ? 'View Structured Preview' : 'View Raw Format'}</span>
          </button>

          <div className="flex items-center gap-2.5">
            {!showRejectInput && (
              <button
                type="button"
                onClick={() => setShowRejectInput(true)}
                disabled={actionLoading}
                className="px-4 py-2 rounded-[12px] bg-white hover:bg-rose-50/70 border border-slate-200/90 hover:border-rose-200 text-[13px] font-semibold text-slate-700 hover:text-rose-600 transition-colors cursor-pointer"
              >
                Request Revision
              </button>
            )}

            <button
              type="button"
              onClick={handleApprove}
              disabled={actionLoading}
              className="btn-emerald-solid bg-emerald-600 hover:bg-emerald-700 px-4 py-2 rounded-[12px] text-white text-[13px] font-semibold inline-flex items-center gap-1.5 cursor-pointer disabled:opacity-50 shadow-sm"
            >
              <HugeiconsIcon icon={CheckmarkCircle02Icon} size={15} strokeWidth={2.2} />
              <span>{actionLoading ? 'Approving...' : 'Approve Note'}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
