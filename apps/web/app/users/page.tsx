"use client";

import { Search, ShieldCheck, UserCheck } from "lucide-react";
import { useCallback, useEffect, useState } from "react";

import { AdminShell } from "@/components/admin-shell";
import { useAuth } from "@/components/auth-provider";
import { Card, EmptyState, ErrorBanner } from "@/components/ui";
import { ApiError, pecoxApi } from "@/lib/api";
import { formatDateTime } from "@/lib/materials";
import type { AdminUserItem, UserRole } from "@/lib/types";

export default function UsersPage() {
  const { user: currentUser } = useAuth();
  const [users, setUsers] = useState<AdminUserItem[]>([]);
  const [total, setTotal] = useState(0);
  const [roleFilter, setRoleFilter] = useState<UserRole | "">("");
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [updatingId, setUpdatingId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const loadUsers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const resp = await pecoxApi.listAdminUsers({
        role: roleFilter,
        search,
        limit: 50,
        offset: 0,
      });
      setUsers(resp.items);
      setTotal(resp.total);
    } catch (err) {
      setError(
        err instanceof ApiError
          ? err.detail
          : "No se pudo cargar el listado de usuarios."
      );
    } finally {
      setLoading(false);
    }
  }, [roleFilter, search]);

  useEffect(() => {
    void loadUsers();
  }, [loadUsers]);

  async function handleRoleChange(target: AdminUserItem, nextRole: UserRole) {
    setUpdatingId(target.id);
    setError(null);
    try {
      const updated = await pecoxApi.updateUserRole(target.id, nextRole);
      setUsers((prev) =>
        prev.map((item) => (item.id === updated.id ? updated : item))
      );
    } catch (err) {
      setError(
        err instanceof ApiError
          ? err.detail
          : "No se pudo actualizar el rol del usuario."
      );
    } finally {
      setUpdatingId(null);
    }
  }

  return (
    <AdminShell
      title="Gestión de usuarios"
      subtitle="Control de cuentas registradas, volumen de actividad y asignación de roles RBAC."
    >
      {error ? (
        <ErrorBanner message={error} onRetry={() => void loadUsers()} />
      ) : null}

      <Card>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div className="relative min-w-[240px] flex-1">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-[#556861]" />
            <input
              type="search"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Buscar usuario por nombre o correo..."
              className="w-full rounded-xl border border-[#dce7e2] bg-[#FAFCFB] py-2 pl-9 pr-3 text-xs text-[#17221E] focus:border-[#087D60] focus:bg-white"
            />
          </div>

          <select
            aria-label="Filtrar por rol"
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value as UserRole | "")}
            className="rounded-xl border border-[#dce7e2] bg-[#FAFCFB] px-3 py-2 text-xs font-medium text-[#17221E]"
          >
            <option value="">Todos los roles</option>
            <option value="user">Usuarios (user)</option>
            <option value="admin">Administradores (admin)</option>
          </select>

          <span className="text-xs font-medium text-[#556861] tabular-nums">
            {total} cuenta(s) encontradas
          </span>
        </div>
      </Card>

      <Card>
        {loading ? (
          <p className="py-10 text-center text-xs text-[#556861]">
            Cargando usuarios...
          </p>
        ) : users.length === 0 ? (
          <EmptyState
            title="No se encontraron usuarios"
            description="Ajusta el filtro de rol o la búsqueda por correo."
          />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead>
                <tr className="border-b border-[#dce7e2] text-[#556861]">
                  <th className="py-2.5 pr-4 font-semibold">Nombre</th>
                  <th className="py-2.5 pr-4 font-semibold">Correo</th>
                  <th className="py-2.5 pr-4 font-semibold">Rol</th>
                  <th className="py-2.5 pr-4 font-semibold">Clasificaciones</th>
                  <th className="py-2.5 pr-4 font-semibold">Registro</th>
                  <th className="py-2.5 font-semibold">Permisos</th>
                </tr>
              </thead>
              <tbody>
                {users.map((item) => {
                  const isSelf = currentUser?.id === item.id;
                  const nextRole: UserRole =
                    item.role === "admin" ? "user" : "admin";
                  return (
                    <tr
                      key={item.id}
                      className="border-b border-[#edf3f0] last:border-0"
                    >
                      <td className="py-3 pr-4 font-semibold text-[#17221E]">
                        {item.name}
                        {isSelf ? (
                          <span className="ml-2 rounded-full bg-[#E9FAF3] px-2 py-0.5 text-[10px] font-semibold text-[#087D60]">
                            Tu sesión
                          </span>
                        ) : null}
                      </td>
                      <td className="py-3 pr-4 text-[#556861]">{item.email}</td>
                      <td className="py-3 pr-4">
                        <span
                          className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[11px] font-semibold ${
                            item.role === "admin"
                              ? "bg-[#12382D] text-[#12C994]"
                              : "bg-slate-100 text-slate-700"
                          }`}
                        >
                          {item.role === "admin" ? (
                            <ShieldCheck className="h-3 w-3" />
                          ) : (
                            <UserCheck className="h-3 w-3" />
                          )}
                          {item.role}
                        </span>
                      </td>
                      <td className="py-3 pr-4 font-semibold tabular-nums">
                        {item.classifications_count}
                      </td>
                      <td className="py-3 pr-4 text-[#556861] tabular-nums">
                        {formatDateTime(item.created_at)}
                      </td>
                      <td className="py-3">
                        <button
                          type="button"
                          disabled={isSelf || updatingId === item.id}
                          onClick={() => void handleRoleChange(item, nextRole)}
                          className="rounded-lg border border-[#dce7e2] bg-white px-2.5 py-1 text-[11px] font-semibold text-[#12382D] hover:bg-[#E9FAF3] disabled:cursor-not-allowed disabled:opacity-40"
                        >
                          {updatingId === item.id
                            ? "Guardando..."
                            : item.role === "admin"
                            ? "Cambiar a user"
                            : "Promover a admin"}
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </Card>
    </AdminShell>
  );
}
