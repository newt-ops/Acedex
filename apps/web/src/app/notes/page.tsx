'use client';

import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../../context/AuthContext';
import { Navbar } from '../../components/layout/Navbar';
import { GradeNoteCard } from '../../components/notes/GradeNoteCard';
import { GradeNoteSubmitModal } from '../../components/notes/GradeNoteSubmitModal';
import { NoteSubjectUnitsResponse, NoteUnitProgressItem } from '../../types/notes-collector';
import { SUBJECTS, GRADES } from '../../lib/constants';
import { api } from '../../lib/api';
import { HugeiconsIcon } from '@hugeicons/react';
import { Loading01Icon, AlertCircleIcon, Refresh01Icon } from '@hugeicons/core-free-icons';
import { Button } from '../../components/ui/Button';

export default function NotesContributorPage() {
  const { profile, isAuthenticated, loading: authLoading } = useAuth();
  const router = useRouter();

  const [unitTree, setUnitTree] = useState<NoteSubjectUnitsResponse | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Grade Batch Modal state
  const [gradeModalTarget, setGradeModalTarget] = useState<number | null>(null);
  const [isGradeModalOpen, setIsGradeModalOpen] = useState<boolean>(false);

  const loadUnits = useCallback(async () => {
    if (!profile) return;
    setLoading(true);
    setError(null);
    try {
      const data = await api.getNoteUnits(profile.subjectCode, profile.contributorId);
      setUnitTree(data);
    } catch (err: any) {
      setError(err.message || 'Unable to load curriculum revision notes');
    } finally {
      setLoading(false);
    }
  }, [profile]);

  useEffect(() => {
    if (!authLoading) {
      if (!isAuthenticated) {
        router.push('/');
      } else {
        loadUnits();
      }
    }
  }, [authLoading, isAuthenticated, router, loadUnits]);

  // Calculate grade statistics
  const gradeStats = useMemo(() => {
    const stats: Record<number, { approved: number; submitted: number; total: number; units: NoteUnitProgressItem[] }> = {};
    GRADES.forEach((g) => {
      stats[g] = { approved: 0, submitted: 0, total: 0, units: [] };
    });

    unitTree?.grades.forEach((g) => {
      const approvedCount = g.units.filter((u) => u.status === 'approved').length;
      const submittedCount = g.units.filter((u) => u.status === 'submitted').length;
      stats[g.grade] = {
        approved: approvedCount,
        submitted: submittedCount,
        total: g.units.length,
        units: g.units,
      };
    });

    return stats;
  }, [unitTree]);

  const subjectCode = profile?.subjectCode || 'ENG';
  const subjectName = profile?.subjectName || SUBJECTS[subjectCode] || subjectCode;

  const approvedUnits = unitTree?.approvedUnits || 0;
  const totalUnits = unitTree?.totalUnits || 32;
  const coveragePct = totalUnits > 0 ? Math.round((approvedUnits / totalUnits) * 100) : 0;

  if (authLoading || !profile) {
    return (
      <div className="flex-1 flex items-center justify-center p-4 min-h-[60vh]">
        <HugeiconsIcon icon={Loading01Icon} size={32} className="animate-spin text-[#7E22CE]" strokeWidth={2} />
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col pb-16">
      <Navbar />

      <main className="flex-1 w-full max-w-[1380px] mx-auto px-4 sm:px-7 py-5 sm:py-8">
        {/* Subject Workspace Hero Banner */}
        <section className="apple-card apple-card-hover p-5 sm:p-7 mb-6 sm:mb-7 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 sm:gap-5">
          {/* Left: Subject Identity */}
          <div>
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-purple-50/90 border border-purple-200/70 text-[#7E22CE] text-[11px] sm:text-[11.5px] font-semibold mb-2.5 sm:mb-3">
              <svg className="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M2 6C2 4.89543 2.89543 4 4 4H9C10.6569 4 12 5.34315 12 7V20C12 18.8954 11.1046 18 10 18H4C2.89543 18 2 17.1046 2 16V6Z" />
                <path d="M22 6C22 4.89543 21.1046 4 20 4H15C13.3431 4 12 5.34315 12 7V20C12 18.8954 12.8954 18 14 18H20C21.1046 18 22 17.1046 22 16V6Z" />
              </svg>
              <span>Subject Workspace</span>
            </div>

            <h1 className="font-display text-2xl sm:text-3xl font-extrabold tracking-[-0.025em] text-slate-900 leading-tight">
              {subjectName} ({subjectCode})
            </h1>

            <p className="mt-1 sm:mt-1.5 text-[13px] sm:text-[13.5px] text-slate-500">
              Assigned Contributor:{' '}
              <strong className="font-semibold text-slate-800">{profile.name}</strong>{' '}
              <span className="font-mono text-slate-500">({profile.contributorId})</span>
            </p>
          </div>

          {/* Right: Approved Coverage Sub-Card */}
          <div className="w-full lg:w-[325px] rounded-[16px] sm:rounded-[18px] bg-[#FBFBFD] border border-slate-200/75 px-4 sm:px-5 py-3.5 sm:py-4 shadow-[inset_0_1px_2px_rgba(15,23,42,0.02)]">
            <div className="flex items-center justify-between gap-3 mb-2.5">
              <span className="text-[12px] sm:text-[12.5px] font-medium text-slate-500">Approved Coverage</span>
              <div className="text-[12.5px] sm:text-[13px] font-bold tabular-nums text-slate-900">
                {approvedUnits} / {totalUnits} Units
                <span className="ml-1 text-[#7E22CE] font-semibold">({coveragePct}%)</span>
              </div>
            </div>

            {/* Animated Progress Track */}
            <div className="w-full h-2.5 rounded-full bg-slate-200/75 overflow-hidden p-[1px]">
              <div
                style={{ width: `${coveragePct}%` }}
                className="h-full rounded-full bg-gradient-to-r from-[#7E22CE] via-[#9333EA] to-[#10B981] transition-all duration-700 ease-spring"
              />
            </div>
          </div>
        </section>

        {/* Section Title & Description */}
        <div className="mb-6">
          <div className="flex items-center gap-2.5">
            <div className="w-7 h-7 rounded-lg bg-purple-50 border border-purple-200/70 flex items-center justify-center text-[#7E22CE]">
              <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M21 15V19C21 20.1046 20.1046 21 19 21H5C3.89543 21 3 20.1046 3 19V15" />
                <path d="M17 8L12 3L7 8" />
                <path d="M12 3V15" />
              </svg>
            </div>
            <h2 className="font-display text-[19px] font-extrabold tracking-[-0.02em] text-slate-900">
              Submit Notes by Grade
            </h2>
          </div>
          <p className="mt-1 text-[13.5px] text-slate-500">
            Generate full textbook revision notes for each grade at once using NotebookLM, and submit the complete grade batch.
          </p>
        </div>

        {/* Error Alert */}
        {error && (
          <div className="p-4 mb-5 bg-rose-500/15 border border-rose-500/30 rounded-2xl text-xs sm:text-sm text-rose-600 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <HugeiconsIcon icon={AlertCircleIcon} size={18} className="text-rose-500 shrink-0" strokeWidth={1.5} />
              <span>{error}</span>
            </div>
            <Button
              size="sm"
              variant="outline"
              onClick={loadUnits}
              icon={<HugeiconsIcon icon={Refresh01Icon} size={14} strokeWidth={1.5} />}
            >
              Retry
            </Button>
          </div>
        )}

        {/* Grade Cards with Smooth Skeleton Loading */}
        {loading ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-5 animate-pulse">
            {[1, 2, 3, 4].map((i) => (
              <div
                key={i}
                className="apple-card p-5 sm:p-6 h-[260px] flex flex-col justify-between"
              >
                <div className="space-y-3">
                  <div className="flex justify-between">
                    <div className="h-5 w-20 bg-slate-100 rounded-full" />
                    <div className="h-5 w-24 bg-slate-100 rounded-full" />
                  </div>
                  <div className="h-6 w-3/4 bg-slate-100 rounded-lg" />
                  <div className="h-4 w-1/2 bg-slate-100 rounded-md" />
                </div>
                <div className="space-y-3">
                  <div className="grid grid-cols-3 gap-2">
                    <div className="h-10 bg-slate-100 rounded-xl" />
                    <div className="h-10 bg-slate-100 rounded-xl" />
                    <div className="h-10 bg-slate-100 rounded-xl" />
                  </div>
                  <div className="h-11 bg-slate-100 rounded-[13px]" />
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-5">
            {GRADES.map((grade) => {
              const stat = gradeStats[grade] || { approved: 0, submitted: 0, total: 8, units: [] };
              return (
                <GradeNoteCard
                  key={grade}
                  grade={grade}
                  subjectName={subjectName}
                  units={stat.units}
                  onSubmitGradeClick={(g) => {
                    setGradeModalTarget(g);
                    setIsGradeModalOpen(true);
                  }}
                />
              );
            })}
          </div>
        )}
      </main>

      {/* Grade Batch Submission Modal */}
      {gradeModalTarget && (
        <GradeNoteSubmitModal
          grade={gradeModalTarget}
          subjectCode={subjectCode}
          subjectName={subjectName}
          units={gradeStats[gradeModalTarget]?.units || []}
          isOpen={isGradeModalOpen}
          onClose={() => {
            setIsGradeModalOpen(false);
            setGradeModalTarget(null);
          }}
          onSuccess={() => {
            loadUnits();
          }}
        />
      )}
    </div>
  );
}
