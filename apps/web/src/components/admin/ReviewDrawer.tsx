'use client';

import React, { useState, useEffect } from 'react';
import { SubmissionSummary, SubmissionDetail } from '../../types/collector';
import { api } from '../../lib/api';
import { formatDate } from '../../lib/utils';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  CheckmarkCircle02Icon,
  CancelCircleIcon,
  Download01Icon,
  FileCodeIcon,
  Loading01Icon,
  AlertCircleIcon,
  Tick02Icon,
  Cancel01Icon,
  Clock01Icon,
} from '@hugeicons/core-free-icons';

interface ReviewDrawerProps {
  submission: SubmissionSummary | null;
  isOpen: boolean;
  onClose: () => void;
  onApproved: () => void;
  onRejected: () => void;
  onExport: (unitCode: string) => void;
}

export function ReviewDrawer({
  submission,
  isOpen,
  onClose,
  onApproved,
  onRejected,
  onExport,
}: ReviewDrawerProps) {
  const [detail, setDetail] = useState<SubmissionDetail | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [actionLoading, setActionLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [showRejectInput, setShowRejectInput] = useState<boolean>(false);
  const [rejectReason, setRejectReason] = useState<string>('');

  useEffect(() => {
    if (isOpen && submission) {
      loadDetail(submission._id);
    } else {
      setDetail(null);
      setError(null);
      setShowRejectInput(false);
      setRejectReason('');
    }
  }, [isOpen, submission]);

  const loadDetail = async (id: string) => {
    setLoading(true);
    setError(null);
    try {
      const data = await api.getSubmissionDetail(id);
      setDetail(data);
    } catch (err: any) {
      setError(err.message || 'Failed to load submission questions');
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async () => {
    if (!submission) return;
    setActionLoading(true);
    try {
      await api.approveSubmission(submission._id);
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
      await api.rejectSubmission(submission._id, rejectReason.trim());
      onRejected();
      onClose();
    } catch (err: any) {
      setError(err.message || 'Rejection failed');
    } finally {
      setActionLoading(false);
    }
  };

  if (!isOpen || !submission) return null;

  const currentStatus = detail?.status || submission.status;
  const isApproved = currentStatus === 'approved';

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
                <HugeiconsIcon icon={FileCodeIcon} size={18} strokeWidth={2} />
              </div>
              <h2 className="font-display text-[18px] sm:text-[20px] font-extrabold tracking-[-0.02em] text-slate-900">
                Inspect Submission: {submission.unitCode}
              </h2>
            </div>
            <p className="mt-1 text-[13px] text-slate-500">
              Grade {submission.grade} • Unit {submission.unitNumber}: {submission.unitTitle} • Contributor:{' '}
              <strong className="font-mono font-semibold text-slate-700">{submission.contributorId}</strong>
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

        {/* Meta Sub-Bar */}
        <div className="px-6 sm:px-7 py-2.5 bg-[#FBFBFD] border-b border-slate-100 flex items-center justify-between text-[12.5px] text-slate-500 shrink-0">
          <span className="font-semibold text-slate-700">
            Verified Questions ({detail?.questions?.length || submission.questionCount} Items)
          </span>
          <span className="tabular-nums">Submitted: {formatDate(submission.submittedAt)}</span>
        </div>

        {/* Scrollable Question Cards List */}
        <div className="px-6 sm:px-7 py-5 overflow-y-auto space-y-4 flex-1 bg-[#F8F9FB]/60">
          {/* Error Banner */}
          {error && (
            <div className="p-3.5 bg-rose-50 border border-rose-200 rounded-[14px] text-xs font-medium text-rose-600 flex items-center gap-2">
              <HugeiconsIcon icon={AlertCircleIcon} size={16} className="text-rose-500 shrink-0" strokeWidth={2} />
              <span>{error}</span>
            </div>
          )}

          {/* Reject Input Box */}
          {showRejectInput && (
            <div className="p-4 bg-rose-50/70 border border-rose-200/80 rounded-[16px] space-y-2.5">
              <label className="text-xs font-bold text-rose-700 block">
                Reason for Rejection (Visible to student):
              </label>
              <textarea
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                placeholder="e.g. Question 4 is missing an explanation, please revise and resubmit."
                rows={2}
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
                  {actionLoading ? 'Rejecting...' : 'Confirm Rejection'}
                </button>
              </div>
            </div>
          )}

          {/* Loading Indicator */}
          {loading && (
            <div className="py-16 flex flex-col items-center justify-center text-slate-400 gap-2">
              <HugeiconsIcon icon={Loading01Icon} size={28} className="animate-spin text-[#7E22CE]" strokeWidth={2} />
              <span className="text-xs font-medium">Loading questions and verified keys...</span>
            </div>
          )}

          {/* Render Questions */}
          {detail && detail.questions && detail.questions.map((q, idx) => (
            <div
              key={q.id || idx}
              className="rounded-[18px] bg-white border border-slate-200/80 p-5 shadow-[0_4px_16px_-6px_rgba(15,23,42,0.04)] space-y-3.5"
            >
              {/* Question Header */}
              <div className="flex items-center justify-between gap-2">
                <span className="font-mono text-[12px] font-bold text-[#7E22CE]">
                  Question #{idx + 1} ({q.id})
                </span>
                <span className="px-2.5 py-0.5 rounded-lg bg-slate-100 border border-slate-200/75 text-[11px] font-semibold text-slate-600 capitalize">
                  {q.difficulty || 'medium'}
                </span>
              </div>

              {/* Prompt */}
              <p className="text-[14.5px] font-bold text-slate-900 leading-snug">
                {q.question}
              </p>

              {/* Options Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                {q.options.map((opt) => {
                  const isCorrect = opt.id === q.correctOptionId;
                  return (
                    <div
                      key={opt.id}
                      className={`flex items-center justify-between gap-2.5 px-3.5 py-2.5 rounded-[12px] border text-[13px] ${
                        isCorrect
                          ? 'bg-emerald-50/75 border-emerald-300/90 text-emerald-700 font-semibold'
                          : 'bg-[#FBFBFD] border-slate-200/80 text-slate-600'
                      }`}
                    >
                      <div className="flex items-center gap-2.5 min-w-0">
                        <span
                          className={`w-5 h-5 rounded-full text-[11px] font-bold flex items-center justify-center shrink-0 ${
                            isCorrect
                              ? 'bg-emerald-500 text-white'
                              : 'bg-slate-200/80 text-slate-600'
                          }`}
                        >
                          {opt.id}
                        </span>
                        <span className="truncate">{opt.text}</span>
                      </div>
                      {isCorrect && (
                        <HugeiconsIcon icon={Tick02Icon} size={15} className="text-emerald-500 shrink-0" strokeWidth={2.4} />
                      )}
                    </div>
                  );
                })}
              </div>

              {/* Explanation Callout */}
              {q.explanation && (
                <div className="rounded-[12px] bg-[#F8F9FB] border border-slate-200/75 px-3.5 py-2.5 text-[12px] leading-relaxed text-slate-600">
                  <strong className="font-semibold text-slate-800">Explanation:</strong> {q.explanation}
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Modal Footer */}
        <div className="px-6 sm:px-7 py-4 bg-white border-t border-slate-100 flex flex-wrap items-center justify-between gap-3 shrink-0">
          <div>
            {isApproved ? (
              <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[12.5px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200/80">
                <HugeiconsIcon icon={CheckmarkCircle02Icon} size={15} className="text-emerald-500" strokeWidth={2.2} />
                <span>Approved</span>
              </span>
            ) : (
              <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[12.5px] font-semibold bg-amber-50 text-amber-600 border border-amber-200/80">
                <HugeiconsIcon icon={Clock01Icon} size={15} className="text-amber-500" strokeWidth={2} />
                <span>Pending Verification</span>
              </span>
            )}
          </div>

          <div className="flex items-center gap-2.5">
            {!isApproved ? (
              <>
                {!showRejectInput && (
                  <button
                    type="button"
                    onClick={() => setShowRejectInput(true)}
                    disabled={actionLoading}
                    className="px-4 py-2 rounded-[12px] bg-white hover:bg-rose-50/70 border border-slate-200/90 hover:border-rose-200 text-[13px] font-semibold text-slate-700 hover:text-rose-600 transition-colors cursor-pointer"
                  >
                    Reject Unit
                  </button>
                )}
                <button
                  type="button"
                  onClick={handleApprove}
                  disabled={actionLoading}
                  className="btn-emerald-solid px-4 py-2 rounded-[12px] text-white text-[13px] font-semibold inline-flex items-center gap-1.5 cursor-pointer disabled:opacity-50"
                >
                  <HugeiconsIcon icon={CheckmarkCircle02Icon} size={15} strokeWidth={2.2} />
                  <span>{actionLoading ? 'Approving...' : 'Approve Unit'}</span>
                </button>
              </>
            ) : (
              <button
                type="button"
                onClick={() => onExport(submission.unitCode)}
                className="px-4 py-2 rounded-[12px] bg-emerald-50/70 hover:bg-emerald-100/80 border border-emerald-200/90 text-emerald-700 text-[13px] font-semibold inline-flex items-center gap-2 transition-colors cursor-pointer"
              >
                <HugeiconsIcon icon={Download01Icon} size={15} className="text-emerald-600" strokeWidth={2} />
                <span>Export JSON</span>
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
