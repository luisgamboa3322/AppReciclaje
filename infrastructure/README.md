# Infraestructura y Despliegue — PECOX Vision

## 0. Entorno local (`docker-compose.yml`)

```bash
cp .env.example .env
docker compose up --build
```

Expone PostgreSQL (`localhost:5432`), FastAPI (`http://localhost:8000`) y PECOX Admin (`http://localhost:3000`) con usuarios no-root (`pecox` / `nextjs`) y healthchecks integrados.

## 1. Preparar variables y modelo ML en el servidor

1. Copia `.env.production.example` a `.env` en la raíz del repositorio y completa `POSTGRES_PASSWORD`, `JWT_SECRET_KEY` (>= 32 caracteres aleatorios), `API_DOMAIN`, `WEB_DOMAIN`, `CORS_ORIGINS` y `NEXT_PUBLIC_API_BASE_URL`.
2. Asegúrate de tener presentes los artefactos del modelo en `ml/artifacts/` (`best_checkpoint.pt` y `model_metadata.json`). El contenedor `api` los monta en solo lectura (`/repo/ml/artifacts:ro`) con PyTorch CPU.

## 2. Levantar stack completo con TLS (PostgreSQL + API ML + Web Admin + Caddy)

```bash
docker compose --env-file .env -f docker-compose.prod.yml up -d --build
```

Notas de seguridad de `docker-compose.prod.yml`:
- PostgreSQL **no** expone puertos al exterior del host Docker.
- Caddy gestiona certificados HTTPS automáticamente y limita cuerpos de subida a `12MB`.
- FastAPI valida en arranque que `APP_ENV=production` no use claves JWT por defecto.

Para crear el primer usuario administrador en producción:

```bash
docker compose -f docker-compose.prod.yml exec api python -m app.seed
```

> Cambia o elimina los usuarios seed de demostración antes de abrir registro público.

## 3. Compilar APK de Android para producción

La app móvil lee la URL base mediante `--dart-define=PECOX_API_URL=...` (`apps/mobile/lib/core/config/api_config.dart`):

```bash
cd apps/mobile
flutter build apk --release --dart-define=PECOX_API_URL=https://api.tu-dominio.com/api/v1
```

## 4. Ciclo continuo de mejora del modelo con datos reales

1. Exporta métricas agregadas de correcciones desde producción:
   ```bash
   PYTHONPATH=. uv run --project services/api python -m ml.datasets.export_feedback_report \
     --database-url "$DATABASE_URL"
   ```
2. Recolecta fotos reales en `ml/datasets/real_world/<clase>/` priorizando las clases del reporte.
3. Reentrena con `--profile camera_robust` (consulta [`ml/datasets/real_world/README.md`](../ml/datasets/real_world/README.md)), valida las métricas en el mismo `test` split y reinicia solo el servicio `api`:
   ```bash
   docker compose -f docker-compose.prod.yml restart api
   ```
