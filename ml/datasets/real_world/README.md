# Curación de fotos reales (`ml/datasets/real_world/`)

Coloca aquí fotografías tomadas con cámara móvil real en condiciones cotidianas (diferentes mesas, fondos, iluminación, ángulos e items parcialmente aplastados) para reducir el *domain shift* respecto a TrashNet.

## Estructura requerida

Solo se indexan archivos `.jpg`, `.jpeg`, `.png` o `.webp` dentro de las 6 carpetas canónicas de PECOX:

```text
ml/datasets/real_world/
├── plastic/
├── glass/
├── metal/
├── cardboard/
├── paper/
└── other/
```

## Flujo de mejora continua (Active Learning sin guardar fotos de usuarios)

1. Genera el reporte agregado de correcciones desde la base de datos:
   ```bash
   PYTHONPATH=. uv run --project ml python -m ml.datasets.export_feedback_report
   ```
2. Revisa `class_curation_priority` en `ml/evaluation/reports/feedback_curation_report.json` para priorizar las clases con más correcciones manuales (`predicted_material -> confirmed_material`).
3. Agrega fotos nuevas en `ml/datasets/real_world/<clase>/` (estas imágenes están excluidas de Git en `.gitignore`).
4. Regenera los splits sin fuga (SHA-256 + dHash) y reentrena con el perfil `camera_robust`:
   ```bash
   PYTHONPATH=. uv run --project ml python -m ml.run_pipeline \
     --skip-download \
     --profile camera_robust \
     --version resnet18-pecox-v1.2.0-real \
     --epochs 8
   ```
