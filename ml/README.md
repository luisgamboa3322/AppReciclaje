# Machine Learning — PECOX Vision

> **Estado:** Fase 0 (estructura inicial). El entrenamiento y la evaluación del modelo se desarrollarán en la **Fase 3**.

## Clases objetivo

1. `plastic` (Plástico)
2. `glass` (Vidrio)
3. `metal` (Metal)
4. `cardboard` (Cartón)
5. `paper` (Papel)
6. `other` (Otros)

## Estructura prevista

- `datasets/`: manifiestos, licencias y scripts de verificación (nunca subir datasets pesados a Git).
- `training/`: EDA, particiones train/val/test sin fuga de datos y baseline reproducible (ResNet18 con transfer learning en PyTorch).
- `evaluation/`: métricas (accuracy, precision, recall, F1 macro/por clase, matriz de confusión, calibración de umbral y latencia).
- `inference/`: cargador determinista del artefacto exportado para `services/api/`.
- `experiments/`: notas y bitácora de experimentos.
