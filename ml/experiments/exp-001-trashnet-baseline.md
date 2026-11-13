# Experiment Log — `exp-001`: TrashNet ResNet18 Baseline

- **Model version:** `resnet18-trashnet-v1.0.0`
- **Date (UTC):** `2026-11-13`
- **Seed:** `42`
- **Hardware:** `Intel Core i5-1135G7 (CPU, 4C/8T)`
- **Total training duration:** `1054.33 s`

## Setup

- Dataset: `garythung/trashnet` (`dataset-resized`, 2,527 raw images -> 2,524 unique after removing 3 exact SHA-256 duplicates; 4 near-duplicate dHash clusters isolated within single splits).
- Splits (`StratifiedGroupKFold`, 7 folds): `train=1803`, `val=360`, `test=361`.
- Backbone: `resnet18` pretrained (`ResNet18_Weights.DEFAULT`), input `224×224`, ImageNet normalization.
- Schedule: 2 epochs frozen backbone (`lr=1e-3`), 4 epochs full fine-tuning (`lr_backbone=1e-4`, `lr_head=5e-4`, `AdamW`, `CosineAnnealingLR`).

## Epoch progression (recorded in `ml/evaluation/reports/training_history.json`)

| Epoch | Phase | Train Macro F1 | Val Accuracy | Val Macro F1 | Time (s) |
|---:|---|---:|---:|---:|---:|
| 1 | `head_warmup` | 0.3687 | 0.6667 | 0.6187 | 95.14 |
| 2 | `head_warmup` | 0.5979 | 0.7167 | 0.6533 | 100.42 |
| 3 | `fine_tune` | 0.7220 | 0.8556 | 0.8384 | 211.49 |
| 4 | `fine_tune` | 0.8707 | 0.8944 | 0.8845 | 212.33 |
| 5 | `fine_tune` | 0.9269 | 0.9083 | 0.8983 | 209.11 |
| 6 | `fine_tune` | 0.9483 | 0.9250 | 0.9180 | 225.43 |

## Held-out Test Summary

- Accuracy: `0.8975` (`324 / 361` exact top-1)
- Macro F1: `0.8881`
- Thresholded (`identified >= 0.50`): `332 / 361` covered (`91.97%`), accuracy `0.9277`; `25` flagged `low_confidence`, `4` flagged `unknown`.
- CPU latency (`batch=1`, 50 samples): `mean=41.17 ms`, `p50=41.01 ms`, `p95=42.96 ms`.

## Next Hypotheses for Future Iterations

1. Augment training with multi-background real-world recycling datasets (e.g., TACO cropped objects or mixed-lighting photos) to mitigate TrashNet's uniform background bias.
2. Evaluate temperature scaling on validation logits if higher threshold separation (`>= 0.70`) is desired without sacrificing `>85%` coverage.
3. Benchmark `mobilenet_v3_small` (already supported in `ml/training/models.py`) if smaller memory footprint for edge/container deployment becomes a priority.
