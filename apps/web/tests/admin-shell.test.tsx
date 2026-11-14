import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

import { AdminShell } from "@/components/admin-shell";
import * as authHook from "@/components/auth-provider";

describe("AdminShell RBAC guard", () => {
  it("blocks standard users with an explicit admin-only message", () => {
    vi.spyOn(authHook, "useAuth").mockReturnValue({
      user: {
        id: "u1",
        name: "Usuario Estándar",
        email: "user@example.com",
        role: "user",
        created_at: "2026-11-13T10:00:00Z",
      },
      isLoading: false,
      isAuthenticated: true,
      isAdmin: false,
      login: vi.fn(),
      logout: vi.fn(),
      refreshSession: vi.fn(),
    });

    render(
      <AdminShell title="Resumen" subtitle="Subtítulo">
        <p>Contenido protegido</p>
      </AdminShell>
    );

    expect(
      screen.getByText("Acceso restringido a administradores")
    ).toBeInTheDocument();
    expect(screen.queryByText("Contenido protegido")).not.toBeInTheDocument();
  });

  it("renders protected content and upcoming badges for admin users", () => {
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

    render(
      <AdminShell title="Resumen" subtitle="Subtítulo">
        <p>Contenido protegido</p>
      </AdminShell>
    );

    expect(screen.getByText("Contenido protegido")).toBeInTheDocument();
    expect(screen.getAllByText("Pronto")).toHaveLength(2);
  });
});
