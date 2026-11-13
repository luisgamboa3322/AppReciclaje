export type MaterialKey =
  | "plastic"
  | "glass"
  | "metal"
  | "cardboard"
  | "paper"
  | "other";

export type UserRole = "user" | "admin";

export interface UserResponse {
  id: string;
  name: string;
  email: string;
  role: UserRole | string;
  created_at: string;
}

export interface TokenResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  user: UserResponse;
}

export interface ModelInfoResponse {
  status: "ready" | "registered_not_loaded" | "not_trained_yet" | string;
  active_version: string | null;
  architecture: string | null;
  identified_threshold?: number | null;
  low_confidence_threshold?: number | null;
  note: string | null;
}

export interface MaterialCountItem {
  material: MaterialKey;
  count: number;
  percentage: number;
}

export interface DailyCountItem {
  date: string;
  count: number;
}

export interface AdminClassificationItem {
  id: string;
  user_id: string;
  user_name: string;
  user_email: string;
  predicted_material: MaterialKey;
  confidence: number | null;
  confirmed_material: MaterialKey;
  model_version: string;
  is_corrected: boolean;
  created_at: string;
  updated_at: string;
}

export interface AdminClassificationListResponse {
  items: AdminClassificationItem[];
  total: number;
  limit: number;
  offset: number;
}

export interface AdminUserItem {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  classifications_count: number;
  created_at: string;
}

export interface AdminUserListResponse {
  items: AdminUserItem[];
  total: number;
  limit: number;
  offset: number;
}

export interface AdminSummaryResponse {
  total_users: number;
  total_admins: number;
  total_classifications: number;
  classifications_last_7_days: number;
  corrected_count: number;
  correction_rate: number;
  average_confidence: number | null;
  by_material: MaterialCountItem[];
  daily_last_7_days: DailyCountItem[];
  recent_classifications: AdminClassificationItem[];
}

export interface PerClassMetrics {
  precision: number;
  recall: number;
  f1_score: number;
  support: number;
}

export interface MlEvaluationMetrics {
  model_version: string;
  architecture: string;
  split: string;
  test_samples: number;
  accuracy: number;
  macro_precision: number;
  macro_recall: number;
  macro_f1: number;
  per_class: Record<MaterialKey, PerClassMetrics>;
  confusion_matrix_labels: MaterialKey[];
  confusion_matrix: number[][];
  uncertainty_gating?: {
    identified_threshold: number;
    low_confidence_threshold: number;
    identified_count: number;
    identified_coverage: number;
    identified_accuracy: number;
    low_confidence_count: number;
    unknown_count: number;
  };
  cpu_latency_ms?: {
    samples_measured: number;
    mean: number;
    p50: number;
    p95: number;
  };
}

export interface EdaReportSummary {
  dataset_id: string;
  raw_valid_images: number;
  exact_sha256_duplicates_removed: number;
  unique_images_after_exact_dedup: number;
  split_totals: Record<string, number>;
  leakage_checks: Record<string, number>;
}

export interface AdminMlReportResponse {
  available: boolean;
  metrics: MlEvaluationMetrics | null;
  eda: EdaReportSummary | null;
  note: string | null;
}
