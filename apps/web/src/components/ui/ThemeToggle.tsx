'use client';

import React, { useState, useEffect } from 'react';
import { HugeiconsIcon } from '@hugeicons/react';
import { Sun01Icon, Moon02Icon } from '@hugeicons/core-free-icons';

interface ThemeToggleProps {
  className?: string;
}

export function ThemeToggle({ className = '' }: ThemeToggleProps) {
  const [isDarkMode, setIsDarkMode] = useState<boolean>(false);
  const [mounted, setMounted] = useState<boolean>(false);

  useEffect(() => {
    setMounted(true);
    const isDark = document.documentElement.classList.contains('dark');
    setIsDarkMode(isDark);
  }, []);

  const toggleTheme = () => {
    const nextDark = !document.documentElement.classList.contains('dark');
    if (nextDark) {
      document.documentElement.classList.add('dark');
      document.documentElement.classList.remove('light');
      try {
        localStorage.setItem('acedex_theme', 'dark');
      } catch (_) {}
    } else {
      document.documentElement.classList.add('light');
      document.documentElement.classList.remove('dark');
      try {
        localStorage.setItem('acedex_theme', 'light');
      } catch (_) {}
    }
    setIsDarkMode(nextDark);
  };

  if (!mounted) {
    return (
      <div className={`w-9 h-9 sm:w-10 sm:h-10 rounded-full border border-slate-200/80 dark:border-white/[0.09] bg-white/90 dark:bg-white/[0.05] ${className}`} />
    );
  }

  return (
    <button
      type="button"
      onClick={toggleTheme}
      aria-label="Toggle Light or Dark Theme"
      className={`group p-2 sm:p-2.5 rounded-full bg-white/90 dark:bg-white/[0.05] hover:bg-slate-50 dark:hover:bg-white/[0.1] border border-slate-200/80 dark:border-white/[0.09] text-slate-600 dark:text-slate-300 backdrop-blur-md shadow-sm transition-all duration-300 active:scale-90 cursor-pointer ${className}`}
    >
      {isDarkMode ? (
        <HugeiconsIcon
          icon={Sun01Icon}
          size={16}
          strokeWidth={2}
          className="text-amber-400 transition-transform duration-500 group-hover:rotate-45"
        />
      ) : (
        <HugeiconsIcon
          icon={Moon02Icon}
          size={16}
          strokeWidth={2}
          className="text-slate-700 dark:text-slate-200 transition-transform duration-500 group-hover:-rotate-12"
        />
      )}
    </button>
  );
}
