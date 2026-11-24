'use client';

import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../../context/AuthContext';
import { Navbar } from '../../components/layout/Navbar';
import { AdminStatsHeader } from '../../components/admin/AdminStatsHeader';
import { SubmissionFilterBar } from '../../components/admin/SubmissionFilterBar';
import { SubmissionsTable } from '../../components/admin/SubmissionsTable';
import { SubmissionsMobileCards } from '../../components/admin/SubmissionsMobileCards';
import { ReviewDrawer } from '../../components/admin/ReviewDrawer';
import { SubmissionSummary } from '../../types/collector';
import { api } from '../../lib/api';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  Loading01Icon,
  ShieldCheckIcon,
  AlertCircleIcon,
  Download01Icon,
} from '@hugeicons/core-free-icons';

export default function AdminPage() {
  const { profile, isAuthenticated, isAdmin, loading: authLoading } = useAuth();
  const router = useRouter();

  const [submissions, setSubmissions] = useState<SubmissionSummary[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Filters & Search
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [subjectFilter, setSubjectFilter] = useState<string>('ALL');
  const [gradeFilter, setGradeFilter] = useState<number | 'ALL'>('ALL');
  const [statusFilter, setStatusFilter] = useState<string>('ALL');

  // Inspection Drawer
  const [selectedSubmission, setSelectedSubmission] = useState<SubmissionSummary | null>(null);
  const [isDrawerOpen, setIsDrawerOpen] = useState<boolean>(false);
  const [approvingId, setApprovingId] = useState<string | null>(null);

  const loadSubmissions = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await api.getAdminSubmissions({
        subjectCode: subjectFilter !== 'ALL' ? subjectFilter : undefined,
        grade: gradeFilter !== 'ALL' ? gradeFilter : undefined,
        status: statusFilter !== 'ALL' ? statusFilter : undefined,
      });
      setSubmissions(data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch admin submission queue');
    } finally {
      setLoading(false);
    }
  }, [subjectFilter, gradeFilter, statusFilter]);

  useEffect(() => {
    if (!authLoading) {
      if (!isAuthenticated) {
        router.push('/');
      } else if (!isAdmin) {
        router.push('/student');
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
  const handleQuickApprove = async (sub: SubmissionSummary) => {
    setApprovingId(sub._id);
    try {
      await api.approveSubmission(sub._id);
      await loadSubmissions();
    } catch (err: any) {
      alert(`Approval error: ${err.message || 'Failed to approve unit'}`);
    } finally {
      setApprovingId(null);
    }
  };

  // Bulk approval
  const handleBulkApprove = async (subIds: string[]) => {
    try {
      for (const id of subIds) {
        await api.approveSubmission(id);
      }
      await loadSubmissions();
    } catch (err: any) {
      alert(`Bulk approval error: ${err.message || 'Failed to approve all selected'}`);
    }
  };

  // 1-Click JSON export and download
  const handleExport = async (unitCode: string) => {
    try {
      const data = await api.exportUnitJson(unitCode);
      const jsonString = `data:text/json;charset=utf-8,${encodeURIComponent(
        JSON.stringify(data, null, 2)
      )}`;
      const downloadAnchor = document.createElement('a');
      downloadAnchor.setAttribute('href', jsonString);
      downloadAnchor.setAttribute('download', `${unitCode}.json`);
      document.body.appendChild(downloadAnchor);
      downloadAnchor.click();
      downloadAnchor.remove();
    } catch (err: any) {
      alert(`Export failed: ${err.message || 'Unable to export JSON'}`);
    }
  };

  // Bulk export bundle
  const handleExportBundle = async () => {
    try {
      const exportItems = [];
      for (const s of filteredSubmissions) {
        try {
          const unitData = await api.exportUnitJson(s.unitCode);
          exportItems.push(unitData);
        } catch {
          // fallback to summary if detail export fails
          exportItems.push(s);
        }
      }
      const jsonString = `data:text/json;charset=utf-8,${encodeURIComponent(
        JSON.stringify(exportItems, null, 2)
      )}`;
      const downloadAnchor = document.createElement('a');
      downloadAnchor.setAttribute('href', jsonString);
      downloadAnchor.setAttribute(
        'download',
        `ACEDEX-Questions-Bundle-${filteredSubmissions.length}units.json`
      );
      document.body.appendChild(downloadAnchor);
      downloadAnchor.click();
      downloadAnchor.remove();
    } catch (err: any) {
      alert(`Bundle export failed: ${err.message || 'Unable to export bundle'}`);
    }
  };

  const handleBulkExportSelected = async (unitCodes: string[]) => {
    try {
      const exportItems = [];
      for (const code of unitCodes) {
        try {
          const unitData = await api.exportUnitJson(code);
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
        `ACEDEX-Selected-Questions-${unitCodes.length}units.json`
      );
      document.body.appendChild(downloadAnchor);
      downloadAnchor.click();
      downloadAnchor.remove();
    } catch (err: any) {
      alert(`Bulk export failed: ${err.message || 'Unable to export selected'}`);
    }
  };

  const handleResetAllFilters = () => {
    setSearchQuery('');
    setSubjectFilter('ALL');
    setGradeFilter('ALL');
    setStatusFilter('ALL');
  };

  if (authLoading || !profile) {
    return (
      <div className="flex-1 flex items-center justify-center min-h-[60vh]">
        <HugeiconsIcon icon={Loading01Icon} size={32} className="animate-spin text-[#7E22CE]" strokeWidth={2} />
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
              <span>Master Review &amp; Exporter Hub</span>
            </div>

            <h1 className="font-display text-2xl sm:text-[29px] font-extrabold tracking-[-0.028em] text-slate-900 leading-tight">
              Question Ingestion Queue
            </h1>

            <p className="mt-1 text-[13.5px] sm:text-[14px] text-slate-500">
              Review sanitized contributor submissions, verify answer keys, and export canonical JSON datasets.
            </p>
          </div>

          {/* Right Contextual Action */}
          <div className="flex flex-wrap items-center gap-3 shrink-0">
            <button
              type="button"
              onClick={handleExportBundle}
              disabled={filteredSubmissions.length === 0}
              className="inline-flex items-center gap-2 px-4 sm:px-5 py-2.5 rounded-[14px] bg-white hover:bg-slate-50 border border-slate-200/90 text-[13px] font-semibold text-slate-700 hover:text-slate-900 shadow-[0_1px_2px_rgba(15,23,42,0.03)] transition-all active:scale-95 cursor-pointer disabled:opacity-50"
            >
              <HugeiconsIcon icon={Download01Icon} size={16} className="text-[#7E22CE]" strokeWidth={2} />
              <span>Export Canonical Bundle</span>
            </button>
          </div>
        </section>

        {/* 2. 4-Card KPI Metric Strip */}
        <AdminStatsHeader submissions={submissions} />

        {/* 3. Filter & Search Toolbar */}
        <SubmissionFilterBar
          searchQuery={searchQuery}
          onSearchChange={setSearchQuery}
          subjectFilter={subjectFilter}
          onSubjectChange={setSubjectFilter}
          gradeFilter={gradeFilter}
          onGradeChange={setGradeFilter}
          statusFilter={statusFilter}
          onStatusChange={setStatusFilter}
          onRefresh={loadSubmissions}
          loading={loading}
        />

        {/* Error Notification */}
        {error && (
          <div className="p-4 bg-rose-50 border border-rose-200 rounded-[16px] text-xs sm:text-sm text-rose-600 flex items-center gap-2">
            <HugeiconsIcon icon={AlertCircleIcon} size={18} className="shrink-0 text-rose-500" strokeWidth={2} />
            <span>{error}</span>
          </div>
        )}

        {/* 4. Table / Content Views */}
        {loading ? (
          <div className="py-20 flex flex-col items-center justify-center text-slate-400 gap-2">
            <HugeiconsIcon icon={Loading01Icon} size={32} className="animate-spin text-[#7E22CE]" strokeWidth={2} />
            <span className="text-sm font-medium">Loading submission queue...</span>
          </div>
        ) : (
          <div className="space-y-4">
            {/* Desktop Wide Table */}
            <div className="hidden md:block">
              <SubmissionsTable
                submissions={filteredSubmissions}
                onInspect={(sub) => {
                  setSelectedSubmission(sub);
                  setIsDrawerOpen(true);
                }}
                onApprove={handleQuickApprove}
                onExport={handleExport}
                approvingId={approvingId}
                onResetFilters={handleResetAllFilters}
                onBulkApprove={handleBulkApprove}
                onBulkExport={handleBulkExportSelected}
              />
            </div>

            {/* Mobile View: Stacked Cards */}
            <div className="md:hidden">
              <SubmissionsMobileCards
                submissions={filteredSubmissions}
                onInspect={(sub) => {
                  setSelectedSubmission(sub);
                  setIsDrawerOpen(true);
                }}
                onApprove={handleQuickApprove}
                onExport={handleExport}
                approvingId={approvingId}
              />
            </div>
          </div>
        )}
      </main>

      {/* 5. Review & Inspection Modal */}
      <ReviewDrawer
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
        onExport={handleExport}
      />
    </div>
  );
}
