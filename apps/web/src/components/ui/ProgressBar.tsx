'use client';

import React from 'react';
import { cn } from '../../lib/utils';

interface ProgressBarProps {
  current: number;
  total: number;
  label?: string;
  className?: string;
  showPercent?: boolean;
}

export function ProgressBar({
  current,
  total,
  label,
  className,
  showPercent = true,
}: ProgressBarProps) {
  const percent = total > 0 ? Math.min(100, Math.round((current / total) * 100)) : 0;

  return (
    <div className={cn('w-full', className)}>
      <div className="flex items-center justify-between text-xs sm:text-sm text-acedex-muted mb-1.5 font-medium">
        <span>{label || 'Progress'}</span>
        <div className="flex items-center gap-1.5 font-semibold text-acedex-text">
          <span>
            {current} / {total} Units
          </span>
          {showPercent && (
            <span className="text-acedex-primary text-xs">({percent}%)</span>
          )}
        </div>
      </div>
      <div className="w-full h-2.5 sm:h-3 bg-acedex-bg rounded-full overflow-hidden border border-acedex-border/60">
        <div
          className="h-full bg-gradient-to-r from-acedex-primary to-emerald-400 rounded-full transition-all duration-500 ease-out"
          style={{ width: `${percent}%` }}
        />
      </div>
    </div>
  );
}
