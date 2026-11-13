# PECOX Vision Mobile (Flutter — Android)

> **Estado:** **Fase 4 implementada (MVP 1.0 conectado a FastAPI + modelo ResNet18)**

## Arquitectura implementada (`lib/`)

- `lib/core/config/api_config.dart`: URL base configurable mediante `--dart-define=PECOX_API_URL=...` (por defecto `http://10.0.2.2:8000/api/v1` para emulador Android).
- `lib/core/services/token_storage.dart`: almacenamiento seguro de tokens JWT (`flutter_secure_storage`, con respaldo en memoria para entornos de prueba sin canal de plataforma).
- `lib/core/services/pecox_api_client.dart`: cliente REST con `Dio`, renovación automática de token (`401 → /auth/refresh`), carga multipart de imágenes y mapeo tipado de errores (`network`, `timeout`, `unauthorized`, `invalidImage`, `modelUnavailable`).
- `lib/core/theme/pecox_theme.dart`: tokens de color, radios, espaciado y Material 3 (`>= 48dp` objetivos táctiles).
- `lib/core/models/pecox_models.dart`: modelos de materiales (`plastic`, `glass`, `metal`, `cardboard`, `paper`, `other`), predicción ML y registros persistidos.
- `lib/core/state/app_state.dart`: estado con `flutter_riverpod` sincronizado con `/auth/*`, `/users/me`, `/model/info`, `/guides`, `/predict` y `/classifications`.
- `lib/core/router/app_router.dart`: rutas con `go_router`.
- `lib/core/widgets/pecox_widgets.dart`: componentes reutilizables (`PecoxBrand`, `PecoxBottomNav`, `PecoxStateCard`, `PecoxHonestyBanner`, `PecoxOfflineBanner`).
- `lib/features/{auth,home,scanner,result,history,guides,profile}/presentation/`: flujo completo Splash → Onboarding → Login/Registro → Home → Escáner/Galería → Preview → Analizando (`/predict`) → Resultado (con incertidumbre y corrección manual) → Guardar (`POST /classifications`) → Historial (`PATCH`/`DELETE`) → Estadísticas reales.

## Ejecución local conectada al backend

1. Inicia el backend FastAPI (`services/api/`) con `ML_ARTIFACT_DIR=../../ml/artifacts` y PyTorch disponible.
2. Ejecuta la app en emulador Android o teléfono físico conectado en red local:

```bash
cd apps/mobile
flutter pub get

# Emulador Android (loopback al host)
flutter run

# Dispositivo físico Android en la misma red Wi-Fi
flutter run --dart-define=PECOX_API_URL=http://<IP-LOCAL-PC>:8000/api/v1
```

También es posible ajustar la URL del servidor en tiempo de ejecución desde **Perfil → Servidor y modelo ML**.

## Verificación automatizada

```bash
cd apps/mobile
flutter analyze
flutter test
```
