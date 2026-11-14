# Machine Learning — PECOX Vision

Pipeline reproducible de visión por computadora para clasificar fotografías de residuos en las **6 clases canónicas** de PECOX Vision (`plastic`, `glass`, `metal`, `cardboard`, `paper`, `other`) con manejo explícito de incertidumbre (`identified`, `low_confidence`, `unknown`).

---

## 1. Dataset, licencias y prevención de fuga de datos

- **Dataset fuente:** [`garythung/trashnet`](https://github.com/garythung/trashnet) (`dataset-resized.zip`, resolución uniforme `512×384`, licencia **MIT**).
- **Mapeo de etiquetas:** `plastic → plastic`, `glass → glass`, `metal → metal`, `cardboard → cardboard`, `paper → paper`, `trash → other`.
- **Manifiesto:** [`ml/datasets/manifest.json`](datasets/manifest.json).
- **Limpieza y partición (`seed = 42`):**
  - Imágenes válidas leídas en bruto: **2,527** (`0` ilegibles).
  - Duplicados exactos detectados por SHA-256 eliminados: **3** → **2,524** imágenes únicas.
  - Grupos de casi-duplicados detectados por *dHash* (64-bit): **4** grupos, asignados íntegramente al mismo split mediante `StratifiedGroupKFold`.
  - Solapamiento SHA-256 y *dHash* entre `train`, `val` y `test`: **0**.
  - **Partición final:** `train = 1,803`, `val = 360`, `test = 361`.

| Clase canónica | Train | Val | Test | Total único |
|---|---:|---:|---:|---:|
| `plastic` | 343 | 68 | 69 | 480 |
| `glass` | 358 | 71 | 72 | 501 |
| `metal` | 292 | 59 | 58 | 409 |
| `cardboard` | 288 | 57 | 58 | 403 |
| `paper` | 425 | 85 | 84 | 594 |
| `other` | 97 | 20 | 20 | 137 |
| **Total** | **1,803** | **360** | **361** | **2,524** |

---

## 2. Entrenamiento y calibración (Baseline v1.0.0)

- **Modelo:** `ResNet18` preentrenado en ImageNet (`ResNet18_Weights.DEFAULT`), cabeza `Dropout(0.2) + Linear(512, 6)`.
- **Versión registrada:** `resnet18-trashnet-v1.0.0` (artefactos binarios `.pt` excluidos de Git; metadatos versionados en [`ml/artifacts/model_metadata.json`](artifacts/model_metadata.json)).
- **Estrategia:** 2 épocas de *head warmup* (`backbone` congelado, `lr = 1e-3`) + 4 épocas de *fine-tuning* completo (`lr_backbone = 1e-4`, `lr_head = 5e-4`, `AdamW`, `CosineAnnealingLR`), `CrossEntropyLoss` con pesos balanceados acotados (`[0.5, 3.0]`) y `label_smoothing = 0.05`.
- **Hardware y tiempo medido:** CPU Intel Core i5-1135G7 (sin GPU dedicada), **1,054.33 s** (~17.6 min), mejor época **#6** seleccionada por `val_macro_f1 = 0.9180` (`val_accuracy = 0.9250`).
- **Calibración sobre validación (`val`, 360 muestras):**
  - `ECE` (*Expected Calibration Error*): **0.0917** (ligera sub-confianza esperada por *label smoothing* y regularización).
  - Umbrales seleccionados sobre validación:
    - `identified_threshold = 0.50` (`accuracy >= 0.90` objetivo en validación: **95.74%** sobre `91.39%` de cobertura).
    - `low_confidence_threshold = 0.35`.

---

## 3. Evaluación en `test` (361 muestras nunca vistas durante entrenamiento/calibración)

Reporte completo en [`ml/evaluation/reports/metrics.json`](evaluation/reports/metrics.json) y matriz visual en [`ml/evaluation/reports/confusion_matrix.png`](evaluation/reports/confusion_matrix.png).

- **Accuracy global:** **89.75%** (`0.8975`)
- **Macro Precision:** **88.05%** (`0.8805`)
- **Macro Recall:** **90.19%** (`0.9019`)
- **Macro F1:** **88.81%** (`0.8881`)
- **Comportamiento con manejo de incertidumbre en `test`:**
  - `identified` (`>= 0.50`): **332 / 361** (`91.97%` cobertura) con **92.77%** de precisión.
  - `low_confidence` (`0.35 – 0.50`): **25** muestras.
  - `unknown` (`< 0.35`): **4** muestras.
- **Latencia de inferencia CPU (`batch = 1`, 50 muestras medidas en i5-1135G7):**
  - Media: **41.17 ms** · P50: **41.01 ms** · P95: **42.96 ms**.

| Clase | Precision | Recall | F1-score | Soporte (`test`) |
|---|---:|---:|---:|---:|
| `plastic` | 0.9104 | 0.8841 | 0.8971 | 69 |
| `glass` | 0.9344 | 0.7917 | 0.8571 | 72 |
| `metal` | 0.8333 | 0.9483 | 0.8871 | 58 |
| `cardboard` | 0.9048 | 0.9828 | 0.9421 | 58 |
| `paper` | 0.9500 | 0.9048 | 0.9268 | 84 |
| `other` | 0.7500 | 0.9000 | 0.8182 | 20 |

---

## 4. Limitaciones y análisis honesto de errores

- **Sesgo de captura (*domain shift*):** TrashNet fue fotografiado principalmente sobre fondos blancos/uniformes con iluminación controlada y un único objeto centrado. En capturas móviles reales (fondos complejos, poca luz, objetos aplastados o varios materiales juntos), la precisión real puede degradarse respecto al `89.75%` medido en `test`.
- **Confusiones observadas en [`ml/evaluation/reports/error_analysis.json`](evaluation/reports/error_analysis.json):**
  - Total de errores en `test`: **37 / 361**.
  - El patrón dominante ocurre entre **`glass` ↔ `metal`** (11 botellas/frascos de vidrio clasificados como metal por reflejos especulares) y entre **`plastic` transparente ↔ `glass`**.
  - También aparecen confusiones entre **`paper` ↔ `cardboard`** (5 muestras de papel clasificadas como cartón) y menor precisión en **`other`** (`0.7500`) por su reducido soporte (`20` muestras en `test`).
- **Calibración probabilística:** El valor `confidence` corresponde a la probabilidad `softmax`, útil como señal orientativa junto con `alternatives` y `status`, **no** como certeza absoluta.

---

## 5. Reproducibilidad y pruebas

```bash
cd ml
uv sync

# Pruebas unitarias, deduplicación sin fuga y contrato de inferencia
uv run ruff check .
uv run pytest -v
```

Para descargar TrashNet, generar particiones, entrenar el baseline y regenerar reportes desde la raíz del repositorio:

```bash
ml/.venv/Scripts/python.exe -m ml.run_pipeline --epochs 6 --freeze-epochs 2
```

Para conectar el artefacto entrenado al backend FastAPI (`services/api/`), configura la variable `ML_ARTIFACT_DIR` apuntando a `../../ml/artifacts` e instala los extras de inferencia o ejecuta en el entorno con PyTorch disponible.

---

## 6. Robustez en cámara real y mejora continua (`exp-002`)

- **Inferencia con 2-view TTA (`ML_USE_TTA=true`):** promedio de probabilidades sobre imagen original y espejo horizontal; mejora en el conjunto `test` evaluado con `WasteClassifierPredictor` de `89.20%` (`0.8782` macro-F1, `45.07 ms`) a `89.75%` (`0.8840` macro-F1, `82.97 ms` en CPU). Ver [`ml/experiments/exp-002-camera-robust.md`](experiments/exp-002-camera-robust.md).
- **Perfil `--profile camera_robust`:** aumentos geométricos, perspectiva, desenfoque, iluminación y oclusión (`RandomPerspective`, `RandomAffine`, `ColorJitter`, `GaussianBlur`, `RandomErasing`) más `--init-checkpoint` para *fine-tuning* desde el modelo base.
- **Curación de fotos reales (`ml/datasets/real_world/`):** exporta reporte de confusiones sin almacenar fotos de usuarios con `uv run python -m ml.datasets.export_feedback_report` y consulta [`ml/datasets/real_world/README.md`](datasets/real_world/README.md).
