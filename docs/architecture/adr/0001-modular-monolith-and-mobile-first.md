# ADR-0001: Monolito modular FastAPI, estrategia móvil primero y separación foto vs depósito

- **Estado:** Aceptado (Fase 0)
- **Fecha:** 2026-11-13
- **Contexto:** PECOX Vision requiere demostrar ingeniería Full Stack, móvil Android, Machine Learning real y una futura integración IoT dentro de un portafolio verificable y mantenible por un desarrollador.

## Decisiones

1. **Monolito modular en FastAPI + PostgreSQL para el backend e inferencia inicial:**
   - **Por qué:** reduce latencia de red interna, simplifica despliegue Docker, permite transacciones ACID directas y evita sobrecarga de orquestación (Kubernetes/event bus) innecesaria para un MVP.
   - **Alternativa descartada:** microservicios separados desde el día uno (mayor costo operativo sin beneficio proporcional).

2. **Estrategia móvil primero (Flutter Android antes del dashboard web Next.js):**
   - **Por qué:** el caso de uso principal es la captura en el momento de separar un residuo; el dashboard web administrativo (V2) cobra sentido real cuando ya existe inferencia y registros reales que visualizar.

3. **Separación estricta entre predicción fotográfica y depósito verificado:**
   - **Por qué:** identificar un envase mediante cámara no demuestra que haya sido depositado físicamente en un contenedor. No se asignan puntos por escaneos de cámara; las recompensas pertenecen exclusivamente a V3 cuando existan sensores/máquinas autenticadas.

## Consecuencias

- El módulo `ml/inference` debe estar encapsulado detrás de una interfaz clara para poder extraerlo a un servicio dedicado en el futuro si el tráfico de inferencia lo exige.
- Todo el flujo móvil MVP se diseña y valida en el prototipo antes de iniciar la implementación en Flutter.
