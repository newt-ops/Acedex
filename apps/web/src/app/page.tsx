'use client';

import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../context/AuthContext';

export default function LoginPage() {
  const { login, isAuthenticated, isAdmin, loading: authLoading } = useAuth();
  const router = useRouter();

  const [accessId, setAccessId] = useState<string>('');
  const [showPassword, setShowPassword] = useState<boolean>(false);
  const [submitting, setSubmitting] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [verifiedProfile, setVerifiedProfile] = useState<{ id: string; role: string } | null>(null);
  const [isDarkMode, setIsDarkMode] = useState<boolean>(false);

  // 3D Card & Parallax Refs
  const cardRef = useRef<HTMLDivElement>(null);
  const brandRef = useRef<HTMLDivElement>(null);
  const keyIconRef = useRef<HTMLDivElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const isHoveringCard = useRef<boolean>(false);

  // Sync theme on mount
  useEffect(() => {
    const isDark = document.documentElement.classList.contains('dark');
    setIsDarkMode(isDark);
  }, []);

  const toggleTheme = () => {
    const nextDark = !document.documentElement.classList.contains('dark');
    if (nextDark) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
    setIsDarkMode(nextDark);
  };

  // Redirect if already authenticated
  useEffect(() => {
    if (isAuthenticated && !verifiedProfile) {
      if (isAdmin) {
        router.push('/admin');
      } else {
        router.push('/student');
      }
    }
  }, [isAuthenticated, isAdmin, router, verifiedProfile]);

  // =========================================================================
  // 3D Tilt Physics & Specular Light Tracking
  // =========================================================================
  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      const card = cardRef.current;
      const brand = brandRef.current;
      if (!card || !brand) return;

      const rect = card.getBoundingClientRect();
      const cardCenterX = rect.left + rect.width / 2;
      const cardCenterY = rect.top + rect.height / 2;

      // Subtle parallax on brand header
      const normWindowX = (e.clientX / window.innerWidth - 0.5) * 2;
      const normWindowY = (e.clientY / window.innerHeight - 0.5) * 2;
      brand.style.transform = `perspective(1000px) rotateX(${(-normWindowY * 4).toFixed(2)}deg) rotateY(${(normWindowX * 5).toFixed(2)}deg) translate3d(${(normWindowX * 4).toFixed(1)}px, ${(normWindowY * 3).toFixed(1)}px, 0)`;

      // Calculate distance from card center for smooth magnetic 3D tilt
      const relX = (e.clientX - cardCenterX) / (rect.width / 2);
      const relY = (e.clientY - cardCenterY) / (rect.height / 2);

      const maxTilt = isHoveringCard.current ? 8.5 : 3.2;
      const clampedX = Math.max(-1.4, Math.min(1.4, relX));
      const clampedY = Math.max(-1.4, Math.min(1.4, relY));

      const rotateY = (clampedX * maxTilt).toFixed(2);
      const rotateX = (-clampedY * maxTilt).toFixed(2);

      card.classList.remove('is-resetting');
      document.documentElement.style.setProperty('--rx', `${rotateX}deg`);
      document.documentElement.style.setProperty('--ry', `${rotateY}deg`);

      // Specular light sheen coordinates
      const localX = ((e.clientX - rect.left) / rect.width) * 100;
      const localY = ((e.clientY - rect.top) / rect.height) * 100;
      document.documentElement.style.setProperty('--glare-x', `${localX.toFixed(1)}%`);
      document.documentElement.style.setProperty('--glare-y', `${localY.toFixed(1)}%`);
    };

    const handleMouseLeave = () => {
      const card = cardRef.current;
      const brand = brandRef.current;
      if (card) {
        card.classList.add('is-resetting');
        document.documentElement.style.setProperty('--rx', '0deg');
        document.documentElement.style.setProperty('--ry', '0deg');
        document.documentElement.style.setProperty('--glare-opacity', '0');
      }
      if (brand) {
        brand.style.transform = 'perspective(1000px) rotateX(0deg) rotateY(0deg) translate3d(0,0,0)';
      }
    };

    window.addEventListener('mousemove', handleMouseMove);
    window.addEventListener('mouseleave', handleMouseLeave);
    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('mouseleave', handleMouseLeave);
    };
  }, []);

  // =========================================================================
  // Ambient 3D Depth Dot-Grid Canvas with Cursor Repulsion
  // =========================================================================
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animId: number;
    let pointer = { x: -1000, y: -1000 };

    const resize = () => {
      const dpr = window.devicePixelRatio || 1;
      canvas.width = window.innerWidth * dpr;
      canvas.height = window.innerHeight * dpr;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    };

    resize();
    window.addEventListener('resize', resize);

    const onPointerMove = (e: MouseEvent) => {
      pointer.x = e.clientX;
      pointer.y = e.clientY;
    };
    const onPointerLeave = () => {
      pointer = { x: -1000, y: -1000 };
    };

    window.addEventListener('mousemove', onPointerMove);
    window.addEventListener('mouseleave', onPointerLeave);

    const render = () => {
      const w = window.innerWidth;
      const h = window.innerHeight;
      ctx.clearRect(0, 0, w, h);

      const isDark = document.documentElement.classList.contains('dark');
      const spacing = 36;
      const influenceRadius = 155;

      for (let x = spacing / 2; x < w; x += spacing) {
        for (let y = spacing / 2; y < h; y += spacing) {
          const dx = pointer.x - x;
          const dy = pointer.y - y;
          const dist = Math.sqrt(dx * dx + dy * dy);

          let radius = 1;
          let alpha = isDark ? 0.07 : 0.09;
          let offsetX = 0;
          let offsetY = 0;

          if (dist < influenceRadius) {
            const factor = 1 - dist / influenceRadius;
            offsetX = -(dx / (dist || 1)) * factor * 4.5;
            offsetY = -(dy / (dist || 1)) * factor * 4.5;
            radius = 1 + factor * 1.45;
            alpha += factor * 0.28;

            ctx.fillStyle = isDark
              ? `rgba(168, 85, 247, ${alpha})`
              : `rgba(126, 34, 206, ${alpha})`;
          } else {
            ctx.fillStyle = isDark
              ? `rgba(255, 255, 255, ${alpha})`
              : `rgba(15, 23, 42, ${alpha})`;
          }

          ctx.beginPath();
          ctx.arc(x + offsetX, y + offsetY, radius, 0, Math.PI * 2);
          ctx.fill();
        }
      }

      animId = requestAnimationFrame(render);
    };

    render();

    return () => {
      cancelAnimationFrame(animId);
      window.removeEventListener('resize', resize);
      window.removeEventListener('mousemove', onPointerMove);
      window.removeEventListener('mouseleave', onPointerLeave);
    };
  }, []);

  // Handle Input Typing & Dynamic Key Rotation
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value.toUpperCase();
    setAccessId(val);
    setError(null);

    const keyIcon = keyIconRef.current;
    if (keyIcon) {
      const angle = Math.min(25, val.length * 3.5);
      keyIcon.style.transform = `rotate(${-14 + angle}deg) scale(1.12)`;
    }
  };

  const handleInputFocus = (focused: boolean) => {
    const keyIcon = keyIconRef.current;
    if (!keyIcon) return;
    if (focused) {
      keyIcon.style.transform = 'rotate(-14deg) scale(1.12)';
    } else {
      keyIcon.style.transform = 'rotate(0deg) scale(1)';
    }
  };

  // Submit Handler
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (submitting) return;

    const trimmed = accessId.trim().toUpperCase();
    if (!trimmed) {
      setError('Please enter your private Access ID to continue.');
      const card = cardRef.current;
      if (card) {
        card.classList.remove('animate-wobble-3d');
        void card.offsetWidth;
        card.classList.add('animate-wobble-3d');
      }
      return;
    }

    setSubmitting(true);
    setError(null);

    try {
      const profile = await login(trimmed);
      setVerifiedProfile({ id: trimmed, role: profile.role });
      setTimeout(() => {
        if (profile.role === 'admin') {
          router.push('/admin');
        } else {
          router.push('/student');
        }
      }, 1200);
    } catch (err: any) {
      setError(err.message || 'Invalid Access ID or server unreachable');
      const card = cardRef.current;
      if (card) {
        card.classList.remove('animate-wobble-3d');
        void card.offsetWidth;
        card.classList.add('animate-wobble-3d');
      }
      setSubmitting(false);
    }
  };

  if (authLoading) {
    return (
      <div className="flex-1 flex items-center justify-center min-h-screen">
        <div className="w-8 h-8 rounded-full border-2 border-[#7E22CE] border-t-transparent animate-spin" />
      </div>
    );
  }

  return (
    <div className="relative min-h-screen flex flex-col selection:bg-purple-500/20 selection:text-purple-700 dark:selection:text-purple-300 overflow-x-hidden">
      {/* Interactive Ambient 3D Depth Dot-Grid Canvas */}
      <canvas ref={canvasRef} className="fixed inset-0 w-full h-full pointer-events-none z-0" />

      {/* Subtle Radial Purple Ambient Glow */}
      <div className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[620px] h-[420px] rounded-full bg-purple-600/[0.045] dark:bg-purple-500/[0.11] blur-[120px] pointer-events-none z-0" />

      {/* Minimal Top Utility Corner (Light / Dark Mode Toggle) */}
      <header className="relative z-20 w-full max-w-6xl mx-auto px-5 pt-5 flex items-center justify-end">
        <button
          onClick={toggleTheme}
          aria-label="Toggle Light or Dark Theme"
          className="group p-2.5 rounded-full bg-white/90 dark:bg-white/[0.05] hover:bg-slate-50 dark:hover:bg-white/[0.1] border border-slate-200/80 dark:border-white/[0.09] text-slate-600 dark:text-slate-300 backdrop-blur-md shadow-sm transition-all duration-300 active:scale-90"
        >
          {isDarkMode ? (
            <svg
              className="w-4 h-4 text-amber-400 transition-transform duration-500 group-hover:rotate-45"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <circle cx="12" cy="12" r="4" />
              <path d="M12 2V4M12 20V22M4.93 4.93L6.34 6.34M17.66 17.66L19.07 19.07M2 12H4M20 12H22M6.34 17.66L4.93 19.07M19.07 4.93L17.66 6.34" />
            </svg>
          ) : (
            <svg
              className="w-4 h-4 text-slate-700 transition-transform duration-500 group-hover:-rotate-12"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
            </svg>
          )}
        </button>
      </header>

      {/* =============================================================== */}
      {/* CENTERED 3D AUTHENTICATION STAGE                                */}
      {/* =============================================================== */}
      <main className="relative z-10 flex-1 flex flex-col items-center justify-center px-4 pb-12 pt-4 perspective-stage">
        {/* Brand Header with Subtle 3D Parallax Layer */}
        <div
          ref={brandRef}
          className="text-center mb-8 animate-3d-in delay-1 transition-transform duration-200 ease-out"
        >
          <h1 className="font-display text-[36px] sm:text-[40px] font-extrabold tracking-[-0.035em] text-[#7E22CE] dark:text-[#9333EA] leading-none select-none drop-shadow-[0_2px_10px_rgba(126,34,206,0.12)]">
            ACEDEX
          </h1>
          <p className="mt-2.5 text-[14.5px] sm:text-[15px] font-normal text-slate-500 dark:text-slate-400 tracking-[-0.01em]">
            Question Collection &amp; Ingestion Portal (Grades 9–12)
          </p>
        </div>

        {/* 3D Card Wrapper with Ambient Floating Frosted Depth Accents */}
        <div className="relative w-full max-w-[432px] animate-3d-in delay-2">
          {/* Floating 3D Frosted Geometric Depth Accent (Top-Left) */}
          <div className="floating-plane-a hidden sm:block absolute -top-6 -left-7 w-24 h-24 rounded-[22px] bg-gradient-to-br from-purple-500/[0.08] to-indigo-500/[0.03] dark:from-purple-500/[0.16] dark:to-indigo-500/[0.05] border border-purple-200/50 dark:border-purple-400/15 backdrop-blur-md pointer-events-none" />

          {/* Floating 3D Frosted Geometric Depth Accent (Bottom-Right) */}
          <div className="floating-plane-b hidden sm:block absolute -bottom-6 -right-7 w-28 h-20 rounded-[22px] bg-gradient-to-tl from-purple-600/[0.07] to-fuchsia-500/[0.02] dark:from-purple-500/[0.14] dark:to-fuchsia-500/[0.04] border border-purple-200/50 dark:border-purple-400/15 backdrop-blur-md pointer-events-none" />

          {/* Interactive 3D Tilt Card */}
          <div
            ref={cardRef}
            onMouseEnter={() => {
              isHoveringCard.current = true;
              document.documentElement.style.setProperty('--glare-opacity', '1');
            }}
            onMouseLeave={() => {
              isHoveringCard.current = false;
              document.documentElement.style.setProperty('--glare-opacity', '0');
            }}
            className="card-3d-shell is-resetting relative w-full bg-white/95 dark:bg-[#13131A]/95 backdrop-blur-xl rounded-[24px] p-7 sm:p-8 apple-3d-shadow"
          >
            {/* Specular Light Sheen Overlay */}
            <div className="card-glare absolute inset-0 rounded-[24px] overflow-hidden" />

            {!verifiedProfile ? (
              /* State A: Authentication Form */
              <form onSubmit={handleSubmit} noValidate className="relative" style={{ transformStyle: 'preserve-3d' }}>
                {/* Label */}
                <div className="layer-z-10 mb-2.5 flex items-center justify-between">
                  <label
                    htmlFor="accessIdInput"
                    className="block text-[11px] font-bold tracking-[0.065em] uppercase text-slate-600 dark:text-slate-300"
                  >
                    CONTRIBUTOR / ADMIN ACCESS ID
                  </label>
                </div>

                {/* Input Container */}
                <div
                  className={`layer-z-20 relative flex items-center rounded-[14px] bg-white dark:bg-[#1A1A23] border ${
                    error
                      ? 'border-rose-500 ring-4 ring-rose-500/15'
                      : 'border-slate-200/90 dark:border-white/[0.1] focus-within:border-[#7E22CE] dark:focus-within:border-[#9333EA] focus-within:ring-4 focus-within:ring-purple-600/10 dark:focus-within:ring-purple-500/15'
                  } shadow-[0_2px_8px_-2px_rgba(15,23,42,0.03)] transition-all duration-300`}
                >
                  {/* Dynamic Key Icon */}
                  <div
                    ref={keyIconRef}
                    className="pl-3.5 pr-2.5 text-[#7E22CE] dark:text-[#A855F7] flex items-center pointer-events-none transition-transform duration-300 ease-out"
                  >
                    <svg
                      className="w-[18px] h-[18px]"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="1.8"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <path d="M15.5 7.5L19 4M21 2L19 4M19 4L21 6" />
                      <circle cx="9.5" cy="14.5" r="4.5" />
                      <path d="M12.7 11.3L16 8" />
                    </svg>
                  </div>

                  {/* Single Credential Input */}
                  <input
                    id="accessIdInput"
                    type={showPassword ? 'text' : 'password'}
                    autoComplete="off"
                    spellCheck="false"
                    placeholder="Enter your ID"
                    value={accessId}
                    onChange={handleInputChange}
                    onFocus={() => handleInputFocus(true)}
                    onBlur={() => handleInputFocus(false)}
                    className="w-full py-3.5 pr-12 bg-transparent text-[14.5px] font-mono font-medium text-slate-900 dark:text-white placeholder:font-sans placeholder:font-normal placeholder:text-slate-400 dark:placeholder:text-slate-500 focus:outline-none"
                  />

                  {/* Show / Hide Credential Eye Toggle */}
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    aria-label="Toggle Access ID visibility"
                    className="absolute right-2.5 p-1.5 rounded-lg text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 hover:bg-slate-100/80 dark:hover:bg-white/[0.06] transition-colors"
                  >
                    {showPassword ? (
                      <svg
                        className="w-4 h-4"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="1.8"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        <path d="M3 3L21 21" />
                        <path d="M10.584 10.587C10.2087 10.962 9.99775 11.4708 9.99756 12.0013C9.99737 12.5318 10.2079 13.0407 10.583 13.416C10.958 13.7913 11.4668 14.0022 11.9973 14.0024C12.5278 14.0026 13.0367 13.7921 13.412 13.417" />
                        <path d="M9.363 5.365C10.2204 5.11972 11.1082 4.99684 12 5C18.364 5 22 12 22 12C21.393 13.135 20.669 14.204 19.84 15.19" />
                        <path d="M6.61 6.61C4.62125 7.96462 3.02987 9.82524 2 12C2 12 5.636 19 12 19C13.9159 19.0051 15.7908 18.4451 17.39 17.39" />
                      </svg>
                    ) : (
                      <svg
                        className="w-4 h-4"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="1.8"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        <path d="M2 12C2 12 5.63636 5 12 5C18.3636 5 22 12 22 12C22 12 18.3636 19 12 19C5.63636 19 2 12 2 12Z" />
                        <circle cx="12" cy="12" r="3" />
                      </svg>
                    )}
                  </button>
                </div>

                {/* Helper / Error Text */}
                <p
                  className={`layer-z-10 mt-2.5 text-[12.5px] transition-colors duration-200 ${
                    error ? 'text-rose-500 font-medium' : 'text-slate-600 dark:text-slate-400'
                  }`}
                >
                  {error || 'Enter your private credential provided by the administrator.'}
                </p>

                {/* Primary CTA Button */}
                <button
                  type="submit"
                  disabled={submitting}
                  className="layer-z-30 group mt-6 w-full h-[48px] rounded-[14px] btn-3d-acedex text-white font-semibold text-[14.5px] tracking-[-0.01em] flex items-center justify-center gap-2 cursor-pointer select-none"
                >
                  {!submitting ? (
                    <span className="inline-flex items-center gap-2">
                      <span>Enter Workspace</span>
                      <svg
                        className="w-4 h-4 transition-transform duration-300 ease-out group-hover:translate-x-1"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2.2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        <path d="M9 6L15 12L9 18" />
                      </svg>
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1.5">
                      <span className="loading-dot w-2 h-2 rounded-full bg-white" />
                      <span className="loading-dot w-2 h-2 rounded-full bg-white" />
                      <span className="loading-dot w-2 h-2 rounded-full bg-white" />
                    </span>
                  )}
                </button>
              </form>
            ) : (
              /* State B: 3D Credential Verification Confirmation */
              <div className="relative text-center py-3" style={{ transformStyle: 'preserve-3d' }}>
                {/* 3D Flipping Checkmark Badge */}
                <div className="layer-z-30 mx-auto w-14 h-14 rounded-2xl bg-emerald-500/10 dark:bg-emerald-500/15 border border-emerald-500/30 flex items-center justify-center text-emerald-600 dark:text-emerald-400 animate-flip-check shadow-sm">
                  <svg
                    className="w-7 h-7"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2.4"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  >
                    <path d="M20 6L9 17L4 12" />
                  </svg>
                </div>

                <h2 className="layer-z-20 mt-4 text-[16px] font-bold tracking-tight text-slate-900 dark:text-white">
                  Credential Verified
                </h2>
                <p className="layer-z-10 mt-1 text-[13px] text-slate-500 dark:text-slate-400 flex items-center justify-center gap-1.5">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-ping" />
                  <span>Redirecting to Workspace...</span>
                </p>

                {/* Masked Credential Pill */}
                <div className="layer-z-10 mt-4 inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-slate-100/90 dark:bg-white/[0.05] border border-slate-200/70 dark:border-white/[0.08] text-xs font-mono text-slate-600 dark:text-slate-300">
                  <span className="w-2 h-2 rounded-full bg-[#7E22CE]" />
                  <span>
                    ID ••••-{verifiedProfile.id.slice(-4)}
                  </span>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Bottom Security & Sync Badge */}
        <div className="mt-7 flex items-center justify-center gap-2 text-[12.5px] font-medium text-slate-600 dark:text-slate-400 animate-3d-in delay-3 select-none">
          <svg
            className="w-[17px] h-[17px] text-[#10B981] shrink-0"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <path d="M12 22C12 22 20 18 20 12V5L12 2L4 5V12C4 18 12 22 12 22Z" />
            <path d="M9 12L11 14L15 10" />
          </svg>
          <span>Role-Gated Access &bull; Direct Question Bank Sync</span>
        </div>
      </main>
    </div>
  );
}
