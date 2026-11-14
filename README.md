# PECOX Vision — AI-Powered Recycling Platform

Plataforma integral de clasificación asistida de residuos cotidianos (`plastic`, `glass`, `metal`, `cardboard`, `paper`, `other`) compuesta por **app móvil Flutter**, **backend REST FastAPI + PostgreSQL**, **pipeline de visión computacional PyTorch (`ResNet18`)**, **dashboard administrativo Next.js** y **orquestación Docker + GitHub Actions CI**.

---

## 1. Contexto, alcance y principio de honestidad

La separación de residuos suele fallar por dudas entre materiales y falta de preparación del envase (lavado, aplastado o descarte por contaminación). **PECOX Vision** resuelve primero la experiencia de usuario y la analítica operativa en software antes de añadir hardware físico en una fase futura:

- **Implementado (Fases 0–6):** prototipo UI/UX interactivo de 14 pantallas, app móvil Flutter conectada a la API real, backend FastAPI con JWT + RBAC + PostgreSQL/Alembic, modelo `ResNet18` entrenado y calibrado sobre TrashNet, dashboard administrativo Next.js y empaquetado Docker + auditorías de seguridad.
- **Reservado como Concepto futuro V3 (`iot/`):** sensores ultrasónicos/balanzas en máquinas RVM, telemetría de llenado y recompensas por depósitos físicamente verificados. Las pantallas de Máquinas y Alertas muestran explícitamente su estado **V3** sin telemetría ni cifras de CO₂ ficticias.

---

## 2. Arquitectura del sistema

```text
  [App Móvil Android — Flutter]        [PECOX Admin Web — Next.js 15]
        (apps/mobile, MVP 1.0)                 (apps/web, V2)
                \                                   /
                 \--------- HTTPS / REST ----------/
                                  |
                        [FastAPI Backend (/api/v1)]
                         /        |          \
                 [Auth/RBAC] [Classifications] [Admin/Stats]
                         \        |          /
                          +-------+---------+
                                  |
                         [PostgreSQL 16 + Alembic]

        FastAPI (/predict) ---> [PyTorch ResNet18 (ml/inference)]
        (V3 futuro) [ESP32 / RVM Hardware] ---> FastAPI
```

---

## 3. Stack tecnológico por capa

| Capa | Ubicación | Tecnologías |
|---|---|---|
| Prototipo UI/UX | [`src/`](./src) | React 19, Vite 8, TypeScript, Tailwind CSS v4 |
| App Móvil Android | [`apps/mobile/`](./apps/mobile) | Flutter, Material 3, `dio`, `flutter_secure_storage`, `image_picker` |
| Backend REST | [`services/api/`](./services/api) | Python 3.12+, FastAPI, Pydantic v2, SQLAlchemy 2, Alembic, PostgreSQL |
| Machine Learning | [`ml/`](./ml) | PyTorch, torchvision (`ResNet18`), scikit-learn, Pillow |
| Dashboard Web Admin | [`apps/web/`](./apps/web) | Next.js 15, React 19, TypeScript, Tailwind CSS v4, Motion, Lucide, Vitest |
| Infraestructura y CI | [`infrastructure/`](./infrastructure), [`.github/workflows/`](./.github/workflows) | Docker Compose, GitHub Actions, Ruff, Pytest, Bandit, `pip-audit`, `pnpm audit` |

---

## 4. Métricas reales del modelo ML (`resnet18-trashnet-v1.0.0`)

Entrenamiento y evaluación reproducible sobre **TrashNet** deduplicado mediante SHA-256 (`2,524` imágenes únicas de `2,527` válidas, `0` fuga entre splits `train=1,803 / val=360 / test=361`):

| Métrica (split `test`, `n=361`) | Resultado medido |
|---|---|
| **Accuracy global** | **89.75%** |
| **Macro F1** | **0.8881** (`Macro Precision 0.8805`, `Macro Recall 0.9019`) |
| **Gating por confianza (`>= 0.50`)** | **91.97% cobertura** · **92.77% accuracy** sobre predicciones identificadas |
| **Latencia CPU (50 muestras)** | **41.01 ms** (P50) · **42.96 ms** (P95) |

Limitación documentada: TrashNet contiene objetos individuales sobre fondo controlado y presenta confusión visual ocasional entre vidrio transparente (`glass`, recall `79.17%`) y metal reflectivo (`metal`). Por ello, PECOX integra umbrales de incertidumbre (`>= 0.50` identificado, `0.35–0.49` baja confianza, `< 0.35` desconocido) y corrección manual persistida en base de datos. Consulta [`ml/evaluation/reports/metrics.json`](./ml/evaluation/reports/metrics.json) y [`ml/README.md`](./ml/README.md).

---

## 5. Ejecución local y Docker

### Opción A — Docker Compose (`PostgreSQL + FastAPI + PECOX Admin`)

```bash
cp .env.example .env
# En producción, usa .env.production.example y docker-compose.prod.yml (con Caddy TLS e inferencia PyTorch CPU)
docker compose up --build
```

Para despliegue productivo con TLS automático, contenedor ML (`api.ml.Dockerfile`) y compilación de APK móvil con `--dart-define=PECOX_API_URL`, consulta [`infrastructure/README.md`](./infrastructure/README.md).

- API FastAPI: `http://localhost:8000` (`/health`, `/docs`)
- Dashboard Web Admin: `http://localhost:3000`

### Opción B — Desarrollo por módulo

- **Backend API (`services/api`):**
  ```bash
  cd services/api
  uv sync
  uv run alembic upgrade head
  uv run uvicorn app.main:app --reload --port 8000
  ```
- **Dashboard Web (`apps/web`):**
  ```bash
  cd apps/web
  pnpm install
  pnpm dev   # http://localhost:3000
  ```
- **App Móvil Flutter (`apps/mobile`):**
  ```bash
  cd apps/mobile
  flutter pub get
  flutter run --dart-define=PECOX_API_URL=http://10.0.2.2:8000/api/v1
  ```

---

## 6. Verificación y pruebas automatizadas

| Módulo | Comandos de verificación |
|---|---|
| Prototipo (`src/`) | `pnpm exec tsc --noEmit` · `pnpm build` |
| Backend (`services/api`) | `uv run ruff check app tests alembic` · `uv run pytest -v` |
| ML (`ml/`) | `uv run ruff check .` · `uv run pytest -v` |
| Móvil (`apps/mobile`) | `flutter analyze` · `flutter test` |
| Web Admin (`apps/web`) | `pnpm typecheck` · `pnpm lint` · `pnpm test` · `pnpm build` |
| Seguridad | `uvx bandit -r app -ll` · `uvx pip-audit --local` · `pnpm audit --prod` |

---

## 7. Roadmap

- [x] **Fase 0** — Especificación (SRS, arquitectura, ADR-0001, OpenAPI draft, design system) y prototipo interactivo de 14 pantallas.
- [x] **Fase 1** — App móvil Flutter con flujos completos y pruebas de widget.
- [x] **Fase 2** — Backend FastAPI, JWT, RBAC, PostgreSQL y migraciones Alembic.
- [x] **Fase 3** — Dataset auditado (TrashNet), entrenamiento `ResNet18`, calibración de umbrales y servicio `/api/v1/predict`.
- [x] **Fase 4** — Integración end-to-end Flutter ↔ FastAPI ↔ PyTorch (MVP 1.0).
- [x] **Fase 5** — Dashboard Web administrativo Next.js + endpoints V2 de analítica y RBAC.
- [x] **Fase 6** — Endurecimiento de seguridad, contenedores Docker no-root, CI y documentación de portafolio.
- [ ] **Fase 7** — Hardware RVM físico e integración IoT autenticado (V3 opcional).

---

## 8. Documentación técnica y licencias

- [SRS](./docs/requirements/srs.md) · [Arquitectura](./docs/architecture/system.md) · [ADR-0001](./docs/architecture/adr/0001-modular-monolith-and-mobile-first.md)
- [Design System](./docs/ui-ux/design-system.md) · [Pantallas](./docs/ui-ux/screens.md) · [OpenAPI Draft](./docs/api/openapi-draft.md)
- [Infraestructura Docker](./infrastructure/README.md) · [Política de Seguridad](./SECURITY.md) · [Guía de Contribución](./CONTRIBUTING.md)
- **Licencia del código:** [MIT](./LICENSE). La referencia estética de Dribbble y el dataset TrashNet se utilizan únicamente bajo atribución e investigación conforme a sus términos originales.
