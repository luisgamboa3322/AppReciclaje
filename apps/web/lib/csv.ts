import type { AdminClassificationItem } from "@/lib/types";

function escapeCsvCell(value: string | number | boolean | null | undefined): string {
  if (value === null || value === undefined) {
    return "";
  }
  const str = String(value);
  if (/[",\n\r]/.test(str)) {
    return `"${str.replace(/"/g, '""')}"`;
  }
  return str;
}

export function buildClassificationsCsv(rows: AdminClassificationItem[]): string {
  const headers = [
    "id",
    "created_at",
    "user_name",
    "user_email",
    "predicted_material",
    "confirmed_material",
    "confidence",
    "is_corrected",
    "model_version",
  ];
  const lines = [
    headers.join(","),
    ...rows.map((row) =>
      [
        row.id,
        row.created_at,
        row.user_name,
        row.user_email,
        row.predicted_material,
        row.confirmed_material,
        row.confidence !== null ? row.confidence.toFixed(4) : "",
        row.is_corrected,
        row.model_version,
      ]
        .map(escapeCsvCell)
        .join(",")
    ),
  ];
  return lines.join("\r\n");
}

export function downloadCsvFile(filename: string, csvContent: string): void {
  const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = filename;
  document.body.appendChild(anchor);
  anchor.click();
  document.body.removeChild(anchor);
  URL.revokeObjectURL(url);
}
