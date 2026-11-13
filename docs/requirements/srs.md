# Especificación de Requerimientos de Software (SRS) — PECOX Vision

> **Estado del documento:** Fase 0 — Planificación técnica. Las capacidades descritas aquí definen el alcance objetivo por versiones (`MVP 1.0`, `V2`, `V3`) y no representan resultados ya implementados en producción.

---

## 1. Propósito y alcance

**PECOX Vision** es una plataforma digital para apoyar la identificación de materiales reciclables mediante visión por computadora, ofrecer guías prácticas de separación y registrar clasificaciones reales en un backend unificado.

### Estrategia por versiones

- **MVP 1.0 (Móvil + Backend + ML):** autenticación, captura/selección de foto, inferencia real con PyTorch, resultado con confianza y alternativas, corrección manual preservando predicción original, historial personal, guía de materiales y pruebas automatizadas.
- **V2 (Dashboard Web + Analítica):** panel administrativo con Next.js, estadísticas personales y agregadas reales, gestión de usuarios/roles, reportes y observabilidad de versiones del modelo.
- **V3 (IoT / Máquina recicladora experimental):** registro de máquinas, telemetría, niveles de llenado, eventos verificados por sensores, códigos QR y puntos por depósitos confirmados.

---

## 2. Perfiles de acceso

| Perfil | Permisos y alcance |
|---|---|
| Visitante | Leer la guía de separación de materiales sin cámara ni cuenta |
| Usuario registrado | Escanear, corregir, guardar y consultar/eliminar su propio historial |
| Administrador (V2) | Consultar métricas agregadas, gestionar usuarios y revisar versiones ML |
| Operador (V3) | Supervisar máquinas recicladoras, depósitos verificados y alertas |
| Dispositivo IoT (V3) | Enviar telemetría y eventos autenticados hacia la API |

---

## 3. Requerimientos Funcionales (RF)

| Código | Requerimiento | Versión |
|---|---|---|
| RF-01 | Registrar e iniciar sesión de usuarios | MVP |
| RF-02 | Capturar fotografías con la cámara del dispositivo | MVP |
| RF-03 | Seleccionar imágenes desde la galería | MVP |
| RF-04 | Clasificar materiales mediante modelo de Machine Learning real | MVP |
| RF-05 | Mostrar categoría sugerida, confianza del modelo y alternativas | MVP |
| RF-06 | Permitir corregir manualmente una predicción | MVP |
| RF-07 | Guardar clasificaciones confirmadas en base de datos | MVP |
| RF-08 | Consultar y gestionar historial personal | MVP |
| RF-09 | Acceder a la guía de materiales sin activar la cámara | MVP |
| RF-10 | Visualizar estadísticas personales basadas en datos reales | V2 |
| RF-11 | Administrar usuarios según permisos (RBAC) | V2 |
| RF-12 | Visualizar estadísticas globales en dashboard web | V2 |
| RF-13 | Exportar reportes en formato CSV/PDF | V2 |
| RF-14 | Administrar versiones y métricas de modelos ML | V2 |
| RF-15 | Registrar máquinas recicladoras | V3 |
| RF-16 | Recibir eventos de sensores IoT autenticados | V3 |
| RF-17 | Consultar nivel de llenado de contenedores | V3 |
| RF-18 | Registrar depósitos mediante QR o código de máquina | V3 |
| RF-19 | Asignar puntos únicamente por depósitos verificados | V3 |
| RF-20 | Enviar alertas de mantenimiento | V3 |

---

## 4. Reglas de negocio críticas

1. **Categorías iniciales:** `plastic`, `glass`, `metal`, `cardboard`, `paper`, `other`.
2. **No certificación automática:** identificar un material por fotografía no garantiza que sea aceptado por el programa de reciclaje local; la guía debe advertirlo.
3. **Manejo explícito de incertidumbre:** cuando la confianza esté por debajo del umbral definido o la foto sea inadecuada, se presenta estado incierto e invitación a corregir manualmente.
4. **Confirmación antes de persistir:** una predicción no se guarda como definitiva sin confirmación del usuario.
5. **Aislamiento de datos:** cada usuario solo ve, corrige y elimina sus propios registros, salvo permisos administrativos explícitos.
6. **Sin métricas ficticias:** las estadísticas deben provenir de registros reales persistidos. No inventar CO₂ evitado ni ahorros económicos sin respaldo metodológico.
7. **Separación foto vs depósito físico:** los escaneos por cámara nunca otorgan recompensas. Los puntos (V3) dependen exclusivamente de depósitos confirmados por máquina.
8. **Retención limitada:** las fotografías enviadas a inferencia no se almacenan indefinidamente por defecto.

---

## 5. Requerimientos No Funcionales (RNF) — Metas por verificar

| Código | Atributo | Meta técnica |
|---|---|---|
| RNF-01 | Latencia API | `p95 < 500 ms` en endpoints CRUD simples en entorno controlado |
| RNF-02 | Latencia ML | Objetivo inicial `< 3 s` por inferencia en hardware de referencia |
| RNF-03 | Seguridad | HTTPS en producción, JWT, RBAC, validación de archivos, secretos fuera de Git |
| RNF-04 | Accesibilidad | WCAG 2.2 AA aplicable (contraste, TalkBack, escalado, `reduce motion`) |
| RNF-05 | Adaptabilidad | Android en múltiples resoluciones y dashboard web responsive |
| RNF-06 | Mantenibilidad | Arquitectura modular, tipado estricto, linting y documentación |
| RNF-07 | Integridad de datos | Migraciones Alembic, llaves foráneas y transacciones consistentes |
| RNF-08 | Disponibilidad | Health checks (`/health`) y recuperación documentada |
| RNF-09 | Calidad | Pruebas automatizadas ejecutadas en GitHub Actions |
| RNF-10 | Privacidad | Minimización de datos y borrado temporal de imágenes |
| RNF-11 | Observabilidad | Logs estructurados con `request_id` sin datos sensibles |
| RNF-12 | Reproducibilidad ML | Dataset, particiones, semilla, parámetros y evaluación documentados |
