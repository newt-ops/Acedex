'use client';

import React, { useEffect } from 'react';
import { cn } from '../../lib/utils';
import { HugeiconsIcon } from '@hugeicons/react';
import { Cancel01Icon } from '@hugeicons/core-free-icons';

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: React.ReactNode;
  description?: React.ReactNode;
  children: React.ReactNode;
  footer?: React.ReactNode;
  maxWidth?: 'sm' | 'md' | 'lg' | 'xl' | '2xl' | '4xl';
}

export function Modal({
  isOpen,
  onClose,
  title,
  description,
  children,
  footer,
  maxWidth = '2xl',
}: ModalProps) {
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      const handleKeyDown = (e: KeyboardEvent) => {
        if (e.key === 'Escape') onClose();
      };
      window.addEventListener('keydown', handleKeyDown);
      return () => {
        document.body.style.overflow = 'unset';
        window.removeEventListener('keydown', handleKeyDown);
      };
    } else {
      document.body.style.overflow = 'unset';
    }
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const maxWidthClasses = {
    sm: 'sm:max-w-sm',
    md: 'sm:max-w-md',
    lg: 'sm:max-w-lg',
    xl: 'sm:max-w-xl',
    '2xl': 'sm:max-w-2xl',
    '4xl': 'sm:max-w-4xl',
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 animate-in fade-in duration-200">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black/75 backdrop-blur-sm transition-opacity"
        onClick={onClose}
      />

      {/* Dialog content */}
      <div
        className={cn(
          'relative w-full z-10 bg-acedex-card border border-acedex-border/80 text-acedex-text shadow-2xl flex flex-col',
          // Mobile: slide up bottom sheet with max-h-[92vh]
          'max-h-[92vh] rounded-t-2xl sm:rounded-2xl',
          maxWidthClasses[maxWidth]
        )}
      >
        {/* Mobile drag handle indicator */}
        <div className="w-12 h-1.5 bg-acedex-border rounded-full mx-auto mt-2.5 sm:hidden shrink-0" />

        {/* Header */}
        <div className="flex items-start justify-between p-4 sm:p-5 border-b border-acedex-border/60 shrink-0">
          <div>
            <h2 className="text-base sm:text-lg font-semibold text-acedex-text flex items-center gap-2">
              {title}
            </h2>
            {description && (
              <div className="text-xs sm:text-sm text-acedex-muted mt-1">
                {description}
              </div>
            )}
          </div>
          <button
            onClick={onClose}
            className="p-1.5 text-acedex-muted hover:text-acedex-text rounded-lg hover:bg-acedex-card-hover transition-colors shrink-0"
            aria-label="Close dialog"
          >
            <HugeiconsIcon icon={Cancel01Icon} size={20} strokeWidth={1.5} />
          </button>
        </div>

        {/* Scrollable Body */}
        <div className="p-4 sm:p-6 overflow-y-auto flex-1 overscroll-contain">
          {children}
        </div>

        {/* Footer */}
        {footer && (
          <div className="p-3 sm:p-4 border-t border-acedex-border/60 bg-acedex-card/80 backdrop-blur-sm shrink-0 flex items-center justify-end gap-2.5">
            {footer}
          </div>
        )}
      </div>
    </div>
  );
}
