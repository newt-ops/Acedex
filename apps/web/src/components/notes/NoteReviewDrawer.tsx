'use client';

import React, { useState, useEffect } from 'react';
import { NoteSubmissionSummary, NoteSubmissionDetail } from '../../types/notes-collector';
import { NotePreviewContent } from './NotePreviewContent';
import { api } from '../../lib/api';
import { Modal } from '../ui/Modal';
import { Button } from '../ui/Button';
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
  SparklesIcon,
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

  if (!submission) return null;

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title={
        <div className="flex items-center gap-2">
          <HugeiconsIcon icon={BookOpen01Icon} size={20} className="text-acedex-primary" strokeWidth={2} />
          <span>Review Quick Note: {submission.unitCode}</span>
        </div>
      }
      description={
        <span>
          Grade {submission.grade} • Unit {submission.unitNumber}: {submission.unitTitle}
        </span>
      }
      maxWidth="4xl"
      footer={
        <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between w-full gap-3">
          <div className="flex items-center gap-2">
            <button
              onClick={() => setShowRawJson(!showRawJson)}
              className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold bg-acedex-bg border border-acedex-border text-acedex-muted hover:text-acedex-text"
            >
              <HugeiconsIcon icon={FileCodeIcon} size={14} strokeWidth={2} />
              <span>{showRawJson ? 'View Rendered Preview' : 'View Raw Format'}</span>
            </button>
          </div>

          <div className="flex items-center gap-2 justify-end">
            {!showRejectInput ? (
              <>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setShowRejectInput(true)}
                  disabled={actionLoading}
                  className="hover:border-rose-500/50 hover:text-rose-400"
                >
                  Request Revision
                </Button>
                <Button
                  variant="primary"
                  size="sm"
                  onClick={handleApprove}
                  loading={actionLoading}
                  className="bg-emerald-600 hover:bg-emerald-500 text-white shadow-md shadow-emerald-600/20"
                  icon={<HugeiconsIcon icon={CheckmarkCircle02Icon} size={15} strokeWidth={2} />}
                >
                  Approve Note
                </Button>
              </>
            ) : (
              <div className="flex items-center gap-2 w-full sm:w-auto">
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setShowRejectInput(false)}
                  disabled={actionLoading}
                >
                  Cancel
                </Button>
                <Button
                  variant="danger"
                  size="sm"
                  onClick={handleReject}
                  loading={actionLoading}
                  disabled={!rejectReason.trim()}
                  icon={<HugeiconsIcon icon={CancelCircleIcon} size={15} strokeWidth={2} />}
                >
                  Confirm Revision
                </Button>
              </div>
            )}
          </div>
        </div>
      }
    >
      <div className="space-y-4">
        {/* Contributor Metadata Bar */}
        <div className="p-3.5 rounded-2xl bg-acedex-bg border border-acedex-border/80 flex flex-wrap items-center justify-between gap-3 text-xs">
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-1.5 text-acedex-muted">
              <HugeiconsIcon icon={UserIcon} size={14} strokeWidth={2} />
              <span>Contributor:</span>
              <span className="font-semibold text-acedex-text font-mono">
                {submission.contributorId}
              </span>
            </div>
            <div className="flex items-center gap-1.5 text-acedex-muted">
              <HugeiconsIcon icon={Clock01Icon} size={14} strokeWidth={2} />
              <span>Submitted:</span>
              <span className="font-semibold text-acedex-text">
                {formatDate(submission.submittedAt)}
              </span>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <span
              className={`px-2.5 py-0.5 rounded-full text-xs font-semibold capitalize ${
                submission.status === 'approved'
                  ? 'bg-emerald-500/15 text-emerald-400 border border-emerald-500/30'
                  : submission.status === 'submitted'
                  ? 'bg-amber-500/15 text-amber-400 border border-amber-500/30'
                  : 'bg-rose-500/15 text-rose-400 border border-rose-500/30'
              }`}
            >
              {submission.status}
            </span>
          </div>
        </div>

        {/* Reject reason input prompt */}
        {showRejectInput && (
          <div className="p-4 rounded-2xl bg-rose-500/10 border border-rose-500/30 space-y-2">
            <label className="block text-xs font-bold text-rose-300">
              Revision Feedback & Required Changes:
            </label>
            <textarea
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              placeholder="Explain what needs to be fixed (e.g. formula syntax error, missing definitions, incorrect EUEE exam weight)..."
              rows={3}
              className="w-full p-3 rounded-xl bg-acedex-bg border border-rose-500/40 text-xs text-acedex-text focus:outline-none focus:ring-1 focus:ring-rose-500"
            />
          </div>
        )}

        {/* Error notification */}
        {error && (
          <div className="p-3.5 rounded-xl bg-rose-500/15 border border-rose-500/30 text-xs text-rose-300 flex items-center gap-2">
            <HugeiconsIcon icon={AlertCircleIcon} size={16} strokeWidth={2} />
            <span>{error}</span>
          </div>
        )}

        {/* Loading state */}
        {loading ? (
          <div className="py-16 flex flex-col items-center justify-center text-acedex-muted gap-2">
            <HugeiconsIcon icon={Loading01Icon} size={28} className="animate-spin text-acedex-primary" strokeWidth={2} />
            <span className="text-xs">Loading revision note...</span>
          </div>
        ) : detail?.note ? (
          showRawJson ? (
            <pre className="p-4 rounded-2xl bg-acedex-bg border border-acedex-border/80 text-xs font-mono text-acedex-text overflow-x-auto max-h-[500px]">
              {JSON.stringify(detail.note, null, 2)}
            </pre>
          ) : (
            <NotePreviewContent note={detail.note} />
          )
        ) : (
          <div className="py-12 text-center text-acedex-muted text-xs">
            No note content available for this submission.
          </div>
        )}
      </div>
    </Modal>
  );
}
