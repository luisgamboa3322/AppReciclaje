import { render, screen, waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

import DashboardOverviewPage from "@/app/page";
import * as authHook from "@/components/auth-provider";
import { pecoxApi } from "@/lib/api";

describe("DashboardOverviewPage", () => {
  it("renders real KPIs and active model info from API", async () => {
    vi.spyOn(authHook, "useAuth").mockReturnValue({
      user: {
        id: "a1",
        name: "Admin PECOX",
        email: "admin@example.com",
        role: "admin",
        created_at: "2026-11-13T10:00:00Z",
      },
      isLoading: false,
      isAuthenticated: true,
      isAdmin: true,
      login: vi.fn(),
      logout: vi.fn(),
      refreshSession: vi.fn(),
    });

    vi.spyOn(pecoxApi, "getAdminSummary").mockResolvedValue({
      total_users: 5,
      total_admins: 1,
      total_classifications: 42,
      classifications_last_7_days: 14,
      corrected_count: 5,
      correction_rate: 12.5,
      average_confidence: 0.815,
      by_material: [
        { material: "plastic", count: 18, percentage: 42.9 },
        { material: "glass", count: 8, percentage: 19.0 },
        { material: "metal", count: 6, percentage: 14.3 },
        { material: "cardboard", count: 5, percentage: 11.9 },
        { material: "paper", count: 4, percentage: 9.5 },
        { material: "other", count: 1, percentage: 2.4 },
      ],
      daily_last_7_days: [
        { date: "2026-11-07", count: 1 },
        { date: "2026-11-08", count: 2 },
        { date: "2026-11-09", count: 0 },
        { date: "2026-11-10", count: 3 },
        { date: "2026-11-11", count: 4 },
        { date: "2026-11-12", count: 2 },
        { date: "2026-11-13", count: 2 },
      ],
      recent_classifications: [],
    });

    vi.spyOn(pecoxApi, "getModelInfo").mockResolvedValue({
      status: "ready",
      active_version: "resnet18-trashnet-v1.0.0",
      architecture: "resnet18",
      identified_threshold: 0.5,
      low_confidence_threshold: 0.35,
      note: "Trained PyTorch model artifact loaded in process memory.",
    });

    render(<DashboardOverviewPage />);

    await waitFor(() => {
      expect(screen.getByText("42")).toBeInTheDocument();
    });
    expect(screen.getByText("81.5%")).toBeInTheDocument();
    expect(screen.getByText("12.5%")).toBeInTheDocument();
    expect(
      screen.getByText("Modelo activo: resnet18-trashnet-v1.0.0")
    ).toBeInTheDocument();
  });
});
