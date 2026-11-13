# Especificación de Pantallas (UI-01 a UI-14) — PECOX Vision

Este documento resume las 14 vistas del prototipo interactivo ubicado en [`src/App.tsx`](../../src/App.tsx) y [`src/screens/`](../../src/screens/) que sirve como referencia de handoff para **Fase 1 (Flutter)**.

---

## Flujo principal y navegación

- **Bottom navigation (4 destinos):** `Inicio` · `Escanear` · `Historial` · `Perfil`.
- **Rutas secundarias:** `Estadísticas (V2 Demo)`, `Guía de materiales`, `Conceptos futuros (V3)`.
- **Flujo MVP:** `UI-01 Splash` → `UI-02 Onboarding` → `UI-03 Auth (o Invitado)` → `UI-04 Home` → `UI-05 Scanner` → `UI-06 Preview` → `UI-07 Analyzing` → `UI-08 Result` → `UI-09 Manual Correction` → `UI-10 History`.

---

## Catálogo de pantallas

| Código | Pantalla | Versión | Estados cubiertos en prototipo |
|---|---|---|---|
| `UI-01` | Splash screen | MVP | Entrada de marca, carga inicial, fallo de sesión con reintento |
| `UI-02` | Onboarding (3 láminas) | MVP | Reconocer, aprender, progreso (etiquetado **GRÁFICA DEMO**), Omitir / Continuar / Empezar |
| `UI-03` | Login, Registro y Recuperación | MVP | Tabs login/registro, ver contraseña, recuperación, modo invitado a guía, errores de credenciales/usuario/sesión/red |
| `UI-04` | Home dashboard | MVP | Saludo, hero de escaneo, resumen dinámico de sesión, acceso directo a 6 categorías, actividad reciente o estado vacío |
| `UI-05` | AI Smart Scanner | MVP | Encuadre 4 esquinas, flash, selector de galería con validación de tamaño/tipo, estado **cámara denegada** |
| `UI-06` | Previsualización de imagen | MVP | Revisión de foto, nota de privacidad temporal, estado **imagen inválida o >10 MB** |
| `UI-07` | Analizando imagen | MVP | Spinner indeterminado sin porcentajes inventados, cancelar, timeout/red con reintento |
| `UI-08` | Resultado de clasificación ML | MVP | Variantes `Identificado`, `Baja confianza`, `Desconocido`, `Error`; alternativas y banner honesto de demostración |
| `UI-09` | Corrección manual | MVP | Bottom sheet con 6 materiales, preserva `predicted_material` separado de `confirmed_material`, botón **Deshacer** |
| `UI-10` | Historial | MVP | Búsqueda, chips por material, agrupación temporal, modal de detalle, eliminar registro y estado vacío |
| `UI-11` | Estadísticas | V2 | Filtros de periodo, gráfica semanal y distribución por material marcadas como **DEMO**, sin CO₂ inventado |
| `UI-12` | Guía de materiales | MVP | Descripción, ejemplos, 3 pasos y advertencia específica para cada uno de los 6 materiales |
| `UI-13` | Perfil y ajustes | MVP | Edición de datos, toggles **Texto grande** y **Reducir movimiento**, borrado de historial demo, cerrar sesión |
| `UI-14` | Conceptos futuros | V3 | Separado en **A. Recompensas verificadas** y **B. Máquinas IoT**, claramente rotulado **CONCEPTO FUTURO (V3)** |
