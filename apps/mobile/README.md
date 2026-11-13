# PECOX Vision Mobile (Flutter — Android)

> **Estado:** **Fase 1 implementada (UI/UX Flutter + navegación + estado local)**  
> La conexión con el backend FastAPI y el modelo ML real se realizará en las **Fases 2, 3 y 4**. Mientras tanto, la app señala explícitamente las vistas de demostración sin simular inferencia real.

## Arquitectura implementada (`lib/`)

- `lib/core/theme/pecox_theme.dart`: tokens de color, radios, espaciado y Material 3 (`>= 48dp` objetivos táctiles).
- `lib/core/models/pecox_models.dart`: modelos de materiales (`plastic`, `glass`, `metal`, `cardboard`, `paper`, `other`), historial y predicciones de demostración.
- `lib/core/state/app_state.dart`: gestor de estado con `flutter_riverpod`.
- `lib/core/router/app_router.dart`: rutas con `go_router`.
- `lib/core/widgets/pecox_widgets.dart`: componentes reutilizables (`PecoxBrand`, `PecoxBottomNav`, `PecoxStateCard`, `PecoxHonestyBanner`, `PecoxOfflineBanner`).
- `lib/features/{auth,home,scanner,result,history,guides,profile}/presentation/`: las 14 pantallas del brief (UI-01 a UI-14) con estados de error, cámara denegada, historial vacío, corrección manual y accesibilidad (`Texto grande` y `Reducir movimiento`).

## Comandos locales

```bash
cd apps/mobile
flutter pub get
flutter analyze
flutter test
```
