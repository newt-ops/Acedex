'use client';

import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../../../context/AuthContext';
import { Navbar } from '../../../components/layout/Navbar';
import { NoteAdminStatsHeader } from '../../../components/notes/NoteAdminStatsHeader';
import { NoteSubmissionsTable } from '../../../components/notes/NoteSubmissionsTable';
import { NoteSubmissionsMobileCards } from '../../../components/notes/NoteSubmissionsMobileCards';
import { NoteReviewDrawer } from '../../../components/notes/NoteReviewDrawer';
import { NoteSubmissionSummary } from '../../../types/notes-collector';
import { SUBJECTS } from '../../../lib/constants';
import { api } from '../../../lib/api';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  Loading01Icon,
  ShieldCheckIcon,
  AlertCircleIcon,
  Refresh01Icon,
  FilterIcon,
  Search01Icon,
  Cancel01Icon,
  CheckmarkCircle02Icon,
  ArrowDown01Icon,
} from '@hugeicons/core-free-icons';

export default function AdminNotesPage() {
  const { profile, isAuthenticated, isAdmin, loading: authLoading } = useAuth();
  const router = useRouter();

  const [submissions, setSubmissions] = useState<NoteSubmissionSummary[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [syncing, setSyncing] = useState<boolean>(false);
  const [syncMessage, setSyncMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Filters & Search
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [subjectFilter, setSubjectFilter] = useState<string>('ALL');
  const [gradeFilter, setGradeFilter] = useState<number | 'ALL'>('ALL');
  const [statusFilter, setStatusFilter] = useState<string>('ALL');

  // Inspection Drawer
  const [selectedSubmission, setSelectedSubmission] = useState<NoteSubmissionSummary | null>(null);
  const [isDrawerOpen, setIsDrawerOpen] = useState<boolean>(false);
  const [approvingId, setApprovingId] = useState<string | null>(null);

  const loadSubmissions = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await api.getAdminNoteSubmissions({
        subjectCode: subjectFilter !== 'ALL' ? subjectFilter : undefined,
        grade: gradeFilter !== 'ALL' ? Number(gradeFilter) : undefined,
        status: statusFilter !== 'ALL' ? statusFilter : undefined,
      });
      setSubmissions(data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch quick note submissions');
    } finally {
      setLoading(false);
    }
  }, [subjectFilter, gradeFilter, statusFilter]);

  useEffect(() => {
    if (!authLoading) {
      if (!isAuthenticated) {
        router.push('/');
      } else if (!isAdmin) {
        router.push('/notes');
      } else {
        loadSubmissions();
      }
    }
  }, [authLoading, isAuthenticated, isAdmin, router, loadSubmissions]);

  // Client-side text filter on top of server query
  const filteredSubmissions = useMemo(() => {
    if (!searchQuery.trim()) return submissions;
    const q = searchQuery.toLowerCase();
    return submissions.filter(
      (s) =>
        s.unitCode.toLowerCase().includes(q) ||
        s.unitTitle.toLowerCase().includes(q) ||
        s.contributorId.toLowerCase().includes(q)
    );
  }, [submissions, searchQuery]);

  // Quick 1-click approval
  const handleQuickApprove = async (sub: NoteSubmissionSummary) => {
    setApprovingId(sub._id);
    try {
      await api.reviewNoteSubmission(sub._id, 'approve');
      await loadSubmissions();
    } catch (err: any) {
      alert(`Approval error: ${err.message || 'Failed to approve note'}`);
    } finally {
      setApprovingId(null);
    }
  };

  // Bulk approval
  const handleBulkApprove = async (subIds: string[]) => {
    try {
      for (const id of subIds) {
        await api.reviewNoteSubmission(id, 'approve');
      }
      await loadSubmissions();
    } catch (err: any) {
      alert(`Bulk approval error: ${err.message || 'Failed to approve all selected'}`);
    }
  };

  // Bulk export note units as JSON
  const handleBulkExport = async (unitCodes: string[]) => {
    try {
      const exportItems = [];
      for (const code of unitCodes) {
        try {
          const unitData = await api.getNoteUnitDetail(code);
          exportItems.push(unitData);
        } catch {
          exportItems.push({ unitCode: code });
        }
      }
      const jsonString = `data:text/json;charset=utf-8,${encodeURIComponent(
        JSON.stringify(exportItems, null, 2)
      )}`;
      const downloadAnchor = document.createElement('a');
      downloadAnchor.setAttribute('href', jsonString);
      downloadAnchor.setAttribute(
        'download',
        `ACEDEX-Notes-Bundle-${unitCodes.length}units.json`
      );
      document.body.appendChild(downloadAnchor);
      downloadAnchor.click();
      downloadAnchor.remove();
    } catch (err: any) {
      alert(`Export failed: ${err.message || 'Unable to export notes bundle'}`);
    }
  };

  // Sync approved notes from database to local storage
  const handleSyncToLocal = async () => {
    setSyncing(true);
    setSyncMessage(null);
    setError(null);
    try {
      const result = await api.syncLocalNotes();
      setSyncMessage(
        `✓ Sync Complete: ${result.exportedCount} approved notes synchronized.`
      );
      await loadSubmissions();
    } catch (err: any) {
      setError(err.message || 'Sync operation failed');
    } finally {
      setSyncing(false);
    }
  };

  const handleResetAllFilters = () => {
    setSearchQuery('');
    setSubjectFilter('ALL');
    setGradeFilter('ALL');
    setStatusFilter('ALL');
  };

  const gradeOptions: { val: number | 'ALL'; label: string }[] = [
    { val: 'ALL', label: 'All Grades' },
    { val: 9, label: 'G9' },
    { val: 10, label: 'G10' },
    { val: 11, label: 'G11' },
    { val: 12, label: 'G12' },
  ];

  const statusOptions: { val: string; label: string }[] = [
    { val: 'ALL', label: 'All Status' },
    { val: 'submitted', label: 'Pending' },
    { val: 'approved', label: 'Approved' },
    { val: 'rejected', label: 'Revision' },
  ];

  if (authLoading || !profile) {
    return (
      <div className="flex-1 flex items-center justify-center min-h-[60vh]">
        <HugeiconsIcon
          icon={Loading01Icon}
          size={32}
          className="animate-spin text-[#7E22CE]"
          strokeWidth={2}
        />
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col min-h-screen bg-[#F8F9FB] pb-16 selection:bg-purple-500/15 selection:text-purple-700">
      <Navbar />

      <main className="flex-1 w-full max-w-[1640px] mx-auto px-4 sm:px-8 lg:px-10 py-6 sm:py-8 space-y-6">
        {/* 1. Hero Command Banner */}
        <section className="admin-surface p-6 sm:p-7 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-5">
          <div>
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-purple-50 border border-purple-200/75 text-[#7E22CE] text-[11.5px] font-semibold mb-2.5">
              <HugeiconsIcon icon={ShieldCheckIcon} size={14} className="shrink-0" strokeWidth={2} />
              <span>Curriculum Verification Hub</span>
            </div>

            <h1 className="font-display text-2xl sm:text-[29px] font-extrabold tracking-[-0.028em] text-slate-900 leading-tight">
              Quick Notes Review &amp; Sync
            </h1>

            <p className="mt-1 text-[13.5px] sm:text-[14px] text-slate-500">
              Review and verify high-yield revision notes across all subjects.
            </p>
          </div>

          {/* Right Contextual Action: Sync Button */}
          <div className="flex flex-wrap items-center gap-3 shrink-0">
            <button
              type="button"
              onClick={handleSyncToLocal}
              disabled={syncing}
              className="btn-acedex-primary px-5 py-2.5 rounded-[14px] text-white text-[13px] font-semibold inline-flex items-center gap-2 cursor-pointer disabled:opacity-60"
            >
              <HugeiconsIcon
                icon={Refresh01Icon}
                size={16}
                className={syncing ? 'animate-spin' : ''}
                strokeWidth={2.1}
              />
              <span>{syncing ? 'Syncing...' : 'Sync Approved Notes'}</span>
            </button>
          </div>
        </section>

        {/* Sync feedback notification */}
        {syncMessage && (
          <div className="p-4 rounded-[16px] bg-emerald-50 border border-emerald-200 text-xs sm:text-sm font-semibold text-emerald-700 flex items-center justify-between animate-in fade-in duration-200">
            <div className="flex items-center gap-2">
              <HugeiconsIcon icon={CheckmarkCircle02Icon} size={18} className="text-emerald-500 shrink-0" strokeWidth={2} />
              <span>{syncMessage}</span>
            </div>
            <button
              type="button"
              onClick={() => setSyncMessage(null)}
              className="text-xs text-emerald-600 hover:text-emerald-800 font-semibold cursor-pointer"
            >
              Dismiss
            </button>
          </div>
        )}

        {/* 2. 4-Card KPI Metric Strip */}
        <NoteAdminStatsHeader submissions={submissions} />

        {/* 3. Filter & Search Toolbar */}
        <section className="admin-surface p-4 sm:px-6 sm:py-4 flex flex-col xl:flex-row xl:items-center xl:justify-between gap-3.5">
          {/* Left: Search + Subject Dropdown + Segmented Grade Pills */}
          <div className="flex flex-wrap items-center gap-3">
            {/* Search Input */}
            <div className="relative w-full sm:w-[250px] lg:w-[280px]">
              <div className="absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400">
                <HugeiconsIcon icon={Search01Icon} size={16} strokeWidth={2} />
              </div>
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search unit code, title, ID..."
                className="w-full pl-9 pr-8 py-2 rounded-[13px] bg-[#F8F9FB] hover:bg-slate-100/80 focus:bg-white border border-slate-200/85 focus:border-[#7E22CE] focus:ring-4 focus:ring-purple-600/10 text-[13px] text-slate-800 placeholder:text-slate-400 focus:outline-none transition-all"
              />
              {searchQuery && (
                <button
                  type="button"
                  onClick={() => setSearchQuery('')}
                  aria-label="Clear search"
                  className="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 p-0.5 cursor-pointer"
                >
                  <HugeiconsIcon icon={Cancel01Icon} size={14} strokeWidth={2} />
                </button>
              )}
            </div>

            {/* Subject Dropdown */}
            <div className="relative">
              <div className="absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400">
                <HugeiconsIcon icon={FilterIcon} size={14} strokeWidth={2} />
              </div>
              <select
                value={subjectFilter}
                onChange={(e) => setSubjectFilter(e.target.value)}
                className="appearance-none pl-9 pr-9 py-2 rounded-[13px] bg-white hover:bg-slate-50 border border-slate-200/85 focus:border-[#7E22CE] focus:outline-none text-[13px] font-semibold text-slate-700 cursor-pointer transition-colors"
              >
                <option value="ALL">All 8 Subjects</option>
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

            {/* Segmented Grade Pills */}
            <div className="inline-flex items-center p-1 rounded-[14px] bg-[#F8F9FB] border border-slate-200/80">
              {gradeOptions.map((g) => {
                const active = gradeFilter === g.val;
                return (
                  <button
                    key={String(g.val)}
                    type="button"
                    onClick={() => setGradeFilter(g.val)}
                    className={`px-3 py-1.5 rounded-[10px] text-[12px] font-semibold transition-all cursor-pointer ${
                      active
                        ? 'bg-[#7E22CE] text-white shadow-[0_2px_8px_-1px_rgba(126,34,206,0.45)]'
                        : 'text-slate-600 hover:text-slate-900'
                    }`}
                  >
                    {g.label}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Right: Status Pills + Refresh Button */}
          <div className="flex flex-wrap items-center justify-between xl:justify-end gap-3">
            <div className="inline-flex items-center p-1 rounded-[14px] bg-[#F8F9FB] border border-slate-200/80">
              {statusOptions.map((s) => {
                const active = statusFilter === s.val;
                return (
                  <button
                    key={s.val}
                    type="button"
                    onClick={() => setStatusFilter(s.val)}
                    className={`px-3 py-1.5 rounded-[10px] text-[12px] font-semibold transition-all cursor-pointer ${
                      active
                        ? 'bg-white text-slate-900 shadow-[0_1px_4px_rgba(15,23,42,0.08)] border border-slate-200/70'
                        : 'text-slate-500 hover:text-slate-800'
                    }`}
                  >
                    {s.label}
                  </button>
                );
              })}
            </div>

            {/* Refresh Button */}
            <button
              type="button"
              onClick={loadSubmissions}
              disabled={loading}
              className="inline-flex items-center gap-2 px-3.5 py-2 rounded-[13px] bg-white hover:bg-slate-50 border border-slate-200/90 text-[13px] font-semibold text-slate-700 hover:text-slate-900 shadow-[0_1px_2px_rgba(15,23,42,0.03)] transition-all active:scale-95 cursor-pointer disabled:opacity-60"
            >
              <HugeiconsIcon
                icon={Refresh01Icon}
                size={14}
                strokeWidth={2}
                className={`text-slate-500 ${loading ? 'animate-spin' : ''}`}
              />
              <span>Refresh</span>
            </button>
          </div>
        </section>

        {/* Error Notification */}
        {error && (
          <div className="p-4 bg-rose-50 border border-rose-200 rounded-[16px] text-xs sm:text-sm text-rose-600 flex items-center gap-2">
            <HugeiconsIcon icon={AlertCircleIcon} size={18} className="text-rose-500 shrink-0" strokeWidth={2} />
            <span>{error}</span>
          </div>
        )}

        {/* 4. Table / Content Views */}
        {loading ? (
          <div className="py-20 flex flex-col items-center justify-center text-slate-400 gap-2">
            <HugeiconsIcon icon={Loading01Icon} size={32} className="animate-spin text-[#7E22CE]" strokeWidth={2} />
            <span className="text-sm font-medium">Loading quick note queue...</span>
          </div>
        ) : (
          <div className="space-y-4">
            {/* Desktop Wide Table */}
            <div className="hidden md:block">
              <NoteSubmissionsTable
                submissions={filteredSubmissions}
                onInspect={(sub) => {
                  setSelectedSubmission(sub);
                  setIsDrawerOpen(true);
                }}
                onApprove={handleQuickApprove}
                approvingId={approvingId}
                onResetFilters={handleResetAllFilters}
                onBulkApprove={handleBulkApprove}
                onBulkExport={handleBulkExport}
              />
            </div>

            {/* Mobile View: Stacked Cards */}
            <div className="md:hidden">
              <NoteSubmissionsMobileCards
                submissions={filteredSubmissions}
                onInspect={(sub) => {
                  setSelectedSubmission(sub);
                  setIsDrawerOpen(true);
                }}
                onApprove={handleQuickApprove}
                approvingId={approvingId}
              />
            </div>
          </div>
        )}
      </main>

      {/* 5. Review & Inspection Modal */}
      <NoteReviewDrawer
        submission={selectedSubmission}
        isOpen={isDrawerOpen}
        onClose={() => {
          setIsDrawerOpen(false);
          setSelectedSubmission(null);
        }}
        onApproved={() => {
          loadSubmissions();
        }}
        onRejected={() => {
          loadSubmissions();
        }}
      />
    </div>
  );
}
