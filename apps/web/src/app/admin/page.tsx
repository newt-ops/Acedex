'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../../context/AuthContext';
import { Navbar } from '../../components/layout/Navbar';
import { Container } from '../../components/layout/Container';
import { AdminStatsHeader } from '../../components/admin/AdminStatsHeader';
import { SubmissionFilterBar } from '../../components/admin/SubmissionFilterBar';
import { SubmissionsTable } from '../../components/admin/SubmissionsTable';
import { SubmissionsMobileCards } from '../../components/admin/SubmissionsMobileCards';
import { ReviewDrawer } from '../../components/admin/ReviewDrawer';
import { SubmissionSummary } from '../../types/collector';
import { api } from '../../lib/api';
import { HugeiconsIcon } from '@hugeicons/react';
import { Loading01Icon, ShieldCheckIcon, AlertCircleIcon } from '@hugeicons/core-free-icons';

export default function AdminPage() {
  const { profile, isAuthenticated, isAdmin, loading: authLoading } = useAuth();
  const router = useRouter();

  const [submissions, setSubmissions] = useState<SubmissionSummary[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Filters
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

  // Quick 1-click approval from table or card
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

  if (authLoading || !profile) {
    return (
      <div className="flex-1 flex items-center justify-center p-4">
        <HugeiconsIcon icon={Loading01Icon} size={32} className="animate-spin text-acedex-primary" strokeWidth={2} />
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col pb-12">
      <Navbar />

      <main className="flex-1">
        <Container className="py-6 space-y-6">
          {/* Admin Header Title */}
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div>
              <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-acedex-accent/15 text-acedex-accent border border-acedex-accent/30 mb-1.5">
                <HugeiconsIcon icon={ShieldCheckIcon} size={15} className="shrink-0" strokeWidth={1.5} />
                <span>Master Review & Exporter Hub</span>
              </div>
              <h1 className="text-xl sm:text-2xl font-bold text-acedex-text tracking-tight">
                Question Ingestion Queue
              </h1>
              <p className="text-xs sm:text-sm text-acedex-muted mt-0.5">
                Review sanitized student submissions, verify answer keys, and export canonical JSON datasets.
              </p>
            </div>
          </div>

          {/* Metric Stats Cards */}
          <AdminStatsHeader submissions={submissions} />

          {/* Filters Bar */}
          <SubmissionFilterBar
            subjectFilter={subjectFilter}
            onSubjectChange={setSubjectFilter}
            gradeFilter={gradeFilter}
            onGradeChange={setGradeFilter}
            statusFilter={statusFilter}
            onStatusChange={setStatusFilter}
            onRefresh={loadSubmissions}
            loading={loading}
          />

          {/* Error Message */}
          {error && (
            <div className="p-4 bg-rose-500/15 border border-rose-500/30 rounded-xl text-xs sm:text-sm text-rose-400 flex items-center gap-2">
              <HugeiconsIcon icon={AlertCircleIcon} size={20} className="shrink-0 text-rose-500" strokeWidth={1.5} />
              <span>{error}</span>
            </div>
          )}

          {/* Content Views */}
          {loading ? (
            <div className="py-16 flex flex-col items-center justify-center text-acedex-muted gap-2">
              <HugeiconsIcon icon={Loading01Icon} size={32} className="animate-spin text-acedex-primary" strokeWidth={2} />
              <span className="text-sm">Loading submission queue...</span>
            </div>
          ) : (
            <div>
              {/* Desktop View: Table */}
              <SubmissionsTable
                submissions={submissions}
                onInspect={(sub) => {
                  setSelectedSubmission(sub);
                  setIsDrawerOpen(true);
                }}
                onApprove={handleQuickApprove}
                onExport={handleExport}
                approvingId={approvingId}
              />

              {/* Mobile View: Stacked Cards */}
              <SubmissionsMobileCards
                submissions={submissions}
                onInspect={(sub) => {
                  setSelectedSubmission(sub);
                  setIsDrawerOpen(true);
                }}
                onApprove={handleQuickApprove}
                onExport={handleExport}
                approvingId={approvingId}
              />
            </div>
          )}
        </Container>
      </main>

      {/* Review & Inspection Modal Drawer */}
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
