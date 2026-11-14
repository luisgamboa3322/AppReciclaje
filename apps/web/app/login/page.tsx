"use client";

import { AlertCircle, Eye, EyeOff, Lock, Mail, Recycle } from "lucide-react";
import { useRouter } from "next/navigation";
import { type FormEvent, useEffect, useState } from "react";
import { z } from "zod";

import { useAuth } from "@/components/auth-provider";
import { API_BASE_URL, ApiError } from "@/lib/api";

const loginSchema = z.object({
  email: z.string().email("Ingresa un correo electrónico válido."),
  password: z.string().min(1, "Ingresa tu contraseña."),
});

export default function LoginPage() {
  const router = useRouter();
  const { isAuthenticated, isAdmin, login } = useAuth();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  useEffect(() => {
    if (isAuthenticated && isAdmin) {
      router.replace("/");
    }
  }, [isAuthenticated, isAdmin, router]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setErrorMsg(null);

    const parsed = loginSchema.safeParse({ email, password });
    if (!parsed.success) {
      const firstIssue = parsed.error.issues[0];
      setErrorMsg(firstIssue?.message ?? "Revisa los campos ingresados.");
      return;
    }

    setSubmitting(true);
    try {
      const user = await login(parsed.data.email, parsed.data.password);
      if (user.role !== "admin") {
        setErrorMsg(
          `La cuenta ${user.email} tiene rol "${user.role}". Se requiere rol "admin" para ingresar al panel.`
        );
        return;
      }
      router.push("/");
    } catch (err) {
      if (err instanceof ApiError) {
        setErrorMsg(err.detail);
      } else {
        setErrorMsg(
          "No fue posible conectar con el servidor de PECOX API. Verifica que FastAPI esté activo."
        );
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="flex min-h-screen flex-col justify-center bg-[#FAFCFB] px-4 py-12 sm:px-6">
      <div className="mx-auto w-full max-w-md rounded-3xl border border-[#dce7e2] bg-white p-7 shadow-sm sm:p-8">
        <div className="flex items-center gap-3">
          <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-[#12382D] text-[#12C994]">
            <Recycle className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-xl font-bold tracking-tight text-[#17221E]">
              PECOX Admin
            </h1>
            <p className="text-xs text-[#556861]">
              Consola Operativa y Analítica V2
            </p>
          </div>
        </div>

        <p className="mt-5 text-sm leading-relaxed text-[#556861]">
          Inicia sesión con una cuenta de administrador registrada en{" "}
          <span className="font-medium text-[#17221E]">PECOX API</span> para
          auditar clasificaciones, usuarios y métricas del modelo ML.
        </p>

        {errorMsg ? (
          <div
            role="alert"
            className="mt-5 flex items-start gap-2.5 rounded-xl border border-rose-200 bg-rose-50 px-3.5 py-3 text-xs font-medium text-rose-900"
          >
            <AlertCircle className="mt-0.5 h-4 w-4 shrink-0 text-rose-600" />
            <span>{errorMsg}</span>
          </div>
        ) : null}

        <form onSubmit={handleSubmit} className="mt-6 space-y-4" noValidate>
          <div>
            <label
              htmlFor="email"
              className="block text-xs font-semibold text-[#17221E]"
            >
              Correo institucional o administrador
            </label>
            <div className="relative mt-1.5">
              <Mail className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-[#556861]" />
              <input
                id="email"
                name="email"
                type="email"
                autoComplete="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@pecox.dev"
                className="w-full rounded-xl border border-[#dce7e2] bg-[#FAFCFB] py-2.5 pl-10 pr-3.5 text-sm text-[#17221E] focus:border-[#087D60] focus:bg-white"
              />
            </div>
          </div>

          <div>
            <label
              htmlFor="password"
              className="block text-xs font-semibold text-[#17221E]"
            >
              Contraseña
            </label>
            <div className="relative mt-1.5">
              <Lock className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-[#556861]" />
              <input
                id="password"
                name="password"
                type={showPassword ? "text" : "password"}
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full rounded-xl border border-[#dce7e2] bg-[#FAFCFB] py-2.5 pl-10 pr-10 text-sm text-[#17221E] focus:border-[#087D60] focus:bg-white"
              />
              <button
                type="button"
                aria-label={
                  showPassword ? "Ocultar contraseña" : "Mostrar contraseña"
                }
                onClick={() => setShowPassword((prev) => !prev)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-[#556861] hover:text-[#17221E]"
              >
                {showPassword ? (
                  <EyeOff className="h-4 w-4" />
                ) : (
                  <Eye className="h-4 w-4" />
                )}
              </button>
            </div>
          </div>

          <button
            type="submit"
            disabled={submitting}
            className="w-full rounded-xl bg-[#12382D] py-2.5 text-sm font-semibold text-white transition hover:bg-[#087D60] disabled:cursor-not-allowed disabled:opacity-60"
          >
            {submitting ? "Ingresando..." : "Ingresar al panel"}
          </button>
        </form>

        <div className="mt-6 rounded-xl border border-[#edf3f0] bg-[#FAFCFB] px-3.5 py-2.5 text-[11px] text-[#556861]">
          Endpoint conectado:{" "}
          <code className="font-mono text-[#12382D]">{API_BASE_URL}</code>
        </div>
      </div>
    </div>
  );
}
