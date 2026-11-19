'use client';

import React from 'react';
import { HugeiconsIcon } from '@hugeicons/react';
import type { IconSvgElement } from '@hugeicons/react';

export interface IconProps extends React.SVGProps<SVGSVGElement> {
  icon: IconSvgElement;
  size?: number | string;
  color?: string;
  strokeWidth?: number;
  className?: string;
}

/**
 * Standard Hugeicons stroke-rounded icon component wrapper
 */
export function Icon({
  icon,
  size = 18,
  color = 'currentColor',
  strokeWidth = 1.5,
  className,
  ...props
}: IconProps) {
  return (
    <HugeiconsIcon
      icon={icon}
      size={size}
      color={color}
      strokeWidth={strokeWidth}
      className={className}
      {...props}
    />
  );
}

export { HugeiconsIcon };
