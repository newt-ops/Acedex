'use client';

import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../../context/AuthContext';
import { Navbar } from '../../components/layout/Navbar';
import { Container } from '../../components/layout/Container';
import { NoteUnitCard } from '../../components/notes/NoteUnitCard';
import { NoteSubmitModal } from '../../components/notes/NoteSubmitModal';
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
  Search01Icon,
  SparklesIcon,
  FilterIcon,
} from '@hugeicons/core-free-icons';

export default function NotesContributorPage() {
  const { profile, isAuthenticated, isAdmin, loading: authLoading } = useAuth();
  const router = useRouter();

  const [selectedSubject, setSelectedSubject] = useState<string>('ENG');
  const [activeGrade, setActiveGrade] = useState<number>(9);
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [unitTree, setUnitTree] = useState<NoteSubjectUnitsResponse | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Submit Modal state
  const [selectedUnit, setSelectedUnit] = useState<NoteUnitProgressItem | null>(null);
  const [isSubmitModalOpen, setIsSubmitModalOpen] = useState<boolean>(false);

  // Set default subject on profile load
  useEffect(() => {
    if (profile?.subjectCode) {
      setSelectedSubject(profile.subjectCode);
    }
  }, [profile]);

  const loadUnits = useCallback(async () => {
    if (!profile) return;
    setLoading(true);
    setError(null);
    try {
      const data = await api.getNoteUnits(selectedSubject, profile.contributorId);
      setUnitTree(data);
    } catch (err: any) {
      setError(err.message || 'Failed to load subject quick notes curriculum');
    } finally {
      setLoading(false);
    }
  }, [profile, selectedSubject]);

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
    const stats: Record<number, { approved: number; submitted: number; total: number }> = {};
    GRADES.forEach((g) => {
      stats[g] = { approved: 0, submitted: 0, total: 0 };
    });

    unitTree?.grades.forEach((g) => {
      const approvedCount = g.units.filter((u) => u.status === 'approved').length;
      const submittedCount = g.units.filter((u) => u.status === 'submitted').length;
      stats[g.grade] = {
        approved: approvedCount,
        submitted: submittedCount,
        total: g.units.length,
      };
    });

    return stats;
  }, [unitTree]);

  // Current grade units filtered by search query
  const currentGradeData = unitTree?.grades.find((g) => g.grade === activeGrade);
  const filteredUnits = useMemo(() => {
    const units = currentGradeData?.units || [];
    if (!searchQuery.trim()) return units;
    const q = searchQuery.toLowerCase();
    return units.filter(
      (u) =>
        u.unitTitle.toLowerCase().includes(q) ||
        u.unitCode.toLowerCase().includes(q) ||
        u.unitNumber.toString() === q
    );
  }, [currentGradeData, searchQuery]);

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
          {/* Top Banner: Subject Selector & Curriculum Progress */}
          <div className="bg-acedex-card/90 border border-acedex-border/80 rounded-3xl p-5 sm:p-7 shadow-lg relative overflow-hidden backdrop-blur-xl">
            <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
              <div className="space-y-2">
                <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-gradient-to-r from-violet-500/15 to-indigo-500/15 text-violet-400 border border-violet-500/30">
                  <HugeiconsIcon icon={BookOpen01Icon} size={14} strokeWidth={2} />
                  <span>237-Unit Quick Revision Portal</span>
                </div>
                <h1 className="text-2xl sm:text-3xl font-black text-acedex-text tracking-tight">
                  {SUBJECTS[selectedSubject] || selectedSubject} Revision Notes
                </h1>
                <p className="text-xs sm:text-sm text-acedex-muted flex items-center gap-2">
                  <span>Contributor: <strong className="text-acedex-text">{profile.name}</strong> ({profile.contributorId})</span>
                  <span className="text-acedex-border">•</span>
                  <span>Database: <code className="text-violet-400 text-xs font-mono">acedex_notes</code></span>
                </p>
              </div>

              {/* Subject Selector & Progress Box */}
              <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
                <div className="flex items-center gap-2 bg-acedex-bg/80 border border-acedex-border/70 px-3 py-2 rounded-2xl">
                  <HugeiconsIcon icon={FilterIcon} size={15} className="text-acedex-muted" strokeWidth={2} />
                  <select
                    value={selectedSubject}
                    onChange={(e) => setSelectedSubject(e.target.value)}
                    className="bg-transparent text-xs sm:text-sm font-semibold text-acedex-text focus:outline-none cursor-pointer"
                  >
                    {Object.entries(SUBJECTS).map(([code, name]) => (
                      <option key={code} value={code} className="bg-acedex-card text-acedex-text">
                        {name} ({code})
                      </option>
                    ))}
                  </select>
                </div>

                {unitTree && (
                  <div className="w-full sm:w-64 bg-acedex-bg/80 border border-acedex-border/70 p-3.5 rounded-2xl shrink-0">
                    <ProgressBar
                      current={unitTree.approvedUnits}
                      total={unitTree.totalUnits}
                      label="Approved Coverage"
                    />
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Controls Bar: Grade Selector Tabs & Search */}
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            {/* Grade Tabs */}
            <div className="flex items-center p-1.5 rounded-2xl bg-acedex-card/90 border border-acedex-border/80 shadow-inner overflow-x-auto">
              {GRADES.map((grade) => {
                const stat = gradeStats[grade] || { approved: 0, submitted: 0, total: 0 };
                const isActive = activeGrade === grade;
                return (
                  <button
                    key={grade}
                    onClick={() => setActiveGrade(grade)}
                    className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs sm:text-sm font-bold transition-all shrink-0 ${
                      isActive
                        ? 'bg-gradient-to-r from-violet-600 to-indigo-600 text-white shadow-md shadow-violet-500/20'
                        : 'text-acedex-muted hover:text-acedex-text hover:bg-acedex-card-hover'
                    }`}
                  >
                    <span>Grade {grade}</span>
                    <span
                      className={`px-1.5 py-0.5 rounded-md text-[10px] font-mono font-bold ${
                        isActive
                          ? 'bg-white/20 text-white'
                          : 'bg-acedex-bg text-acedex-muted'
                      }`}
                    >
                      {stat.approved}/{stat.total}
                    </span>
                  </button>
                );
              })}
            </div>

            {/* Unit Search Bar */}
            <div className="relative sm:w-72">
              <HugeiconsIcon
                icon={Search01Icon}
                size={16}
                className="absolute left-3.5 top-1/2 -translate-y-1/2 text-acedex-muted"
                strokeWidth={2}
              />
              <input
                type="text"
                placeholder="Search unit title or code..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-9 pr-4 py-2.5 rounded-2xl bg-acedex-card/90 border border-acedex-border/80 text-xs sm:text-sm text-acedex-text placeholder:text-acedex-muted focus:outline-none focus:ring-2 focus:ring-violet-500/50"
              />
            </div>
          </div>

          {/* Error Alert */}
          {error && (
            <div className="p-4 bg-rose-500/15 border border-rose-500/30 rounded-2xl text-xs sm:text-sm text-rose-300 flex items-center justify-between">
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

          {/* Unit Grid */}
          {loading ? (
            <div className="py-20 flex flex-col items-center justify-center text-acedex-muted gap-3">
              <HugeiconsIcon
                icon={Loading01Icon}
                size={36}
                className="animate-spin text-violet-400"
                strokeWidth={2}
              />
              <span className="text-sm font-medium">
                Loading Grade {activeGrade} {SUBJECTS[selectedSubject]} revision curriculum...
              </span>
            </div>
          ) : (
            <div className="space-y-4">
              <div className="flex items-center justify-between text-xs text-acedex-muted">
                <span>
                  Showing {filteredUnits.length} units for Grade {activeGrade}
                </span>
                <span className="font-semibold text-acedex-text">
                  Target: 1 High-Yield Note per Unit (237 total across all grades)
                </span>
              </div>

              {filteredUnits.length === 0 ? (
                <div className="p-12 text-center rounded-3xl bg-acedex-card/50 border border-acedex-border/60 text-acedex-muted space-y-2">
                  <p className="font-medium text-sm">No curriculum units match &ldquo;{searchQuery}&rdquo;</p>
                  <button
                    onClick={() => setSearchQuery('')}
                    className="text-xs text-violet-400 hover:underline font-semibold"
                  >
                    Clear search filter
                  </button>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {filteredUnits.map((unit) => (
                    <NoteUnitCard
                      key={unit.unitCode}
                      unit={unit}
                      onSubmitClick={(target) => {
                        setSelectedUnit(target);
                        setIsSubmitModalOpen(true);
                      }}
                    />
                  ))}
                </div>
              )}
            </div>
          )}
        </Container>
      </main>

      {/* Note Submit Modal */}
      <NoteSubmitModal
        unit={selectedUnit}
        isOpen={isSubmitModalOpen}
        onClose={() => {
          setIsSubmitModalOpen(false);
          setSelectedUnit(null);
        }}
        onSuccess={() => {
          loadUnits();
        }}
      />
    </div>
  );
}
