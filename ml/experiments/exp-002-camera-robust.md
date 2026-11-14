# Experiment Log — `exp-002`: Real-World Camera Robustness & TTA Evaluation

- **Base checkpoint evaluated:** `resnet18-trashnet-v1.0.0` (`ml/artifacts/best_checkpoint.pt`)
- **Date (UTC):** `2026-11-14`
- **Hardware:** `Intel Core i5-1135G7 (CPU, 4C/8T)`

## Context (Live Mobile Field Validation)

During physical Android device testing (Samsung Galaxy S20 FE 5G -> FastAPI CPU inference):
- Predictions on TrashNet-domain test photos matched offline test accuracy cleanly.
- Predictions on handheld real-room camera photos showed lower confidence (`0.3655` and `0.4051`) and an observed `paper -> plastic` confusion due to complex backgrounds, lighting shifts, and close-up framing relative to TrashNet's uniform studio background.
- Live feedback summary (`python -m ml.datasets.export_feedback_report` on 10 confirmed test records): `observed_agreement_rate = 0.80` (`8 / 10`), observed corrections: `glass -> metal (1)` and `paper -> plastic (1)`.

## Implemented Engineering Upgrades

1. **Test-Time Augmentation (2-view TTA) (`ml/inference/predictor.py`, `services/api/app/core/config.py`):**
   - Averages `softmax` probabilities across original + horizontally mirrored RGB input (`ML_USE_TTA=true` in production config).
2. **`camera_robust` Augmentation Profile (`ml/training/transforms.py`, `ml/training/train.py`, `ml/run_pipeline.py`):**
   - Wider `RandomResizedCrop(scale=(0.45, 1.0))`, `RandomPerspective(0.25)`, `RandomAffine(degrees=25, translate=0.08, shear=10)`, stronger `ColorJitter(0.3, 0.3, 0.3, 0.05)`, `GaussianBlur`, and `RandomErasing(p=0.25)` simulating hands/labels/clutter.
   - Added `--init-checkpoint` for warm-start domain adaptation fine-tuning once real photos are collected.
3. **Zero-PII Active Learning Loop (`ml/datasets/export_feedback_report.py`, `ml/datasets/prepare_splits.py`):**
   - Reads aggregate confusion pairs (`predicted_material -> confirmed_material`) without storing raw user photos, ranks classes to photograph into `ml/datasets/real_world/<class>/`, and ingests them via `--real-world-dir` with SHA-256 + dHash zero-leakage guarantees.

## Measured Test Benchmark: Single-View vs 2-View TTA (`test`, 361 TrashNet samples)

Evaluated end-to-end through `WasteClassifierPredictor.predict_pil` (including `low_confidence_threshold = 0.35` gating to `other`):

| Mode | Thresholded Accuracy | Macro F1 | Mean CPU Latency (ms/img) |
|---|---:|---:|---:|
| `use_tta=False` (1 view) | `0.8920` (`89.20%`) | `0.8782` | `45.07 ms` |
| `use_tta=True` (2 views: original + mirror) | `0.8975` (`89.75%`) | `0.8840` | `82.97 ms` |

- **Observed delta:** `+0.55 pp` accuracy and `+0.0058` macro-F1 on the exact same `v1.0.0` weights at `+37.9 ms` additional CPU latency (~83 ms total, well within interactive mobile budget).

## Next Step for Supervised Domain Adaptation (`v1.1.0+`)

Collect ~30–100 real-world mobile photos per priority class into `ml/datasets/real_world/<class>/` (starting with `plastic` and `metal`) and run:

```bash
PYTHONPATH=. uv run --project ml python -m ml.run_pipeline \
  --skip-download \
  --profile camera_robust \
  --init-checkpoint ml/artifacts/best_checkpoint.pt \
  --freeze-epochs 0 \
  --epochs 4 \
  --lr-backbone 5e-5 \
  --lr-head 2e-4 \
  --version resnet18-pecox-v1.1.0-robust
```
