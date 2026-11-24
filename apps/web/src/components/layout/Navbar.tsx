'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAuth } from '../../context/AuthContext';
import { ThemeToggle } from '../ui/ThemeToggle';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  HelpCircleIcon,
  BookOpen01Icon,
  UserIcon,
  Logout01Icon,
} from '@hugeicons/core-free-icons';

export function Navbar() {
  const { profile, logout, isAdmin } = useAuth();
  const pathname = usePathname();

  const isNotesActive = pathname?.includes('/notes');

  return (
    <header className="sticky top-0 z-30 bg-white/90 dark:bg-[#111116]/90 backdrop-blur-xl border-b border-slate-200/70 dark:border-white/[0.08] transition-colors duration-200">
      <div className="max-w-[1640px] mx-auto px-4 sm:px-8 lg:px-10 py-2.5 md:py-0 md:h-[68px] flex flex-wrap md:flex-nowrap items-center justify-between gap-y-2.5 gap-x-3">
        {/* Left: ACEDEX Wordmark + Curriculum Portal Pill */}
        <div className="flex items-center gap-2 shrink-0 order-1">
          <Link
            href={isNotesActive ? (isAdmin ? '/admin/notes' : '/notes') : (isAdmin ? '/admin' : '/student')}
            className="font-display text-[21px] sm:text-[24px] font-extrabold tracking-[-0.035em] text-[#7E22CE] dark:text-[#A855F7] leading-none select-none hover:opacity-90 transition-opacity"
          >
            ACEDEX
          </Link>
          <span className="inline-flex items-center px-2 sm:px-2.5 py-0.5 sm:py-1 rounded-full text-[9.5px] sm:text-[10px] font-bold tracking-[0.07em] uppercase text-[#7E22CE] dark:text-[#C084FC] bg-purple-50/90 dark:bg-purple-950/40 border border-purple-200/70 dark:border-purple-800/50">
            <span className="sm:hidden">{isAdmin ? 'ADMIN' : 'PORTAL'}</span>
            <span className="hidden sm:inline">{isAdmin ? 'ADMIN REVIEW HUB' : 'CURRICULUM PORTAL'}</span>
          </span>
        </div>

        {/* Center: Segmented Mode Control */}
        {profile && (
          <div className="w-full md:w-auto order-3 md:order-2 flex justify-center">
            <div className="relative grid grid-cols-2 md:inline-flex w-full md:w-auto items-center p-1 rounded-full bg-slate-100/90 dark:bg-white/[0.06] border border-slate-200/70 dark:border-white/[0.08] shadow-inner">
              <Link
                href={isAdmin ? '/admin' : '/student'}
                className={`relative z-10 inline-flex items-center justify-center gap-2 min-h-[38px] md:min-h-0 px-4 sm:px-5 py-1.5 rounded-full text-[13px] font-semibold transition-all duration-200 cursor-pointer ${
                  !isNotesActive
                    ? 'bg-[#7E22CE] text-white shadow-[0_3px_10px_-2px_rgba(126,34,206,0.45)]'
                    : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
                }`}
              >
                <HugeiconsIcon icon={HelpCircleIcon} size={16} strokeWidth={2} className="shrink-0" />
                <span>Questions</span>
              </Link>

              <Link
                href={isAdmin ? '/admin/notes' : '/notes'}
                className={`relative z-10 inline-flex items-center justify-center gap-2 min-h-[38px] md:min-h-0 px-4 sm:px-5 py-1.5 rounded-full text-[13px] font-semibold transition-all duration-200 cursor-pointer ${
                  isNotesActive
                    ? 'bg-[#7E22CE] text-white shadow-[0_3px_10px_-2px_rgba(126,34,206,0.45)]'
                    : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
                }`}
              >
                <HugeiconsIcon icon={BookOpen01Icon} size={16} strokeWidth={2} className="shrink-0" />
                <span>Quick Notes</span>
              </Link>
            </div>
          </div>
        )}

        {/* Right: Theme Toggle + Contributor Profile Pill + Sign Out Button */}
        <div className="flex items-center gap-2 sm:gap-2.5 shrink-0 order-2 md:order-3">
          {/* Universal Light/Dark Theme Toggle (Using Hugeicons Sun01/Moon02) */}
          <ThemeToggle />

          {profile && (
            <>
              {/* Contributor Pill */}
              <div className="flex items-center gap-2 sm:gap-2.5 px-2.5 sm:px-3.5 py-1 sm:py-1.5 rounded-[12px] sm:rounded-[14px] bg-white dark:bg-[#181820] border border-slate-200/80 dark:border-white/[0.09] shadow-[0_1px_3px_rgba(15,23,42,0.03)]">
                <div className="w-6 h-6 sm:w-7 sm:h-7 rounded-full bg-purple-50 dark:bg-purple-950/40 border border-purple-200/70 dark:border-purple-800/50 flex items-center justify-center text-[#7E22CE] dark:text-[#A855F7] shrink-0">
                  <HugeiconsIcon icon={UserIcon} size={14} strokeWidth={2} />
                </div>
                <div className="leading-tight">
                  <div className="hidden sm:block text-[12.5px] font-semibold text-slate-800 dark:text-slate-200">
                    {profile.name}
                  </div>
                  <div className="text-[11px] sm:text-[10.5px] font-mono font-semibold sm:font-normal text-slate-700 dark:text-slate-400">
                    {profile.contributorId}
                  </div>
                </div>
              </div>

              {/* Sign Out Button */}
              <button
                type="button"
                onClick={logout}
                aria-label="Sign Out"
                className="inline-flex items-center justify-center gap-1.5 min-h-[36px] sm:min-h-0 px-2.5 sm:px-3.5 py-1.5 sm:py-2 rounded-[12px] sm:rounded-[13px] bg-white dark:bg-[#181820] hover:bg-slate-50 dark:hover:bg-white/[0.06] border border-slate-200/85 dark:border-white/[0.09] text-[12px] sm:text-[12.5px] font-semibold text-slate-700 dark:text-slate-300 hover:text-slate-900 dark:hover:text-white shadow-[0_1px_2px_rgba(15,23,42,0.03)] transition-all duration-200 active:scale-95 cursor-pointer"
              >
                <HugeiconsIcon icon={Logout01Icon} size={14} strokeWidth={2} className="text-slate-500 dark:text-slate-400 shrink-0" />
                <span className="hidden sm:inline">Sign Out</span>
              </button>
            </>
          )}
        </div>
      </div>
    </header>
  );
}
