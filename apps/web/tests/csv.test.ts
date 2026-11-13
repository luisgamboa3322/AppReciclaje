import { describe, expect, it } from "vitest";

import { buildClassificationsCsv } from "@/lib/csv";
import type { AdminClassificationItem } from "@/lib/types";

describe("buildClassificationsCsv", () => {
  it("serializes classification rows and escapes commas and quotes", () => {
    const rows: AdminClassificationItem[] = [
      {
        id: "cls-1",
        user_id: "usr-1",
        user_name: 'Ana, "La Recicladora"',
        user_email: "ana@example.com",
        predicted_material: "plastic",
        confidence: 0.91234,
        confirmed_material: "plastic",
        model_version: "resnet18-trashnet-v1.0.0",
        is_corrected: false,
        created_at: "2026-11-13T10:00:00Z",
        updated_at: "2026-11-13T10:00:00Z",
      },
      {
        id: "cls-2",
        user_id: "usr-2",
        user_name: "Luis",
        user_email: "luis@example.com",
        predicted_material: "glass",
        confidence: null,
        confirmed_material: "metal",
        model_version: "resnet18-trashnet-v1.0.0",
        is_corrected: true,
        created_at: "2026-11-13T11:00:00Z",
        updated_at: "2026-11-13T11:05:00Z",
      },
    ];

    const csv = buildClassificationsCsv(rows);
    const lines = csv.split("\r\n");

    expect(lines).toHaveLength(3);
    expect(lines[0]).toBe(
      "id,created_at,user_name,user_email,predicted_material,confirmed_material,confidence,is_corrected,model_version"
    );
    expect(lines[1]).toContain('"Ana, ""La Recicladora"""');
    expect(lines[1]).toContain("0.9123");
    expect(lines[2]).toContain("luis@example.com,glass,metal,,true,");
  });
});
