# PECOX Vision Backend API (FastAPI + PostgreSQL + Alembic)

> **Estado:** **Fase 2 implementada** (Auth JWT/Argon2, RBAC, CRUD de clasificaciones, guías de materiales, migraciones Alembic y pruebas Pytest).  
> El endpoint `POST /api/v1/predict` valida archivos e imágenes y responde `503` honestamente hasta conectar el modelo PyTorch en la **Fase 3**.

## Estructura implementada (`services/api/`)

- `app/core/`: configuración (`pydantic-settings`), seguridad (`Argon2` + `PyJWT`), SQLAlchemy `Base`/sesiones y middleware de `request_id`.
- `app/models/`: `User`, `Classification`, `ModelVersion`, `MaterialGuide`.
- `app/schemas/`: contratos Pydantic `/api/v1`.
- `app/repositories/` y `app/services/`: acceso a datos y reglas de negocio (propiedad por recurso).
- `app/api/`: `/health`, `/api/v1/auth/*`, `/api/v1/users/me`, `/api/v1/classifications/*`, `/api/v1/guides`, `/api/v1/model/info`, `/api/v1/predict`.
- `alembic/`: esquema inicial `0001_initial_schema.py`.
- `tests/`: pruebas Pytest + FastAPI `TestClient` (auth, refresh, ownership 403, CRUD, guías y validación de imagen).

## Ejecución local

```bash
cd services/api
uv sync
uv run alembic upgrade head
uv run uvicorn app.main:app --reload
```

Pruebas y linting:

```bash
cd services/api
uv run ruff check app tests
uv run pytest -v
```
