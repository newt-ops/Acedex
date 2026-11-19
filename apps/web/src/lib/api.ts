import {
  ContributorProfile,
  SubjectUnitsResponse,
  SubmissionSummary,
  SubmissionDetail,
  SanitizeResult,
  QuestionItem,
} from '../types/collector';
import { DEFAULT_API_URL } from './constants';

const STORAGE_API_KEY = 'acedex_api_url';
const STORAGE_CONTRIBUTOR_KEY = 'acedex_contributor_id';

export function getBaseApiUrl(): string {
  if (typeof window !== 'undefined') {
    const saved = localStorage.getItem(STORAGE_API_KEY);
    if (saved) return saved;
  }
  return DEFAULT_API_URL;
}

export function setBaseApiUrl(url: string): void {
  if (typeof window !== 'undefined') {
    localStorage.setItem(STORAGE_API_KEY, url);
  }
}

export function getStoredContributorId(): string | null {
  if (typeof window !== 'undefined') {
    return localStorage.getItem(STORAGE_CONTRIBUTOR_KEY);
  }
  return null;
}

export function setStoredContributorId(id: string | null): void {
  if (typeof window !== 'undefined') {
    if (id) {
      localStorage.setItem(STORAGE_CONTRIBUTOR_KEY, id);
    } else {
      localStorage.removeItem(STORAGE_CONTRIBUTOR_KEY);
    }
  }
}

async function request<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const baseUrl = getBaseApiUrl();
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>),
  };

  const contributorId = getStoredContributorId();
  if (contributorId && !headers['x-contributor-id']) {
    headers['x-contributor-id'] = contributorId;
  }

  const res = await fetch(`${baseUrl}${endpoint}`, {
    ...options,
    headers,
  });

  const json = await res.json().catch(() => ({}));

  if (!res.ok) {
    const message =
      json?.error?.message ||
      json?.message ||
      `Request failed with status ${res.status}`;
    throw new Error(message);
  }

  return (json.data !== undefined ? json.data : json) as T;
}

export const api = {
  async login(contributorId: string): Promise<ContributorProfile> {
    const data = await request<ContributorProfile>('/api/v1/collector/login', {
      method: 'POST',
      body: JSON.stringify({ contributorId }),
    });
    setStoredContributorId(contributorId);
    return data;
  },

  async getUnits(
    subjectCode: string,
    contributorId?: string
  ): Promise<SubjectUnitsResponse> {
    const params = new URLSearchParams({ subjectCode });
    if (contributorId) params.append('contributorId', contributorId);
    return request<SubjectUnitsResponse>(
      `/api/v1/collector/units?${params.toString()}`
    );
  },

  async sanitize(rawText: string): Promise<SanitizeResult> {
    return request<SanitizeResult>('/api/v1/collector/sanitize', {
      method: 'POST',
      body: JSON.stringify({ rawText }),
    });
  },

  async submitUnit(
    unitCode: string,
    contributorId: string,
    rawPastedText: string,
    questions: QuestionItem[]
  ): Promise<any> {
    return request(`/api/v1/collector/units/${unitCode}/submit`, {
      method: 'POST',
      body: JSON.stringify({
        contributorId,
        rawPastedText,
        questions,
      }),
    });
  },

  async getAdminSubmissions(filters: {
    subjectCode?: string;
    grade?: number;
    status?: string;
  } = {}): Promise<SubmissionSummary[]> {
    const params = new URLSearchParams();
    if (filters.subjectCode && filters.subjectCode !== 'ALL') {
      params.append('subjectCode', filters.subjectCode);
    }
    if (filters.grade) {
      params.append('grade', filters.grade.toString());
    }
    if (filters.status && filters.status !== 'ALL') {
      params.append('status', filters.status);
    }
    const query = params.toString() ? `?${params.toString()}` : '';
    return request<SubmissionSummary[]>(
      `/api/v1/collector/admin/submissions${query}`
    );
  },

  async getSubmissionDetail(
    submissionId: string
  ): Promise<SubmissionDetail> {
    return request<SubmissionDetail>(
      `/api/v1/collector/admin/submissions/${submissionId}`
    );
  },

  async approveSubmission(
    submissionId: string,
    reviewNotes?: string
  ): Promise<any> {
    return request(
      `/api/v1/collector/admin/submissions/${submissionId}/approve`,
      {
        method: 'POST',
        body: JSON.stringify({ reviewNotes }),
      }
    );
  },

  async rejectSubmission(
    submissionId: string,
    rejectionReason: string
  ): Promise<any> {
    return request(
      `/api/v1/collector/admin/submissions/${submissionId}/reject`,
      {
        method: 'POST',
        body: JSON.stringify({ rejectionReason }),
      }
    );
  },

  async exportUnitJson(unitCode: string): Promise<any> {
    return request(
      `/api/v1/collector/admin/submissions/${unitCode}/export`
    );
  },
};
