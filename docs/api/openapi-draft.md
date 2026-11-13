# Borrador de Contratos API (`/api/v1`) — PECOX Vision

> **Estado:** Diseño de Fase 0 (previo a la implementación de FastAPI en Fase 2).

## 1. Endpoints planeados

| Método | Ruta | Versión | Descripción |
|---|---|---|---|
| `GET` | `/health` | MVP | Verificación técnica del servicio y conexión a PostgreSQL |
| `POST` | `/api/v1/auth/register` | MVP | Registro de usuario |
| `POST` | `/api/v1/auth/login` | MVP | Inicio de sesión (JWT) |
| `POST` | `/api/v1/auth/refresh` | MVP | Renovación segura de token |
| `GET` | `/api/v1/users/me` | MVP | Perfil del usuario autenticado |
| `POST` | `/api/v1/predict` | MVP | Inferencia ML (`multipart/form-data`, imagen validada) |
| `GET` | `/api/v1/model/info` | MVP | Versión activa del modelo y metadatos |
| `POST` | `/api/v1/classifications` | MVP | Confirmar y persistir clasificación |
| `GET` | `/api/v1/classifications` | MVP | Historial paginado del usuario autenticado |
| `GET` | `/api/v1/classifications/{id}` | MVP | Detalle de clasificación propia |
| `PATCH` | `/api/v1/classifications/{id}` | MVP | Actualizar corrección manual |
| `DELETE` | `/api/v1/classifications/{id}` | MVP | Eliminar clasificación propia |
| `GET` | `/api/v1/guides` | MVP | Guías de materiales (público) |
| `GET` | `/api/v1/statistics/me` | V2 | Estadísticas personales reales |
| `GET` | `/api/v1/admin/summary` | V2 | Analítica administrativa agregada (RBAC) |

---

## 2. Ejemplo ilustrativo de contrato `POST /api/v1/predict`

> Los valores numéricos son un ejemplo estructural del contrato, no métricas de un modelo entrenado.

```json
{
  "prediction_id": "example-id",
  "material": "plastic",
  "confidence": 0.86,
  "alternatives": [
    { "material": "glass", "confidence": 0.08 },
    { "material": "other", "confidence": 0.04 }
  ],
  "model_version": "example-version",
  "status": "identified"
}
```

Estados esperados para `status`: `"identified"`, `"low_confidence"`, `"unknown"`.
