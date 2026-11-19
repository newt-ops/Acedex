'use client';

import React from 'react';
import { cn } from '../../lib/utils';
import { HugeiconsIcon } from '@hugeicons/react';
import { Loading01Icon } from '@hugeicons/core-free-icons';

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'success' | 'danger' | 'outline' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  icon?: React.ReactNode;
  iconPosition?: 'left' | 'right';
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      className,
      variant = 'primary',
      size = 'md',
      loading = false,
      icon,
      iconPosition = 'left',
      children,
      disabled,
      ...props
    },
    ref
  ) => {
    const baseStyles =
      'inline-flex items-center justify-center font-medium whitespace-nowrap transition-all duration-150 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-acedex-primary focus-visible:ring-offset-2 focus-visible:ring-offset-acedex-bg disabled:opacity-50 disabled:pointer-events-none rounded-xl select-none active:scale-[0.98]';

    const variants = {
      primary:
        'bg-acedex-primary hover:bg-acedex-primary-hover text-white shadow-sm shadow-blue-500/20',
      secondary:
        'bg-acedex-card hover:bg-acedex-card-hover text-acedex-text border border-acedex-border',
      success:
        'bg-acedex-success hover:bg-emerald-600 text-white shadow-sm shadow-emerald-500/20',
      danger:
        'bg-acedex-danger hover:bg-red-600 text-white shadow-sm shadow-red-500/20',
      outline:
        'border border-acedex-border text-acedex-text hover:bg-acedex-card hover:border-acedex-primary',
      ghost:
        'text-acedex-muted hover:text-acedex-text hover:bg-acedex-card/50',
    };

    const sizes = {
      sm: 'h-9 px-3 text-xs gap-1.5 min-h-[36px]',
      md: 'h-11 px-4 text-sm gap-2 min-h-[44px]',
      lg: 'h-12 px-6 text-base gap-2.5 min-h-[48px]',
    };

    const iconSize = size === 'sm' ? 15 : size === 'lg' ? 18 : 16;

    return (
      <button
        ref={ref}
        className={cn(baseStyles, variants[variant], sizes[size], className)}
        disabled={disabled || loading}
        {...props}
      >
        {loading ? (
          <span className="inline-flex items-center justify-center shrink-0">
            <HugeiconsIcon
              icon={Loading01Icon}
              size={iconSize}
              className="animate-spin shrink-0"
              strokeWidth={2}
            />
          </span>
        ) : (
          icon &&
          iconPosition === 'left' && (
            <span className="inline-flex items-center justify-center shrink-0">
              {icon}
            </span>
          )
        )}
        {children && (
          <span className="inline-flex items-center justify-center gap-1.5 truncate leading-none">
            {children}
          </span>
        )}
        {!loading && icon && iconPosition === 'right' && (
          <span className="inline-flex items-center justify-center shrink-0">
            {icon}
          </span>
        )}
      </button>
    );
  }
);

Button.displayName = 'Button';
