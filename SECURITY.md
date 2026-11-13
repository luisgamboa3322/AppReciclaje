# Política de Seguridad — PECOX Vision

## Reporte de vulnerabilidades

Si detectas una vulnerabilidad o problema de seguridad en este repositorio:

1. **No** publiques detalles explotables ni credenciales en issues públicos.
2. Abre un reporte privado de seguridad en GitHub (*Security Advisories*) o contacta directamente al mantenedor del proyecto.
3. Incluye pasos reproducibles, alcance afectado y severidad estimada.

## Controles y principios del proyecto

- **Secretos fuera de Git:** nunca subir archivos `.env`, tokens JWT, llaves privadas o credenciales de base de datos. Usar [`.env.example`](./.env.example) como plantilla con valores ficticios.
- **Privacidad de imágenes:** las fotografías enviadas para inferencia se validan en tamaño/formato y no deben almacenarse indefinidamente por defecto.
- **Autorización por recurso:** todo registro de clasificación pertenece a un usuario; ningún usuario estándar puede leer, modificar ni eliminar registros de otro.
- **Separación de recompensas (V3):** una predicción fotográfica nunca acredita puntos ni recompensas; cualquier incentivo futuro dependerá únicamente de depósitos verificados por hardware/IoT autenticado.
- **Revisión continua:** al incorporar dependencias Python, Flutter y Next.js se ejecutarán revisiones con `pip-audit`, `Bandit` y auditorías de paquetes en CI.
