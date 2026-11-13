# Política de Seguridad — PECOX Vision

## Reporte de vulnerabilidades

Si detectas una vulnerabilidad o problema de seguridad en este repositorio:

1. **No** publiques detalles explotables ni credenciales en issues públicos.
2. Abre un reporte privado de seguridad en GitHub (*Security Advisories*) o contacta directamente al mantenedor del proyecto.
3. Incluye pasos reproducibles, alcance afectado y severidad estimada.

## Controles implementados

- **Secretos fuera de Git y validación en producción:** archivos `.env`, llaves y checkpoints están excluidos en `.gitignore`. Cuando `APP_ENV=production`, `services/api/app/core/config.py` impide arrancar si `JWT_SECRET_KEY` utiliza valores de ejemplo o mide menos de 32 caracteres.
- **Autenticación y RBAC:** contraseñas con hashing seguro (`argon2`/`bcrypt` vía `passlib`), JWT de acceso + refresh con rotación y aislamiento estricto de recursos por `user_id` y endpoints `/api/v1/admin/*` protegidos con `require_admin`.
- **Privacidad y validación de imágenes:** `/api/v1/predict` valida MIME type (`image/jpeg`, `image/png`, `image/webp`), límite de carga (`MAX_IMAGE_UPLOAD_MB`) e integridad vía Pillow sin persistir las fotografías en disco ni base de datos.
- **Cabeceras HTTP de seguridad:** tanto FastAPI (`SecurityHeadersMiddleware`) como Next.js (`next.config.ts`) envían `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: strict-origin-when-cross-origin` y `Permissions-Policy`.
- **Contenedores no-root:** `infrastructure/docker/api.Dockerfile` y `infrastructure/docker/web.Dockerfile` ejecutan procesos sin privilegios root (`pecox` y `nextjs`) y definen `HEALTHCHECK`.
- **Auditoría continua en CI:** `.github/workflows/security-ci.yml` ejecuta `bandit`, `pip-audit` y `pnpm audit --prod`.
- **Separación de recompensas (V3):** una predicción fotográfica nunca acredita puntos ni recompensas; cualquier incentivo futuro dependerá únicamente de depósitos verificados por hardware/IoT autenticado.
