# Guía de Contribución — PECOX Vision

Gracias por revisar o contribuir a **PECOX Vision**. Este proyecto sigue un enfoque incremental por fases con entregables verificables.

## Convención de commits

Usar commits pequeños, descriptivos y bajo el formato *Conventional Commits*:

- `docs(fase-0): add SRS and system architecture`
- `feat(mobile): implement scanner viewfinder screen`
- `feat(api): add classification persistence endpoints`
- `ml(training): add ResNet18 baseline evaluation`
- `test(api): verify ownership authorization`
- `fix(ui): adjust contrast on emerald action buttons`

## Flujo de trabajo

1. Trabaja sobre ramas temáticas (`feat/...`, `fix/...`, `docs/...`).
2. Verifica que el código pase linting, tipado y pruebas antes de abrir PR.
3. No incluyas datasets pesados, pesos de modelos sin control o archivos `.env` con credenciales.
4. No presentes métricas, predicciones o funcionalidades futuras (V2/V3) como implementadas si aún son prototipos.

## Definition of Done (DoD)

Una funcionalidad se considera terminada solo cuando:
- Cumple su criterio de aceptación y contempla estados de carga, vacío y error.
- Fue probada localmente y cuenta con pruebas automatizadas pertinentes.
- Respeta controles básicos de seguridad y accesibilidad (WCAG 2.2 AA aplicable).
- Su documentación y limitaciones conocidas quedan actualizadas.
