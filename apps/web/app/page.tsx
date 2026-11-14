"use client";

import Link from "next/link";
import {
  Activity,
  ArrowRight,
  CheckCircle2,
  Cpu,
  Edit3,
  Layers,
  RefreshCw,
  Users,
} from "lucide-react";
import { useCallback, useEffect, useState } from "react";

import { AdminShell } from "@/components/admin-shell";
import {
  DailyTrendChart,
  MaterialBreakdownChart,
} from "@/components/charts";
import {
  Card,
  EmptyState,
  ErrorBanner,
  KpiCard,
  LoadingGrid,
  MaterialBadge,
} from "@/components/ui";
import { ApiError, pecoxApi } from "@/lib/api";
import { formatConfidence, formatDateTime } from "@/lib/materials";
import type { AdminSummaryResponse, ModelInfoResponse } from "@/lib/types";

export default function DashboardOverviewPage() {
  const [summary, setSummary] = useState<AdminSummaryResponse | null>(null);
  const [modelInfo, setModelInfo] = useState<ModelInfoResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [summaryRes, modelRes] = await Promise.all([
        pecoxApi.getAdminSummary(),
        pecoxApi.getModelInfo(),
      ]);
      setSummary(summaryRes);
      setModelInfo(modelRes);
    } catch (err) {
      setError(
        err instanceof ApiError
          ? err.detail
          : "No se pudo cargar el resumen administrativo desde la API."
      );
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  return (
    <AdminShell
      title="Resumen operativo"
      subtitle="Métricas reales de clasificaciones y actividad de la plataforma."
      actions={
        <button
          type="button"
          onClick={() => void loadData()}
          className="inline-flex items-center gap-2 rounded-xl border border-[#dce7e2] bg-white px-3.5 py-2 text-xs font-semibold text-[#12382D] hover:bg-[#E9FAF3]"
        >
          <RefreshCw className={`h-3.5 w-3.5 ${loading ? "animate-spin" : ""}`} />
          Actualizar
        </button>
      }
    >
      {error ? (
        <ErrorBanner message={error} onRetry={() => void loadData()} />
      ) : null}

      {loading && !summary ? <LoadingGrid /> : null}

      {summary ? (
        <>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <KpiCard
              title="Clasificaciones totales"
              value={summary.total_classifications.toLocaleString("es-CO")}
              subtitle={`${summary.classifications_last_7_days} registradas últimos 7 días`}
              icon={<Layers className="h-5 w-5" />}
              tone="emerald"
            />
            <KpiCard
              title="Usuarios registrados"
              value={summary.total_users.toLocaleString("es-CO")}
              subtitle={`${summary.total_admins} con rol administrador`}
              icon={<Users className="h-5 w-5" />}
            />
            <KpiCard
              title="Confianza promedio"
              value={formatConfidence(summary.average_confidence)}
              subtitle="Promedio de inferencia registrada"
              icon={<Activity className="h-5 w-5" />}
              tone="emerald"
            />
            <KpiCard
              title="Corrección manual"
              value={`${summary.correction_rate.toFixed(1)}%`}
              subtitle={`${summary.corrected_count} registros ajustados por usuario`}
              icon={<Edit3 className="h-5 w-5" />}
              tone="amber"
            />
          </div>

          {modelInfo ? (
            <Card className="flex flex-wrap items-center justify-between gap-4 border-[#c9e6da] bg-[#E9FAF3]/40">
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#12382D] text-[#12C994]">
                  <Cpu className="h-5 w-5" />
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-bold text-[#17221E]">
                      Modelo activo: {modelInfo.active_version ?? "Sin checkpoint"}
                    </span>
                    <span
                      className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-semibold ${
                        modelInfo.status === "ready"
                          ? "bg-emerald-100 text-emerald-900"
                          : "bg-amber-100 text-amber-900"
                      }`}
                    >
                      <CheckCircle2 className="h-3 w-3" />
                      {modelInfo.status}
                    </span>
                  </div>
                  <p className="text-xs text-[#556861]">
                    {modelInfo.architecture
                      ? `Arquitectura ${modelInfo.architecture} · Umbral identificado ${
                          modelInfo.identified_threshold ?? 0.5
                        }`
                      : modelInfo.note}
                  </p>
                </div>
              </div>
              <Link
                href="/models"
                className="inline-flex items-center gap-1.5 rounded-xl bg-[#12382D] px-3.5 py-2 text-xs font-semibold text-white hover:bg-[#087D60]"
              >
                Ver métricas ML
                <ArrowRight className="h-3.5 w-3.5" />
              </Link>
            </Card>
          ) : null}

          <div className="grid gap-6 lg:grid-cols-2">
            <Card>
              <div className="mb-4 flex items-center justify-between">
                <div>
                  <h2 className="text-sm font-bold text-[#17221E]">
                    Distribución por material
                  </h2>
                  <p className="text-xs text-[#556861]">
                    Basada en el material confirmado de cada clasificación.
                  </p>
                </div>
              </div>
              <MaterialBreakdownChart items={summary.by_material} />
            </Card>

            <Card>
              <div className="mb-4">
                <h2 className="text-sm font-bold text-[#17221E]">
                  Actividad diaria (últimos 7 días UTC)
                </h2>
                <p className="text-xs text-[#556861]">
                  Conteo real diario de clasificaciones registradas en la plataforma.
                </p>
              </div>
              <DailyTrendChart items={summary.daily_last_7_days} />
            </Card>
          </div>

          <Card>
            <div className="mb-4 flex flex-wrap items-center justify-between gap-2">
              <div>
                <h2 className="text-sm font-bold text-[#17221E]">
                  Clasificaciones recientes
                </h2>
                <p className="text-xs text-[#556861]">
                  Últimos registros enviados desde la aplicación móvil.
                </p>
              </div>
              <Link
                href="/classifications"
                className="inline-flex items-center gap-1 text-xs font-semibold text-[#087D60] hover:underline"
              >
                Ver historial completo
                <ArrowRight className="h-3.5 w-3.5" />
              </Link>
            </div>

            {summary.recent_classifications.length === 0 ? (
              <EmptyState
                title="Aún no hay clasificaciones registradas"
                description="Cuando los usuarios clasifiquen residuos desde PECOX Vision móvil, aparecerán aquí en tiempo real."
              />
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-left text-xs">
                  <thead>
                    <tr className="border-b border-[#dce7e2] text-[#556861]">
                      <th className="py-2.5 pr-4 font-semibold">Usuario</th>
                      <th className="py-2.5 pr-4 font-semibold">Predicción</th>
                      <th className="py-2.5 pr-4 font-semibold">Confirmado</th>
                      <th className="py-2.5 pr-4 font-semibold">Confianza</th>
                      <th className="py-2.5 pr-4 font-semibold">Modelo</th>
                      <th className="py-2.5 font-semibold">Fecha</th>
                    </tr>
                  </thead>
                  <tbody>
                    {summary.recent_classifications.map((row) => (
                      <tr
                        key={row.id}
                        className="border-b border-[#edf3f0] last:border-0"
                      >
                        <td className="py-3 pr-4">
                          <p className="font-semibold text-[#17221E]">
                            {row.user_name}
                          </p>
                          <p className="text-[11px] text-[#556861]">
                            {row.user_email}
                          </p>
                        </td>
                        <td className="py-3 pr-4">
                          <MaterialBadge material={row.predicted_material} />
                        </td>
                        <td className="py-3 pr-4">
                          <div className="flex items-center gap-1.5">
                            <MaterialBadge material={row.confirmed_material} />
                            {row.is_corrected ? (
                              <span className="rounded bg-amber-100 px-1.5 py-0.5 text-[10px] font-semibold text-amber-900">
                                Corregido
                              </span>
                            ) : null}
                          </div>
                        </td>
                        <td className="py-3 pr-4 font-semibold tabular-nums">
                          {formatConfidence(row.confidence)}
                        </td>
                        <td className="py-3 pr-4 font-mono text-[11px] text-[#556861]">
                          {row.model_version}
                        </td>
                        <td className="py-3 text-[#556861] tabular-nums">
                          {formatDateTime(row.created_at)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </Card>
        </>
      ) : null}
    </AdminShell>
  );
}
