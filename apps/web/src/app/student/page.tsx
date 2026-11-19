'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../../context/AuthContext';
import { Navbar } from '../../components/layout/Navbar';
import { Container } from '../../components/layout/Container';
import { GradeTabBar } from '../../components/student/GradeTabBar';
import { UnitCard } from '../../components/student/UnitCard';
import { QuestionSubmitModal } from '../../components/student/QuestionSubmitModal';
import { ProgressBar } from '../../components/ui/ProgressBar';
import { SubjectUnitsResponse, UnitProgressItem } from '../../types/collector';
import { api } from '../../lib/api';
import { Loader2, BookOpen, AlertCircle, RefreshCw } from 'lucide-react';
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
      <div className="flex-1 flex items-center justify-center p-4">
        <Loader2 className="w-8 h-8 animate-spin text-acedex-primary" />
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

  return (
    <div className="flex-1 flex flex-col pb-12">
      <Navbar />

      <main className="flex-1">
        <Container className="py-6 space-y-6">
          {/* Subject Overview Banner */}
          <div className="bg-acedex-card border border-acedex-border/80 rounded-2xl p-5 sm:p-6 shadow-md relative overflow-hidden">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div>
                <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-acedex-primary/15 text-acedex-primary border border-acedex-primary/30 mb-2">
                  <BookOpen className="w-3.5 h-3.5" />
                  <span>Subject Workspace</span>
                </div>
                <h1 className="text-xl sm:text-2xl font-bold text-acedex-text tracking-tight">
                  {profile.subjectName} ({profile.subjectCode})
                </h1>
                <p className="text-xs sm:text-sm text-acedex-muted mt-1">
                  Responsible Contributor:{' '}
                  <span className="font-semibold text-acedex-text">{profile.name}</span> ({profile.contributorId})
                </p>
              </div>

              {/* Progress Summary Card */}
              {unitTree && (
                <div className="sm:w-72 bg-acedex-bg/80 border border-acedex-border/60 p-4 rounded-xl shrink-0">
                  <ProgressBar
                    current={unitTree.approvedUnits}
                    total={unitTree.totalUnits}
                    label="Approved Coverage"
                  />
                </div>
              )}
            </div>
          </div>

          {/* Grade Selector Strip */}
          <GradeTabBar
            activeGrade={activeGrade}
            onSelectGrade={setActiveGrade}
            gradeStats={gradeStats}
          />

          {/* Error display */}
          {error && (
            <div className="p-4 bg-rose-500/15 border border-rose-500/30 rounded-xl text-xs sm:text-sm text-rose-400 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <AlertCircle className="w-5 h-5 shrink-0" />
                <span>{error}</span>
              </div>
              <Button size="sm" variant="outline" onClick={loadUnits}>
                <RefreshCw className="w-3.5 h-3.5 mr-1" /> Retry
              </Button>
            </div>
          )}

          {/* Units Grid */}
          {loading ? (
            <div className="py-16 flex flex-col items-center justify-center text-acedex-muted gap-2">
              <Loader2 className="w-8 h-8 animate-spin text-acedex-primary" />
              <span className="text-sm">Loading Grade {activeGrade} curriculum units...</span>
            </div>
          ) : (
            <div className="space-y-4">
              <div className="flex items-center justify-between text-xs text-acedex-muted">
                <span>
                  Showing {currentUnits.length} units for Grade {activeGrade}
                </span>
                <span className="font-medium text-acedex-text">
                  Target: 15 questions per unit
                </span>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
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
            </div>
          )}
        </Container>
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
