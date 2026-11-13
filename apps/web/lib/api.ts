import type {
  AdminClassificationListResponse,
  AdminMlReportResponse,
  AdminSummaryResponse,
  AdminUserItem,
  AdminUserListResponse,
  MaterialKey,
  ModelInfoResponse,
  TokenResponse,
  UserResponse,
  UserRole,
} from "@/lib/types";

const STORAGE_KEY = "pecox_admin_session_v1";

export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/$/, "") ??
  "http://localhost:8000/api/v1";

export interface StoredSession {
  accessToken: string;
  refreshToken: string;
}

export class ApiError extends Error {
  status: number;
  detail: string;

  constructor(status: number, detail: string) {
    super(detail);
    this.name = "ApiError";
    this.status = status;
    this.detail = detail;
  }
}

export function loadStoredSession(): StoredSession | null {
  if (typeof window === "undefined") {
    return null;
  }
  const raw = window.sessionStorage.getItem(STORAGE_KEY);
  if (!raw) {
    return null;
  }
  try {
    const parsed = JSON.parse(raw) as Partial<StoredSession>;
    if (parsed.accessToken && parsed.refreshToken) {
      return {
        accessToken: parsed.accessToken,
        refreshToken: parsed.refreshToken,
      };
    }
    return null;
  } catch {
    return null;
  }
}

export function saveStoredSession(session: StoredSession | null): void {
  if (typeof window === "undefined") {
    return;
  }
  if (!session) {
    window.sessionStorage.removeItem(STORAGE_KEY);
    return;
  }
  window.sessionStorage.setItem(STORAGE_KEY, JSON.stringify(session));
}

async function parseErrorDetail(response: Response): Promise<string> {
  try {
    const payload = (await response.json()) as { detail?: unknown };
    if (typeof payload.detail === "string") {
      return payload.detail;
    }
    if (Array.isArray(payload.detail)) {
      return payload.detail
        .map((item) =>
          typeof item === "object" && item !== null && "msg" in item
            ? String((item as { msg: unknown }).msg)
            : JSON.stringify(item)
        )
        .join(" · ");
    }
  } catch {
    // ignore non-JSON body
  }
  return `Error HTTP ${response.status}`;
}

let activeRefreshPromise: Promise<StoredSession | null> | null = null;

async function tryRefreshSession(): Promise<StoredSession | null> {
  if (activeRefreshPromise) {
    return activeRefreshPromise;
  }

  activeRefreshPromise = (async () => {
    const current = loadStoredSession();
    if (!current?.refreshToken) {
      return null;
    }

    try {
      const response = await fetch(`${API_BASE_URL}/auth/refresh`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ refresh_token: current.refreshToken }),
      });
      if (!response.ok) {
        saveStoredSession(null);
        return null;
      }
      const data = (await response.json()) as TokenResponse;
      const updated: StoredSession = {
        accessToken: data.access_token,
        refreshToken: data.refresh_token,
      };
      saveStoredSession(updated);
      return updated;
    } catch {
      return null;
    } finally {
      activeRefreshPromise = null;
    }
  })();

  return activeRefreshPromise;
}

async function apiFetch<T>(
  path: string,
  options: RequestInit & { auth?: boolean } = {}
): Promise<T> {
  const { auth = true, headers, ...rest } = options;
  const session = auth ? loadStoredSession() : null;

  const requestHeaders = new Headers(headers);
  if (!requestHeaders.has("Content-Type") && rest.body) {
    requestHeaders.set("Content-Type", "application/json");
  }
  if (auth && session?.accessToken) {
    requestHeaders.set("Authorization", `Bearer ${session.accessToken}`);
  }

  let response = await fetch(`${API_BASE_URL}${path}`, {
    ...rest,
    headers: requestHeaders,
  });

  if (response.status === 401 && auth && session?.refreshToken) {
    const refreshed = await tryRefreshSession();
    if (refreshed) {
      requestHeaders.set("Authorization", `Bearer ${refreshed.accessToken}`);
      response = await fetch(`${API_BASE_URL}${path}`, {
        ...rest,
        headers: requestHeaders,
      });
    }
  }

  if (!response.ok) {
    const detail = await parseErrorDetail(response);
    throw new ApiError(response.status, detail);
  }

  if (response.status === 204) {
    return undefined as T;
  }
  return (await response.json()) as T;
}

export const pecoxApi = {
  async login(email: string, password: string): Promise<TokenResponse> {
    const data = await apiFetch<TokenResponse>("/auth/login", {
      method: "POST",
      auth: false,
      body: JSON.stringify({ email, password }),
    });
    saveStoredSession({
      accessToken: data.access_token,
      refreshToken: data.refresh_token,
    });
    return data;
  },

  logout(): void {
    saveStoredSession(null);
  },

  getMe(): Promise<UserResponse> {
    return apiFetch<UserResponse>("/users/me");
  },

  getModelInfo(): Promise<ModelInfoResponse> {
    return apiFetch<ModelInfoResponse>("/model/info", { auth: false });
  },

  getAdminSummary(): Promise<AdminSummaryResponse> {
    return apiFetch<AdminSummaryResponse>("/admin/summary");
  },

  listAdminClassifications(params?: {
    material?: MaterialKey | "";
    correctedOnly?: boolean;
    search?: string;
    limit?: number;
    offset?: number;
  }): Promise<AdminClassificationListResponse> {
    const query = new URLSearchParams();
    if (params?.material) {
      query.set("material", params.material);
    }
    if (params?.correctedOnly) {
      query.set("corrected_only", "true");
    }
    if (params?.search?.trim()) {
      query.set("search", params.search.trim());
    }
    query.set("limit", String(params?.limit ?? 25));
    query.set("offset", String(params?.offset ?? 0));
    return apiFetch<AdminClassificationListResponse>(
      `/admin/classifications?${query.toString()}`
    );
  },

  listAdminUsers(params?: {
    role?: UserRole | "";
    search?: string;
    limit?: number;
    offset?: number;
  }): Promise<AdminUserListResponse> {
    const query = new URLSearchParams();
    if (params?.role) {
      query.set("role", params.role);
    }
    if (params?.search?.trim()) {
      query.set("search", params.search.trim());
    }
    query.set("limit", String(params?.limit ?? 25));
    query.set("offset", String(params?.offset ?? 0));
    return apiFetch<AdminUserListResponse>(`/admin/users?${query.toString()}`);
  },

  updateUserRole(userId: string, role: UserRole): Promise<AdminUserItem> {
    return apiFetch<AdminUserItem>(`/admin/users/${userId}/role`, {
      method: "PATCH",
      body: JSON.stringify({ role }),
    });
  },

  getAdminMlReport(): Promise<AdminMlReportResponse> {
    return apiFetch<AdminMlReportResponse>("/admin/ml-report");
  },
};
