'use client';

import React from 'react';
import Link from 'next/link';
import { Button } from '../components/ui/Button';
import { HugeiconsIcon } from '@hugeicons/react';
import { Home01Icon } from '@hugeicons/core-free-icons';

export default function NotFound() {
  return (
    <div className="flex-1 flex flex-col items-center justify-center p-6 text-center">
      <div className="space-y-4 max-w-md">
        <span className="text-6xl font-black bg-gradient-to-r from-acedex-primary to-acedex-accent bg-clip-text text-transparent">
          404
        </span>
        <h2 className="text-xl font-bold text-acedex-text">Page Not Found</h2>
        <p className="text-sm text-acedex-muted">
          The requested page or resource could not be found.
        </p>
        <div className="pt-2">
          <Link href="/">
            <Button
              variant="primary"
              size="md"
              icon={<HugeiconsIcon icon={Home01Icon} size={16} className="shrink-0" strokeWidth={1.5} />}
            >
              Return to Login
            </Button>
          </Link>
        </div>
      </div>
    </div>
  );
}
