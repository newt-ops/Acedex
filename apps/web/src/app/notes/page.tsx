'use client';

import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../../context/AuthContext';
import { Navbar } from '../../components/layout/Navbar';
import { Container } from '../../components/layout/Container';
import { GradeNoteCard } from '../../components/notes/GradeNoteCard';
import { GradeNoteSubmitModal } from '../../components/notes/GradeNoteSubmitModal';
import { ProgressBar } from '../../components/ui/ProgressBar';
import { Button } from '../../components/ui/Button';
import { NoteSubjectUnitsResponse, NoteUnitProgressItem } from '../../types/notes-collector';
import { SUBJECTS, GRADES } from '../../lib/constants';
import { api } from '../../lib/api';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  Loading01Icon,
  BookOpen01Icon,
  AlertCircleIcon,
  Refresh01Icon,
  Upload01Icon,
} from '@hugeicons/core-free-icons';

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
        <Container className="py-6 space-y-8">
          {/* Top Banner: Subject Info & Progress */}
          <div className="bg-acedex-card/90 border border-acedex-border/80 rounded-3xl p-5 sm:p-7 shadow-lg relative overflow-hidden backdrop-blur-xl">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
              <div className="space-y-2">
                <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-acedex-primary/15 text-acedex-primary border border-acedex-primary/30">
                  <HugeiconsIcon icon={BookOpen01Icon} size={14} strokeWidth={2} />
                  <span>Subject Workspace</span>
                </div>
                <h1 className="text-2xl sm:text-3xl font-black text-acedex-text tracking-tight">
                  {subjectName} ({subjectCode})
                </h1>
                <p className="text-xs sm:text-sm text-acedex-muted flex items-center gap-2">
                  <span>Assigned Contributor: <strong className="text-acedex-text">{profile.name}</strong> ({profile.contributorId})</span>
                </p>
              </div>

              {/* Progress Summary Card */}
              {unitTree && (
                <div className="w-full sm:w-72 bg-acedex-bg/80 border border-acedex-border/70 p-4 rounded-2xl shrink-0">
                  <ProgressBar
                    current={unitTree.approvedUnits}
                    total={unitTree.totalUnits}
                    label="Approved Coverage"
                  />
                </div>
              )}
            </div>
          </div>

          {/* Section: Submit by Grade Cards */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-base sm:text-lg font-bold text-acedex-text flex items-center gap-2">
                  <HugeiconsIcon icon={Upload01Icon} size={18} className="text-acedex-primary" strokeWidth={2} />
                  <span>Submit Notes by Grade</span>
                </h2>
                <p className="text-xs text-acedex-muted">
                  Generate full textbook revision notes for each grade at once using NotebookLM, and submit the complete grade batch.
                </p>
              </div>
            </div>

            {/* Error Alert */}
            {error && (
              <div className="p-4 bg-rose-500/15 border border-rose-500/30 rounded-2xl text-xs sm:text-sm text-rose-300 flex items-center justify-between animate-in fade-in duration-200">
                <div className="flex items-center gap-2">
                  <HugeiconsIcon icon={AlertCircleIcon} size={18} className="text-rose-400 shrink-0" strokeWidth={2} />
                  <span>{error}</span>
                </div>
                <Button
                  size="sm"
                  variant="outline"
                  onClick={loadUnits}
                  icon={<HugeiconsIcon icon={Refresh01Icon} size={14} strokeWidth={2} />}
                >
                  Retry
                </Button>
              </div>
            )}

            {/* Grade Cards with Smooth Skeleton Loading */}
            {loading ? (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 animate-pulse">
                {[1, 2, 3, 4].map((i) => (
                  <div
                    key={i}
                    className="p-6 rounded-3xl bg-acedex-card/70 border border-acedex-border/60 h-64 flex flex-col justify-between space-y-4"
                  >
                    <div className="space-y-3">
                      <div className="flex justify-between">
                        <div className="h-6 w-20 bg-acedex-bg/80 rounded-xl" />
                        <div className="h-6 w-24 bg-acedex-bg/80 rounded-full" />
                      </div>
                      <div className="h-6 w-3/4 bg-acedex-bg/80 rounded-lg" />
                      <div className="h-4 w-1/2 bg-acedex-bg/80 rounded-md" />
                    </div>
                    <div className="space-y-2">
                      <div className="h-2 w-full bg-acedex-bg/80 rounded-full" />
                      <div className="grid grid-cols-3 gap-2">
                        <div className="h-10 bg-acedex-bg/80 rounded-xl" />
                        <div className="h-10 bg-acedex-bg/80 rounded-xl" />
                        <div className="h-10 bg-acedex-bg/80 rounded-xl" />
                      </div>
                    </div>
                    <div className="h-10 bg-acedex-bg/80 rounded-xl" />
                  </div>
                ))}
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                {GRADES.map((grade) => {
                  const stat = gradeStats[grade] || { approved: 0, submitted: 0, total: 0, units: [] };
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
          </div>
        </Container>
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
