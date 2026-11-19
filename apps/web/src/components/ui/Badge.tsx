'use client';

import React from 'react';
import { cn } from '../../lib/utils';
import { SubmissionStatus } from '../../types/collector';
import { STATUS_LABELS, STATUS_BADGE_STYLES } from '../../lib/constants';
import { HugeiconsIcon } from '@hugeicons/react';
import {
  CheckmarkCircle02Icon,
  Clock01Icon,
  CancelCircleIcon,
  AlertCircleIcon,
} from '@hugeicons/core-free-icons';

interface BadgeProps {
  status?: SubmissionStatus;
  label?: string;
  className?: string;
  children?: React.ReactNode;
}

export function Badge({ status, label, className, children }: BadgeProps) {
  if (status) {
    const style = STATUS_BADGE_STYLES[status] || STATUS_BADGE_STYLES.not_started;
    const text = label || STATUS_LABELS[status] || status;

    const renderIcon = () => {
      switch (status) {
        case 'approved':
          return <HugeiconsIcon icon={CheckmarkCircle02Icon} size={14} className="text-emerald-500 shrink-0" strokeWidth={1.75} />;
        case 'submitted':
          return <HugeiconsIcon icon={Clock01Icon} size={14} className="text-amber-500 shrink-0" strokeWidth={1.75} />;
        case 'rejected':
          return <HugeiconsIcon icon={CancelCircleIcon} size={14} className="text-rose-500 shrink-0" strokeWidth={1.75} />;
        default:
          return <HugeiconsIcon icon={AlertCircleIcon} size={14} className="text-slate-400 shrink-0" strokeWidth={1.75} />;
      }
    };

    return (
      <span
        className={cn(
          'inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold border',
          style.bg,
          style.text,
          style.border,
          className
        )}
      >
        {renderIcon()}
        <span>{text}</span>
      </span>
    );
  }

  return (
    <span
      className={cn(
        'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-acedex-card text-acedex-muted border border-acedex-border',
        className
      )}
    >
      {children || label}
    </span>
  );
}
