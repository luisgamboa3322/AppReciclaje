# PECOX Vision — AI-Powered Recycling Platform

> **Estado actual:** **Fase 0 completada + Prototipo UI/UX interactivo completo (14 pantallas)**.  
> Los módulos de Flutter (`apps/mobile`), backend FastAPI (`services/api`), modelo PyTorch (`ml`), dashboard web Next.js (`apps/web`) e IoT (`iot`) se encuentran planificados para las siguientes fases y **aún no están implementados**.

---

## 1. Contexto y problemática

La separación correcta de residuos cotidianos suele fallar por desconocimiento de las categorías (`plástico`, `vidrio`, `metal`, `cartón`, `papel`, `otros`) y de cómo preparar los envases antes de desecharlos. **PECOX Vision** aborda el problema mediante una plataforma de software independiente —primero móvil y luego web— antes de integrar conectividad física con una máquina experimental en una fase posterior.

**Principio de honestidad del producto:**
- Identificar un material por fotografía **no certifica** su reciclabilidad en todos los programas municipales ni equivale a un depósito físico verificado.
- El prototipo actual etiqueta explícitamente los resultados de demostración y las vistas futuras (V2/V3) sin fingir predicciones ML, ahorros de CO₂ o telemetría real.

---

## 2. Lo que ya funciona en este repositorio

1. **Prototipo interactivo UI/UX (`src/`):**
   - Cubre las **14 pantallas** del brief (`UI-01` Splash hasta `UI-14` Conceptos futuros V3) con inspector lateral en escritorio para navegar entre vistas y simular estados transversales (`sin conexión`, `cámara denegada`, `imagen inválida`, `modelo ML caído`, `baja confianza`, `historial vacío`, `texto grande`, `reducir movimiento`).
2. **Documentación técnica de Fase 0 (`docs/`):**
   - [Especificación de Requerimientos (SRS)](./docs/requirements/srs.md)
   - [Arquitectura del Sistema](./docs/architecture/system.md) y [ADR-0001](./docs/architecture/adr/0001-modular-monolith-and-mobile-first.md)
   - [Design System](./docs/ui-ux/design-system.md) y [Especificación de Pantallas](./docs/ui-ux/screens.md)
   - [Borrador de contratos API](./docs/api/openapi-draft.md)
   - [Plan de Pruebas y Calidad](./docs/testing/test-plan.md)
3. **CI del prototipo (`.github/workflows/prototype-ci.yml`):**
   - Ejecuta `pnpm exec tsc --noEmit` y `pnpm build`.

---

## 3. Arquitectura objetivo

```text
  [App Móvil Android — Flutter]        [Dashboard Web — Next.js (V2)]
                \                                   /
                 \--------- HTTPS + REST ----------/
                                  |
                        [FastAPI Backend (/api/v1)]
                         /        |         \
                 [Auth/RBAC] [Clasificaciones] [Analytics]
                         \        |         /
                          +-------+--------+
                                  |
                            [PostgreSQL]

        FastAPI -- inference --> [PyTorch Model (ml/inference)]

        (V3) [ESP32 / Sensores] -- eventos autenticados --> FastAPI
```

---

## 4. Stack tecnológico previsto

- **Prototipo UI/UX (actual):** React 19, Vite 8, TypeScript 5.7, Tailwind CSS v4.
- **Móvil (Fase 1):** Flutter, Material 3, `flutter_riverpod`, `go_router`, `dio`, `camera`, `image_picker`, `flutter_secure_storage`.
- **Backend (Fase 2):** Python, FastAPI, Pydantic, SQLAlchemy, Alembic, PostgreSQL.
- **Machine Learning (Fase 3):** PyTorch, torchvision (baseline ResNet18), scikit-learn, Pillow.
- **Web Admin (Fase 5 / V2):** Next.js, TypeScript, Tailwind CSS, shadcn/ui, Motion for React, TanStack Query/Table, Recharts, Playwright.

---

## 5. Ejecución local del prototipo actual

Requisitos: Node.js 22+ y `pnpm`.

```bash
pnpm install --frozen-lockfile
pnpm dev
```

Validación de tipos y build de producción:

```bash
pnpm exec tsc --noEmit
pnpm build
```

Para la futura configuración de entorno local de backend/web, consulta [`.env.example`](./.env.example).

---

## 6. Estructura del repositorio

```text
AppReciclaje/
├── src/                    # Prototipo interactivo UI/UX (React + Vite + Tailwind v4)
├── apps/
│   ├── mobile/             # App Android Flutter (Fase 1)
│   └── web/                # Dashboard administrativo Next.js (Fase 5)
├── services/
│   └── api/                # Backend REST FastAPI + Alembic (Fase 2)
├── ml/                     # Datasets (manifiestos), entrenamiento y evaluación PyTorch (Fase 3)
├── iot/                    # Firmware y protocolos de máquina recicladora V3 (Fase 7)
├── docs/                   # SRS, arquitectura, ADR, UI/UX, OpenAPI draft y plan de pruebas
├── infrastructure/         # Docker y guías de despliegue
├── .github/workflows/      # Flujos de CI
├── .env.example            # Plantilla de variables sin secretos reales
├── SECURITY.md             # Política de seguridad y privacidad
├── CONTRIBUTING.md         # Convenciones de commits y DoD
└── LICENSE                 # MIT
```

---

## 7. Roadmap por fases

- [x] **Fase 0 — Análisis, planificación, estructura del repositorio y prototipo UI/UX completo**
- [ ] **Fase 1 — App móvil Flutter (`apps/mobile`)**
- [ ] **Fase 2 — Backend FastAPI + PostgreSQL + Alembic (`services/api`)**
- [ ] **Fase 3 — Entrenamiento y evaluación de modelo PyTorch (`ml`)**
- [ ] **Fase 4 — Integración end-to-end móvil + API + ML (MVP 1.0)**
- [ ] **Fase 5 — Dashboard administrativo Next.js (`apps/web`, V2)**
- [ ] **Fase 6 — DevOps, revisión de seguridad, accesibilidad y release de portafolio**
- [ ] **Fase 7 — Prototipo físico e integración IoT (`iot`, V3 opcional)**

---

## 8. Atribuciones y limitaciones

- **Inspiración estética:** dirección visual inspirada en [*Garbage Recycling app design mobile app* — LazyInterface UI UX Team (Dribbble)](https://dribbble.com/shots/22225493-Garbage-Recycling-app-design-mobile-app), interpretada con identidad original de **PECOX Vision** sin copiar activos protegidos.
- **Limitación actual:** no hay un modelo ML conectado todavía ni persistencia en base de datos; todas las clasificaciones y estadísticas del prototipo corresponden a datos de sesión demostrativos.
