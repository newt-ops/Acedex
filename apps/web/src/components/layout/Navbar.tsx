'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAuth } from '../../context/AuthContext';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  Logout01Icon,
  ShieldCheckIcon,
  UserIcon,
  BookOpen01Icon,
  FileCodeIcon,
} from '@hugeicons/core-free-icons';

export function Navbar() {
  const { profile, logout, isAdmin } = useAuth();
  const pathname = usePathname();

  const isNotesActive = pathname?.includes('/notes');

  return (
    <header className="sticky top-0 z-40 w-full border-b border-acedex-border/80 bg-acedex-bg/85 backdrop-blur-xl">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16 gap-3">
          {/* Logo & Portal Branding */}
          <div className="flex items-center gap-2.5">
            <Link
              href={isNotesActive ? (isAdmin ? '/admin/notes' : '/notes') : (isAdmin ? '/admin' : '/student')}
              className="flex items-center gap-2 group"
            >
              <span className="text-xl sm:text-2xl font-black bg-gradient-to-r from-acedex-primary via-purple-500 to-acedex-accent bg-clip-text text-transparent tracking-tight group-hover:opacity-90 transition-opacity">
                ACEDEX
              </span>
              <span className="hidden md:inline-block px-2.5 py-0.5 rounded-full text-[10px] font-bold tracking-wider uppercase bg-acedex-primary/10 text-acedex-primary border border-acedex-primary/30">
                {isAdmin ? 'ADMIN REVIEW HUB' : 'CURRICULUM PORTAL'}
              </span>
            </Link>
          </div>

          {/* Center Mode Switcher: Questions vs Quick Notes */}
          {profile && (
            <div className="flex items-center p-1 rounded-2xl bg-acedex-card/80 border border-acedex-border/80 shadow-inner">
              <Link
                href={isAdmin ? '/admin' : '/student'}
                className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-bold transition-all duration-200 ${
                  !isNotesActive
                    ? 'bg-acedex-primary text-white shadow-md'
                    : 'text-acedex-muted hover:text-acedex-text'
                }`}
              >
                <HugeiconsIcon icon={FileCodeIcon} size={13} strokeWidth={2} />
                <span>Questions</span>
              </Link>
              <Link
                href={isAdmin ? '/admin/notes' : '/notes'}
                className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-bold transition-all duration-200 ${
                  isNotesActive
                    ? 'bg-gradient-to-r from-violet-600 to-indigo-600 text-white shadow-md shadow-indigo-500/20'
                    : 'text-acedex-muted hover:text-acedex-text'
                }`}
              >
                <HugeiconsIcon icon={BookOpen01Icon} size={13} strokeWidth={2} />
                <span>Quick Notes</span>
              </Link>
            </div>
          )}

          {/* User Profile & Actions */}
          <div className="flex items-center gap-2.5 sm:gap-4">
            {profile && (
              <>
                {/* Contributor Profile Tag */}
                <div className="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-acedex-card/80 border border-acedex-border/70 text-xs">
                  <div className="w-7 h-7 rounded-lg bg-acedex-primary/10 border border-acedex-primary/20 flex items-center justify-center shrink-0">
                    {isAdmin ? (
                      <HugeiconsIcon
                        icon={ShieldCheckIcon}
                        size={15}
                        className="text-acedex-accent shrink-0"
                        strokeWidth={1.5}
                      />
                    ) : (
                      <HugeiconsIcon
                        icon={UserIcon}
                        size={15}
                        className="text-acedex-primary shrink-0"
                        strokeWidth={1.5}
                      />
                    )}
                  </div>
                  <div className="flex flex-col text-left">
                    <span className="font-semibold text-acedex-text leading-tight max-w-[100px] sm:max-w-none truncate">
                      {profile.name}
                    </span>
                    <span className="text-[10px] font-mono text-acedex-muted leading-tight">
                      {profile.contributorId}
                    </span>
                  </div>
                </div>

                {/* Logout Button */}
                <button
                  onClick={logout}
                  className="inline-flex items-center justify-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold bg-acedex-card hover:bg-rose-500/15 hover:text-rose-400 text-acedex-muted border border-acedex-border/80 transition-colors min-h-[36px] select-none active:scale-[0.98]"
                  title="Sign Out"
                >
                  <HugeiconsIcon
                    icon={Logout01Icon}
                    size={15}
                    strokeWidth={1.5}
                    className="shrink-0"
                  />
                  <span className="hidden sm:inline">Sign Out</span>
                </button>
              </>
            )}
          </div>
        </div>
      </div>
    </header>
  );
}
