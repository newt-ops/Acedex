'use client';

import { useState, useEffect } from 'react';

interface ContributorProfile {
  contributorId: string;
  name: string;
  subjectCode: string;
  subjectName: string;
}

interface UnitProgressItem {
  unitCode: string;
  grade: number;
  unitNumber: number;
  unitTitle: string;
  status: 'not_started' | 'submitted' | 'approved' | 'rejected';
  questionCount?: number;
  submittedAt?: string;
  approvedAt?: string;
  reviewNotes?: string;
}

interface SubjectUnitsResponse {
  subjectCode: string;
  subjectName: string;
  contributorId: string;
  totalUnits: number;
  approvedUnits: number;
  submittedUnits: number;
  grades: {
    grade: number;
    units: UnitProgressItem[];
  }[];
}

export default function ContributorPage() {
  const [apiUrl, setApiUrl] = useState<string>('https://acedex-api.onrender.com');
  const [contributorIdInput, setContributorIdInput] = useState<string>('');
  const [profile, setProfile] = useState<ContributorProfile | null>(null);
  const [unitTree, setUnitTree] = useState<SubjectUnitsResponse | null>(null);
  const [activeGrade, setActiveGrade] = useState<number>(9);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  // Modal submission state
  const [selectedUnit, setSelectedUnit] = useState<UnitProgressItem | null>(null);
  const [rawPastedText, setRawPastedText] = useState<string>('');
  const [sanitizing, setSanitizing] = useState<boolean>(false);
  const [sanitizedData, setSanitizedData] = useState<any | null>(null);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState<boolean>(false);
  const [submitSuccess, setSubmitSuccess] = useState<boolean>(false);

  useEffect(() => {
    const url = process.env.NEXT_PUBLIC_API_URL || 'https://acedex-api.onrender.com';
    setApiUrl(url);

    // Auto-login from localStorage if available
    const savedId = localStorage.getItem('acedex_contributor_id');
    if (savedId) {
      setContributorIdInput(savedId);
      handleLogin(savedId, url);
    }
  }, []);

  const handleLogin = async (idToUse?: string, targetApiUrl?: string) => {
    const targetId = (idToUse || contributorIdInput).trim().toUpperCase();
    if (!targetId) {
      setError('Please enter your Contributor ID');
      return;
    }

    setLoading(true);
    setError(null);
    const base = targetApiUrl || apiUrl;

    try {
      const res = await fetch(`${base}/api/v1/collector/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ contributorId: targetId }),
      });

      const json = await res.json();
      if (!res.ok) {
        throw new Error(json.error?.message || 'Login failed. Invalid Contributor ID.');
      }

      const prof: ContributorProfile = json.data;
      setProfile(prof);
      localStorage.setItem('acedex_contributor_id', prof.contributorId);

      // Load units
      await loadUnits(prof.subjectCode, prof.contributorId, base);
    } catch (err: any) {
      setError(err.message || 'Failed to connect to Acedex API');
      setProfile(null);
    } finally {
      setLoading(false);
    }
  };

  const loadUnits = async (subjectCode: string, contribId: string, base: string) => {
    try {
      const res = await fetch(
        `${base}/api/v1/collector/units?subjectCode=${subjectCode}&contributorId=${encodeURIComponent(contribId)}`
      );
      const json = await res.json();
      if (res.ok) {
        setUnitTree(json.data);
      }
    } catch (err) {
      console.error('Failed to load unit progress tree', err);
    }
  };

  const handleSignOut = () => {
    localStorage.removeItem('acedex_contributor_id');
    setProfile(null);
    setUnitTree(null);
    setContributorIdInput('');
  };

  // Run live sanitizer on pasted text
  const handleLiveSanitize = async (text: string) => {
    setRawPastedText(text);
    setSubmitError(null);
    if (!text.trim() || !selectedUnit) {
      setSanitizedData(null);
      return;
    }

    setSanitizing(true);
    try {
      const res = await fetch(`${apiUrl}/api/v1/collector/sanitize`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          rawText: text,
          expectedUnitCode: selectedUnit.unitCode,
        }),
      });

      const json = await res.json();
      if (res.ok && json.data) {
        setSanitizedData(json.data);
      }
    } catch (err: any) {
      console.error('Sanitization request failed', err);
    } finally {
      setSanitizing(false);
    }
  };

  // Submit unit questions
  const handleSubmitQuestions = async () => {
    if (!selectedUnit || !profile) return;
    if (!sanitizedData || !sanitizedData.success || !sanitizedData.questions) {
      setSubmitError('Please paste valid JSON with 15 questions before submitting.');
      return;
    }

    setSubmitting(true);
    setSubmitError(null);

    try {
      const res = await fetch(`${apiUrl}/api/v1/collector/units/${selectedUnit.unitCode}/submit`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contributorId: profile.contributorId,
          questions: sanitizedData.questions,
          rawPastedText,
        }),
      });

      const json = await res.json();
      if (!res.ok) {
        throw new Error(json.error?.message || 'Failed to submit questions');
      }

      setSubmitSuccess(true);
      // Reload units
      await loadUnits(profile.subjectCode, profile.contributorId, apiUrl);

      setTimeout(() => {
        setSubmitSuccess(false);
        setSelectedUnit(null);
        setRawPastedText('');
        setSanitizedData(null);
      }, 1500);
    } catch (err: any) {
      setSubmitError(err.message || 'Submission error');
    } finally {
      setSubmitting(false);
    }
  };

  // ==========================================
  // VIEW 1: Contributor Login View
  // ==========================================
  if (!profile) {
    return (
      <main style={{ maxWidth: '540px', margin: '4rem auto', padding: '1.5rem' }}>
        <div
          style={{
            background: 'var(--card)',
            border: '1px solid var(--border)',
            borderRadius: '16px',
            padding: '2.5rem',
            boxShadow: '0 10px 25px -5px rgba(0, 0, 0, 0.3)',
          }}
        >
          <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
            <span style={{ fontSize: '2.75rem', display: 'block', marginBottom: '0.5rem' }}>📚</span>
            <h1 style={{ fontSize: '1.75rem', fontWeight: 800, color: 'var(--text)' }}>
              Acedex Contributor Portal
            </h1>
            <p style={{ color: 'var(--muted)', fontSize: '0.95rem', marginTop: '0.5rem' }}>
              Enter your assigned Subject Contributor ID to access your workspace.
            </p>
          </div>

          {error && (
            <div
              style={{
                background: 'rgba(239, 68, 68, 0.1)',
                border: '1px solid rgba(239, 68, 68, 0.4)',
                borderRadius: '8px',
                padding: '0.85rem',
                color: '#f87171',
                fontSize: '0.9rem',
                marginBottom: '1.5rem',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
              }}
            >
              <span>⚠️</span>
              <span>{error}</span>
            </div>
          )}

          <form
            onSubmit={(e) => {
              e.preventDefault();
              handleLogin();
            }}
          >
            <div style={{ marginBottom: '1.5rem' }}>
              <label
                style={{
                  display: 'block',
                  fontSize: '0.85rem',
                  fontWeight: 600,
                  color: 'var(--text)',
                  marginBottom: '0.5rem',
                  textTransform: 'uppercase',
                  letterSpacing: '0.05em',
                }}
              >
                Contributor ID
              </label>
              <input
                type="text"
                placeholder="e.g. GEO#982, PHY#101, HIS#808"
                value={contributorIdInput}
                onChange={(e) => setContributorIdInput(e.target.value.toUpperCase())}
                style={{
                  width: '100%',
                  padding: '0.85rem 1rem',
                  background: 'rgba(15, 23, 42, 0.6)',
                  border: '1px solid var(--border)',
                  borderRadius: '10px',
                  color: 'var(--text)',
                  fontSize: '1.1rem',
                  fontWeight: 600,
                  outline: 'none',
                  letterSpacing: '0.05em',
                }}
                disabled={loading}
                autoFocus
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              style={{
                width: '100%',
                padding: '0.95rem',
                background: 'var(--primary)',
                color: '#fff',
                border: 'none',
                borderRadius: '10px',
                fontSize: '1.05rem',
                fontWeight: 700,
                cursor: loading ? 'not-allowed' : 'pointer',
                transition: 'all 0.2s',
                opacity: loading ? 0.7 : 1,
              }}
            >
              {loading ? 'Entering Workspace...' : 'Enter Subject Workspace →'}
            </button>
          </form>

          {/* Quick Subject Hints */}
          <div style={{ marginTop: '2.5rem', borderTop: '1px solid var(--border)', paddingTop: '1.5rem' }}>
            <p style={{ fontSize: '0.8rem', color: 'var(--muted)', marginBottom: '0.75rem', fontWeight: 600 }}>
              Subject ID Roster:
            </p>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.5rem' }}>
              {[
                { code: 'GEO#982', name: 'Geography' },
                { code: 'PHY#101', name: 'Physics' },
                { code: 'CHE#202', name: 'Chemistry' },
                { code: 'BIO#303', name: 'Biology' },
                { code: 'MAT#404', name: 'Mathematics' },
                { code: 'ENG#505', name: 'English' },
                { code: 'ECO#606', name: 'Economics' },
                { code: 'HIS#808', name: 'History' },
              ].map((sub) => (
                <button
                  key={sub.code}
                  type="button"
                  onClick={() => setContributorIdInput(sub.code)}
                  style={{
                    padding: '0.35rem 0.65rem',
                    background: 'rgba(51, 65, 85, 0.5)',
                    border: '1px solid var(--border)',
                    borderRadius: '6px',
                    color: 'var(--muted)',
                    fontSize: '0.75rem',
                    cursor: 'pointer',
                  }}
                >
                  <strong style={{ color: 'var(--text)' }}>{sub.code}</strong> ({sub.name})
                </button>
              ))}
            </div>
          </div>
        </div>
      </main>
    );
  }

  // ==========================================
  // VIEW 2: Subject Dashboard View
  // ==========================================
  const currentGradeUnits = unitTree?.grades.find((g) => g.grade === activeGrade)?.units || [];
  const approvedCount = unitTree?.approvedUnits || 0;
  const totalCount = unitTree?.totalUnits || 0;
  const progressPercent = totalCount > 0 ? Math.round((approvedCount / totalCount) * 100) : 0;

  return (
    <main style={{ maxWidth: '1100px', margin: '0 auto', padding: '2rem 1.5rem' }}>
      {/* Top Header Card */}
      <header
        style={{
          background: 'var(--card)',
          border: '1px solid var(--border)',
          borderRadius: '16px',
          padding: '1.75rem 2rem',
          marginBottom: '2rem',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: '1.5rem',
        }}
      >
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            <span style={{ fontSize: '1.75rem' }}>📖</span>
            <div>
              <h1 style={{ fontSize: '1.6rem', fontWeight: 800 }}>
                {profile.subjectName} Workspace
              </h1>
              <p style={{ color: 'var(--muted)', fontSize: '0.85rem' }}>
                Contributor ID: <strong style={{ color: 'var(--primary)' }}>{profile.contributorId}</strong> ({profile.name})
              </p>
            </div>
          </div>
        </div>

        {/* Progress Tracker */}
        <div style={{ minWidth: '240px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', marginBottom: '0.35rem' }}>
            <span style={{ color: 'var(--muted)' }}>Subject Progress</span>
            <strong>{approvedCount} / {totalCount} Units ({progressPercent}%)</strong>
          </div>
          <div
            style={{
              width: '100%',
              height: '8px',
              background: 'rgba(51, 65, 85, 0.6)',
              borderRadius: '999px',
              overflow: 'hidden',
            }}
          >
            <div
              style={{
                width: `${progressPercent}%`,
                height: '100%',
                background: 'var(--success)',
                transition: 'width 0.4s ease',
              }}
            />
          </div>
        </div>

        <button
          onClick={handleSignOut}
          style={{
            padding: '0.6rem 1rem',
            background: 'transparent',
            border: '1px solid var(--border)',
            borderRadius: '8px',
            color: 'var(--muted)',
            fontSize: '0.85rem',
            fontWeight: 600,
            cursor: 'pointer',
          }}
        >
          Sign Out
        </button>
      </header>

      {/* Grade Selector Tabs */}
      <div
        style={{
          display: 'flex',
          gap: '0.75rem',
          marginBottom: '1.75rem',
          borderBottom: '1px solid var(--border)',
          paddingBottom: '0.75rem',
        }}
      >
        {[9, 10, 11, 12].map((grade) => {
          const gUnits = unitTree?.grades.find((g) => g.grade === grade)?.units || [];
          const gApproved = gUnits.filter((u) => u.status === 'approved').length;
          const isActive = activeGrade === grade;

          return (
            <button
              key={grade}
              onClick={() => setActiveGrade(grade)}
              style={{
                padding: '0.75rem 1.5rem',
                borderRadius: '10px',
                border: 'none',
                background: isActive ? 'var(--primary)' : 'rgba(30, 41, 59, 0.6)',
                color: isActive ? '#fff' : 'var(--muted)',
                fontWeight: 700,
                fontSize: '0.95rem',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                transition: 'all 0.15s ease',
              }}
            >
              <span>Grade {grade}</span>
              <span
                style={{
                  fontSize: '0.75rem',
                  padding: '0.15rem 0.45rem',
                  borderRadius: '999px',
                  background: isActive ? 'rgba(255, 255, 255, 0.25)' : 'rgba(51, 65, 85, 0.8)',
                  color: isActive ? '#fff' : 'var(--muted)',
                }}
              >
                {gApproved}/{gUnits.length}
              </span>
            </button>
          );
        })}
      </div>

      {/* Units Grid */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))',
          gap: '1rem',
        }}
      >
        {currentGradeUnits.map((unit) => {
          const isApproved = unit.status === 'approved';
          const isSubmitted = unit.status === 'submitted';
          const isRejected = unit.status === 'rejected';

          let statusBg = 'rgba(51, 65, 85, 0.4)';
          let statusBorder = 'var(--border)';
          let badgeText = 'Not Submitted';
          let badgeColor = 'var(--muted)';
          let badgeIcon = '⚪';

          if (isApproved) {
            statusBg = 'rgba(16, 185, 129, 0.1)';
            statusBorder = 'rgba(16, 185, 129, 0.4)';
            badgeText = 'Approved';
            badgeColor = '#34d399';
            badgeIcon = '✅';
          } else if (isSubmitted) {
            statusBg = 'rgba(245, 158, 11, 0.1)';
            statusBorder = 'rgba(245, 158, 11, 0.4)';
            badgeText = 'Submitted (Under Review)';
            badgeColor = '#fbbf24';
            badgeIcon = '⏳';
          } else if (isRejected) {
            statusBg = 'rgba(239, 68, 68, 0.1)';
            statusBorder = 'rgba(239, 68, 68, 0.4)';
            badgeText = 'Revision Requested';
            badgeColor = '#f87171';
            badgeIcon = '⚠️';
          }

          return (
            <div
              key={unit.unitCode}
              onClick={() => {
                setSelectedUnit(unit);
                setRawPastedText('');
                setSanitizedData(null);
                setSubmitError(null);
              }}
              style={{
                background: statusBg,
                border: `1px solid ${statusBorder}`,
                borderRadius: '12px',
                padding: '1.25rem',
                cursor: 'pointer',
                transition: 'transform 0.15s ease, border-color 0.15s ease',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'space-between',
              }}
              onMouseEnter={(e) => (e.currentTarget.style.transform = 'translateY(-2px)')}
              onMouseLeave={(e) => (e.currentTarget.style.transform = 'translateY(0)')}
            >
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
                  <span style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--muted)' }}>
                    {unit.unitCode}
                  </span>
                  <span
                    style={{
                      fontSize: '0.75rem',
                      fontWeight: 700,
                      color: badgeColor,
                      display: 'flex',
                      alignItems: 'center',
                      gap: '0.35rem',
                    }}
                  >
                    <span>{badgeIcon}</span>
                    <span>{badgeText}</span>
                  </span>
                </div>

                <h3 style={{ fontSize: '1.05rem', fontWeight: 700, marginBottom: '0.5rem', lineHeight: 1.4 }}>
                  Unit {unit.unitNumber}: {unit.unitTitle}
                </h3>

                {unit.reviewNotes && (
                  <p style={{ fontSize: '0.8rem', color: '#f87171', background: 'rgba(239, 68, 68, 0.15)', padding: '0.4rem 0.6rem', borderRadius: '6px', marginTop: '0.5rem' }}>
                    <strong>Admin Note:</strong> {unit.reviewNotes}
                  </p>
                )}
              </div>

              <div style={{ marginTop: '1rem', paddingTop: '0.75rem', borderTop: '1px solid rgba(255, 255, 255, 0.07)', display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '0.8rem', color: 'var(--muted)' }}>
                <span>{unit.questionCount ? `${unit.questionCount} Questions` : '15 Questions required'}</span>
                <span style={{ color: 'var(--primary)', fontWeight: 600 }}>
                  {isApproved ? 'View / Update →' : 'Paste & Submit →'}
                </span>
              </div>
            </div>
          );
        })}
      </div>

      {/* ==========================================
          MODAL: Unit Submission Drawer
         ========================================== */}
      {selectedUnit && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0, 0, 0, 0.75)',
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            zIndex: 100,
            padding: '1rem',
          }}
        >
          <div
            style={{
              background: 'var(--card)',
              border: '1px solid var(--border)',
              borderRadius: '16px',
              maxWidth: '800px',
              width: '100%',
              maxHeight: '90vh',
              overflowY: 'auto',
              padding: '2rem',
              boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.5)',
            }}
          >
            {/* Modal Header */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '1.5rem', borderBottom: '1px solid var(--border)', paddingBottom: '1rem' }}>
              <div>
                <span style={{ fontSize: '0.8rem', color: 'var(--primary)', fontWeight: 700 }}>
                  {selectedUnit.unitCode} • Grade {selectedUnit.grade}
                </span>
                <h2 style={{ fontSize: '1.35rem', fontWeight: 800 }}>
                  Unit {selectedUnit.unitNumber}: {selectedUnit.unitTitle}
                </h2>
              </div>
              <button
                onClick={() => setSelectedUnit(null)}
                style={{
                  background: 'transparent',
                  border: 'none',
                  color: 'var(--muted)',
                  fontSize: '1.5rem',
                  cursor: 'pointer',
                  lineHeight: 1,
                }}
              >
                ✕
              </button>
            </div>

            {submitSuccess && (
              <div
                style={{
                  background: 'rgba(16, 185, 129, 0.2)',
                  border: '1px solid var(--success)',
                  borderRadius: '8px',
                  padding: '1rem',
                  color: '#34d399',
                  textAlign: 'center',
                  fontWeight: 700,
                  marginBottom: '1rem',
                }}
              >
                ✅ Successfully submitted to Admin! Updating unit status...
              </div>
            )}

            {submitError && (
              <div
                style={{
                  background: 'rgba(239, 68, 68, 0.15)',
                  border: '1px solid rgba(239, 68, 68, 0.4)',
                  borderRadius: '8px',
                  padding: '0.85rem',
                  color: '#f87171',
                  fontSize: '0.85rem',
                  marginBottom: '1rem',
                }}
              >
                ⚠️ {submitError}
              </div>
            )}

            {/* Paste Box */}
            <div style={{ marginBottom: '1.5rem' }}>
              <label
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  fontSize: '0.85rem',
                  fontWeight: 600,
                  color: 'var(--text)',
                  marginBottom: '0.5rem',
                }}
              >
                <span>Paste NotebookLM Output (JSON or Text)</span>
                {sanitizing && <span style={{ color: 'var(--primary)' }}>⚡ Auto-cleaning...</span>}
              </label>

              <textarea
                rows={10}
                placeholder="Paste the raw text or JSON you received from NotebookLM here..."
                value={rawPastedText}
                onChange={(e) => handleLiveSanitize(e.target.value)}
                style={{
                  width: '100%',
                  padding: '1rem',
                  background: 'rgba(15, 23, 42, 0.7)',
                  border: '1px solid var(--border)',
                  borderRadius: '10px',
                  color: 'var(--text)',
                  fontSize: '0.85rem',
                  fontFamily: 'monospace',
                  outline: 'none',
                  resize: 'vertical',
                }}
              />
            </div>

            {/* Live Auto-Fixer Status Box */}
            {sanitizedData && (
              <div
                style={{
                  background: sanitizedData.success ? 'rgba(16, 185, 129, 0.08)' : 'rgba(239, 68, 68, 0.08)',
                  border: `1px solid ${sanitizedData.success ? 'rgba(16, 185, 129, 0.3)' : 'rgba(239, 68, 68, 0.3)'}`,
                  borderRadius: '10px',
                  padding: '1rem',
                  marginBottom: '1.5rem',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
                  <strong style={{ color: sanitizedData.success ? '#34d399' : '#f87171', fontSize: '0.95rem' }}>
                    {sanitizedData.success ? '✅ 15 Questions Cleaned & Verified' : '❌ Validation Issues Detected'}
                  </strong>
                  {sanitizedData.questions && (
                    <span style={{ fontSize: '0.8rem', background: 'rgba(51, 65, 85, 0.6)', padding: '0.2rem 0.5rem', borderRadius: '4px' }}>
                      {sanitizedData.questions.length} / 15 Questions
                    </span>
                  )}
                </div>

                {sanitizedData.autoFixedIssues && sanitizedData.autoFixedIssues.length > 0 && (
                  <div style={{ fontSize: '0.8rem', color: '#60a5fa', marginBottom: '0.5rem' }}>
                    <strong>Auto-repairs applied:</strong>
                    <ul style={{ paddingLeft: '1.25rem', marginTop: '0.25rem' }}>
                      {sanitizedData.autoFixedIssues.map((msg: string, i: number) => (
                        <li key={i}>{msg}</li>
                      ))}
                    </ul>
                  </div>
                )}

                {sanitizedData.errors && sanitizedData.errors.length > 0 && (
                  <div style={{ fontSize: '0.8rem', color: '#f87171' }}>
                    <strong>Errors to resolve:</strong>
                    <ul style={{ paddingLeft: '1.25rem', marginTop: '0.25rem' }}>
                      {sanitizedData.errors.map((err: string, i: number) => (
                        <li key={i}>{err}</li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>
            )}

            {/* Action Buttons */}
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '1rem' }}>
              <button
                type="button"
                onClick={() => setSelectedUnit(null)}
                style={{
                  padding: '0.75rem 1.25rem',
                  background: 'transparent',
                  border: '1px solid var(--border)',
                  borderRadius: '8px',
                  color: 'var(--muted)',
                  fontWeight: 600,
                  cursor: 'pointer',
                }}
              >
                Cancel
              </button>

              <button
                type="button"
                onClick={handleSubmitQuestions}
                disabled={submitting || !sanitizedData?.success}
                style={{
                  padding: '0.75rem 1.5rem',
                  background: sanitizedData?.success ? 'var(--primary)' : 'rgba(51, 65, 85, 0.5)',
                  color: '#fff',
                  border: 'none',
                  borderRadius: '8px',
                  fontWeight: 700,
                  fontSize: '0.95rem',
                  cursor: sanitizedData?.success && !submitting ? 'pointer' : 'not-allowed',
                  opacity: sanitizedData?.success ? 1 : 0.6,
                }}
              >
                {submitting ? 'Submitting to Admin...' : 'Submit to Admin →'}
              </button>
            </div>
          </div>
        </div>
      )}
    </main>
  );
}
