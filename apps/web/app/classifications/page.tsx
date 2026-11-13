"use client";

import {
  ChevronLeft,
  ChevronRight,
  Download,
  Filter,
  Search,
  X,
} from "lucide-react";
import { useCallback, useEffect, useState } from "react";

import { AdminShell } from "@/components/admin-shell";
import {
  Card,
  EmptyState,
  ErrorBanner,
  MaterialBadge,
} from "@/components/ui";
import { ApiError, pecoxApi } from "@/lib/api";
import { buildClassificationsCsv, downloadCsvFile } from "@/lib/csv";
import {
  MATERIAL_KEYS,
  MATERIAL_META,
  formatConfidence,
  formatDateTime,
} from "@/lib/materials";
import type { AdminClassificationItem, MaterialKey } from "@/lib/types";

const PAGE_SIZE = 20;

export default function ClassificationsPage() {
  const [items, setItems] = useState<AdminClassificationItem[]>([]);
  const [total, setTotal] = useState(0);
  const [material, setMaterial] = useState<MaterialKey | "">("");
  const [correctedOnly, setCorrectedOnly] = useState(false);
  const [search, setSearch] = useState("");
  const [offset, setOffset] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selected, setSelected] = useState<AdminClassificationItem | null>(
    null
  );

  const loadRows = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const resp = await pecoxApi.listAdminClassifications({
        material,
        correctedOnly,
        search,
        limit: PAGE_SIZE,
        offset,
      });
      setItems(resp.items);
      setTotal(resp.total);
    } catch (err) {
      setError(
        err instanceof ApiError
          ? err.detail
          : "No se pudieron cargar las clasificaciones."
      );
    } finally {
      setLoading(false);
    }
  }, [material, correctedOnly, search, offset]);

  useEffect(() => {
    void loadRows();
  }, [loadRows]);

  function handleExportCsv() {
    const csv = buildClassificationsCsv(items);
    downloadCsvFile("pecox-clasificaciones.csv", csv);
  }

  const currentPage = Math.floor(offset / PAGE_SIZE) + 1;
  const totalPages = Math.max(Math.ceil(total / PAGE_SIZE), 1);

  return (
    <AdminShell
      title="Historial de clasificaciones"
      subtitle="Auditoría global con filtros por material, correcciones manuales y búsqueda por usuario."
      actions={
        <button
          type="button"
          disabled={items.length === 0}
          onClick={handleExportCsv}
          className="inline-flex items-center gap-2 rounded-xl bg-[#12382D] px-3.5 py-2 text-xs font-semibold text-white hover:bg-[#087D60] disabled:opacity-50"
        >
          <Download className="h-3.5 w-3.5" />
          Exportar CSV ({items.length})
        </button>
      }
    >
      {error ? (
        <ErrorBanner message={error} onRetry={() => void loadRows()} />
      ) : null}

      <Card>
        <div className="flex flex-wrap items-center gap-3">
          <div className="relative min-w-[220px] flex-1">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-[#556861]" />
            <input
              type="search"
              value={search}
              onChange={(e) => {
                setOffset(0);
                setSearch(e.target.value);
              }}
              placeholder="Buscar por nombre, correo o versión del modelo..."
              className="w-full rounded-xl border border-[#dce7e2] bg-[#FAFCFB] py-2 pl-9 pr-3 text-xs text-[#17221E] focus:border-[#087D60] focus:bg-white"
            />
          </div>

          <div className="flex items-center gap-2">
            <Filter className="h-4 w-4 text-[#556861]" />
            <select
              aria-label="Filtrar por material"
              value={material}
              onChange={(e) => {
                setOffset(0);
                setMaterial(e.target.value as MaterialKey | "");
              }}
              className="rounded-xl border border-[#dce7e2] bg-[#FAFCFB] px-3 py-2 text-xs font-medium text-[#17221E]"
            >
              <option value="">Todos los materiales</option>
              {MATERIAL_KEYS.map((key) => (
                <option key={key} value={key}>
                  {MATERIAL_META[key].label}
                </option>
              ))}
            </select>
          </div>

          <label className="inline-flex cursor-pointer items-center gap-2 rounded-xl border border-[#dce7e2] bg-[#FAFCFB] px-3 py-2 text-xs font-medium text-[#17221E]">
            <input
              type="checkbox"
              checked={correctedOnly}
              onChange={(e) => {
                setOffset(0);
                setCorrectedOnly(e.target.checked);
              }}
              className="h-3.5 w-3.5 accent-[#087D60]"
            />
            Solo corregidas manualmente
          </label>
        </div>
      </Card>

      <div className="grid gap-6 lg:grid-cols-3">
        <Card className={selected ? "lg:col-span-2" : "lg:col-span-3"}>
          {loading ? (
            <p className="py-10 text-center text-xs text-[#556861]">
              Cargando registros...
            </p>
          ) : items.length === 0 ? (
            <EmptyState
              title="Sin resultados para los filtros actuales"
              description="Prueba limpiando el filtro de material o la búsqueda por usuario."
            />
          ) : (
            <>
              <div className="overflow-x-auto">
                <table className="w-full text-left text-xs">
                  <thead>
                    <tr className="border-b border-[#dce7e2] text-[#556861]">
                      <th className="py-2.5 pr-4 font-semibold">Usuario</th>
                      <th className="py-2.5 pr-4 font-semibold">Predicho</th>
                      <th className="py-2.5 pr-4 font-semibold">Confirmado</th>
                      <th className="py-2.5 pr-4 font-semibold">Confianza</th>
                      <th className="py-2.5 pr-4 font-semibold">Fecha</th>
                      <th className="py-2.5 font-semibold">Acción</th>
                    </tr>
                  </thead>
                  <tbody>
                    {items.map((row) => (
                      <tr
                        key={row.id}
                        className="border-b border-[#edf3f0] last:border-0 hover:bg-[#FAFCFB]"
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
                        <td className="py-3 pr-4 text-[#556861] tabular-nums">
                          {formatDateTime(row.created_at)}
                        </td>
                        <td className="py-3">
                          <button
                            type="button"
                            onClick={() => setSelected(row)}
                            className="font-semibold text-[#087D60] hover:underline"
                          >
                            Inspeccionar
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              <div className="mt-4 flex flex-wrap items-center justify-between gap-2 border-t border-[#edf3f0] pt-4 text-xs text-[#556861]">
                <span className="tabular-nums">
                  Mostrando {items.length} de {total} registros · Página{" "}
                  {currentPage} de {totalPages}
                </span>
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    disabled={offset === 0}
                    onClick={() => setOffset((prev) => Math.max(prev - PAGE_SIZE, 0))}
                    className="inline-flex items-center gap-1 rounded-lg border border-[#dce7e2] px-2.5 py-1.5 font-medium text-[#17221E] disabled:opacity-40"
                  >
                    <ChevronLeft className="h-3.5 w-3.5" />
                    Anterior
                  </button>
                  <button
                    type="button"
                    disabled={offset + PAGE_SIZE >= total}
                    onClick={() => setOffset((prev) => prev + PAGE_SIZE)}
                    className="inline-flex items-center gap-1 rounded-lg border border-[#dce7e2] px-2.5 py-1.5 font-medium text-[#17221E] disabled:opacity-40"
                  >
                    Siguiente
                    <ChevronRight className="h-3.5 w-3.5" />
                  </button>
                </div>
              </div>
            </>
          )}
        </Card>

        {selected ? (
          <Card className="h-fit space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-bold text-[#17221E]">
                Detalle del registro
              </h2>
              <button
                type="button"
                aria-label="Cerrar detalle"
                onClick={() => setSelected(null)}
                className="rounded-lg p-1 text-[#556861] hover:bg-slate-100"
              >
                <X className="h-4 w-4" />
              </button>
            </div>
            <dl className="space-y-2.5 text-xs">
              <div>
                <dt className="text-[#556861]">ID clasificación</dt>
                <dd className="mt-0.5 break-all font-mono text-[11px] text-[#17221E]">
                  {selected.id}
                </dd>
              </div>
              <div>
                <dt className="text-[#556861]">Usuario</dt>
                <dd className="mt-0.5 font-semibold text-[#17221E]">
                  {selected.user_name} ({selected.user_email})
                </dd>
              </div>
              <div className="flex items-center justify-between border-t border-[#edf3f0] pt-2">
                <dt className="text-[#556861]">Predicción ML</dt>
                <dd>
                  <MaterialBadge material={selected.predicted_material} />
                </dd>
              </div>
              <div className="flex items-center justify-between">
                <dt className="text-[#556861]">Material confirmado</dt>
                <dd>
                  <MaterialBadge material={selected.confirmed_material} />
                </dd>
              </div>
              <div className="flex items-center justify-between">
                <dt className="text-[#556861]">Confianza</dt>
                <dd className="font-semibold tabular-nums">
                  {formatConfidence(selected.confidence)}
                </dd>
              </div>
              <div className="flex items-center justify-between">
                <dt className="text-[#556861]">Contenedor destino</dt>
                <dd className="font-medium text-[#12382D]">
                  {MATERIAL_META[selected.confirmed_material].binLabel}
                </dd>
              </div>
              <div className="border-t border-[#edf3f0] pt-2">
                <dt className="text-[#556861]">Versión modelo</dt>
                <dd className="mt-0.5 font-mono text-[11px] text-[#17221E]">
                  {selected.model_version}
                </dd>
              </div>
              <div>
                <dt className="text-[#556861]">Registrada</dt>
                <dd className="mt-0.5 text-[#17221E]">
                  {formatDateTime(selected.created_at)}
                </dd>
              </div>
            </dl>
          </Card>
        ) : null}
      </div>
    </AdminShell>
  );
}
