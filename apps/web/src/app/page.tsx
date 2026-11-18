'use client';

import { useState, useEffect } from 'react';

// ==========================================
// Types
// ==========================================

interface ContributorProfile {
  contributorId: string;
  name: string;
  subjectCode: string;
  subjectName: string;
  role?: 'student' | 'admin';
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

interface SubmissionSummary {
  _id: string;
  unitCode: string;
  subjectCode: string;
  grade: number;
  unitNumber: number;
  unitTitle: string;
  contributorId: string;
  questionCount: number;
  status: 'not_started' | 'submitted' | 'approved' | 'rejected';
  submittedAt: string;
  reviewedAt?: string;
  reviewNotes?: string;
}

interface QuestionItem {
  id: string;
  type: string;
  difficulty: string;
  question: string;
  options: { id: string; text: string }[];
  correctOptionId: string;
  explanation: string;
  sourceReference?: string;
}

interface SubmissionDetail extends SubmissionSummary {
  questions: QuestionItem[];
  rawPastedText?: string;
}

export default function MainPage() {
  const [apiUrl, setApiUrl] = useState<string>('http://localhost:5000');
  const [showConfig, setShowConfig] = useState<boolean>(false);
  const [accessIdInput, setAccessIdInput] = useState<string>('');
  const [profile, setProfile] = useState<ContributorProfile | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [loginError, setLoginError] = useState<string | null>(null);

  // Student Contributor State
  const [unitTree, setUnitTree] = useState<SubjectUnitsResponse | null>(null);
  const [activeGrade, setActiveGrade] = useState<number>(9);
  const [selectedUnit, setSelectedUnit] = useState<UnitProgressItem | null>(null);
  const [rawPastedText, setRawPastedText] = useState<string>('');
  const [sanitizing, setSanitizing] = useState<boolean>(false);
  const [sanitizedData, setSanitizedData] = useState<any | null>(null);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState<boolean>(false);
  const [submitSuccess, setSubmitSuccess] = useState<boolean>(false);

  // Admin Collector State
  const [adminSubmissions, setAdminSubmissions] = useState<SubmissionSummary[]>([]);
  const [adminSubjectFilter, setAdminSubjectFilter] = useState<string>('ALL');
  const [adminStatusFilter, setAdminStatusFilter] = useState<string>('ALL');
  const [selectedSubmissionId, setSelectedSubmissionId] = useState<string | null>(null);
  const [adminDetail, setAdminDetail] = useState<SubmissionDetail | null>(null);
  const [loadingDetail, setLoadingDetail] = useState<boolean>(false);
  const [adminActionLoading, setAdminActionLoading] = useState<boolean>(false);
  const [adminActionMessage, setAdminActionMessage] = useState<string | null>(null);
  const [showRejectModal, setShowRejectModal] = useState<boolean>(false);
  const [rejectNote, setRejectNote] = useState<string>('');

  useEffect(() => {
    // Detect environment: use local 5000 if running locally or env var or render
    const savedApi = localStorage.getItem('acedex_api_url') ||
      process.env.NEXT_PUBLIC_API_URL ||
      (typeof window !== 'undefined' && window.location.hostname === 'localhost' ? 'http://localhost:5000' : 'https://acedex-api.onrender.com');

    setApiUrl(savedApi);

    // Auto-login from localStorage if available
    const savedId = localStorage.getItem('acedex_access_id');
    if (savedId) {
      setAccessIdInput(savedId);
      handleLogin(savedId, savedApi);
    }
  }, []);

  const handleLogin = async (idToUse?: string, targetApiUrl?: string) => {
    const targetId = (idToUse || accessIdInput).trim().toUpperCase();
    if (!targetId) {
      setLoginError('Please enter your Access ID');
      return;
    }

    setLoading(true);
    setLoginError(null);
    const base = targetApiUrl || apiUrl;

    try {
      const res = await fetch(`${base}/api/v1/collector/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ contributorId: targetId }),
      });

      const json = await res.json();
      if (!res.ok) {
        throw new Error(json.error?.message || 'Access ID not recognized.');
      }

      const prof: ContributorProfile = json.data;
      setProfile(prof);
      localStorage.setItem('acedex_access_id', prof.contributorId);

      // Branch based on role:
      if (prof.role === 'admin' || prof.contributorId === 'ADM#15') {
        await loadAdminSubmissions(base, prof.contributorId);
      } else {
        await loadStudentUnits(prof.subjectCode, prof.contributorId, base);
      }
    } catch (err: any) {
      setLoginError(err.message || 'Unable to connect to API server.');
      setProfile(null);
    } finally {
      setLoading(false);
    }
  };

  const handleSignOut = () => {
    localStorage.removeItem('acedex_access_id');
    setProfile(null);
    setUnitTree(null);
    setAdminSubmissions([]);
    setAccessIdInput('');
  };

  // Student: Load subject units
  const loadStudentUnits = async (subjectCode: string, contribId: string, base: string) => {
    try {
      const res = await fetch(
        `${base}/api/v1/collector/units?subjectCode=${subjectCode}&contributorId=${encodeURIComponent(contribId)}`
      );
      const json = await res.json();
      if (res.ok) {
        setUnitTree(json.data);
      }
    } catch (err) {
      console.error('Failed to load units', err);
    }
  };

  // Student: Live Sanitize
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
    } catch (err) {
      console.error('Sanitization failed', err);
    } finally {
      setSanitizing(false);
    }
  };

  // Student: Submit Unit Questions
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
      await loadStudentUnits(profile.subjectCode, profile.contributorId, apiUrl);

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

  // Admin: Load submissions
  const loadAdminSubmissions = async (base: string, idToUse?: string) => {
    setLoading(true);
    try {
      const res = await fetch(`${base}/api/v1/collector/admin/submissions`, {
        headers: {
          'x-admin-key': idToUse || profile?.contributorId || 'ADM#15',
          'x-contributor-id': idToUse || profile?.contributorId || 'ADM#15',
        },
      });
      const json = await res.json();
      if (res.ok) {
        setAdminSubmissions(json.data || []);
      }
    } catch (err) {
      console.error('Failed to load admin submissions', err);
    } finally {
      setLoading(false);
    }
  };

  // Admin: Open Submission Detail
  const openAdminDetail = async (id: string) => {
    setSelectedSubmissionId(id);
    setLoadingDetail(true);
    setAdminActionMessage(null);

    try {
      const res = await fetch(`${apiUrl}/api/v1/collector/admin/submissions/${id}`, {
        headers: { 'x-admin-key': profile?.contributorId || 'ADM#15' },
      });
      const json = await res.json();
      if (res.ok) {
        setAdminDetail(json.data);
      }
    } catch (err) {
      console.error('Failed to load detail', err);
    } finally {
      setLoadingDetail(false);
    }
  };

  // Admin: Approve
  const handleAdminApprove = async () => {
    if (!adminDetail) return;
    setAdminActionLoading(true);
    setAdminActionMessage(null);

    try {
      const res = await fetch(`${apiUrl}/api/v1/collector/admin/submissions/${adminDetail._id}/approve`, {
        method: 'POST',
        headers: {
          'x-admin-key': profile?.contributorId || 'ADM#15',
          'Content-Type': 'application/json',
        },
      });

      if (!res.ok) throw new Error('Failed to approve');

      setAdminActionMessage('✅ Approved! The student panel now displays a green checkmark.');
      setAdminDetail((prev) => (prev ? { ...prev, status: 'approved' } : null));
      await loadAdminSubmissions(apiUrl);
    } catch (err: any) {
      setAdminActionMessage(`❌ Error: ${err.message}`);
    } finally {
      setAdminActionLoading(false);
    }
  };

  // Admin: Reject
  const handleAdminReject = async () => {
    if (!adminDetail) return;
    setAdminActionLoading(true);

    try {
      const res = await fetch(`${apiUrl}/api/v1/collector/admin/submissions/${adminDetail._id}/reject`, {
        method: 'POST',
        headers: {
          'x-admin-key': profile?.contributorId || 'ADM#15',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ notes: rejectNote }),
      });

      if (!res.ok) throw new Error('Failed to request revision');

      setAdminActionMessage('⚠️ Revision requested. The student will see your feedback note.');
      setAdminDetail((prev) => (prev ? { ...prev, status: 'rejected', reviewNotes: rejectNote } : null));
      setShowRejectModal(false);
      setRejectNote('');
      await loadAdminSubmissions(apiUrl);
    } catch (err: any) {
      setAdminActionMessage(`❌ Error: ${err.message}`);
    } finally {
      setAdminActionLoading(false);
    }
  };

  // Admin: Export JSON
  const handleAdminExportJson = (unitCode: string) => {
    window.open(
      `${apiUrl}/api/v1/collector/admin/submissions/${unitCode}/export?adminKey=${encodeURIComponent(profile?.contributorId || 'ADM#15')}`,
      '_blank'
    );
  };

  // ==========================================
  // VIEW 1: Clean, Single Login Page
  // ==========================================
  if (!profile) {
    return (
      <main style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', padding: '1.5rem' }}>
        <div
          style={{
            maxWidth: '440px',
            width: '100%',
            background: 'var(--card)',
            border: '1px solid var(--border)',
            borderRadius: '20px',
            padding: '2.5rem 2rem',
            boxShadow: '0 20px 40px -15px rgba(0, 0, 0, 0.5)',
          }}
        >
          {/* Logo / Header */}
          <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
            <span style={{ fontSize: '3rem', display: 'block', marginBottom: '0.5rem' }}>🔐</span>
            <h1 style={{ fontSize: '1.75rem', fontWeight: 800, color: 'var(--text)' }}>
              Acedex Portal
            </h1>
            <p style={{ color: 'var(--muted)', fontSize: '0.9rem', marginTop: '0.35rem' }}>
              Sign in with your authorized Access ID.
            </p>
          </div>

          {loginError && (
            <div
              style={{
                background: 'rgba(239, 68, 68, 0.12)',
                border: '1px solid rgba(239, 68, 68, 0.4)',
                borderRadius: '10px',
                padding: '0.85rem',
                color: '#f87171',
                fontSize: '0.85rem',
                marginBottom: '1.5rem',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
              }}
            >
              <span>⚠️</span>
              <span>{loginError}</span>
            </div>
          )}

          <form
            onSubmit={(e) => {
              e.preventDefault();
              handleLogin();
            }}
          >
            <div style={{ marginBottom: '1.75rem' }}>
              <label
                style={{
                  display: 'block',
                  fontSize: '0.8rem',
                  fontWeight: 700,
                  color: 'var(--muted)',
                  marginBottom: '0.5rem',
                  textTransform: 'uppercase',
                  letterSpacing: '0.07em',
                }}
              >
                Access ID
              </label>
              <input
                type="text"
                placeholder="Enter your ID..."
                value={accessIdInput}
                onChange={(e) => setAccessIdInput(e.target.value.toUpperCase())}
                style={{
                  width: '100%',
                  padding: '0.95rem 1.15rem',
                  background: 'rgba(15, 23, 42, 0.7)',
                  border: '1px solid var(--border)',
                  borderRadius: '12px',
                  color: 'var(--text)',
                  fontSize: '1.15rem',
                  fontWeight: 700,
                  outline: 'none',
                  letterSpacing: '0.08em',
                  textAlign: 'center',
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
                padding: '1rem',
                background: 'var(--primary)',
                color: '#fff',
                border: 'none',
                borderRadius: '12px',
                fontSize: '1.05rem',
                fontWeight: 700,
                cursor: loading ? 'not-allowed' : 'pointer',
                transition: 'all 0.2s',
                opacity: loading ? 0.7 : 1,
              }}
            >
              {loading ? 'Validating ID...' : 'Enter Workspace →'}
            </button>
          </form>

          {/* Config Drawer Toggle */}
          <div style={{ marginTop: '2rem', textAlign: 'center' }}>
            <button
              type="button"
              onClick={() => setShowConfig(!showConfig)}
              style={{ background: 'transparent', border: 'none', color: 'rgba(148, 163, 184, 0.5)', fontSize: '0.75rem', cursor: 'pointer' }}
            >
              ⚙️ Server Endpoint: {apiUrl}
            </button>
            {showConfig && (
              <div style={{ marginTop: '0.75rem', display: 'flex', gap: '0.5rem' }}>
                <input
                  type="text"
                  value={apiUrl}
                  onChange={(e) => {
                    setApiUrl(e.target.value);
                    localStorage.setItem('acedex_api_url', e.target.value);
                  }}
                  style={{ width: '100%', padding: '0.4rem', background: '#0f172a', border: '1px solid var(--border)', borderRadius: '6px', color: '#fff', fontSize: '0.75rem' }}
                />
              </div>
            )}
          </div>
        </div>
      </main>
    );
  }

  // ==========================================
  // VIEW 2: Master Admin Review Hub (ADM#15)
  // ==========================================
  if (profile.role === 'admin' || profile.contributorId === 'ADM#15') {
    const subjectsList = ['ALL', 'GEO', 'PHY', 'CHE', 'BIO', 'MAT', 'ENG', 'ECO', 'HIS'];
    const filtered = adminSubmissions.filter((s) => {
      const matchSub = adminSubjectFilter === 'ALL' || s.subjectCode === adminSubjectFilter;
      const matchSt = adminStatusFilter === 'ALL' || s.status === adminStatusFilter;
      return matchSub && matchSt;
    });

    return (
      <main style={{ maxWidth: '1200px', margin: '0 auto', padding: '2rem 1.5rem' }}>
        <header
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            flexWrap: 'wrap',
            gap: '1rem',
            marginBottom: '2rem',
            borderBottom: '1px solid var(--border)',
            paddingBottom: '1.25rem',
          }}
        >
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span style={{ fontSize: '1.5rem' }}>👑</span>
              <h1 style={{ fontSize: '1.75rem', fontWeight: 800 }}>
                Admin Question Review Hub
              </h1>
            </div>
            <p style={{ color: 'var(--muted)', fontSize: '0.85rem' }}>
              Logged in as Master Administrator (<strong style={{ color: 'var(--primary)' }}>ADM#15</strong>)
            </p>
          </div>

          <div style={{ display: 'flex', gap: '0.75rem' }}>
            <button
              onClick={() => loadAdminSubmissions(apiUrl)}
              style={{ padding: '0.55rem 1rem', background: 'rgba(51, 65, 85, 0.5)', border: '1px solid var(--border)', borderRadius: '8px', color: 'var(--text)', fontSize: '0.85rem', fontWeight: 600, cursor: 'pointer' }}
            >
              🔄 Refresh
            </button>
            <button
              onClick={handleSignOut}
              style={{ padding: '0.55rem 1rem', background: 'transparent', border: '1px solid var(--border)', borderRadius: '8px', color: 'var(--muted)', fontSize: '0.85rem', fontWeight: 600, cursor: 'pointer' }}
            >
              Sign Out
            </button>
          </div>
        </header>

        {/* Filters */}
        <div style={{ marginBottom: '1.5rem' }}>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.5rem', marginBottom: '0.75rem' }}>
            {subjectsList.map((sub) => (
              <button
                key={sub}
                onClick={() => setAdminSubjectFilter(sub)}
                style={{
                  padding: '0.4rem 0.85rem',
                  borderRadius: '6px',
                  border: 'none',
                  background: adminSubjectFilter === sub ? 'var(--primary)' : 'var(--card)',
                  color: adminSubjectFilter === sub ? '#fff' : 'var(--muted)',
                  fontWeight: 600,
                  fontSize: '0.85rem',
                  cursor: 'pointer',
                }}
              >
                {sub}
              </button>
            ))}
          </div>

          <div style={{ display: 'flex', gap: '0.5rem' }}>
            {[
              { id: 'ALL', label: 'All Statuses' },
              { id: 'submitted', label: 'Submitted / Pending' },
              { id: 'approved', label: 'Approved ✅' },
              { id: 'rejected', label: 'Rejected' },
            ].map((st) => (
              <button
                key={st.id}
                onClick={() => setAdminStatusFilter(st.id)}
                style={{
                  padding: '0.35rem 0.75rem',
                  borderRadius: '6px',
                  border: '1px solid var(--border)',
                  background: adminStatusFilter === st.id ? 'rgba(51, 65, 85, 0.8)' : 'transparent',
                  color: adminStatusFilter === st.id ? 'var(--text)' : 'var(--muted)',
                  fontWeight: 600,
                  fontSize: '0.8rem',
                  cursor: 'pointer',
                }}
              >
                {st.label}
              </button>
            ))}
          </div>
        </div>

        {/* Submissions Table */}
        {loading ? (
          <div style={{ textAlign: 'center', padding: '4rem', color: 'var(--muted)' }}>
            Loading submissions...
          </div>
        ) : filtered.length === 0 ? (
          <div style={{ background: 'var(--card)', border: '1px solid var(--border)', borderRadius: '12px', padding: '3rem', textAlign: 'center', color: 'var(--muted)' }}>
            <span style={{ fontSize: '2rem', display: 'block', marginBottom: '0.5rem' }}>📭</span>
            No submissions found for the selected filter.
          </div>
        ) : (
          <div style={{ background: 'var(--card)', border: '1px solid var(--border)', borderRadius: '12px', overflow: 'hidden' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.9rem' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid var(--border)', background: 'rgba(15, 23, 42, 0.4)', color: 'var(--muted)', fontSize: '0.8rem', textTransform: 'uppercase' }}>
                  <th style={{ padding: '0.9rem 1rem' }}>Unit Code</th>
                  <th style={{ padding: '0.9rem 1rem' }}>Grade</th>
                  <th style={{ padding: '0.9rem 1rem' }}>Title</th>
                  <th style={{ padding: '0.9rem 1rem' }}>Contributor</th>
                  <th style={{ padding: '0.9rem 1rem' }}>Status</th>
                  <th style={{ padding: '0.9rem 1rem' }}>Submitted</th>
                  <th style={{ padding: '0.9rem 1rem', textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((s) => {
                  const isApproved = s.status === 'approved';
                  const isSubmitted = s.status === 'submitted';

                  return (
                    <tr key={s._id} style={{ borderBottom: '1px solid var(--border)' }}>
                      <td style={{ padding: '0.9rem 1rem', fontWeight: 700, color: 'var(--text)' }}>
                        {s.unitCode}
                      </td>
                      <td style={{ padding: '0.9rem 1rem', color: 'var(--muted)' }}>
                        Grade {s.grade}
                      </td>
                      <td style={{ padding: '0.9rem 1rem', fontWeight: 600 }}>
                        Unit {s.unitNumber}: {s.unitTitle}
                      </td>
                      <td style={{ padding: '0.9rem 1rem', color: 'var(--primary)', fontWeight: 600 }}>
                        {s.contributorId}
                      </td>
                      <td style={{ padding: '0.9rem 1rem' }}>
                        <span
                          style={{
                            fontSize: '0.75rem',
                            padding: '0.2rem 0.55rem',
                            borderRadius: '999px',
                            fontWeight: 700,
                            background: isApproved
                              ? 'rgba(16, 185, 129, 0.2)'
                              : isSubmitted
                              ? 'rgba(245, 158, 11, 0.2)'
                              : 'rgba(239, 68, 68, 0.2)',
                            color: isApproved ? '#34d399' : isSubmitted ? '#fbbf24' : '#f87171',
                          }}
                        >
                          {isApproved ? 'Approved ✅' : isSubmitted ? 'Submitted' : 'Rejected'}
                        </span>
                      </td>
                      <td style={{ padding: '0.9rem 1rem', color: 'var(--muted)', fontSize: '0.8rem' }}>
                        {new Date(s.submittedAt).toLocaleDateString()}
                      </td>
                      <td style={{ padding: '0.9rem 1rem', textAlign: 'right' }}>
                        <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'flex-end' }}>
                          <button
                            onClick={() => openAdminDetail(s._id)}
                            style={{
                              padding: '0.4rem 0.75rem',
                              background: 'var(--primary)',
                              color: '#fff',
                              border: 'none',
                              borderRadius: '6px',
                              fontSize: '0.8rem',
                              fontWeight: 600,
                              cursor: 'pointer',
                            }}
                          >
                            Review Questions
                          </button>

                          <button
                            onClick={() => handleAdminExportJson(s.unitCode)}
                            style={{
                              padding: '0.4rem 0.75rem',
                              background: 'rgba(51, 65, 85, 0.7)',
                              color: 'var(--text)',
                              border: '1px solid var(--border)',
                              borderRadius: '6px',
                              fontSize: '0.8rem',
                              fontWeight: 600,
                              cursor: 'pointer',
                            }}
                            title="Download JSON file for question bank"
                          >
                            ⬇️ Export
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}

        {/* Admin Detail Drawer */}
        {selectedSubmissionId && (
          <div
            style={{
              position: 'fixed',
              inset: 0,
              background: 'rgba(0, 0, 0, 0.85)',
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              zIndex: 100,
              padding: '1.5rem',
            }}
          >
            <div
              style={{
                background: 'var(--card)',
                border: '1px solid var(--border)',
                borderRadius: '16px',
                maxWidth: '900px',
                width: '100%',
                maxHeight: '92vh',
                overflowY: 'auto',
                padding: '2rem',
                boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.5)',
              }}
            >
              {loadingDetail || !adminDetail ? (
                <div style={{ textAlign: 'center', padding: '3rem', color: 'var(--muted)' }}>
                  Loading unit questions...
                </div>
              ) : (
                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', borderBottom: '1px solid var(--border)', paddingBottom: '1rem', marginBottom: '1.5rem' }}>
                    <div>
                      <span style={{ fontSize: '0.8rem', color: 'var(--primary)', fontWeight: 700 }}>
                        {adminDetail.unitCode} • Grade {adminDetail.grade} • Contributor: {adminDetail.contributorId}
                      </span>
                      <h2 style={{ fontSize: '1.4rem', fontWeight: 800 }}>
                        Unit {adminDetail.unitNumber}: {adminDetail.unitTitle}
                      </h2>
                    </div>
                    <button
                      onClick={() => setSelectedSubmissionId(null)}
                      style={{ background: 'transparent', border: 'none', color: 'var(--muted)', fontSize: '1.5rem', cursor: 'pointer' }}
                    >
                      ✕
                    </button>
                  </div>

                  {adminActionMessage && (
                    <div style={{ padding: '0.85rem', borderRadius: '8px', background: 'rgba(51, 65, 85, 0.5)', marginBottom: '1.25rem', fontWeight: 600 }}>
                      {adminActionMessage}
                    </div>
                  )}

                  {/* Actions */}
                  <div style={{ display: 'flex', gap: '0.75rem', marginBottom: '1.5rem', flexWrap: 'wrap' }}>
                    <button
                      onClick={handleAdminApprove}
                      disabled={adminActionLoading || adminDetail.status === 'approved'}
                      style={{
                        padding: '0.65rem 1.25rem',
                        background: adminDetail.status === 'approved' ? 'rgba(16, 185, 129, 0.3)' : 'var(--success)',
                        color: '#fff',
                        border: 'none',
                        borderRadius: '8px',
                        fontWeight: 700,
                        fontSize: '0.9rem',
                        cursor: adminDetail.status === 'approved' ? 'default' : 'pointer',
                      }}
                    >
                      {adminDetail.status === 'approved' ? 'Approved ✅' : 'Approve Unit (Show Checkmark) ✅'}
                    </button>

                    <button
                      onClick={() => handleAdminExportJson(adminDetail.unitCode)}
                      style={{
                        padding: '0.65rem 1.25rem',
                        background: 'var(--primary)',
                        color: '#fff',
                        border: 'none',
                        borderRadius: '8px',
                        fontWeight: 700,
                        fontSize: '0.9rem',
                        cursor: 'pointer',
                      }}
                    >
                      ⬇️ Export JSON File
                    </button>

                    <button
                      onClick={() => setShowRejectModal(true)}
                      disabled={adminActionLoading}
                      style={{
                        padding: '0.65rem 1.25rem',
                        background: 'rgba(239, 68, 68, 0.2)',
                        color: '#f87171',
                        border: '1px solid rgba(239, 68, 68, 0.4)',
                        borderRadius: '8px',
                        fontWeight: 700,
                        fontSize: '0.9rem',
                        cursor: 'pointer',
                      }}
                    >
                      Request Revision ⚠️
                    </button>
                  </div>

                  {/* Questions */}
                  <h3 style={{ fontSize: '1.1rem', fontWeight: 700, marginBottom: '1rem' }}>
                    Questions ({adminDetail.questions.length})
                  </h3>

                  <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                    {adminDetail.questions.map((q, idx) => (
                      <div
                        key={q.id || idx}
                        style={{
                          background: 'rgba(15, 23, 42, 0.6)',
                          border: '1px solid var(--border)',
                          borderRadius: '10px',
                          padding: '1.25rem',
                        }}
                      >
                        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem' }}>
                          <span style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--primary)' }}>
                            Q{idx + 1} ({q.id})
                          </span>
                          <span style={{ fontSize: '0.75rem', textTransform: 'uppercase', color: 'var(--muted)', fontWeight: 600 }}>
                            {q.difficulty}
                          </span>
                        </div>

                        <p style={{ fontSize: '0.95rem', fontWeight: 600, marginBottom: '0.85rem' }}>
                          {q.question}
                        </p>

                        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.5rem', marginBottom: '0.85rem' }}>
                          {q.options.map((opt) => {
                            const isCorrect = opt.id === q.correctOptionId;
                            return (
                              <div
                                key={opt.id}
                                style={{
                                  padding: '0.5rem 0.75rem',
                                  borderRadius: '6px',
                                  background: isCorrect ? 'rgba(16, 185, 129, 0.15)' : 'rgba(51, 65, 85, 0.3)',
                                  border: `1px solid ${isCorrect ? 'var(--success)' : 'rgba(255, 255, 255, 0.05)'}`,
                                  color: isCorrect ? '#34d399' : 'var(--text)',
                                  fontSize: '0.85rem',
                                  fontWeight: isCorrect ? 700 : 400,
                                }}
                              >
                                <strong>{opt.id})</strong> {opt.text} {isCorrect && '✓'}
                              </div>
                            );
                          })}
                        </div>

                        <div style={{ fontSize: '0.8rem', color: 'var(--muted)', background: 'rgba(51, 65, 85, 0.25)', padding: '0.5rem 0.75rem', borderRadius: '6px' }}>
                          <strong style={{ color: 'var(--text)' }}>Explanation:</strong> {q.explanation}
                          {q.sourceReference && <span> ({q.sourceReference})</span>}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Reject Modal */}
        {showRejectModal && (
          <div style={{ position: 'fixed', inset: 0, background: 'rgba(0, 0, 0, 0.85)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 110 }}>
            <div style={{ background: 'var(--card)', border: '1px solid var(--border)', borderRadius: '12px', padding: '1.5rem', maxWidth: '480px', width: '100%' }}>
              <h3 style={{ fontSize: '1.1rem', fontWeight: 700, marginBottom: '0.75rem' }}>
                Request Revision
              </h3>
              <textarea
                rows={4}
                placeholder="Enter feedback for student contributor..."
                value={rejectNote}
                onChange={(e) => setRejectNote(e.target.value)}
                style={{ width: '100%', padding: '0.75rem', background: 'rgba(15, 23, 42, 0.7)', border: '1px solid var(--border)', borderRadius: '8px', color: 'var(--text)', fontSize: '0.85rem', marginBottom: '1rem', outline: 'none' }}
              />
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.75rem' }}>
                <button
                  onClick={() => setShowRejectModal(false)}
                  style={{ padding: '0.5rem 1rem', background: 'transparent', border: '1px solid var(--border)', borderRadius: '6px', color: 'var(--muted)', cursor: 'pointer' }}
                >
                  Cancel
                </button>
                <button
                  onClick={handleAdminReject}
                  style={{ padding: '0.5rem 1rem', background: '#ef4444', color: '#fff', border: 'none', borderRadius: '6px', fontWeight: 700, cursor: 'pointer' }}
                >
                  Send Revision Request
                </button>
              </div>
            </div>
          </div>
        )}
      </main>
    );
  }

  // ==========================================
  // VIEW 3: Student Contributor Workspace
  // ==========================================
  const currentGradeUnits = unitTree?.grades.find((g) => g.grade === activeGrade)?.units || [];
  const approvedCount = unitTree?.approvedUnits || 0;
  const totalCount = unitTree?.totalUnits || 0;
  const progressPercent = totalCount > 0 ? Math.round((approvedCount / totalCount) * 100) : 0;

  return (
    <main style={{ maxWidth: '1100px', margin: '0 auto', padding: '2rem 1.5rem' }}>
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
          <h1 style={{ fontSize: '1.6rem', fontWeight: 800 }}>
            {profile.subjectName} Workspace
          </h1>
          <p style={{ color: 'var(--muted)', fontSize: '0.85rem' }}>
            Contributor ID: <strong style={{ color: 'var(--primary)' }}>{profile.contributorId}</strong>
          </p>
        </div>

        <div style={{ minWidth: '240px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', marginBottom: '0.35rem' }}>
            <span style={{ color: 'var(--muted)' }}>Subject Progress</span>
            <strong>{approvedCount} / {totalCount} Units ({progressPercent}%)</strong>
          </div>
          <div style={{ width: '100%', height: '8px', background: 'rgba(51, 65, 85, 0.6)', borderRadius: '999px', overflow: 'hidden' }}>
            <div style={{ width: `${progressPercent}%`, height: '100%', background: 'var(--success)', transition: 'width 0.4s ease' }} />
          </div>
        </div>

        <button
          onClick={handleSignOut}
          style={{ padding: '0.6rem 1rem', background: 'transparent', border: '1px solid var(--border)', borderRadius: '8px', color: 'var(--muted)', fontSize: '0.85rem', fontWeight: 600, cursor: 'pointer' }}
        >
          Sign Out
        </button>
      </header>

      {/* Grade Selector Tabs */}
      <div style={{ display: 'flex', gap: '0.75rem', marginBottom: '1.75rem', borderBottom: '1px solid var(--border)', paddingBottom: '0.75rem' }}>
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
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '1rem' }}>
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
                transition: 'transform 0.15s ease',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'space-between',
              }}
            >
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
                  <span style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--muted)' }}>
                    {unit.unitCode}
                  </span>
                  <span style={{ fontSize: '0.75rem', fontWeight: 700, color: badgeColor, display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
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

      {/* Student Submission Modal */}
      {selectedUnit && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0, 0, 0, 0.8)',
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
                style={{ background: 'transparent', border: 'none', color: 'var(--muted)', fontSize: '1.5rem', cursor: 'pointer' }}
              >
                ✕
              </button>
            </div>

            {submitSuccess && (
              <div style={{ background: 'rgba(16, 185, 129, 0.2)', border: '1px solid var(--success)', borderRadius: '8px', padding: '1rem', color: '#34d399', textAlign: 'center', fontWeight: 700, marginBottom: '1rem' }}>
                ✅ Successfully submitted to Admin!
              </div>
            )}

            {submitError && (
              <div style={{ background: 'rgba(239, 68, 68, 0.15)', border: '1px solid rgba(239, 68, 68, 0.4)', borderRadius: '8px', padding: '0.85rem', color: '#f87171', fontSize: '0.85rem', marginBottom: '1rem' }}>
                ⚠️ {submitError}
              </div>
            )}

            <div style={{ marginBottom: '1.5rem' }}>
              <label style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', fontWeight: 600, color: 'var(--text)', marginBottom: '0.5rem' }}>
                <span>Paste NotebookLM Output (JSON or Text)</span>
                {sanitizing && <span style={{ color: 'var(--primary)' }}>⚡ Auto-cleaning...</span>}
              </label>

              <textarea
                rows={10}
                placeholder="Paste the raw text or JSON you received from NotebookLM here..."
                value={rawPastedText}
                onChange={(e) => handleLiveSanitize(e.target.value)}
                style={{ width: '100%', padding: '1rem', background: 'rgba(15, 23, 42, 0.7)', border: '1px solid var(--border)', borderRadius: '10px', color: 'var(--text)', fontSize: '0.85rem', fontFamily: 'monospace', outline: 'none', resize: 'vertical' }}
              />
            </div>

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

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '1rem' }}>
              <button
                type="button"
                onClick={() => setSelectedUnit(null)}
                style={{ padding: '0.75rem 1.25rem', background: 'transparent', border: '1px solid var(--border)', borderRadius: '8px', color: 'var(--muted)', fontWeight: 600, cursor: 'pointer' }}
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
