"""Tests verifying canonical class order, deduplication, and zero split leakage."""

from __future__ import annotations

import csv
import random
from pathlib import Path

from PIL import Image

from ml.datasets.prepare_splits import build_splits_and_eda
from ml.training.constants import CANONICAL_CLASSES, CLASS_TO_IDX, TRASHNET_TO_PECOX


def _write_textured_png(path: Path, seed: int, base_rgb: tuple[int, int, int]) -> None:
    rng = random.Random(seed)
    img = Image.new("RGB", (64, 64), base_rgb)
    pixels = img.load()
    assert pixels is not None
    for y in range(0, 64, 4):
        for x in range(0, 64, 4):
            delta = rng.randint(-40, 40)
            r = max(0, min(255, base_rgb[0] + delta))
            g = max(0, min(255, base_rgb[1] - delta))
            b = max(0, min(255, base_rgb[2] + (delta // 2)))
            for dy in range(4):
                for dx in range(4):
                    pixels[x + dx, y + dy] = (r, g, b)
    img.save(path, format="JPEG", quality=92)


def test_canonical_classes_and_mapping() -> None:
    assert CANONICAL_CLASSES == ("plastic", "glass", "metal", "cardboard", "paper", "other")
    assert set(TRASHNET_TO_PECOX.values()) == set(CANONICAL_CLASSES)
    for idx, label in enumerate(CANONICAL_CLASSES):
        assert CLASS_TO_IDX[label] == idx


def test_deduplication_and_zero_split_leakage(tmp_path: Path) -> None:
    raw_root = tmp_path / "dataset-resized"
    base_colors = {
        "plastic": (40, 140, 220),
        "glass": (80, 190, 130),
        "metal": (160, 165, 175),
        "cardboard": (175, 130, 80),
        "paper": (235, 232, 220),
        "trash": (105, 85, 95),
    }

    seed_counter = 1
    for raw_cls, rgb in base_colors.items():
        cls_dir = raw_root / raw_cls
        cls_dir.mkdir(parents=True)
        for sample_i in range(9):
            _write_textured_png(cls_dir / f"{raw_cls}_{sample_i}.jpg", seed_counter, rgb)
            seed_counter += 1

    # Add 2 exact duplicate bytes to verify SHA-256 deduplication removes them.
    plastic_0 = (raw_root / "plastic" / "plastic_0.jpg").read_bytes()
    (raw_root / "plastic" / "plastic_0_dup.jpg").write_bytes(plastic_0)
    glass_0 = (raw_root / "glass" / "glass_0.jpg").read_bytes()
    (raw_root / "glass" / "glass_0_dup.jpg").write_bytes(glass_0)

    splits_csv = tmp_path / "splits.csv"
    eda_report = tmp_path / "eda_report.json"

    report = build_splits_and_eda(
        raw_root=raw_root,
        splits_csv=splits_csv,
        eda_report_path=eda_report,
        seed=42,
    )

    assert report["raw_valid_images"] == 56
    assert report["exact_sha256_duplicates_removed"] == 2
    assert report["unique_images_after_exact_dedup"] == 54
    assert report["leakage_checks"]["sha256_cross_split_overlap"] == 0
    assert report["leakage_checks"]["dhash_cross_split_overlap"] == 0

    with splits_csv.open("r", newline="", encoding="utf-8") as fh:
        rows = list(csv.DictReader(fh))
    assert len(rows) == 54
    assert {r["split"] for r in rows} == {"train", "val", "test"}
