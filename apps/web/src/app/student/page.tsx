'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../../context/AuthContext';
import { Navbar } from '../../components/layout/Navbar';
import { GradeTabBar } from '../../components/student/GradeTabBar';
import { UnitCard } from '../../components/student/UnitCard';
import { QuestionSubmitModal } from '../../components/student/QuestionSubmitModal';
import { SubjectUnitsResponse, UnitProgressItem } from '../../types/collector';
import { api } from '../../lib/api';
import { HugeiconsIcon } from '@hugeicons/react';
import { Loading01Icon, AlertCircleIcon, Refresh01Icon, BookOpen01Icon } from '@hugeicons/core-free-icons';
import { Button } from '../../components/ui/Button';

export default function StudentPortalPage() {
  const { profile, isAuthenticated, isAdmin, loading: authLoading } = useAuth();
  const router = useRouter();

  const [unitTree, setUnitTree] = useState<SubjectUnitsResponse | null>(null);
  const [activeGrade, setActiveGrade] = useState<number>(9);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Modal state
  const [selectedUnit, setSelectedUnit] = useState<UnitProgressItem | null>(null);
  const [isSubmitModalOpen, setIsSubmitModalOpen] = useState<boolean>(false);

  const loadUnits = useCallback(async () => {
    if (!profile) return;
    setLoading(true);
    setError(null);
    try {
      const data = await api.getUnits(profile.subjectCode, profile.contributorId);
      setUnitTree(data);
    } catch (err: any) {
      setError(err.message || 'Failed to load subject unit curriculum');
    } finally {
      setLoading(false);
    }
  }, [profile]);

  useEffect(() => {
    if (!authLoading) {
      if (!isAuthenticated) {
        router.push('/');
      } else if (isAdmin) {
        router.push('/admin');
      } else {
        loadUnits();
      }
    }
  }, [authLoading, isAuthenticated, isAdmin, router, loadUnits]);

  if (authLoading || !profile) {
    return (
      <div className="flex-1 flex items-center justify-center p-4 min-h-[60vh]">
        <HugeiconsIcon icon={Loading01Icon} size={32} className="animate-spin text-[#7E22CE]" strokeWidth={2} />
      </div>
    );
  }

  // Calculate grade statistics for tabs
  const gradeStats: Record<number, { approved: number; total: number }> = {};
  unitTree?.grades.forEach((g) => {
    const approvedCount = g.units.filter((u) => u.status === 'approved').length;
    gradeStats[g.grade] = {
      approved: approvedCount,
      total: g.units.length,
    };
  });

  const currentGradeData = unitTree?.grades.find((g) => g.grade === activeGrade);
  const currentUnits = currentGradeData?.units || [];

  const approvedUnits = unitTree?.approvedUnits || 0;
  const totalUnits = unitTree?.totalUnits || 32;
  const coveragePct = totalUnits > 0 ? Math.round((approvedUnits / totalUnits) * 100) : 0;

  return (
    <div className="flex-1 flex flex-col pb-16">
      <Navbar />

      <main className="flex-1 w-full max-w-[1380px] mx-auto px-4 sm:px-7 py-5 sm:py-8">
        {/* Subject Workspace Hero Banner */}
        <section className="apple-card apple-card-hover p-5 sm:p-7 mb-6 sm:mb-7 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 sm:gap-5">
          {/* Left: Subject Identity */}
          <div>
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-purple-50/90 border border-purple-200/70 text-[#7E22CE] text-[11px] sm:text-[11.5px] font-semibold mb-2.5 sm:mb-3">
              <HugeiconsIcon icon={BookOpen01Icon} size={14} strokeWidth={2} className="shrink-0" />
              <span>Subject Workspace</span>
            </div>

            <h1 className="font-display text-2xl sm:text-3xl font-extrabold tracking-[-0.025em] text-slate-900 leading-tight">
              {profile.subjectName} ({profile.subjectCode})
            </h1>

            <p className="mt-1 sm:mt-1.5 text-[13px] sm:text-[13.5px] text-slate-500">
              Responsible Contributor:{' '}
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

        {/* Grade Filter Segmented Bar */}
        <GradeTabBar
          activeGrade={activeGrade}
          onSelectGrade={setActiveGrade}
          gradeStats={gradeStats}
        />

        {/* Subheader Meta Row */}
        <div className="flex flex-wrap items-center justify-between gap-2 mb-4 px-0.5">
          <p className="text-[12.5px] sm:text-[13px] font-medium text-slate-500">
            Showing {currentUnits.length} units for Grade {activeGrade}
          </p>
          <p className="text-[12.5px] sm:text-[13px] font-semibold text-slate-700">
            Target: 15 questions per unit
          </p>
        </div>

        {/* Error display */}
        {error && (
          <div className="p-4 mb-4 bg-rose-500/15 border border-rose-500/30 rounded-2xl text-xs sm:text-sm text-rose-600 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <HugeiconsIcon icon={AlertCircleIcon} size={20} className="shrink-0 text-rose-500" strokeWidth={1.5} />
              <span>{error}</span>
            </div>
            <Button
              size="sm"
              variant="outline"
              onClick={loadUnits}
              icon={<HugeiconsIcon icon={Refresh01Icon} size={14} className="shrink-0" strokeWidth={1.5} />}
            >
              Retry
            </Button>
          </div>
        )}

        {/* Units Grid */}
        {loading ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5 animate-pulse">
            {[1, 2, 3, 4, 5, 6].map((i) => (
              <div
                key={i}
                className="apple-card p-5 sm:p-6 h-[230px] flex flex-col justify-between"
              >
                <div className="space-y-3">
                  <div className="flex justify-between">
                    <div className="h-5 w-24 bg-slate-100 rounded-lg" />
                    <div className="h-5 w-20 bg-slate-100 rounded-full" />
                  </div>
                  <div className="h-6 w-3/4 bg-slate-100 rounded-md" />
                </div>
                <div className="space-y-3">
                  <div className="h-4 w-1/2 bg-slate-100 rounded" />
                  <div className="h-11 w-full bg-slate-100 rounded-[13px]" />
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5">
            {currentUnits.map((unit) => (
              <UnitCard
                key={unit.unitCode}
                unit={unit}
                onOpenSubmit={(target) => {
                  setSelectedUnit(target);
                  setIsSubmitModalOpen(true);
                }}
              />
            ))}
          </div>
        )}
      </main>

      {/* Question Submit Modal with Auto-Fixer */}
      <QuestionSubmitModal
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
