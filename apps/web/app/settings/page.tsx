"use client";

import { KeyRound, LogOut, Server, ShieldCheck } from "lucide-react";
import { useRouter } from "next/navigation";

import { AdminShell } from "@/components/admin-shell";
import { useAuth } from "@/components/auth-provider";
import { Card } from "@/components/ui";
import { API_BASE_URL } from "@/lib/api";
import { formatDateTime } from "@/lib/materials";

export default function SettingsPage() {
  const router = useRouter();
  const { user, logout } = useAuth();

  return (
    <AdminShell
      title="Configuración y sesión"
      subtitle="Información de la cuenta administradora activa y parámetros de conexión."
    >
      <div className="grid gap-6 lg:grid-cols-2">
        <Card className="space-y-4">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#E9FAF3] text-[#087D60]">
              <ShieldCheck className="h-5 w-5" />
            </div>
            <div>
              <h2 className="text-sm font-bold text-[#17221E]">
                Perfil administrador
              </h2>
              <p className="text-xs text-[#556861]">
                Sesión autenticada con el servidor
              </p>
            </div>
          </div>

          {user ? (
            <dl className="space-y-2.5 text-xs">
              <div className="flex justify-between border-b border-[#edf3f0] pb-2">
                <dt className="text-[#556861]">Nombre</dt>
                <dd className="font-semibold text-[#17221E]">{user.name}</dd>
              </div>
              <div className="flex justify-between border-b border-[#edf3f0] pb-2">
                <dt className="text-[#556861]">Correo</dt>
                <dd className="font-semibold text-[#17221E]">{user.email}</dd>
              </div>
              <div className="flex justify-between border-b border-[#edf3f0] pb-2">
                <dt className="text-[#556861]">Rol de cuenta</dt>
                <dd className="font-mono font-bold text-[#087D60]">
                  {user.role}
                </dd>
              </div>
              <div className="flex justify-between">
                <dt className="text-[#556861]">Cuenta creada</dt>
                <dd className="text-[#17221E]">
                  {formatDateTime(user.created_at)}
                </dd>
              </div>
            </dl>
          ) : null}
        </Card>

        <Card className="space-y-4">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#12382D] text-[#12C994]">
              <Server className="h-5 w-5" />
            </div>
            <div>
              <h2 className="text-sm font-bold text-[#17221E]">
                Entorno y seguridad
              </h2>
              <p className="text-xs text-[#556861]">
                Sesión efímera almacenada en sessionStorage del navegador
              </p>
            </div>
          </div>

          <div className="rounded-xl border border-[#dce7e2] bg-[#FAFCFB] p-3 text-xs">
            <p className="text-[#556861]">URL del servidor</p>
            <code className="mt-1 block break-all font-mono font-semibold text-[#12382D]">
              {API_BASE_URL}
            </code>
          </div>

          <div className="flex items-start gap-2.5 rounded-xl bg-[#E9FAF3]/60 p-3 text-xs text-[#12382D]">
            <KeyRound className="mt-0.5 h-4 w-4 shrink-0 text-[#087D60]" />
            <span>
              Los tokens de acceso se renuevan automáticamente con{" "}
              <code className="font-mono">/auth/refresh</code> cuando expira el
              access token y se eliminan al cerrar sesión o cerrar la pestaña.
            </span>
          </div>

          <button
            type="button"
            onClick={() => {
              logout();
              router.push("/login");
            }}
            className="inline-flex items-center gap-2 rounded-xl border border-rose-200 bg-rose-50 px-4 py-2 text-xs font-semibold text-rose-800 hover:bg-rose-100"
          >
            <LogOut className="h-3.5 w-3.5" />
            Cerrar sesión administrativa
          </button>
        </Card>
      </div>
    </AdminShell>
  );
}
