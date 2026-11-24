'use client';

import React, { useState } from 'react';
import { SubmissionSummary } from '../../types/collector';
import { formatDate } from '../../lib/utils';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  EyeIcon,
  CheckmarkCircle02Icon,
  Download01Icon,
  Clock01Icon,
  AlertCircleIcon,
  Search01Icon,
} from '@hugeicons/core-free-icons';

interface SubmissionsTableProps {
  submissions: SubmissionSummary[];
  onInspect: (submission: SubmissionSummary) => void;
  onApprove: (submission: SubmissionSummary) => void;
  onExport: (unitCode: string) => void;
  approvingId?: string | null;
  onResetFilters?: () => void;
  onBulkApprove?: (subIds: string[]) => Promise<void>;
  onBulkExport?: (unitCodes: string[]) => Promise<void>;
}

export function SubmissionsTable({
  submissions,
  onInspect,
  onApprove,
  onExport,
  approvingId,
  onResetFilters,
  onBulkApprove,
  onBulkExport,
}: SubmissionsTableProps) {
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [bulkLoading, setBulkLoading] = useState<boolean>(false);

  const toggleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedIds(new Set(submissions.map((s) => s._id)));
    } else {
      setSelectedIds(new Set());
    }
  };

  const toggleSelectRow = (id: string) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  };

  const clearSelection = () => {
    setSelectedIds(new Set());
  };

  const handleBulkApprove = async () => {
    if (selectedIds.size === 0) return;
    setBulkLoading(true);
    try {
      const idsToApprove = submissions
        .filter((s) => selectedIds.has(s._id) && s.status !== 'approved')
        .map((s) => s._id);

      if (onBulkApprove && idsToApprove.length > 0) {
        await onBulkApprove(idsToApprove);
      } else {
        for (const sub of submissions.filter((s) => selectedIds.has(s._id) && s.status !== 'approved')) {
          await onApprove(sub);
        }
      }
      clearSelection();
    } finally {
      setBulkLoading(false);
    }
  };

  const handleBulkExport = async () => {
    if (selectedIds.size === 0) return;
    const unitCodes = submissions
      .filter((s) => selectedIds.has(s._id))
      .map((s) => s.unitCode);

    if (onBulkExport) {
      await onBulkExport(unitCodes);
    } else {
      for (const code of unitCodes) {
        onExport(code);
      }
    }
    clearSelection();
  };

  const isAllSelected = submissions.length > 0 && selectedIds.size === submissions.length;

  return (
    <section className="admin-surface overflow-hidden">
      {/* Contextual Bulk Action Bar */}
      {selectedIds.size > 0 && (
        <div className="px-6 py-3 bg-purple-50/95 border-b border-purple-200/80 flex flex-wrap items-center justify-between gap-3 animate-in fade-in duration-150">
          <div className="flex items-center gap-2.5 text-[13px] font-semibold text-[#7E22CE]">
            <span className="px-2.5 py-0.5 rounded-full bg-[#7E22CE] text-white text-[11.5px] font-bold tabular-nums">
              {selectedIds.size}
            </span>
            <span>items selected in current view</span>
          </div>
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={handleBulkApprove}
              disabled={bulkLoading}
              className="btn-emerald-solid px-3.5 py-1.5 rounded-[11px] text-white text-[12.5px] font-semibold inline-flex items-center gap-1.5 cursor-pointer disabled:opacity-50"
            >
              <HugeiconsIcon icon={CheckmarkCircle02Icon} size={14} strokeWidth={2.2} />
              <span>{bulkLoading ? 'Approving...' : 'Approve Selected'}</span>
            </button>
            <button
              type="button"
              onClick={handleBulkExport}
              className="px-3.5 py-1.5 rounded-[11px] bg-white hover:bg-slate-50 border border-slate-200/90 text-slate-700 text-[12.5px] font-semibold inline-flex items-center gap-1.5 cursor-pointer shadow-sm"
            >
              <HugeiconsIcon icon={Download01Icon} size={14} strokeWidth={2} className="text-slate-500" />
              <span>Export JSON</span>
            </button>
            <button
              type="button"
              onClick={clearSelection}
              className="px-2.5 py-1.5 rounded-[11px] text-[12.5px] font-medium text-slate-500 hover:text-slate-800 cursor-pointer"
            >
              Clear
            </button>
          </div>
        </div>
      )}

      {/* Responsive Wide Table Wrapper */}
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse min-w-[960px]">
          <thead className="bg-[#FBFBFD] border-b border-slate-200/75">
            <tr className="text-[11px] font-bold uppercase tracking-[0.06em] text-slate-400">
              <th className="py-3.5 pl-6 pr-3 w-10">
                <input
                  type="checkbox"
                  checked={isAllSelected}
                  onChange={(e) => toggleSelectAll(e.target.checked)}
                  aria-label="Select all submissions"
                  className="w-4 h-4 rounded border-slate-300 text-[#7E22CE] focus:ring-[#7E22CE] cursor-pointer"
                />
              </th>
              <th className="py-3.5 px-4">Unit Code</th>
              <th className="py-3.5 px-4">Unit Title</th>
              <th className="py-3.5 px-4">Contributor</th>
              <th className="py-3.5 px-4">Items</th>
              <th className="py-3.5 px-4">Submitted At</th>
              <th className="py-3.5 px-4">Status</th>
              <th className="py-3.5 pl-4 pr-6 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100/90 text-[13.5px]">
            {submissions.map((sub, idx) => {
              const isChecked = selectedIds.has(sub._id);
              const isApproved = sub.status === 'approved';
              const isApproving = approvingId === sub._id;
              const delay = (idx * 0.03).toFixed(2);

              return (
                <tr
                  key={sub._id}
                  style={{ animationDelay: `${delay}s` }}
                  className={`queue-row hover:bg-purple-50/30 transition-colors ${
                    isChecked ? 'bg-purple-50/45' : ''
                  }`}
                >
                  {/* Checkbox */}
                  <td className="py-4 pl-6 pr-3">
                    <input
                      type="checkbox"
                      checked={isChecked}
                      onChange={() => toggleSelectRow(sub._id)}
                      aria-label={`Select ${sub.unitCode}`}
                      className="w-4 h-4 rounded border-slate-300 text-[#7E22CE] focus:ring-[#7E22CE] cursor-pointer"
                    />
                  </td>

                  {/* Unit Code */}
                  <td className="py-4 px-4 font-mono text-[12.5px] font-bold text-[#7E22CE] whitespace-nowrap">
                    {sub.unitCode}
                  </td>

                  {/* Unit Title */}
                  <td className="py-4 px-4 font-semibold text-slate-900 max-w-sm truncate">
                    <span className="text-[12px] font-medium text-slate-400 mr-1.5">
                      G{sub.grade} U{sub.unitNumber}:
                    </span>
                    {sub.unitTitle}
                  </td>

                  {/* Contributor */}
                  <td className="py-4 px-4 font-mono text-[12px] text-slate-500 whitespace-nowrap">
                    {sub.contributorId}
                  </td>

                  {/* Items Count */}
                  <td className="py-4 px-4 font-semibold text-slate-700 whitespace-nowrap tabular-nums text-[12.5px]">
                    {sub.questionCount} Qs
                  </td>

                  {/* Submitted At */}
                  <td className="py-4 px-4 text-slate-500 text-[12.5px] whitespace-nowrap tabular-nums">
                    {formatDate(sub.submittedAt)}
                  </td>

                  {/* Status Pill */}
                  <td className="py-4 px-4 whitespace-nowrap">
                    {sub.status === 'approved' && (
                      <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[12px] font-semibold bg-emerald-50/90 text-emerald-700 border border-emerald-200/80">
                        <HugeiconsIcon icon={CheckmarkCircle02Icon} size={14} className="text-emerald-500" strokeWidth={2.2} />
                        <span>Approved</span>
                      </span>
                    )}
                    {sub.status === 'submitted' && (
                      <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[12px] font-semibold bg-amber-50/95 text-amber-600 border border-amber-200/85">
                        <HugeiconsIcon icon={Clock01Icon} size={14} className="text-amber-500" strokeWidth={2.1} />
                        <span>Pending</span>
                      </span>
                    )}
                    {sub.status === 'rejected' && (
                      <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[12px] font-semibold bg-rose-50/95 text-rose-600 border border-rose-200/85">
                        <HugeiconsIcon icon={AlertCircleIcon} size={14} className="text-rose-500" strokeWidth={2.1} />
                        <span>Rejected</span>
                      </span>
                    )}
                  </td>

                  {/* Actions */}
                  <td className="py-4 pl-4 pr-6 text-right whitespace-nowrap">
                    <div className="inline-flex items-center justify-end gap-2">
                      <button
                        type="button"
                        onClick={() => onInspect(sub)}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-[11px] bg-white hover:bg-slate-50 border border-slate-200/90 text-[12.5px] font-semibold text-slate-700 hover:text-slate-900 shadow-[0_1px_2px_rgba(15,23,42,0.03)] transition-all active:scale-95 cursor-pointer"
                        title="Inspect questions"
                      >
                        <HugeiconsIcon icon={EyeIcon} size={14} className="text-slate-500" strokeWidth={1.8} />
                        <span>Inspect</span>
                      </button>

                      {!isApproved ? (
                        <button
                          type="button"
                          onClick={() => onApprove(sub)}
                          disabled={isApproving}
                          className="btn-emerald-solid px-3.5 py-1.5 rounded-[11px] text-white text-[12.5px] font-semibold inline-flex items-center gap-1.5 cursor-pointer disabled:opacity-50"
                          title="Approve unit"
                        >
                          <HugeiconsIcon icon={CheckmarkCircle02Icon} size={14} strokeWidth={2.2} />
                          <span>{isApproving ? 'Approving...' : 'Approve'}</span>
                        </button>
                      ) : (
                        <button
                          type="button"
                          onClick={() => onExport(sub.unitCode)}
                          className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-[11px] bg-emerald-50/70 hover:bg-emerald-100/80 border border-emerald-200/85 text-[12.5px] font-semibold text-emerald-700 transition-all active:scale-95 cursor-pointer"
                          title="Export JSON"
                        >
                          <HugeiconsIcon icon={Download01Icon} size={14} className="text-emerald-600" strokeWidth={2} />
                          <span>Export</span>
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* Empty State Box */}
      {submissions.length === 0 && (
        <div className="py-16 px-6 text-center">
          <div className="w-12 h-12 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3">
            <HugeiconsIcon icon={Search01Icon} size={24} strokeWidth={1.8} />
          </div>
          <h3 className="text-[15px] font-bold text-slate-800">No matching submissions found</h3>
          <p className="mt-1 text-[13px] text-slate-500">
            Try clearing your search query or switching grade/status filters.
          </p>
          {onResetFilters && (
            <button
              type="button"
              onClick={onResetFilters}
              className="mt-4 px-4 py-2 rounded-[12px] bg-purple-50 hover:bg-purple-100 text-[#7E22CE] text-[12.5px] font-semibold transition-colors cursor-pointer"
            >
              Reset All Filters
            </button>
          )}
        </div>
      )}

      {/* Table Footer Summary */}
      <div className="px-6 py-3.5 bg-[#FBFBFD] border-t border-slate-200/70 flex flex-wrap items-center justify-between gap-3 text-[12.5px] text-slate-500">
        <div className="font-medium tabular-nums">
          Showing {submissions.length} canonical submissions
        </div>
        <div className="flex items-center gap-2 text-[12px]">
          <span className="inline-flex items-center gap-1.5 text-emerald-600 font-semibold">
            <span className="w-2 h-2 rounded-full bg-emerald-500" />
            Schema v2.4 Sanitized
          </span>
          <span className="text-slate-300">•</span>
          <span>Live Question Bank Sync Ready</span>
        </div>
      </div>
    </section>
  );
}
