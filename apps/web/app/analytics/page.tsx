"use client";

import { Download, Layers, RefreshCw, TrendingUp } from "lucide-react";
import { useCallback, useEffect, useState } from "react";

import { AdminShell } from "@/components/admin-shell";
import {
  DailyTrendChart,
  MaterialBreakdownChart,
} from "@/components/charts";
import { Card, ErrorBanner, KpiCard, LoadingGrid } from "@/components/ui";
import { ApiError, pecoxApi } from "@/lib/api";
import { buildClassificationsCsv, downloadCsvFile } from "@/lib/csv";
import { MATERIAL_META, formatConfidence } from "@/lib/materials";
import type {
  AdminClassificationItem,
  AdminSummaryResponse,
} from "@/lib/types";

export default function AnalyticsPage() {
  const [summary, setSummary] = useState<AdminSummaryResponse | null>(null);
  const [rows, setRows] = useState<AdminClassificationItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadAnalytics = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [summaryRes, listRes] = await Promise.all([
        pecoxApi.getAdminSummary(),
        pecoxApi.listAdminClassifications({ limit: 200, offset: 0 }),
      ]);
      setSummary(summaryRes);
      setRows(listRes.items);
    } catch (err) {
      setError(
        err instanceof ApiError
          ? err.detail
          : "No se pudieron cargar las analíticas."
      );
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadAnalytics();
  }, [loadAnalytics]);

  function handleExportCsv() {
    downloadCsvFile("pecox-analitica-clasificaciones.csv", buildClassificationsCsv(rows));
  }

  return (
    <AdminShell
      title="Analítica de reciclaje"
      subtitle="Indicadores verificables de volumen, tasa de aceptación sin corrección manual y exportación CSV."
      actions={
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => void loadAnalytics()}
            className="inline-flex items-center gap-2 rounded-xl border border-[#dce7e2] bg-white px-3 py-2 text-xs font-semibold text-[#12382D] hover:bg-[#E9FAF3]"
          >
            <RefreshCw className={`h-3.5 w-3.5 ${loading ? "animate-spin" : ""}`} />
            Recargar
          </button>
          <button
            type="button"
            disabled={rows.length === 0}
            onClick={handleExportCsv}
            className="inline-flex items-center gap-2 rounded-xl bg-[#12382D] px-3.5 py-2 text-xs font-semibold text-white hover:bg-[#087D60] disabled:opacity-50"
          >
            <Download className="h-3.5 w-3.5" />
            Exportar muestra ({rows.length})
          </button>
        </div>
      }
    >
      {error ? (
        <ErrorBanner message={error} onRetry={() => void loadAnalytics()} />
      ) : null}

      {loading && !summary ? <LoadingGrid /> : null}

      {summary ? (
        <>
          <div className="grid gap-4 sm:grid-cols-3">
            <KpiCard
              title="Tasa sin corrección"
              value={`${(100 - summary.correction_rate).toFixed(1)}%`}
              subtitle="Clasificaciones confirmadas tal como predijo el modelo"
              icon={<TrendingUp className="h-5 w-5" />}
              tone="emerald"
            />
            <KpiCard
              title="Correcciones registradas"
              value={summary.corrected_count.toLocaleString("es-CO")}
              subtitle={`${summary.correction_rate.toFixed(1)}% del total histórico`}
              icon={<Layers className="h-5 w-5" />}
              tone="amber"
            />
            <KpiCard
              title="Confianza media real"
              value={formatConfidence(summary.average_confidence)}
              subtitle="Calculada sobre registros con score ML"
              icon={<TrendingUp className="h-5 w-5" />}
            />
          </div>

          <div className="grid gap-6 lg:grid-cols-2">
            <Card>
              <h2 className="mb-3 text-sm font-bold text-[#17221E]">
                Proporción por categoría de residuo
              </h2>
              <MaterialBreakdownChart items={summary.by_material} />
            </Card>
            <Card>
              <h2 className="mb-3 text-sm font-bold text-[#17221E]">
                Serie diaria (últimos 7 días)
              </h2>
              <DailyTrendChart items={summary.daily_last_7_days} />
            </Card>
          </div>

          <Card>
            <h2 className="mb-3 text-sm font-bold text-[#17221E]">
              Resumen tabular por contenedor
            </h2>
            <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
              {summary.by_material.map((item) => {
                const meta = MATERIAL_META[item.material];
                return (
                  <div
                    key={item.material}
                    className="rounded-xl border border-[#dce7e2] bg-[#FAFCFB] p-3.5"
                  >
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-bold text-[#17221E]">
                        {meta.label}
                      </span>
                      <span className="text-xs font-bold text-[#087D60] tabular-nums">
                        {item.percentage.toFixed(1)}%
                      </span>
                    </div>
                    <p className="mt-1 text-lg font-bold text-[#12382D] tabular-nums">
                      {item.count}
                    </p>
                    <p className="text-[11px] text-[#556861]">{meta.binLabel}</p>
                  </div>
                );
              })}
            </div>
          </Card>
        </>
      ) : null}
    </AdminShell>
  );
}
