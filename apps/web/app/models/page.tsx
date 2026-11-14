"use client";

import { AlertTriangle, CheckCircle2, Cpu, Gauge, RefreshCw } from "lucide-react";
import { useCallback, useEffect, useState } from "react";

import { AdminShell } from "@/components/admin-shell";
import { ConfusionMatrixTable } from "@/components/charts";
import { Card, ErrorBanner, KpiCard, LoadingGrid } from "@/components/ui";
import { ApiError, pecoxApi } from "@/lib/api";
import { MATERIAL_META } from "@/lib/materials";
import type {
  AdminMlReportResponse,
  MaterialKey,
  ModelInfoResponse,
} from "@/lib/types";

export default function ModelsPage() {
  const [modelInfo, setModelInfo] = useState<ModelInfoResponse | null>(null);
  const [report, setReport] = useState<AdminMlReportResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadModelTelemetry = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [infoRes, reportRes] = await Promise.all([
        pecoxApi.getModelInfo(),
        pecoxApi.getAdminMlReport(),
      ]);
      setModelInfo(infoRes);
      setReport(reportRes);
    } catch (err) {
      setError(
        err instanceof ApiError
          ? err.detail
          : "No se pudo consultar el estado y reporte del modelo ML."
      );
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadModelTelemetry();
  }, [loadModelTelemetry]);

  const metrics = report?.metrics;
  const eda = report?.eda;

  return (
    <AdminShell
      title="Modelos ML y evaluación"
      subtitle="Estado en vivo del modelo de visión y métricas auditadas sobre el conjunto de prueba."
      actions={
        <button
          type="button"
          onClick={() => void loadModelTelemetry()}
          className="inline-flex items-center gap-2 rounded-xl border border-[#dce7e2] bg-white px-3.5 py-2 text-xs font-semibold text-[#12382D] hover:bg-[#E9FAF3]"
        >
          <RefreshCw className={`h-3.5 w-3.5 ${loading ? "animate-spin" : ""}`} />
          Actualizar
        </button>
      }
    >
      {error ? (
        <ErrorBanner message={error} onRetry={() => void loadModelTelemetry()} />
      ) : null}

      {loading && !modelInfo ? <LoadingGrid /> : null}

      {modelInfo ? (
        <Card className="border-[#c9e6da] bg-[#E9FAF3]/35">
          <div className="flex flex-wrap items-start justify-between gap-4">
            <div className="flex items-start gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#12382D] text-[#12C994]">
                <Cpu className="h-5 w-5" />
              </div>
              <div>
                <div className="flex flex-wrap items-center gap-2">
                  <h2 className="text-sm font-bold text-[#17221E]">
                    {modelInfo.active_version ?? "Sin modelo cargado"}
                  </h2>
                  <span className="inline-flex items-center gap-1 rounded-full bg-emerald-100 px-2.5 py-0.5 text-[11px] font-semibold text-emerald-900">
                    <CheckCircle2 className="h-3 w-3" />
                    {modelInfo.status}
                  </span>
                </div>
                <p className="mt-1 text-xs text-[#556861]">
                  Arquitectura: {modelInfo.architecture ?? "N/A"} ·{" "}
                  {modelInfo.note ?? "Sin notas adicionales"}
                </p>
              </div>
            </div>

            <div className="flex gap-4 text-xs">
              <div>
                <p className="text-[#556861]">Umbral identificado</p>
                <p className="font-bold text-[#12382D] tabular-nums">
                  {modelInfo.identified_threshold ?? "N/A"}
                </p>
              </div>
              <div>
                <p className="text-[#556861]">Umbral baja confianza</p>
                <p className="font-bold text-[#12382D] tabular-nums">
                  {modelInfo.low_confidence_threshold ?? "N/A"}
                </p>
              </div>
            </div>
          </div>
        </Card>
      ) : null}

      {metrics ? (
        <>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <KpiCard
              title="Accuracy (test)"
              value={`${(metrics.accuracy * 100).toFixed(2)}%`}
              subtitle={`Evaluado sobre ${metrics.test_samples} imágenes test`}
              icon={<CheckCircle2 className="h-5 w-5" />}
              tone="emerald"
            />
            <KpiCard
              title="Macro F1"
              value={metrics.macro_f1.toFixed(4)}
              subtitle={`Precision ${metrics.macro_precision.toFixed(3)} · Recall ${metrics.macro_recall.toFixed(3)}`}
              icon={<Cpu className="h-5 w-5" />}
            />
            <KpiCard
              title="Latencia CPU (P50)"
              value={
                metrics.cpu_latency_ms
                  ? `${metrics.cpu_latency_ms.p50.toFixed(1)} ms`
                  : "N/A"
              }
              subtitle={
                metrics.cpu_latency_ms
                  ? `P95: ${metrics.cpu_latency_ms.p95.toFixed(1)} ms`
                  : undefined
              }
              icon={<Gauge className="h-5 w-5" />}
            />
            <KpiCard
              title="Cobertura segura (>=0.50)"
              value={
                metrics.uncertainty_gating
                  ? `${(metrics.uncertainty_gating.identified_coverage * 100).toFixed(1)}%`
                  : "N/A"
              }
              subtitle={
                metrics.uncertainty_gating
                  ? `Exactitud filtrada: ${(metrics.uncertainty_gating.identified_accuracy * 100).toFixed(1)}%`
                  : undefined
              }
              icon={<CheckCircle2 className="h-5 w-5" />}
              tone="emerald"
            />
          </div>

          <div className="grid gap-6 lg:grid-cols-2">
            <Card>
              <h2 className="mb-3 text-sm font-bold text-[#17221E]">
                Desempeño por clase (split test)
              </h2>
              <div className="overflow-x-auto">
                <table className="w-full text-left text-xs">
                  <thead>
                    <tr className="border-b border-[#dce7e2] text-[#556861]">
                      <th className="py-2 pr-4 font-semibold">Material</th>
                      <th className="py-2 pr-4 font-semibold">Precision</th>
                      <th className="py-2 pr-4 font-semibold">Recall</th>
                      <th className="py-2 pr-4 font-semibold">F1</th>
                      <th className="py-2 font-semibold">Soporte</th>
                    </tr>
                  </thead>
                  <tbody>
                    {(Object.keys(metrics.per_class) as MaterialKey[]).map(
                      (key) => {
                        const row = metrics.per_class[key];
                        return (
                          <tr
                            key={key}
                            className="border-b border-[#edf3f0] last:border-0"
                          >
                            <td className="py-2.5 pr-4 font-semibold text-[#17221E]">
                              {MATERIAL_META[key]?.label ?? key}
                            </td>
                            <td className="py-2.5 pr-4 tabular-nums">
                              {(row.precision * 100).toFixed(1)}%
                            </td>
                            <td className="py-2.5 pr-4 tabular-nums">
                              {(row.recall * 100).toFixed(1)}%
                            </td>
                            <td className="py-2.5 pr-4 font-semibold text-[#087D60] tabular-nums">
                              {(row.f1_score * 100).toFixed(1)}%
                            </td>
                            <td className="py-2.5 tabular-nums">{row.support}</td>
                          </tr>
                        );
                      }
                    )}
                  </tbody>
                </table>
              </div>
            </Card>

            <Card>
              <h2 className="mb-1 text-sm font-bold text-[#17221E]">
                Matriz de confusión (test)
              </h2>
              <p className="mb-3 text-xs text-[#556861]">
                Observa las confusiones reales entre clases visualmente cercanas
                (por ejemplo vidrio transparente y metal brillante).
              </p>
              <ConfusionMatrixTable
                labels={metrics.confusion_matrix_labels}
                matrix={metrics.confusion_matrix}
              />
            </Card>
          </div>
        </>
      ) : report && !report.available ? (
        <Card>
          <p className="text-xs text-[#556861]">{report.note}</p>
        </Card>
      ) : null}

      <Card className="border-amber-200 bg-amber-50/40">
        <div className="flex items-start gap-3">
          <AlertTriangle className="mt-0.5 h-5 w-5 shrink-0 text-amber-700" />
          <div className="space-y-1 text-xs leading-relaxed text-amber-950">
            <h2 className="font-bold">
              Limitaciones conocidas del modelo actual
            </h2>
            <p>
              Dataset base:{" "}
              <strong>
                {eda
                  ? `${eda.dataset_id} (${eda.unique_images_after_exact_dedup} imágenes únicas tras deduplicación SHA-256, 0 fuga entre splits)`
                  : "TrashNet (2,524 imágenes únicas)"}
              </strong>
              . Fondo de estudio controlado; el desempeño en escenas reales con
              suciedad severa, iluminación mixta o residuos múltiples puede variar,
              por lo que PECOX permite corrección manual y clasificación segura
              con umbral 0.50.
            </p>
          </div>
        </div>
      </Card>
    </AdminShell>
  );
}
