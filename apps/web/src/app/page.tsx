'use client';

import { useState, useEffect } from 'react';

interface HealthData {
  status?: string;
  uptimeSeconds?: number;
  environment?: string;
  version?: string;
  database?: {
    status?: string;
    connected?: boolean;
    name?: string;
  };
}

export default function AdminHomePage() {
  const [apiUrl, setApiUrl] = useState<string>('');
  const [health, setHealth] = useState<HealthData | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const url = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000';
    setApiUrl(url);
    checkHealth(url);
  }, []);

  const checkHealth = async (targetUrl: string) => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`${targetUrl}/health`);
      if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      const json = await res.json();
      setHealth(json.data || json);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to reach API');
      setHealth(null);
    } finally {
      setLoading(false);
    }
  };

  return (
    <main style={{ maxWidth: '1200px', margin: '0 auto', padding: '2rem' }}>
      {/* Header */}
      <header
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          paddingBottom: '2rem',
          borderBottom: '1px solid var(--border)',
          marginBottom: '2.5rem',
        }}
      >
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            <span
              style={{
                fontSize: '1.75rem',
                fontWeight: 'bold',
                background: 'linear-gradient(135deg, #3b82f6, #8b5cf6)',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
              }}
            >
              ACEDEX
            </span>
            <span
              style={{
                fontSize: '0.75rem',
                backgroundColor: '#3b82f620',
                color: '#60a5fa',
                padding: '0.2rem 0.6rem',
                borderRadius: '9999px',
                border: '1px solid #3b82f640',
                fontWeight: 600,
              }}
            >
              ADMIN PORTAL
            </span>
          </div>
          <p style={{ color: 'var(--muted)', marginTop: '0.5rem', fontSize: '0.95rem' }}>
            Internal Educational & Assessment Management Platform (Grades 9–12)
          </p>
        </div>

        <div style={{ textAlign: 'right' }}>
          <span
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '0.4rem',
              fontSize: '0.85rem',
              color: '#34d399',
              backgroundColor: '#065f4630',
              padding: '0.35rem 0.85rem',
              borderRadius: '9999px',
              border: '1px solid #05966950',
            }}
          >
            ● Vercel Deployment Live
          </span>
        </div>
      </header>

      {/* Backend API Connection Banner */}
      <section
        style={{
          backgroundColor: 'var(--card)',
          border: '1px solid var(--border)',
          borderRadius: '12px',
          padding: '1.5rem',
          marginBottom: '2.5rem',
        }}
      >
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <h3 style={{ fontSize: '1.1rem', marginBottom: '0.35rem' }}>Backend API Connectivity Probe</h3>
            <p style={{ color: 'var(--muted)', fontSize: '0.875rem' }}>
              Target Backend:{' '}
              <code style={{ color: '#93c5fd', backgroundColor: '#1e293b', padding: '0.2rem 0.4rem', borderRadius: '4px' }}>
                {apiUrl}
              </code>
            </p>
          </div>
          <button
            onClick={() => checkHealth(apiUrl)}
            disabled={loading}
            style={{
              backgroundColor: 'var(--primary)',
              color: 'white',
              border: 'none',
              padding: '0.6rem 1.2rem',
              borderRadius: '8px',
              cursor: loading ? 'not-allowed' : 'pointer',
              fontWeight: 600,
              fontSize: '0.875rem',
            }}
          >
            {loading ? 'Checking...' : 'Probe Live Health'}
          </button>
        </div>

        <div style={{ marginTop: '1.25rem', paddingTop: '1.25rem', borderTop: '1px solid var(--border)' }}>
          {health ? (
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '1rem' }}>
              <div>
                <span style={{ fontSize: '0.75rem', color: 'var(--muted)', textTransform: 'uppercase' }}>API Status</span>
                <p style={{ fontSize: '1.1rem', fontWeight: 'bold', color: health.status === 'healthy' ? '#34d399' : '#f59e0b' }}>
                  {health.status?.toUpperCase() || 'OK'}
                </p>
              </div>
              <div>
                <span style={{ fontSize: '0.75rem', color: 'var(--muted)', textTransform: 'uppercase' }}>Database</span>
                <p style={{ fontSize: '1.1rem', fontWeight: 'bold', color: health.database?.connected ? '#34d399' : '#ef4444' }}>
                  {health.database?.connected ? `Connected (${health.database?.name})` : 'Disconnected'}
                </p>
              </div>
              <div>
                <span style={{ fontSize: '0.75rem', color: 'var(--muted)', textTransform: 'uppercase' }}>Uptime</span>
                <p style={{ fontSize: '1.1rem', fontWeight: 'bold' }}>{health.uptimeSeconds}s</p>
              </div>
              <div>
                <span style={{ fontSize: '0.75rem', color: 'var(--muted)', textTransform: 'uppercase' }}>Environment</span>
                <p style={{ fontSize: '1.1rem', fontWeight: 'bold' }}>{health.environment}</p>
              </div>
            </div>
          ) : error ? (
            <div style={{ color: '#f87171', fontSize: '0.9rem' }}>
              ⚠️ Unable to reach backend at {apiUrl} ({error}). Once Render backend is live, update{' '}
              <code>NEXT_PUBLIC_API_URL</code> in Vercel environment variables.
            </div>
          ) : (
            <p style={{ color: 'var(--muted)', fontSize: '0.875rem' }}>Probing backend status...</p>
          )}
        </div>
      </section>

      {/* Admin Modules Grid */}
      <h2 style={{ fontSize: '1.25rem', marginBottom: '1.25rem' }}>Administrative Modules (Roadmap)</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '1.5rem' }}>
        {[
          {
            title: 'Question Bank Pipeline',
            desc: 'Validate, preview, and publish 30-item unit question JSONs. 238 unit datasets prepared across 8 subjects.',
            tag: 'Phase 3 Priority',
            color: '#3b82f6',
          },
          {
            title: 'Curriculum Management',
            desc: 'Organize Ethiopian secondary curriculum grades (9–12), national subjects, and unit metadata.',
            tag: 'Curriculum',
            color: '#8b5cf6',
          },
          {
            title: 'Student Accounts & Records',
            desc: 'Inspect registered student profiles, track assessment activity, and review academic performance history.',
            tag: 'Users',
            color: '#10b981',
          },
          {
            title: 'Assessment Engine & Key Isolation',
            desc: 'Enforce answer key isolation. Configure passing thresholds, timers, and assessment rules.',
            tag: 'Scoring',
            color: '#f59e0b',
          },
          {
            title: 'Platform Analytics',
            desc: 'Question-level discrimination metrics, student accuracy, subject difficulties, and activity heatmaps.',
            tag: 'Analytics',
            color: '#ec4899',
          },
          {
            title: 'Access Control & Audit Logs',
            desc: 'Role-based access control (super_admin, admin, content_manager) and administrative action auditing.',
            tag: 'Security',
            color: '#6366f1',
          },
        ].map((mod, idx) => (
          <div
            key={idx}
            style={{
              backgroundColor: 'var(--card)',
              border: '1px solid var(--border)',
              borderRadius: '12px',
              padding: '1.5rem',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.75rem' }}>
              <h3 style={{ fontSize: '1.05rem', fontWeight: 600 }}>{mod.title}</h3>
              <span
                style={{
                  fontSize: '0.7rem',
                  padding: '0.2rem 0.5rem',
                  borderRadius: '6px',
                  backgroundColor: `${mod.color}20`,
                  color: mod.color,
                  fontWeight: 600,
                }}
              >
                {mod.tag}
              </span>
            </div>
            <p style={{ color: 'var(--muted)', fontSize: '0.875rem', lineHeight: '1.5' }}>{mod.desc}</p>
          </div>
        ))}
      </div>
    </main>
  );
}
