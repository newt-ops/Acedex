'use client';

import React from 'react';
import { cn } from '../../lib/utils';
import { SubmissionStatus } from '../../types/collector';
import { STATUS_LABELS, STATUS_BADGE_STYLES } from '../../lib/constants';
import { CheckCircle2, Clock, AlertCircle, CircleDashed } from 'lucide-react';

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
          return <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />;
        case 'submitted':
          return <Clock className="w-3.5 h-3.5 text-amber-400" />;
        case 'rejected':
          return <AlertCircle className="w-3.5 h-3.5 text-rose-400" />;
        default:
          return <CircleDashed className="w-3.5 h-3.5 text-slate-400" />;
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
