export type Screen =
  | "splash"
  | "onboarding"
  | "auth"
  | "home"
  | "scan"
  | "preview"
  | "analyzing"
  | "result"
  | "history"
  | "stats"
  | "guide"
  | "profile"
  | "future";

export type MaterialKey =
  | "plastic"
  | "glass"
  | "metal"
  | "cardboard"
  | "paper"
  | "other";

export type ResultVariant = "identified" | "low-confidence" | "unknown" | "error";

export type AuthSimulationError =
  | "none"
  | "invalid-credentials"
  | "existing-user"
  | "session-expired";

export interface MaterialAlternative {
  key: MaterialKey;
  confidence: number;
}

export interface ClassificationRecord {
  id: string;
  title: string;
  predictedMaterial: MaterialKey;
  confirmedMaterial: MaterialKey;
  confidence: number | null;
  status: "confirmed" | "corrected";
  dateGroup: "HOY" | "ESTA SEMANA" | "ANTERIORES";
  timestampLabel: string;
  imageUrl?: string;
  notes?: string;
}

export interface UserProfile {
  name: string;
  email: string;
  initials: string;
  badge: string;
  isGuest: boolean;
}

export interface AccessibilitySettings {
  largeText: boolean;
  reduceMotion: boolean;
}

export interface PrototypeSimulationFlags {
  offline: boolean;
  cameraDenied: boolean;
  invalidImage: boolean;
  mlUnavailable: boolean;
  splashError: boolean;
  resultVariant: ResultVariant;
  authError: AuthSimulationError;
}
