'use client';

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../context/AuthContext';
import { Card, CardContent } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { getBaseApiUrl, setBaseApiUrl } from '../lib/api';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  Key01Icon,
  ArrowRight01Icon,
  AlertCircleIcon,
  ShieldCheckIcon,
  ServerIcon,
} from '@hugeicons/core-free-icons';

export default function LoginPage() {
  const { login, isAuthenticated, isAdmin, loading: authLoading } = useAuth();
  const router = useRouter();

  const [accessId, setAccessId] = useState<string>('');
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  // API Url setting toggle
  const [apiUrl, setApiUrlState] = useState<string>('https://acedex-api.onrender.com');
  const [showConfig, setShowConfig] = useState<boolean>(false);

  useEffect(() => {
    setApiUrlState(getBaseApiUrl());
    if (isAuthenticated) {
      if (isAdmin) {
        router.push('/admin');
      } else {
        router.push('/student');
      }
    }
  }, [isAuthenticated, isAdmin, router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!accessId.trim()) {
      setError('Please enter your assigned Access ID');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      await login(accessId.trim().toUpperCase());
      // AuthProvider automatically routes to /admin or /student
    } catch (err: any) {
      setError(err.message || 'Invalid Access ID or server unreachable');
    } finally {
      setLoading(false);
    }
  };

  const handleUrlChange = (url: string) => {
    setBaseApiUrl(url);
    setApiUrlState(url);
    setShowConfig(false);
  };

  if (authLoading) {
    return (
      <div className="flex-1 flex items-center justify-center p-4">
        <div className="w-8 h-8 rounded-full border-2 border-acedex-primary border-t-transparent animate-spin" />
      </div>
    );
  }

  const isLocal = apiUrl.includes('localhost') || apiUrl.includes('127.0.0.1');

  return (
    <div className="flex-1 flex flex-col justify-between p-4 sm:p-6 lg:p-8 max-w-lg mx-auto w-full">
      {/* Top spacer */}
      <div />

      {/* Main Login Card */}
      <div className="w-full my-auto">
        {/* Brand Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center gap-2 mb-2">
            <span className="text-3xl sm:text-4xl font-black bg-gradient-to-r from-acedex-primary to-acedex-accent bg-clip-text text-transparent tracking-tight">
              ACEDEX
            </span>
          </div>
          <p className="text-sm text-acedex-muted">
            Question Collection & Ingestion Portal (Grades 9–12)
          </p>
        </div>

        <Card className="border-acedex-border/80 shadow-2xl bg-acedex-card/90 backdrop-blur-sm">
          <CardContent className="p-6 sm:p-8">
            <form onSubmit={handleSubmit} className="space-y-5">
              <div className="space-y-2">
                <label
                  htmlFor="accessId"
                  className="block text-xs font-semibold text-acedex-muted uppercase tracking-wider"
                >
                  Contributor / Admin Access ID
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-acedex-muted">
                    <HugeiconsIcon icon={Key01Icon} size={16} className="text-acedex-primary" strokeWidth={1.5} />
                  </div>
                  <input
                    id="accessId"
                    type="text"
                    value={accessId}
                    onChange={(e) => {
                      setAccessId(e.target.value.toUpperCase());
                      setError(null);
                    }}
                    placeholder="Enter your ID"
                    autoCapitalize="characters"
                    autoCorrect="off"
                    spellCheck="false"
                    className="w-full pl-10 pr-4 py-3 bg-acedex-bg border border-acedex-border rounded-xl text-sm font-mono text-acedex-text placeholder:text-acedex-muted/40 focus:border-acedex-primary focus:ring-2 focus:ring-acedex-primary/20 transition-all min-h-[48px]"
                  />
                </div>
                <p className="text-[11px] text-acedex-muted/70">
                  Enter your private credential provided by the administrator.
                </p>
              </div>

              {/* Error message */}
              {error && (
                <div className="p-3 bg-rose-500/10 border border-rose-500/25 rounded-xl text-xs text-rose-400 flex items-start gap-2">
                  <HugeiconsIcon icon={AlertCircleIcon} size={16} className="shrink-0 mt-0.5 text-rose-500" strokeWidth={1.5} />
                  <span className="leading-snug">{error}</span>
                </div>
              )}

              {/* Submit button */}
              <Button
                type="submit"
                variant="primary"
                size="lg"
                loading={loading}
                className="w-full text-sm font-semibold min-h-[48px]"
              >
                <span>Enter Workspace</span>
                <HugeiconsIcon icon={ArrowRight01Icon} size={16} className="ml-1.5 shrink-0" strokeWidth={2} />
              </Button>
            </form>
          </CardContent>
        </Card>

        {/* Security badge */}
        <div className="flex items-center justify-center gap-1.5 mt-6 text-xs text-acedex-muted/80">
          <HugeiconsIcon icon={ShieldCheckIcon} size={16} className="text-emerald-500 shrink-0" strokeWidth={1.5} />
          <span>Role-Gated Access • Direct Question Bank Sync</span>
        </div>
      </div>

      {/* Target Backend API switcher */}
      <div className="pt-8 text-center">
        <button
          onClick={() => setShowConfig(!showConfig)}
          className="inline-flex items-center gap-1.5 text-xs text-acedex-muted/60 hover:text-acedex-muted transition-colors"
        >
          <HugeiconsIcon icon={ServerIcon} size={14} className="shrink-0" strokeWidth={1.5} />
          <span>Backend: {isLocal ? 'Local:5000' : 'Production Render'}</span>
        </button>

        {showConfig && (
          <div className="mt-3 p-3 bg-acedex-card border border-acedex-border rounded-xl max-w-sm mx-auto text-xs space-y-2">
            <div className="font-semibold text-acedex-text">Select Backend API:</div>
            <div className="flex gap-2">
              <Button
                size="sm"
                variant={!isLocal ? 'primary' : 'outline'}
                className="flex-1 text-xs"
                onClick={() => handleUrlChange('https://acedex-api.onrender.com')}
              >
                Production (Render)
              </Button>
              <Button
                size="sm"
                variant={isLocal ? 'primary' : 'outline'}
                className="flex-1 text-xs"
                onClick={() => handleUrlChange('http://localhost:5000')}
              >
                Localhost (5000)
              </Button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
