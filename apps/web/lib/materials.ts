import type { MaterialKey } from "@/lib/types";

export interface MaterialMeta {
  key: MaterialKey;
  label: string;
  binLabel: string;
  accentHex: string;
  badgeClass: string;
  dotClass: string;
}

export const MATERIAL_META: Record<MaterialKey, MaterialMeta> = {
  plastic: {
    key: "plastic",
    label: "Plástico",
    binLabel: "Contenedor Blanco",
    accentHex: "#0EA5E9",
    badgeClass: "bg-sky-50 text-sky-800 border-sky-200",
    dotClass: "bg-sky-500",
  },
  glass: {
    key: "glass",
    label: "Vidrio",
    binLabel: "Contenedor Blanco / Vidrio",
    accentHex: "#10B981",
    badgeClass: "bg-emerald-50 text-emerald-800 border-emerald-200",
    dotClass: "bg-emerald-500",
  },
  metal: {
    key: "metal",
    label: "Metal",
    binLabel: "Contenedor Blanco",
    accentHex: "#64748B",
    badgeClass: "bg-slate-100 text-slate-800 border-slate-300",
    dotClass: "bg-slate-500",
  },
  cardboard: {
    key: "cardboard",
    label: "Cartón",
    binLabel: "Contenedor Azul",
    accentHex: "#D97706",
    badgeClass: "bg-amber-50 text-amber-800 border-amber-200",
    dotClass: "bg-amber-500",
  },
  paper: {
    key: "paper",
    label: "Papel",
    binLabel: "Contenedor Azul",
    accentHex: "#3B82F6",
    badgeClass: "bg-blue-50 text-blue-800 border-blue-200",
    dotClass: "bg-blue-500",
  },
  other: {
    key: "other",
    label: "Otro / No aprovechable",
    binLabel: "Contenedor Negro",
    accentHex: "#6B7280",
    badgeClass: "bg-zinc-100 text-zinc-800 border-zinc-300",
    dotClass: "bg-zinc-500",
  },
};

export const MATERIAL_KEYS: MaterialKey[] = [
  "plastic",
  "glass",
  "metal",
  "cardboard",
  "paper",
  "other",
];

export function formatConfidence(confidence: number | null | undefined): string {
  if (confidence === null || confidence === undefined) {
    return "Sin dato";
  }
  return `${(confidence * 100).toFixed(1)}%`;
}

export function formatDateTime(iso: string): string {
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) {
    return iso;
  }
  return new Intl.DateTimeFormat("es-CO", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(date);
}
