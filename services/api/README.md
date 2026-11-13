# PECOX Vision Backend API (FastAPI + PostgreSQL)

> **Estado:** Planificado para **Fase 2**.

## Estructura objetivo (`services/api/`)

- `app/api/`: routers `/api/v1` y `/health`
- `app/core/`: configuración, logs con `request_id`, JWT/RBAC
- `app/models/`: modelos SQLAlchemy (`users`, `classifications`, `model_versions`, `material_guides`)
- `app/schemas/`: validación Pydantic
- `app/services/`: reglas de negocio e integración con `ml/inference`
- `app/repositories/`: persistencia PostgreSQL
- `alembic/`: migraciones de base de datos
- `tests/`: pruebas unitarias y de integración (`pytest` + `httpx`)
