'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../../../context/AuthContext';
import { Navbar } from '../../../components/layout/Navbar';
import { Container } from '../../../components/layout/Container';
import { NoteAdminStatsHeader } from '../../../components/notes/NoteAdminStatsHeader';
import { NoteSubmissionsTable } from '../../../components/notes/NoteSubmissionsTable';
import { NoteSubmissionsMobileCards } from '../../../components/notes/NoteSubmissionsMobileCards';
import { NoteReviewDrawer } from '../../../components/notes/NoteReviewDrawer';
import { NoteSubmissionSummary } from '../../../types/notes-collector';
import { SUBJECTS, GRADES } from '../../../lib/constants';
import { api } from '../../../lib/api';
import { Button } from '../../../components/ui/Button';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  Loading01Icon,
  ShieldCheckIcon,
  AlertCircleIcon,
  Refresh01Icon,
  FilterIcon,
} from '@hugeicons/core-free-icons';

export default function AdminNotesPage() {
  const { profile, isAuthenticated, isAdmin, loading: authLoading } = useAuth();
  const router = useRouter();

  const [submissions, setSubmissions] = useState<NoteSubmissionSummary[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [syncing, setSyncing] = useState<boolean>(false);
  const [syncMessage, setSyncMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Filters
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

  if (authLoading || !profile) {
    return (
      <div className="flex-1 flex items-center justify-center min-h-[60vh]">
        <HugeiconsIcon
          icon={Loading01Icon}
          size={32}
          className="animate-spin text-acedex-primary"
          strokeWidth={2}
        />
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col pb-16">
      <Navbar />

      <main className="flex-1">
        <Container className="py-6 space-y-6">
          {/* Header Banner */}
          <div className="bg-acedex-card/90 border border-acedex-border/80 rounded-3xl p-5 sm:p-7 shadow-lg relative overflow-hidden backdrop-blur-xl">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div>
                <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-acedex-primary/15 text-acedex-primary border border-acedex-primary/30 mb-2">
                  <HugeiconsIcon icon={ShieldCheckIcon} size={15} strokeWidth={2} />
                  <span>Curriculum Verification Hub</span>
                </div>
                <h1 className="text-2xl sm:text-3xl font-black text-acedex-text tracking-tight">
                  Quick Notes Review & Sync
                </h1>
                <p className="text-xs sm:text-sm text-acedex-muted mt-1">
                  Review and verify high-yield revision notes across all subjects.
                </p>
              </div>

              {/* Sync Button */}
              <div className="shrink-0">
                <Button
                  onClick={handleSyncToLocal}
                  loading={syncing}
                  variant="primary"
                  className="bg-acedex-primary hover:bg-acedex-primary-hover text-white shadow-md shadow-purple-500/20 w-full sm:w-auto"
                  icon={
                    <HugeiconsIcon
                      icon={Refresh01Icon}
                      size={15}
                      className={syncing ? 'animate-spin' : ''}
                      strokeWidth={2}
                    />
                  }
                >
                  Sync Approved Notes
                </Button>
              </div>
            </div>

            {/* Sync feedback banner */}
            {syncMessage && (
              <div className="mt-4 p-3 rounded-2xl bg-emerald-500/15 border border-emerald-500/30 text-xs font-semibold text-emerald-300 flex items-center justify-between animate-in fade-in duration-200">
                <span>{syncMessage}</span>
                <button
                  onClick={() => setSyncMessage(null)}
                  className="text-xs text-emerald-400 hover:underline ml-2"
                >
                  Dismiss
                </button>
              </div>
            )}
          </div>

          {/* Metric Stats Cards */}
          <NoteAdminStatsHeader submissions={submissions} />

          {/* Filters Bar */}
          <div className="p-4 rounded-2xl bg-acedex-card/90 border border-acedex-border/80 shadow-sm flex flex-wrap items-center justify-between gap-3">
            <div className="flex flex-wrap items-center gap-2.5">
              {/* Subject Dropdown */}
              <div className="flex items-center gap-1.5 bg-acedex-bg border border-acedex-border px-3 py-1.5 rounded-xl text-xs transition-colors hover:border-acedex-primary/40">
                <HugeiconsIcon icon={FilterIcon} size={13} className="text-acedex-muted" strokeWidth={2} />
                <select
                  value={subjectFilter}
                  onChange={(e) => setSubjectFilter(e.target.value)}
                  className="bg-transparent text-xs font-semibold text-acedex-text focus:outline-none cursor-pointer"
                >
                  <option value="ALL">All 8 Subjects</option>
                  {Object.entries(SUBJECTS).map(([code, name]) => (
                    <option key={code} value={code} className="bg-acedex-card text-acedex-text">
                      {name} ({code})
                    </option>
                  ))}
                </select>
              </div>

              {/* Grade Filter Pills */}
              <div className="flex items-center p-1 rounded-xl bg-acedex-bg border border-acedex-border text-xs">
                <button
                  onClick={() => setGradeFilter('ALL')}
                  className={`px-2.5 py-1 rounded-lg font-bold transition-all duration-150 ${
                    gradeFilter === 'ALL'
                      ? 'bg-acedex-primary text-white shadow-sm'
                      : 'text-acedex-muted hover:text-acedex-text'
                  }`}
                >
                  All Grades
                </button>
                {GRADES.map((g) => (
                  <button
                    key={g}
                    onClick={() => setGradeFilter(g)}
                    className={`px-2.5 py-1 rounded-lg font-bold transition-all duration-150 ${
                      gradeFilter === g
                        ? 'bg-acedex-primary text-white shadow-sm'
                        : 'text-acedex-muted hover:text-acedex-text'
                    }`}
                  >
                    G{g}
                  </button>
                ))}
              </div>

              {/* Status Filter Pills */}
              <div className="flex items-center p-1 rounded-xl bg-acedex-bg border border-acedex-border text-xs">
                {['ALL', 'submitted', 'approved', 'rejected'].map((st) => (
                  <button
                    key={st}
                    onClick={() => setStatusFilter(st)}
                    className={`px-2.5 py-1 rounded-lg font-bold capitalize transition-all duration-150 ${
                      statusFilter === st
                        ? 'bg-acedex-card text-acedex-text border border-acedex-border shadow-sm'
                        : 'text-acedex-muted hover:text-acedex-text'
                    }`}
                  >
                    {st === 'ALL' ? 'All Status' : st === 'submitted' ? 'Pending' : st}
                  </button>
                ))}
              </div>
            </div>

            {/* Refresh Button */}
            <Button
              size="sm"
              variant="outline"
              onClick={loadSubmissions}
              loading={loading}
              icon={<HugeiconsIcon icon={Refresh01Icon} size={14} strokeWidth={2} />}
            >
              Refresh
            </Button>
          </div>

          {/* Error Message */}
          {error && (
            <div className="p-4 bg-rose-500/15 border border-rose-500/30 rounded-2xl text-xs sm:text-sm text-rose-300 flex items-center gap-2 animate-in fade-in duration-200">
              <HugeiconsIcon icon={AlertCircleIcon} size={18} className="text-rose-400 shrink-0" strokeWidth={2} />
              <span>{error}</span>
            </div>
          )}

          {/* Table / Cards content with Skeleton Loading */}
          {loading ? (
            <div className="p-6 rounded-3xl border border-acedex-border/80 bg-acedex-card/90 space-y-4 animate-pulse">
              <div className="h-4 w-36 bg-acedex-bg rounded" />
              <div className="space-y-3">
                {[1, 2, 3, 4, 5].map((i) => (
                  <div key={i} className="h-12 bg-acedex-bg/80 rounded-xl" />
                ))}
              </div>
            </div>
          ) : (
            <div className="animate-in fade-in duration-200">
              <NoteSubmissionsTable
                submissions={submissions}
                onInspect={(sub) => {
                  setSelectedSubmission(sub);
                  setIsDrawerOpen(true);
                }}
                onApprove={handleQuickApprove}
                approvingId={approvingId}
              />
              <NoteSubmissionsMobileCards
                submissions={submissions}
                onInspect={(sub) => {
                  setSelectedSubmission(sub);
                  setIsDrawerOpen(true);
                }}
                onApprove={handleQuickApprove}
                approvingId={approvingId}
              />
            </div>
          )}
        </Container>
      </main>

      {/* Review Drawer */}
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
