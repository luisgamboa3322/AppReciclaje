# PECOX Admin Web Dashboard (Next.js)

> **Estado:** **Fase 5 (V2)** implementada — conectada en vivo al backend FastAPI (`/api/v1/*`) con RBAC de administrador (`role = "admin"`).

## Stack implementado

- **Next.js 15 (App Router)** + **React 19** + **TypeScript**
- **Tailwind CSS v4** + tokens de marca PECOX Eco-Tech (`#12382D`, `#087D60`, `#12C994`, `#E9FAF3`, `#FAFCFB`)
- **Motion (`motion/react`)** respetando `reducedMotion="user"`
- **Lucide React** + **Zod** + **Vitest** / **Testing Library**

## Vistas implementadas

- `/login`: Autenticación JWT contra `POST /api/v1/auth/login` con verificación de rol `admin` y auto-refresh en `401`.
- `/`: Resumen operativo con KPIs reales, modelo ML activo (`/api/v1/model/info`), distribución por material, serie de últimos 7 días y clasificaciones recientes.
- `/classifications`: Auditoría global paginada con filtros por material, solo corregidas y búsqueda por usuario/modelo, inspector de detalle y exportación CSV.
- `/users`: Listado de cuentas registradas, conteo real de clasificaciones y cambio de rol `user` <-> `admin`.
- `/analytics`: Proporciones reales por categoría/contenedor y descarga CSV.
- `/models`: Estado del predictor PyTorch en vivo + reporte auditado offline (`accuracy`, `macro_f1`, latencia CPU P50/P95, tabla por clase y matriz de confusión 6x6).
- `/machines` y `/alerts`: Marcadas explícitamente como **Concepto futuro (V3)** sin datos ni telemetría simulada.
- `/settings`: Perfil administrador, URL de API y cierre de sesión.

## Comandos locales

```bash
cd apps/web
pnpm install
pnpm dev        # http://localhost:3000
pnpm typecheck  # tsc --noEmit
pnpm lint       # eslint .
pnpm test       # vitest run
pnpm build      # next build
```

Asegúrate de tener `services/api` corriendo en `http://localhost:8000` (o configura `NEXT_PUBLIC_API_BASE_URL` en `apps/web/.env.local`).
