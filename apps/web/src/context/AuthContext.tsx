'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { ContributorProfile } from '../types/collector';
import { api, setStoredContributorId } from '../lib/api';

const STORAGE_PROFILE_KEY = 'acedex_profile';

interface AuthContextType {
  profile: ContributorProfile | null;
  loading: boolean;
  isAuthenticated: boolean;
  isAdmin: boolean;
  login: (id: string) => Promise<ContributorProfile>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [profile, setProfile] = useState<ContributorProfile | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const router = useRouter();

  useEffect(() => {
    try {
      const stored = localStorage.getItem(STORAGE_PROFILE_KEY);
      if (stored) {
        const parsed = JSON.parse(stored);
        setProfile(parsed);
      }
    } catch {
      localStorage.removeItem(STORAGE_PROFILE_KEY);
    } finally {
      setLoading(false);
    }
  }, []);

  const login = async (contributorId: string): Promise<ContributorProfile> => {
    const data = await api.login(contributorId);
    setProfile(data);
    localStorage.setItem(STORAGE_PROFILE_KEY, JSON.stringify(data));

    if (data.role === 'admin') {
      router.push('/admin');
    } else {
      router.push('/student');
    }
    return data;
  };

  const logout = () => {
    setProfile(null);
    setStoredContributorId(null);
    localStorage.removeItem(STORAGE_PROFILE_KEY);
    router.push('/');
  };

  return (
    <AuthContext.Provider
      value={{
        profile,
        loading,
        isAuthenticated: !!profile,
        isAdmin: profile?.role === 'admin',
        login,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
