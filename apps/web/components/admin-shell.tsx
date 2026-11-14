"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  Activity,
  BarChart3,
  Bell,
  Cpu,
  LayoutDashboard,
  ListChecks,
  LogOut,
  Menu,
  Recycle,
  ServerCog,
  Settings,
  ShieldAlert,
  Users,
  X,
} from "lucide-react";
import { useEffect, useState } from "react";

import { useAuth } from "@/components/auth-provider";

interface NavItem {
  href: string;
  label: string;
  icon: React.ComponentType<{ className?: string }>;
  badge?: string;
}

const NAV_ITEMS: NavItem[] = [
  { href: "/", label: "Resumen", icon: LayoutDashboard },
  { href: "/classifications", label: "Clasificaciones", icon: ListChecks },
  { href: "/users", label: "Usuarios", icon: Users },
  { href: "/analytics", label: "Analítica", icon: BarChart3 },
  { href: "/models", label: "Modelos ML", icon: Cpu },
  { href: "/machines", label: "Máquinas", icon: ServerCog, badge: "Pronto" },
  { href: "/alerts", label: "Alertas", icon: Bell, badge: "Pronto" },
  { href: "/settings", label: "Configuración", icon: Settings },
];

export function AdminShell({
  title,
  subtitle,
  actions,
  children,
}: {
  title: string;
  subtitle: string;
  actions?: React.ReactNode;
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const router = useRouter();
  const { user, isLoading, isAuthenticated, isAdmin, logout } = useAuth();
  const [mobileNavOpen, setMobileNavOpen] = useState(false);

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.replace("/login");
    }
  }, [isLoading, isAuthenticated, router]);

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-[#FAFCFB]">
        <div className="flex items-center gap-3 rounded-2xl border border-[#dce7e2] bg-white px-5 py-3 text-sm font-medium text-[#12382D] shadow-sm">
          <Activity className="h-4 w-4 animate-spin text-[#087D60]" />
          Verificando sesión de administrador...
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return null;
  }

  if (!isAdmin) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-[#FAFCFB] p-6">
        <div className="max-w-md rounded-2xl border border-rose-200 bg-white p-6 shadow-sm">
          <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-rose-50 text-rose-700">
            <ShieldAlert className="h-6 w-6" />
          </div>
          <h1 className="mt-4 text-lg font-bold text-[#17221E]">
            Acceso restringido a administradores
          </h1>
          <p className="mt-2 text-sm leading-relaxed text-[#556861]">
            Has iniciado sesión como{" "}
            <span className="font-semibold text-[#17221E]">{user?.email}</span>{" "}
            con rol <code className="rounded bg-slate-100 px-1.5 py-0.5">{user?.role}</code>.
            El panel PECOX Admin requiere permisos de rol{" "}
            <code className="rounded bg-slate-100 px-1.5 py-0.5">admin</code>.
          </p>
          <div className="mt-5 flex gap-3">
            <button
              type="button"
              onClick={() => {
                logout();
                router.push("/login");
              }}
              className="rounded-xl bg-[#12382D] px-4 py-2 text-sm font-semibold text-white hover:bg-[#087D60]"
            >
              Cambiar de cuenta
            </button>
          </div>
        </div>
      </div>
    );
  }

  const sidebarContent = (
    <div className="flex h-full flex-col justify-between bg-[#12382D] p-4 text-white">
      <div>
        <Link
          href="/"
          className="flex items-center gap-3 rounded-xl px-2 py-2.5 hover:bg-white/5"
          onClick={() => setMobileNavOpen(false)}
        >
          <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-[#12C994] text-[#12382D]">
            <Recycle className="h-5 w-5" />
          </div>
          <div>
            <p className="text-sm font-bold tracking-tight">PECOX Admin</p>
            <p className="text-[11px] text-emerald-200/80">
              Gestión Operativa
            </p>
          </div>
        </Link>

        <nav className="mt-6 space-y-1" aria-label="Navegación principal">
          {NAV_ITEMS.map((item) => {
            const Icon = item.icon;
            const active =
              item.href === "/"
                ? pathname === "/"
                : pathname.startsWith(item.href);
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setMobileNavOpen(false)}
                className={`flex items-center justify-between rounded-xl px-3 py-2.5 text-sm font-medium transition-colors ${
                  active
                    ? "bg-[#12C994] text-[#12382D] font-semibold"
                    : "text-emerald-50/85 hover:bg-white/10 hover:text-white"
                }`}
              >
                <span className="flex items-center gap-2.5">
                  <Icon className="h-4 w-4 shrink-0" />
                  {item.label}
                </span>
                {item.badge ? (
                  <span
                    className={`rounded-full px-1.5 py-0.5 text-[10px] font-bold ${
                      active
                        ? "bg-[#12382D]/15 text-[#12382D]"
                        : "bg-white/15 text-emerald-100"
                    }`}
                  >
                    {item.badge}
                  </span>
                ) : null}
              </Link>
            );
          })}
        </nav>
      </div>

      <div className="border-t border-white/10 pt-4">
        <div className="rounded-xl bg-white/5 px-3 py-2.5">
          <p className="truncate text-xs font-semibold text-white">
            {user?.name}
          </p>
          <p className="truncate text-[11px] text-emerald-200/80">
            {user?.email}
          </p>
        </div>
        <button
          type="button"
          onClick={() => {
            logout();
            router.push("/login");
          }}
          className="mt-2.5 flex w-full items-center justify-center gap-2 rounded-xl border border-white/15 px-3 py-2 text-xs font-semibold text-emerald-50 hover:bg-white/10"
        >
          <LogOut className="h-3.5 w-3.5" />
          Cerrar sesión
        </button>
      </div>
    </div>
  );

  return (
    <div className="flex min-h-screen bg-[#FAFCFB] text-[#17221E]">
      {/* Desktop persistent sidebar */}
      <aside className="hidden w-64 shrink-0 lg:block">{sidebarContent}</aside>

      {/* Mobile drawer */}
      {mobileNavOpen ? (
        <div className="fixed inset-0 z-50 flex lg:hidden">
          <div className="w-72 max-w-[85vw]">{sidebarContent}</div>
          <button
            type="button"
            aria-label="Cerrar menú"
            className="flex-1 bg-black/40"
            onClick={() => setMobileNavOpen(false)}
          />
        </div>
      ) : null}

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="sticky top-0 z-30 border-b border-[#dce7e2] bg-white/95 backdrop-blur">
          <div className="mx-auto flex max-w-7xl flex-wrap items-center justify-between gap-4 px-4 py-4 sm:px-6">
            <div className="flex items-center gap-3">
              <button
                type="button"
                aria-label="Abrir navegación"
                onClick={() => setMobileNavOpen((prev) => !prev)}
                className="flex h-9 w-9 items-center justify-center rounded-xl border border-[#dce7e2] text-[#12382D] lg:hidden"
              >
                {mobileNavOpen ? (
                  <X className="h-4 w-4" />
                ) : (
                  <Menu className="h-4 w-4" />
                )}
              </button>
              <div>
                <h1 className="text-lg font-bold tracking-tight text-[#17221E] sm:text-xl">
                  {title}
                </h1>
                <p className="text-xs text-[#556861]">{subtitle}</p>
              </div>
            </div>
            {actions ? <div className="flex items-center gap-2">{actions}</div> : null}
          </div>
        </header>

        <main className="mx-auto w-full max-w-7xl flex-1 space-y-6 p-4 sm:p-6">
          {children}
        </main>
      </div>
    </div>
  );
}
