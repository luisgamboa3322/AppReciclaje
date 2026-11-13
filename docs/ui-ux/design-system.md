# Design System — PECOX Vision

**Dirección visual:** *Eco-Tech Premium — Reconoce. Aprende. Recicla.*  
**Referencia de inspiración estética:** [Garbage Recycling App Design — LazyInterface UI UX Team (Dribbble)](https://dribbble.com/shots/22225493-Garbage-Recycling-app-design-mobile-app).

> **Regla de originalidad:** La referencia de Dribbble se utiliza exclusivamente como inspiración de estética limpia, fondos aireados, acentos esmeralda y tarjetas sobrias. No se copian pantallas, logotipos, ilustraciones, fotografías ni código.

---

## 1. Tokens de color

| Token | Hex | Uso principal |
|---|---|---|
| `forest-900` | `#12382D` | Encabezados principales, splash, tarjeta hero, marca |
| `emerald-700` | `#087D60` | Botones primarios con texto blanco (contraste accesible) |
| `emerald-500` | `#12C994` | Acentos de escáner, indicadores, detalles activos |
| `mint-100` | `#E9FAF3` | Fondos suaves de estadísticas, notas y estados |
| `lime-300` | `#C9F36B` | Acentos gráficos menores (nunca único indicador de estado) |
| `canvas` | `#FAFCFB` | Fondo general de pantallas |
| `surface` | `#FFFFFF` | Tarjetas, formularios y bottom sheets |
| `ink` | `#17221E` | Texto principal |
| `text-muted` | `#66766E` | Texto secundario y metadatos |
| `border` | `#E7EFEB` | Bordes y separadores suaves |
| `error` | `#C83D42` | Errores de validación e inferencia |

**Regla de accesibilidad de contraste:** `#12C994` funciona como acento visual; para botones con texto blanco se usa `#087D60` o texto oscuro sobre superficies claras para mantener legibilidad acorde a WCAG 2.2 AA (`>= 4.5:1` en texto normal).

---

## 2. Tipografía, escala y espaciado

- **Familia principal:** `Manrope` (o `Plus Jakarta Sans` en handoff equivalente).
- **Base de diseño móvil:** `390 × 844 dp`, retícula de `8 px`, padding horizontal `20–24 px`, radios `16–26 px`.
- **Escala orientativa:**
  - Display: `32–40 px`
  - H1: `24–28 px`
  - H2: `18–22 px`
  - Body: `14–16 px`
  - Metadatos / etiquetas: `11–13 px` (evitar tamaños diminutos en implementación final Flutter)
- **Objetivos táctiles:** controles interactivos de `>= 48 × 48 dp` en Flutter.

---

## 3. Componentes del sistema

Componentes implementados en el prototipo (`src/`) y proyectados para Flutter (`apps/mobile/`):

- `AppHeader` / `TopBar`
- `BottomNavigation` (4 destinos: `Inicio`, `Escanear`, `Historial`, `Perfil`)
- `PrimaryButton`, `SecondaryButton`, `IconButton`
- `StatisticCard`, `MaterialCategoryCard` (6 categorías con tonos diferenciados)
- `ScanViewfinder` (4 esquinas esmeralda + línea de escaneo)
- `ImagePreview`, `ResultBottomSheet`, `ConfidenceIndicator`
- `MaterialCorrectionSheet`, `HistoryItem`, `FilterChip`, `ChartCard`
- `GuideArticleCard`, `StateCard` (`EmptyState`, `LoadingState`, `ErrorState`, `PermissionDialog`) y `OfflineBanner`

---

## 4. Accesibilidad y movimiento

- Respeto explícito a `prefers-reduced-motion` y ajuste manual **Reducir movimiento** en perfil.
- Soporte para **Texto grande** sin truncamientos críticos.
- Toda información crítica (confianza baja, error, offline) se comunica con texto e icono, nunca solo por color.
- Prototipo interactivo disponible en la raíz del proyecto (`src/App.tsx`).
