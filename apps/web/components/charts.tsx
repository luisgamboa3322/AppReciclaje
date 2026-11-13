"use client";

import { motion } from "motion/react";

import { MATERIAL_META } from "@/lib/materials";
import type {
  DailyCountItem,
  MaterialCountItem,
  MaterialKey,
} from "@/lib/types";

export function MaterialBreakdownChart({
  items,
}: {
  items: MaterialCountItem[];
}) {
  const maxCount = Math.max(...items.map((i) => i.count), 1);

  return (
    <div className="space-y-3" aria-label="Distribución por material">
      {items.map((item) => {
        const meta = MATERIAL_META[item.material];
        const widthPct = Math.round((item.count / maxCount) * 100);
        return (
          <div key={item.material} className="space-y-1.5">
            <div className="flex items-center justify-between text-xs">
              <div className="flex items-center gap-2 font-semibold text-[#17221E]">
                <span className={`h-2.5 w-2.5 rounded-full ${meta.dotClass}`} />
                <span>{meta.label}</span>
              </div>
              <div className="text-[#556861] tabular-nums">
                <span className="font-semibold text-[#17221E]">{item.count}</span>{" "}
                ({item.percentage.toFixed(1)}%)
              </div>
            </div>
            <div className="h-2.5 w-full overflow-hidden rounded-full bg-[#EFF5F2]">
              <motion.div
                initial={{ width: 0 }}
                animate={{ width: `${widthPct}%` }}
                transition={{ duration: 0.45, ease: "easeOut" }}
                className="h-full rounded-full"
                style={{ backgroundColor: meta.accentHex }}
              />
            </div>
          </div>
        );
      })}
    </div>
  );
}

export function DailyTrendChart({ items }: { items: DailyCountItem[] }) {
  const maxCount = Math.max(...items.map((i) => i.count), 1);

  return (
    <div className="pt-2" aria-label="Tendencia últimos 7 días">
      <div className="grid h-44 grid-cols-7 items-end gap-2 sm:gap-3">
        {items.map((item) => {
          const heightPct = Math.max(
            item.count > 0 ? Math.round((item.count / maxCount) * 100) : 6,
            6
          );
          const shortDate = item.date.slice(5); // MM-DD
          return (
            <div
              key={item.date}
              className="flex h-full flex-col items-center justify-end gap-1.5"
            >
              <span className="text-[11px] font-semibold text-[#17221E] tabular-nums">
                {item.count}
              </span>
              <div className="flex h-32 w-full items-end rounded-xl bg-[#F3F8F5] p-1">
                <motion.div
                  initial={{ height: 0 }}
                  animate={{ height: `${heightPct}%` }}
                  transition={{ duration: 0.4, ease: "easeOut" }}
                  className={`w-full rounded-lg ${
                    item.count > 0 ? "bg-[#087D60]" : "bg-[#D5E4DD]"
                  }`}
                  title={`${item.date}: ${item.count} clasificaciones`}
                />
              </div>
              <span className="text-[11px] text-[#556861] tabular-nums">
                {shortDate}
              </span>
            </div>
          );
        })}
      </div>
    </div>
  );
}

export function ConfusionMatrixTable({
  labels,
  matrix,
}: {
  labels: MaterialKey[];
  matrix: number[][];
}) {
  const rowTotals = matrix.map((row) =>
    row.reduce((sum, cell) => sum + cell, 0)
  );

  return (
    <div className="overflow-x-auto">
      <table className="w-full border-collapse text-xs">
        <thead>
          <tr className="border-b border-[#dce7e2] text-left text-[#556861]">
            <th className="py-2 pr-3 font-semibold">Real \ Pred.</th>
            {labels.map((label) => (
              <th key={label} className="px-2 py-2 text-center font-semibold">
                {MATERIAL_META[label].label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {matrix.map((row, rowIdx) => {
            const total = rowTotals[rowIdx] || 1;
            return (
              <tr
                key={labels[rowIdx]}
                className="border-b border-[#edf3f0] last:border-0"
              >
                <td className="py-2 pr-3 font-semibold text-[#17221E]">
                  {MATERIAL_META[labels[rowIdx]].label}
                </td>
                {row.map((val, colIdx) => {
                  const ratio = val / total;
                  const isDiagonal = rowIdx === colIdx;
                  const cellClass = isDiagonal
                    ? "bg-[#E9FAF3] font-bold text-[#12382D]"
                    : ratio >= 0.1
                    ? "bg-amber-50 font-semibold text-amber-900"
                    : "text-[#556861]";
                  return (
                    <td
                      key={`${rowIdx}-${colIdx}`}
                      className={`rounded px-2 py-2 text-center tabular-nums ${cellClass}`}
                    >
                      {val}
                    </td>
                  );
                })}
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
