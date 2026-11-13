# Plan de Pruebas y Calidad — PECOX Vision

## 1. Estrategia por capa

| Capa | Herramientas objetivo | Alcance |
|---|---|---|
| Prototipo UI/UX (actual) | `tsc --noEmit`, `vite build` | Compilación TypeScript y empaquetado sin errores |
| Móvil Flutter (Fase 1+) | `flutter analyze`, `flutter test`, `integration_test` | Lógica de estado, widgets, flujos y accesibilidad |
| Backend FastAPI (Fase 2+) | `pytest`, `httpx`, `Bandit`, `pip-audit` | Validaciones, DB, RBAC, propiedad de recursos y seguridad |
| Machine Learning (Fase 3+) | `scikit-learn` | Accuracy, precision/recall, F1 macro/por clase, matriz de confusión, latencia |
| Dashboard Web (Fase 5+) | `Vitest`, Testing Library, `Playwright` | Formularios, tablas, filtros, permisos y E2E |
| Accesibilidad | `axe-core`, Lighthouse, TalkBack | Contraste, foco por teclado, lector de pantalla y escalado de texto |

---

## 2. Casos de prueba obligatorios del producto

1. Imagen válida con modelo cargado devuelve resultado tipado.
2. Archivo inválido o demasiado grande devuelve error controlado (`HTTP 400/413` en backend).
3. Imagen fuera de distribución o borrosa genera estado de baja confianza sin ocultar incertidumbre.
4. Usuario no autenticado no puede acceder a historial privado (`HTTP 401`).
5. Usuario A no puede leer, editar ni eliminar clasificaciones del Usuario B (`HTTP 403/404`).
6. Permiso de cámara denegado permite usar galería o consultar guía sin bloqueo.
7. Pérdida de conexión muestra mensaje comprensible y opción de reintento.
8. Estadísticas coinciden exactamente con consultas reales sobre registros persistidos.
9. Textos escalados en Flutter no provocan desbordamientos críticos.
10. Componentes web son operables por teclado con foco visible.
11. El mapeo de clases entre entrenamiento e inferencia mantiene orden idéntico.
12. GitHub Actions reporta explícitamente qué suites corrieron y su resultado real.

---

## 3. Evidencia verificada en Fase 0

- Compilación y tipado del prototipo interactivo validados con `pnpm exec tsc --noEmit` y `pnpm build`.
- Workflow inicial de CI configurado en [`.github/workflows/prototype-ci.yml`](../../.github/workflows/prototype-ci.yml).
