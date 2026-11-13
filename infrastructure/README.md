# PECOX Vision — Infraestructura y Docker Compose

## Levantar stack completo local (`PostgreSQL + FastAPI + Next.js Admin`)

1. Copia `.env.example` a `.env` en la raíz y define una clave robusta en `JWT_SECRET_KEY` (mínimo 32 caracteres aleatorios en entornos `APP_ENV=production`).
2. Construye e inicia los servicios:

```bash
docker compose up --build
```

Servicios expuestos:
- **PostgreSQL 16:** `localhost:5432`
- **FastAPI Backend (`api`):** `http://localhost:8000` (`/health`, `/docs`, `/api/v1/*`)
- **PECOX Admin Web (`web`):** `http://localhost:3000`

## Endurecimiento incluido

- Contenedores `api` y `web` ejecutan procesos bajo usuarios no-root (`pecox` y `nextjs`).
- Healthchecks integrados para `db`, `api` y `web`.
- En `APP_ENV=production`, `services/api/app/core/config.py` rechaza arrancar si `JWT_SECRET_KEY` conserva valores de ejemplo o mide menos de 32 caracteres.
- Los pesos PyTorch (`ml/artifacts/*.pt`) no se empaquetan en Git ni por defecto en la imagen liviana de API; para habilitar inferencia ML dentro de Docker monta el volumen `./ml/artifacts:/repo/ml/artifacts` e instala las dependencias de inferencia (`torch`, `torchvision`, `pillow`).
