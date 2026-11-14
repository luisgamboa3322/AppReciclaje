import type { ReactNode } from "react";
import { AlertCircle, Inbox, Sparkles } from "lucide-react";

import { MATERIAL_META } from "@/lib/materials";
import type { MaterialKey } from "@/lib/types";

export function Card({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <section
      className={`rounded-2xl border border-[#dce7e2] bg-white p-5 shadow-[0_1px_2px_rgba(18,56,45,0.04)] ${className}`}
    >
      {children}
    </section>
  );
}

export function KpiCard({
  title,
  value,
  subtitle,
  icon,
  tone = "default",
}: {
  title: string;
  value: string;
  subtitle?: string;
  icon: ReactNode;
  tone?: "default" | "emerald" | "amber";
}) {
  const iconStyle =
    tone === "emerald"
      ? "bg-[#E9FAF3] text-[#087D60]"
      : tone === "amber"
      ? "bg-amber-50 text-amber-700"
      : "bg-slate-100 text-[#12382D]";

  return (
    <Card className="flex items-start justify-between gap-4">
      <div className="min-w-0">
        <p className="text-xs font-semibold uppercase tracking-wider text-[#556861]">
          {title}
        </p>
        <p className="mt-2 text-2xl font-bold tracking-tight text-[#17221E] tabular-nums">
          {value}
        </p>
        {subtitle ? (
          <p className="mt-1 text-xs text-[#556861]">{subtitle}</p>
        ) : null}
      </div>
      <div
        className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl ${iconStyle}`}
      >
        {icon}
      </div>
    </Card>
  );
}

export function MaterialBadge({ material }: { material: MaterialKey }) {
  const meta = MATERIAL_META[material];
  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-full border px-2.5 py-0.5 text-xs font-semibold ${meta.badgeClass}`}
    >
      <span className={`h-1.5 w-1.5 rounded-full ${meta.dotClass}`} />
      {meta.label}
    </span>
  );
}

export function FutureConceptBanner({
  title,
  description,
}: {
  title: string;
  description: string;
}) {
  return (
    <div className="rounded-2xl border border-amber-200 bg-amber-50/70 p-4 text-amber-950">
      <div className="flex items-start gap-3">
        <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-amber-100 text-amber-700">
          <Sparkles className="h-5 w-5" />
        </div>
        <div>
          <div className="flex flex-wrap items-center gap-2">
            <span className="inline-flex items-center rounded-full bg-amber-200/80 px-2.5 py-0.5 text-xs font-bold uppercase tracking-wide text-amber-900">
              Próxima etapa
            </span>
            <h2 className="text-sm font-semibold">{title}</h2>
          </div>
          <p className="mt-1.5 text-sm leading-relaxed text-amber-900/90">
            {description}
          </p>
        </div>
      </div>
    </div>
  );
}

export function ErrorBanner({
  message,
  onRetry,
}: {
  message: string;
  onRetry?: () => void;
}) {
  return (
    <div
      role="alert"
      className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-900"
    >
      <div className="flex items-center gap-2.5">
        <AlertCircle className="h-4 w-4 shrink-0 text-rose-600" />
        <span>{message}</span>
      </div>
      {onRetry ? (
        <button
          type="button"
          onClick={onRetry}
          className="rounded-lg border border-rose-300 bg-white px-3 py-1 text-xs font-semibold text-rose-800 hover:bg-rose-100"
        >
          Reintentar
        </button>
      ) : null}
    </div>
  );
}

export function EmptyState({
  title,
  description,
}: {
  title: string;
  description: string;
}) {
  return (
    <div className="flex flex-col items-center justify-center rounded-2xl border border-dashed border-[#dce7e2] bg-white px-6 py-12 text-center">
      <div className="flex h-11 w-11 items-center justify-center rounded-full bg-[#E9FAF3] text-[#087D60]">
        <Inbox className="h-5 w-5" />
      </div>
      <h3 className="mt-3 text-sm font-semibold text-[#17221E]">{title}</h3>
      <p className="mt-1 max-w-md text-xs leading-relaxed text-[#556861]">
        {description}
      </p>
    </div>
  );
}

export function LoadingGrid() {
  return (
    <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
      {[0, 1, 2, 3].map((item) => (
        <div
          key={item}
          className="h-28 animate-pulse rounded-2xl border border-[#dce7e2] bg-white/80 p-5"
        />
      ))}
    </div>
  );
}
