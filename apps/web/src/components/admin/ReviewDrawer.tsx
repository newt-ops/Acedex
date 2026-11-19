'use client';

import React, { useState, useEffect } from 'react';
import { SubmissionSummary, SubmissionDetail } from '../../types/collector';
import { api } from '../../lib/api';
import { Modal } from '../ui/Modal';
import { Button } from '../ui/Button';
import { Badge } from '../ui/Badge';
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

  if (!submission) return null;

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      maxWidth="4xl"
      title={
        <div className="flex items-center gap-2">
          <HugeiconsIcon icon={FileCodeIcon} size={20} className="text-acedex-primary" strokeWidth={1.5} />
          <span>Inspect Submission: {submission.unitCode}</span>
        </div>
      }
      description={
        <span>
          Grade {submission.grade} • Unit {submission.unitNumber}: {submission.unitTitle} • Contributor:{' '}
          <span className="font-mono text-acedex-text">{submission.contributorId}</span>
        </span>
      }
      footer={
        <div className="flex items-center justify-between w-full flex-wrap gap-2">
          <Badge status={detail?.status || submission.status} />

          <div className="flex items-center gap-2">
            {detail?.status === 'approved' ? (
              <Button
                variant="outline"
                size="sm"
                className="text-emerald-400 border-emerald-500/30 hover:bg-emerald-500/10 text-xs"
                onClick={() => onExport(submission.unitCode)}
              >
                <HugeiconsIcon icon={Download01Icon} size={15} className="mr-1" strokeWidth={1.5} /> Export JSON
              </Button>
            ) : (
              <>
                {!showRejectInput ? (
                  <Button
                    variant="danger"
                    size="sm"
                    className="text-xs"
                    onClick={() => setShowRejectInput(true)}
                    disabled={actionLoading}
                  >
                    <HugeiconsIcon icon={CancelCircleIcon} size={15} className="mr-1" strokeWidth={1.5} /> Reject
                  </Button>
                ) : (
                  <Button
                    variant="ghost"
                    size="sm"
                    className="text-xs"
                    onClick={() => setShowRejectInput(false)}
                  >
                    Cancel
                  </Button>
                )}

                <Button
                  variant="success"
                  size="sm"
                  className="text-xs"
                  onClick={handleApprove}
                  loading={actionLoading}
                >
                  <HugeiconsIcon icon={CheckmarkCircle02Icon} size={15} className="mr-1" strokeWidth={1.75} /> Approve Unit
                </Button>
              </>
            )}
          </div>
        </div>
      }
    >
      <div className="space-y-4">
        {/* Error message */}
        {error && (
          <div className="p-3 bg-rose-500/15 border border-rose-500/30 rounded-xl text-xs text-rose-400 flex items-center gap-2">
            <HugeiconsIcon icon={AlertCircleIcon} size={16} className="shrink-0 text-rose-500" strokeWidth={1.5} />
            <span>{error}</span>
          </div>
        )}

        {/* Reject note input */}
        {showRejectInput && (
          <div className="p-3.5 bg-rose-500/10 border border-rose-500/30 rounded-xl space-y-2">
            <label className="text-xs font-semibold text-rose-400 block">
              Reason for Rejection (Visible to student):
            </label>
            <textarea
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              placeholder="e.g. Question 4 is missing an explanation, please revise and resubmit."
              className="w-full text-xs p-2.5 rounded-lg bg-acedex-bg border border-rose-500/40 text-acedex-text focus:outline-none focus:border-rose-400"
              rows={2}
            />
            <div className="flex justify-end">
              <Button
                variant="danger"
                size="sm"
                className="text-xs"
                onClick={handleReject}
                loading={actionLoading}
                disabled={!rejectReason.trim()}
              >
                Confirm Rejection
              </Button>
            </div>
          </div>
        )}

        {/* Loading state */}
        {loading && (
          <div className="py-12 flex flex-col items-center justify-center text-acedex-muted gap-2">
            <HugeiconsIcon icon={Loading01Icon} size={24} className="animate-spin text-acedex-primary" strokeWidth={2} />
            <span className="text-xs">Loading questions and options...</span>
          </div>
        )}

        {/* Question cards */}
        {detail && detail.questions && (
          <div className="space-y-3">
            <div className="text-xs font-semibold text-acedex-muted flex items-center justify-between pb-1 border-b border-acedex-border/40">
              <span>Verified Questions ({detail.questions.length} Items)</span>
              <span>Submitted: {formatDate(detail.submittedAt)}</span>
            </div>

            {detail.questions.map((q, idx) => (
              <div
                key={q.id || idx}
                className="p-4 rounded-xl bg-acedex-bg border border-acedex-border/80 space-y-3"
              >
                {/* Question header */}
                <div className="flex items-center justify-between text-xs font-mono text-acedex-muted">
                  <span className="font-semibold text-acedex-primary">
                    Question #{idx + 1} ({q.id})
                  </span>
                  <span className="capitalize px-2 py-0.5 rounded bg-acedex-card border border-acedex-border/60">
                    {q.difficulty || 'medium'}
                  </span>
                </div>

                {/* Question prompt */}
                <p className="text-sm font-medium text-acedex-text leading-relaxed">
                  {q.question}
                </p>

                {/* Multiple choice options */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
                  {q.options.map((opt) => {
                    const isCorrect = opt.id === q.correctOptionId;
                    return (
                      <div
                        key={opt.id}
                        className={`p-2.5 rounded-lg border flex items-start gap-2 ${
                          isCorrect
                            ? 'bg-emerald-500/15 border-emerald-500/40 text-emerald-300 font-semibold'
                            : 'bg-acedex-card/80 border-acedex-border/50 text-acedex-muted'
                        }`}
                      >
                        <span
                          className={`w-5 h-5 rounded-full flex items-center justify-center text-[10px] font-bold shrink-0 ${
                            isCorrect
                              ? 'bg-emerald-500 text-white'
                              : 'bg-acedex-border text-acedex-muted'
                          }`}
                        >
                          {opt.id}
                        </span>
                        <span className="flex-1 leading-normal">{opt.text}</span>
                        {isCorrect && (
                          <HugeiconsIcon icon={Tick02Icon} size={15} className="text-emerald-400 shrink-0 ml-1" strokeWidth={2} />
                        )}
                      </div>
                    );
                  })}
                </div>

                {/* Explanation */}
                {q.explanation && (
                  <div className="p-2.5 rounded-lg bg-acedex-card/50 border border-acedex-border/40 text-xs text-acedex-muted">
                    <span className="font-semibold text-acedex-text">Explanation: </span>
                    {q.explanation}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </Modal>
  );
}
