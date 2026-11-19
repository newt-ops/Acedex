'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useAuth } from '../../context/AuthContext';
import { getBaseApiUrl, setBaseApiUrl } from '../../lib/api';
import { LogOut, ShieldCheck, UserCheck, Server, ChevronDown } from 'lucide-react';

export function Navbar() {
  const { profile, logout, isAdmin } = useAuth();
  const [apiUrl, setApiUrlState] = useState<string>(() => getBaseApiUrl());
  const [showConfig, setShowConfig] = useState<boolean>(false);

  const handleUrlChange = (newUrl: string) => {
    setBaseApiUrl(newUrl);
    setApiUrlState(newUrl);
    setShowConfig(false);
    window.location.reload();
  };

  const isLocal = apiUrl.includes('localhost') || apiUrl.includes('127.0.0.1');

  return (
    <header className="sticky top-0 z-40 w-full border-b border-acedex-border/80 bg-acedex-bg/85 backdrop-blur-md">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16 gap-3">
          {/* Logo & Portal Tag */}
          <div className="flex items-center gap-2.5">
            <Link href={isAdmin ? '/admin' : '/student'} className="flex items-center gap-2 group">
              <span className="text-xl sm:text-2xl font-black bg-gradient-to-r from-acedex-primary to-acedex-accent bg-clip-text text-transparent tracking-tight group-hover:opacity-90 transition-opacity">
                ACEDEX
              </span>
              <span className="hidden sm:inline-block px-2 py-0.5 rounded-full text-[10px] font-bold tracking-wider uppercase bg-acedex-primary/10 text-acedex-primary border border-acedex-primary/30">
                {isAdmin ? 'ADMIN HUB' : 'QUESTION COLLECTOR'}
              </span>
            </Link>
          </div>

          {/* User Profile & Actions */}
          <div className="flex items-center gap-2 sm:gap-3">
            {/* API Status & Config Pill */}
            <div className="relative">
              <button
                onClick={() => setShowConfig(!showConfig)}
                className="flex items-center gap-1.5 px-2.5 py-1 text-xs rounded-lg bg-acedex-card border border-acedex-border text-acedex-muted hover:text-acedex-text transition-colors"
                title="API Endpoint Configuration"
              >
                <span
                  className={`w-2 h-2 rounded-full ${
                    isLocal ? 'bg-amber-400' : 'bg-emerald-400 animate-pulse'
                  }`}
                />
                <span className="hidden md:inline font-mono">
                  {isLocal ? 'Local:5000' : 'Render Live'}
                </span>
                <ChevronDown className="w-3 h-3 text-acedex-muted" />
              </button>

              {showConfig && (
                <div className="absolute right-0 mt-2 w-64 bg-acedex-card border border-acedex-border rounded-xl shadow-xl p-3 z-50 text-xs text-acedex-text">
                  <div className="font-semibold text-acedex-text mb-2 flex items-center gap-1.5">
                    <Server className="w-3.5 h-3.5 text-acedex-primary" /> Target API Endpoint
                  </div>
                  <div className="space-y-1.5">
                    <button
                      onClick={() => handleUrlChange('https://acedex-api.onrender.com')}
                      className={`w-full text-left p-2 rounded-lg border transition-colors ${
                        !isLocal
                          ? 'border-acedex-primary bg-acedex-primary/10 text-acedex-primary font-medium'
                          : 'border-acedex-border/60 hover:bg-acedex-card-hover'
                      }`}
                    >
                      <div className="font-semibold">Production (Render)</div>
                      <div className="text-[10px] text-acedex-muted truncate">
                        https://acedex-api.onrender.com
                      </div>
                    </button>
                    <button
                      onClick={() => handleUrlChange('http://localhost:5000')}
                      className={`w-full text-left p-2 rounded-lg border transition-colors ${
                        isLocal
                          ? 'border-acedex-primary bg-acedex-primary/10 text-acedex-primary font-medium'
                          : 'border-acedex-border/60 hover:bg-acedex-card-hover'
                      }`}
                    >
                      <div className="font-semibold">Local Development</div>
                      <div className="text-[10px] text-acedex-muted">
                        http://localhost:5000
                      </div>
                    </button>
                  </div>
                </div>
              )}
            </div>

            {/* Profile Info */}
            {profile && (
              <div className="flex items-center gap-2">
                <div className="hidden sm:flex flex-col text-right">
                  <span className="text-xs font-semibold text-acedex-text leading-tight flex items-center justify-end gap-1">
                    {isAdmin ? (
                      <ShieldCheck className="w-3.5 h-3.5 text-acedex-accent" />
                    ) : (
                      <UserCheck className="w-3.5 h-3.5 text-acedex-primary" />
                    )}
                    {profile.name}
                  </span>
                  <span className="text-[11px] font-mono text-acedex-muted">
                    {profile.contributorId}
                  </span>
                </div>

                {/* Logout Button */}
                <button
                  onClick={logout}
                  className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium bg-acedex-card hover:bg-red-500/15 hover:text-red-400 text-acedex-muted border border-acedex-border transition-colors min-h-[36px]"
                  title="Sign Out"
                >
                  <LogOut className="w-3.5 h-3.5" />
                  <span className="hidden sm:inline">Sign Out</span>
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </header>
  );
}
