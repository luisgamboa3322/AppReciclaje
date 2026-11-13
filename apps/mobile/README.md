# PECOX Vision Mobile (Flutter — Android)

> **Estado:** Pendiente de implementación (**Fase 1**).  
> El prototipo interactivo de diseño UI/UX (14 pantallas y estados transversales) se encuentra en la raíz del repositorio (`src/`).

## Estructura objetivo (`apps/mobile/`)

- `lib/core/`: tema PECOX, tokens de diseño, `go_router`, cliente `dio`, `flutter_secure_storage`.
- `lib/features/{auth,home,scanner,result,history,guides,profile}/`: arquitectura *feature-first* con `flutter_riverpod`.
- `assets/`: iconografía e ilustraciones propias autorizadas.
- `test/`: pruebas unitarias, de widgets e integración (`integration_test`).
