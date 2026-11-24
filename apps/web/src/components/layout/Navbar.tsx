'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAuth } from '../../context/AuthContext';

export function Navbar() {
  const { profile, logout, isAdmin } = useAuth();
  const pathname = usePathname();

  const isNotesActive = pathname?.includes('/notes');

  return (
    <header className="sticky top-0 z-30 bg-white/90 backdrop-blur-xl border-b border-slate-200/70">
      <div className="max-w-[1640px] mx-auto px-4 sm:px-8 lg:px-10 py-2.5 md:py-0 md:h-[68px] flex flex-wrap md:flex-nowrap items-center justify-between gap-y-2.5 gap-x-3">
        {/* Left: ACEDEX Wordmark + Curriculum Portal Pill */}
        <div className="flex items-center gap-2 shrink-0 order-1">
          <Link
            href={isNotesActive ? (isAdmin ? '/admin/notes' : '/notes') : (isAdmin ? '/admin' : '/student')}
            className="font-display text-[21px] sm:text-[24px] font-extrabold tracking-[-0.035em] text-[#7E22CE] leading-none select-none hover:opacity-90 transition-opacity"
          >
            ACEDEX
          </Link>
          <span className="inline-flex items-center px-2 sm:px-2.5 py-0.5 sm:py-1 rounded-full text-[9.5px] sm:text-[10px] font-bold tracking-[0.07em] uppercase text-[#7E22CE] bg-purple-50/90 border border-purple-200/70">
            <span className="sm:hidden">{isAdmin ? 'ADMIN' : 'PORTAL'}</span>
            <span className="hidden sm:inline">{isAdmin ? 'ADMIN REVIEW HUB' : 'CURRICULUM PORTAL'}</span>
          </span>
        </div>

        {/* Center: Segmented Mode Control */}
        {profile && (
          <div className="w-full md:w-auto order-3 md:order-2 flex justify-center">
            <div className="relative grid grid-cols-2 md:inline-flex w-full md:w-auto items-center p-1 rounded-full bg-slate-100/90 border border-slate-200/70 shadow-inner">
              <Link
                href={isAdmin ? '/admin' : '/student'}
                className={`relative z-10 inline-flex items-center justify-center gap-2 min-h-[38px] md:min-h-0 px-4 sm:px-5 py-1.5 rounded-full text-[13px] font-semibold transition-all duration-200 cursor-pointer ${
                  !isNotesActive
                    ? 'bg-[#7E22CE] text-white shadow-[0_3px_10px_-2px_rgba(126,34,206,0.45)]'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <svg className="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M14 2H7C5.89543 2 5 2.89543 5 4V20C5 21.1046 5.89543 22 7 22H17C18.1046 22 19 21.1046 19 20V7L14 2Z" />
                  <path d="M14 2V7H19" />
                  <path d="M9.5 13.5C9.5 12.4 10.4 11.5 11.5 11.5C12.6 11.5 13.5 12.4 13.5 13.5C13.5 14.3 13 14.9 12.2 15.2C11.8 15.4 11.5 15.8 11.5 16.2" />
                  <circle cx="11.5" cy="18.5" r="0.6" fill="currentColor" />
                </svg>
                <span>Questions</span>
              </Link>

              <Link
                href={isAdmin ? '/admin/notes' : '/notes'}
                className={`relative z-10 inline-flex items-center justify-center gap-2 min-h-[38px] md:min-h-0 px-4 sm:px-5 py-1.5 rounded-full text-[13px] font-semibold transition-all duration-200 cursor-pointer ${
                  isNotesActive
                    ? 'bg-[#7E22CE] text-white shadow-[0_3px_10px_-2px_rgba(126,34,206,0.45)]'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <svg className="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M2 6C2 4.89543 2.89543 4 4 4H9C10.6569 4 12 5.34315 12 7V20C12 18.8954 11.1046 18 10 18H4C2.89543 18 2 17.1046 2 16V6Z" />
                  <path d="M22 6C22 4.89543 21.1046 4 20 4H15C13.3431 4 12 5.34315 12 7V20C12 18.8954 12.8954 18 14 18H20C21.1046 18 22 17.1046 22 16V6Z" />
                </svg>
                <span>Quick Notes</span>
              </Link>
            </div>
          </div>
        )}

        {/* Right: Contributor Profile Pill + Sign Out Button */}
        <div className="flex items-center gap-2 sm:gap-2.5 shrink-0 order-2 md:order-3">
          {profile && (
            <>
              {/* Contributor Pill */}
              <div className="flex items-center gap-2 sm:gap-2.5 px-2.5 sm:px-3.5 py-1 sm:py-1.5 rounded-[12px] sm:rounded-[14px] bg-white border border-slate-200/80 shadow-[0_1px_3px_rgba(15,23,42,0.03)]">
                <div className="w-6 h-6 sm:w-7 sm:h-7 rounded-full bg-purple-50 border border-purple-200/70 flex items-center justify-center text-[#7E22CE] shrink-0">
                  <svg className="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="8" r="4" />
                    <path d="M5 20C5 16.6863 8.13401 14 12 14C15.866 14 19 16.6863 19 20" />
                  </svg>
                </div>
                <div className="leading-tight">
                  <div className="hidden sm:block text-[12.5px] font-semibold text-slate-800">
                    {profile.name}
                  </div>
                  <div className="text-[11px] sm:text-[10.5px] font-mono font-semibold sm:font-normal text-slate-700 sm:text-slate-400">
                    {profile.contributorId}
                  </div>
                </div>
              </div>

              {/* Sign Out Button */}
              <button
                type="button"
                onClick={logout}
                aria-label="Sign Out"
                className="inline-flex items-center justify-center gap-1.5 min-h-[36px] sm:min-h-0 px-2.5 sm:px-3.5 py-1.5 sm:py-2 rounded-[12px] sm:rounded-[13px] bg-white hover:bg-slate-50 border border-slate-200/85 text-[12px] sm:text-[12.5px] font-semibold text-slate-700 hover:text-slate-900 shadow-[0_1px_2px_rgba(15,23,42,0.03)] transition-all duration-200 active:scale-95 cursor-pointer"
              >
                <svg className="w-3.5 h-3.5 text-slate-500 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M9 21H5C4.46957 21 3.96086 20.7893 3.58579 20.4142C3.21071 20.0391 3 19.5304 3 19V5C3 4.46957 3.21071 3.96086 3.58579 3.58579C3.96086 3.21071 4.46957 3 5 3H9" />
                  <path d="M16 17L21 12L16 7" />
                  <path d="M21 12H9" />
                </svg>
                <span className="hidden sm:inline">Sign Out</span>
              </button>
            </>
          )}
        </div>
      </div>
    </header>
  );
}
