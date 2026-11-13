# Arquitectura del Sistema — PECOX Vision

## 1. Estilo arquitectónico

PECOX Vision adopta un **monolito modular con API REST** (`/api/v1`) y un módulo de inferencia ML encapsulado en el mismo servicio backend. Esta decisión evita la complejidad operativa prematura de microservicios o Kubernetes durante el MVP y facilita el despliegue reproducible.

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
                      (usuarios, registros, guías)

        FastAPI -- inference --> [ml/inference (PyTorch ResNet18)]

        (V3) [ESP32 / Sensores] -- eventos autenticados --> FastAPI
```

---

## 2. Organización por capas

### Cliente móvil (`apps/mobile/` — Fase 1)
Arquitectura **feature-first**:
- `lib/core/`: tema PECOX, tokens, router (`go_router`), cliente HTTP (`dio`), almacenamiento seguro (`flutter_secure_storage`).
- `lib/features/{auth,home,scanner,result,history,guides,profile}/`: capas separadas de presentación (widgets), estado (`flutter_riverpod`) y datos (repositorios).

### Backend (`services/api/` — Fase 2)
Capas desacopladas dentro de FastAPI:
- `app/api/`: routers HTTP y dependencias de autenticación.
- `app/schemas/`: contratos Pydantic de entrada y salida.
- `app/services/`: reglas de negocio (umbral de incertidumbre, validación de propiedad).
- `app/repositories/`: acceso a datos con SQLAlchemy.
- `app/models/`: entidades ORM y migraciones Alembic.
- `ml/inference/`: carga única del modelo PyTorch en memoria por proceso y preprocesamiento determinista.

### Dashboard web (`apps/web/` — Fase 5)
- Next.js + TypeScript + Tailwind CSS + shadcn/ui + Motion for React.
- Consume exactamente la misma API REST `/api/v1` con permisos administrativos.

---

## 3. Modelo de datos inicial (Fase 2)

- **`users`**: `id`, `name`, `email` (único), `password_hash`, `role`, `created_at`, `updated_at`.
- **`classifications`**: `id`, `user_id` (FK), `predicted_material`, `confidence`, `confirmed_material`, `model_version`, `created_at`, `updated_at`.
- **`model_versions`**: `id`, `version`, `architecture`, `metrics_location`, `created_at`, `is_active`.
- **`material_guides`**: `id`, `material_key`, `title`, `instructions`, `updated_at`.
- **Tablas V3 futuras**: `machines`, `sensor_events`, `deposits`, `rewards`, `maintenance_alerts`.

---

## 4. Convenciones transversales

- **Versionado:** todas las rutas de negocio cuelgan de `/api/v1`, manteniendo `/health` en raíz.
- **Tiempos:** almacenamiento en UTC en servidor y base de datos; formateo local solo en el cliente.
- **Trazabilidad:** inclusión de `request_id` por petición y manejo uniforme de errores JSON.
- **Privacidad:** sin imágenes completas ni tokens JWT en logs.
