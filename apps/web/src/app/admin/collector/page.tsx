'use client';

import { useState, useEffect } from 'react';

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

export default function AdminCollectorPage() {
  const [apiUrl, setApiUrl] = useState<string>('https://acedex-api.onrender.com');
  const [adminKey, setAdminKey] = useState<string>('acedex-admin-2026');
  const [submissions, setSubmissions] = useState<SubmissionSummary[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  // Filters
  const [subjectFilter, setSubjectFilter] = useState<string>('ALL');
  const [statusFilter, setStatusFilter] = useState<string>('ALL');

  // Detail / Review Drawer
  const [selectedSubmissionId, setSelectedSubmissionId] = useState<string | null>(null);
  const [detail, setDetail] = useState<SubmissionDetail | null>(null);
  const [loadingDetail, setLoadingDetail] = useState<boolean>(false);
  const [actionLoading, setActionLoading] = useState<boolean>(false);
  const [actionMessage, setActionMessage] = useState<string | null>(null);

  // Reject note modal
  const [showRejectModal, setShowRejectModal] = useState<boolean>(false);
  const [rejectNote, setRejectNote] = useState<string>('');

  useEffect(() => {
    const url = process.env.NEXT_PUBLIC_API_URL || 'https://acedex-api.onrender.com';
    setApiUrl(url);

    const savedKey = localStorage.getItem('acedex_admin_key') || 'acedex-admin-2026';
    setAdminKey(savedKey);
    fetchSubmissions(savedKey, url);
  }, []);

  const fetchSubmissions = async (keyToUse?: string, baseApi?: string) => {
    setLoading(true);
    setError(null);
    const key = keyToUse || adminKey;
    const base = baseApi || apiUrl;

    try {
      const res = await fetch(`${base}/api/v1/collector/admin/submissions`, {
        headers: {
          'x-admin-key': key,
        },
      });

      const json = await res.json();
      if (!res.ok) {
        throw new Error(json.error?.message || 'Failed to load submissions. Check admin key.');
      }

      setSubmissions(json.data || []);
      localStorage.setItem('acedex_admin_key', key);
    } catch (err: any) {
      setError(err.message || 'Error fetching submissions');
    } finally {
      setLoading(false);
    }
  };

  const openDetail = async (id: string) => {
    setSelectedSubmissionId(id);
    setLoadingDetail(true);
    setActionMessage(null);

    try {
      const res = await fetch(`${apiUrl}/api/v1/collector/admin/submissions/${id}`, {
        headers: { 'x-admin-key': adminKey },
      });
      const json = await res.json();
      if (res.ok) {
        setDetail(json.data);
      }
    } catch (err) {
      console.error('Failed to load detail', err);
    } finally {
      setLoadingDetail(false);
    }
  };

  const handleApprove = async () => {
    if (!detail) return;
    setActionLoading(true);
    setActionMessage(null);

    try {
      const res = await fetch(`${apiUrl}/api/v1/collector/admin/submissions/${detail._id}/approve`, {
        method: 'POST',
        headers: {
          'x-admin-key': adminKey,
          'Content-Type': 'application/json',
        },
      });

      if (!res.ok) throw new Error('Failed to approve');

      setActionMessage('✅ Unit approved! The student portal now shows a green checkmark.');
      setDetail((prev) => (prev ? { ...prev, status: 'approved' } : null));
      await fetchSubmissions();
    } catch (err: any) {
      setActionMessage(`❌ Error: ${err.message}`);
    } finally {
      setActionLoading(false);
    }
  };

  const handleReject = async () => {
    if (!detail) return;
    setActionLoading(true);

    try {
      const res = await fetch(`${apiUrl}/api/v1/collector/admin/submissions/${detail._id}/reject`, {
        method: 'POST',
        headers: {
          'x-admin-key': adminKey,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ notes: rejectNote }),
      });

      if (!res.ok) throw new Error('Failed to reject');

      setActionMessage('⚠️ Revision requested. The student will see your feedback note.');
      setDetail((prev) => (prev ? { ...prev, status: 'rejected', reviewNotes: rejectNote } : null));
      setShowRejectModal(false);
      setRejectNote('');
      await fetchSubmissions();
    } catch (err: any) {
      setActionMessage(`❌ Error: ${err.message}`);
    } finally {
      setActionLoading(false);
    }
  };

  const handleExportJson = (unitCode: string) => {
    window.open(`${apiUrl}/api/v1/collector/admin/submissions/${unitCode}/export?adminKey=${encodeURIComponent(adminKey)}`, '_blank');
  };

  // Filter logic
  const filteredSubmissions = submissions.filter((s) => {
    const matchesSubject = subjectFilter === 'ALL' || s.subjectCode === subjectFilter;
    const matchesStatus = statusFilter === 'ALL' || s.status === statusFilter;
    return matchesSubject && matchesStatus;
  });

  const subjects = ['ALL', 'GEO', 'PHY', 'CHE', 'BIO', 'MAT', 'ENG', 'ECO', 'HIS'];

  return (
    <main style={{ maxWidth: '1200px', margin: '0 auto', padding: '2rem 1.5rem' }}>
      {/* Header */}
      <header
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: '1rem',
          marginBottom: '2rem',
          borderBottom: '1px solid var(--border)',
          paddingBottom: '1.5rem',
        }}
      >
        <div>
          <h1 style={{ fontSize: '1.75rem', fontWeight: 800 }}>
            Question Bank Review Hub
          </h1>
          <p style={{ color: 'var(--muted)', fontSize: '0.9rem', marginTop: '0.25rem' }}>
            Review student submissions, approve units (marks student checkmark), and export standardized JSON files.
          </p>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', background: 'var(--card)', border: '1px solid var(--border)', padding: '0.4rem 0.75rem', borderRadius: '8px' }}>
            <span style={{ fontSize: '0.75rem', color: 'var(--muted)', fontWeight: 600 }}>KEY:</span>
            <input
              type="password"
              value={adminKey}
              onChange={(e) => setAdminKey(e.target.value)}
              style={{ background: 'transparent', border: 'none', color: 'var(--text)', fontSize: '0.85rem', width: '140px', outline: 'none' }}
            />
            <button
              onClick={() => fetchSubmissions(adminKey)}
              style={{ background: 'var(--primary)', color: '#fff', border: 'none', borderRadius: '4px', padding: '0.2rem 0.5rem', fontSize: '0.75rem', cursor: 'pointer', fontWeight: 600 }}
            >
              Apply
            </button>
          </div>

          <button
            onClick={() => fetchSubmissions()}
            style={{
              padding: '0.55rem 1rem',
              background: 'rgba(51, 65, 85, 0.5)',
              border: '1px solid var(--border)',
              borderRadius: '8px',
              color: 'var(--text)',
              fontSize: '0.85rem',
              fontWeight: 600,
              cursor: 'pointer',
            }}
          >
            🔄 Refresh
          </button>
        </div>
      </header>

      {error && (
        <div style={{ background: 'rgba(239, 68, 68, 0.1)', border: '1px solid rgba(239, 68, 68, 0.4)', borderRadius: '8px', padding: '0.85rem', color: '#f87171', marginBottom: '1.5rem' }}>
          ⚠️ {error}
        </div>
      )}

      {/* Filter Tabs */}
      <div style={{ marginBottom: '1.5rem' }}>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.5rem', marginBottom: '0.75rem' }}>
          {subjects.map((sub) => (
            <button
              key={sub}
              onClick={() => setSubjectFilter(sub)}
              style={{
                padding: '0.4rem 0.85rem',
                borderRadius: '6px',
                border: 'none',
                background: subjectFilter === sub ? 'var(--primary)' : 'var(--card)',
                color: subjectFilter === sub ? '#fff' : 'var(--muted)',
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
              onClick={() => setStatusFilter(st.id)}
              style={{
                padding: '0.35rem 0.75rem',
                borderRadius: '6px',
                border: '1px solid var(--border)',
                background: statusFilter === st.id ? 'rgba(51, 65, 85, 0.8)' : 'transparent',
                color: statusFilter === st.id ? 'var(--text)' : 'var(--muted)',
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

      {/* Submissions Table / Grid */}
      {loading ? (
        <div style={{ textAlign: 'center', padding: '4rem', color: 'var(--muted)' }}>
          Loading submissions...
        </div>
      ) : filteredSubmissions.length === 0 ? (
        <div style={{ background: 'var(--card)', border: '1px solid var(--border)', borderRadius: '12px', padding: '3rem', textAlign: 'center', color: 'var(--muted)' }}>
          <span style={{ fontSize: '2rem', display: 'block', marginBottom: '0.5rem' }}>📭</span>
          No submissions found for the selected filters.
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
              {filteredSubmissions.map((s) => {
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
                          onClick={() => openDetail(s._id)}
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
                          onClick={() => handleExportJson(s.unitCode)}
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
                          title="Download standardized JSON file"
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

      {/* ==========================================
          MODAL: Review Detail Drawer
         ========================================== */}
      {selectedSubmissionId && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0, 0, 0, 0.8)',
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
            {loadingDetail || !detail ? (
              <div style={{ textAlign: 'center', padding: '3rem', color: 'var(--muted)' }}>
                Loading unit questions...
              </div>
            ) : (
              <div>
                {/* Header */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', borderBottom: '1px solid var(--border)', paddingBottom: '1rem', marginBottom: '1.5rem' }}>
                  <div>
                    <span style={{ fontSize: '0.8rem', color: 'var(--primary)', fontWeight: 700 }}>
                      {detail.unitCode} • Grade {detail.grade} • Contributor: {detail.contributorId}
                    </span>
                    <h2 style={{ fontSize: '1.4rem', fontWeight: 800 }}>
                      Unit {detail.unitNumber}: {detail.unitTitle}
                    </h2>
                  </div>
                  <button
                    onClick={() => setSelectedSubmissionId(null)}
                    style={{ background: 'transparent', border: 'none', color: 'var(--muted)', fontSize: '1.5rem', cursor: 'pointer' }}
                  >
                    ✕
                  </button>
                </div>

                {actionMessage && (
                  <div style={{ padding: '0.85rem', borderRadius: '8px', background: 'rgba(51, 65, 85, 0.5)', marginBottom: '1.25rem', fontWeight: 600 }}>
                    {actionMessage}
                  </div>
                )}

                {/* Top Action Toolbar */}
                <div style={{ display: 'flex', gap: '0.75rem', marginBottom: '1.5rem', flexWrap: 'wrap' }}>
                  <button
                    onClick={handleApprove}
                    disabled={actionLoading || detail.status === 'approved'}
                    style={{
                      padding: '0.65rem 1.25rem',
                      background: detail.status === 'approved' ? 'rgba(16, 185, 129, 0.3)' : 'var(--success)',
                      color: '#fff',
                      border: 'none',
                      borderRadius: '8px',
                      fontWeight: 700,
                      fontSize: '0.9rem',
                      cursor: detail.status === 'approved' ? 'default' : 'pointer',
                    }}
                  >
                    {detail.status === 'approved' ? 'Approved ✅' : 'Approve Unit (Show Checkmark) ✅'}
                  </button>

                  <button
                    onClick={() => handleExportJson(detail.unitCode)}
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
                    disabled={actionLoading}
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

                {/* 15 Questions Inspection Cards */}
                <h3 style={{ fontSize: '1.1rem', fontWeight: 700, marginBottom: '1rem' }}>
                  Questions ({detail.questions.length})
                </h3>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                  {detail.questions.map((q, idx) => (
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

                      {/* Options */}
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

                      {/* Explanation */}
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

      {/* Reject Note Modal */}
      {showRejectModal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0, 0, 0, 0.85)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 110 }}>
          <div style={{ background: 'var(--card)', border: '1px solid var(--border)', borderRadius: '12px', padding: '1.5rem', maxWidth: '480px', width: '100%' }}>
            <h3 style={{ fontSize: '1.1rem', fontWeight: 700, marginBottom: '0.75rem' }}>
              Request Revision from Contributor
            </h3>
            <textarea
              rows={4}
              placeholder="Enter feedback for the student (e.g. Question 5 has incomplete options)..."
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
                onClick={handleReject}
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
