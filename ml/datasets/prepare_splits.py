"""Deduplicate images and create reproducible stratified train/val/test splits."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageOps
from sklearn.model_selection import StratifiedGroupKFold, StratifiedShuffleSplit

from ml.training.constants import CANONICAL_CLASSES, CLASS_TO_IDX, TRASHNET_TO_PECOX

DEFAULT_RAW_DIR = Path(__file__).resolve().parent / "raw" / "trashnet" / "dataset-resized"
DEFAULT_REAL_WORLD_DIR = Path(__file__).resolve().parent / "real_world"
DEFAULT_SPLITS_CSV = Path(__file__).resolve().parent / "splits.csv"
DEFAULT_EDA_REPORT = (
    Path(__file__).resolve().parent.parent / "evaluation" / "reports" / "eda_report.json"
)

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}
REAL_WORLD_LABEL_MAP: dict[str, str] = {
    **TRASHNET_TO_PECOX,
    "other": "other",
}


@dataclass(frozen=True)
class ImageRecord:
    relative_path: str
    raw_label: str
    pecox_label: str
    label_idx: int
    width: int
    height: int
    sha256: str
    dhash: str


def compute_sha256(path: Path) -> str:
    """Compute SHA-256 hex digest of file bytes."""
    digest = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def compute_dhash(img: Image.Image, hash_size: int = 8) -> str:
    """Compute 64-bit difference hash to group near-identical captures."""
    resized = ImageOps.grayscale(img).resize(
        (hash_size + 1, hash_size),
        Image.Resampling.LANCZOS,
    )
    pixels = list(resized.getdata())
    bits: list[str] = []
    stride = hash_size + 1
    for row in range(hash_size):
        row_offset = row * stride
        for col in range(hash_size):
            bits.append("1" if pixels[row_offset + col] > pixels[row_offset + col + 1] else "0")
    return hex(int("".join(bits), 2))[2:].zfill(hash_size * hash_size // 4)


def _scan_labeled_directory(
    root: Path,
    label_map: dict[str, str],
    repo_relative_base: Path,
    *,
    require_all_dirs: bool,
) -> tuple[list[ImageRecord], list[str]]:
    """Scan labeled subdirectories into verified ImageRecord objects."""
    records: list[ImageRecord] = []
    invalid_files: list[str] = []

    for raw_label, pecox_label in sorted(label_map.items()):
        class_dir = root / raw_label
        if not class_dir.is_dir():
            if require_all_dirs:
                raise FileNotFoundError(f"Expected directory not found: {class_dir}")
            continue

        for img_path in sorted(class_dir.iterdir()):
            if not img_path.is_file() or img_path.suffix.lower() not in IMAGE_EXTENSIONS:
                continue
            try:
                with Image.open(img_path) as img:
                    img.verify()
                with Image.open(img_path) as img:
                    rgb = ImageOps.exif_transpose(img).convert("RGB")
                    width, height = rgb.size
                    dhash = compute_dhash(rgb)
                sha = compute_sha256(img_path)
            except Exception as exc:
                invalid_files.append(f"{img_path}: {exc}")
                continue

            try:
                rel_path = img_path.relative_to(repo_relative_base).as_posix()
            except ValueError:
                rel_path = img_path.as_posix()
            records.append(
                ImageRecord(
                    relative_path=rel_path,
                    raw_label=raw_label,
                    pecox_label=pecox_label,
                    label_idx=CLASS_TO_IDX[pecox_label],
                    width=width,
                    height=height,
                    sha256=sha,
                    dhash=dhash,
                )
            )

    return records, invalid_files


def scan_dataset(
    raw_root: Path,
    repo_relative_base: Path,
    real_world_root: Path | None = None,
) -> tuple[list[ImageRecord], list[str], int]:
    """Validate images, compute hashes, and return records, invalid paths, and real-world count."""
    records, invalid_files = _scan_labeled_directory(
        root=raw_root,
        label_map=TRASHNET_TO_PECOX,
        repo_relative_base=repo_relative_base,
        require_all_dirs=True,
    )
    real_world_count = 0
    if real_world_root is not None and real_world_root.is_dir():
        rw_records, rw_invalid = _scan_labeled_directory(
            root=real_world_root,
            label_map=REAL_WORLD_LABEL_MAP,
            repo_relative_base=repo_relative_base,
            require_all_dirs=False,
        )
        records.extend(rw_records)
        invalid_files.extend(rw_invalid)
        real_world_count = len(rw_records)

    return records, invalid_files, real_world_count


def deduplicate_exact(records: list[ImageRecord]) -> tuple[list[ImageRecord], int]:
    """Drop exact SHA-256 duplicate files while keeping deterministic sorted order."""
    seen: set[str] = set()
    unique: list[ImageRecord] = []
    duplicates_removed = 0
    for rec in records:
        if rec.sha256 in seen:
            duplicates_removed += 1
            continue
        seen.add(rec.sha256)
        unique.append(rec)
    return unique, duplicates_removed


def assign_stratified_splits(
    records: list[ImageRecord],
    seed: int = 42,
) -> list[tuple[ImageRecord, str]]:
    """Split records ~70/15/15 keeping dHash groups together to prevent leakage."""
    groups = [rec.dhash for rec in records]
    labels = [rec.label_idx for rec in records]

    # Use StratifiedGroupKFold (7 folds ~= 14.3% each -> 5 train, 1 val, 1 test)
    unique_groups = len(set(groups))
    if unique_groups >= 7 and min(Counter(labels).values()) >= 7:
        sgkf = StratifiedGroupKFold(n_splits=7, shuffle=True, random_state=seed)
        folds = list(sgkf.split(records, labels, groups))
        val_indices = set(folds[0][1].tolist())
        test_indices = set(folds[1][1].tolist())
        assigned: list[tuple[ImageRecord, str]] = []
        for idx, rec in enumerate(records):
            if idx in test_indices:
                assigned.append((rec, "test"))
            elif idx in val_indices:
                assigned.append((rec, "val"))
            else:
                assigned.append((rec, "train"))
        return assigned

    # Fallback for tiny synthetic unit-test fixtures
    indices = list(range(len(records)))
    splitter_test = StratifiedShuffleSplit(n_splits=1, test_size=0.15, random_state=seed)
    train_val_idx, test_idx = next(splitter_test.split(indices, labels))
    train_val_labels = [labels[i] for i in train_val_idx]
    splitter_val = StratifiedShuffleSplit(n_splits=1, test_size=0.1765, random_state=seed)
    rel_train_idx, rel_val_idx = next(splitter_val.split(train_val_idx, train_val_labels))
    val_set = {int(train_val_idx[i]) for i in rel_val_idx}
    test_set = {int(i) for i in test_idx}

    assigned = []
    for idx, rec in enumerate(records):
        if idx in test_set:
            assigned.append((rec, "test"))
        elif idx in val_set:
            assigned.append((rec, "val"))
        else:
            assigned.append((rec, "train"))
    return assigned


def verify_no_leakage(assigned: list[tuple[ImageRecord, str]]) -> None:
    """Assert zero SHA-256 and dHash overlap across train, val, and test splits."""
    split_shas: dict[str, set[str]] = defaultdict(set)
    split_dhashes: dict[str, set[str]] = defaultdict(set)
    for rec, split in assigned:
        split_shas[split].add(rec.sha256)
        split_dhashes[split].add(rec.dhash)

    pairs = [("train", "val"), ("train", "test"), ("val", "test")]
    for a, b in pairs:
        sha_overlap = split_shas[a] & split_shas[b]
        if sha_overlap:
            raise AssertionError(f"SHA-256 leakage between {a} and {b}: {len(sha_overlap)} items")
        dhash_overlap = split_dhashes[a] & split_dhashes[b]
        if dhash_overlap:
            raise AssertionError(f"dHash leakage between {a} and {b}: {len(dhash_overlap)} items")


def build_splits_and_eda(
    raw_root: Path = DEFAULT_RAW_DIR,
    splits_csv: Path = DEFAULT_SPLITS_CSV,
    eda_report_path: Path = DEFAULT_EDA_REPORT,
    seed: int = 42,
    relative_base: Path | None = None,
    real_world_root: Path | None = DEFAULT_REAL_WORLD_DIR,
) -> dict:
    """Run scanning, deduplication, stratified group splitting, and save CSV + EDA JSON."""
    ml_root = relative_base or Path(__file__).resolve().parent.parent
    resolved_raw = raw_root.resolve()
    resolved_rw = real_world_root.resolve() if real_world_root is not None else None
    try:
        resolved_raw.relative_to(ml_root.resolve())
        base_for_paths = ml_root.resolve()
    except ValueError:
        base_for_paths = resolved_raw.parent
    raw_records, invalid_files, real_world_images = scan_dataset(
        raw_root=resolved_raw,
        repo_relative_base=base_for_paths,
        real_world_root=resolved_rw,
    )
    unique_records, exact_duplicates_removed = deduplicate_exact(raw_records)
    assigned = assign_stratified_splits(unique_records, seed=seed)
    verify_no_leakage(assigned)

    splits_csv.parent.mkdir(parents=True, exist_ok=True)
    with splits_csv.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh)
        writer.writerow(
            [
                "relative_path",
                "split",
                "raw_label",
                "pecox_label",
                "label_idx",
                "width",
                "height",
                "sha256",
                "dhash",
            ]
        )
        for rec, split in assigned:
            writer.writerow(
                [
                    rec.relative_path,
                    split,
                    rec.raw_label,
                    rec.pecox_label,
                    rec.label_idx,
                    rec.width,
                    rec.height,
                    rec.sha256,
                    rec.dhash,
                ]
            )

    split_counts: dict[str, dict[str, int]] = {
        split: {cls_name: 0 for cls_name in CANONICAL_CLASSES}
        for split in ("train", "val", "test")
    }
    resolution_counts: Counter[str] = Counter()
    dhash_clusters: Counter[str] = Counter()
    for rec, split in assigned:
        split_counts[split][rec.pecox_label] += 1
        resolution_counts[f"{rec.width}x{rec.height}"] += 1
        dhash_clusters[rec.dhash] += 1

    near_duplicate_groups = sum(1 for count in dhash_clusters.values() if count > 1)
    report = {
        "dataset_id": "trashnet-resized"
        + ("+real_world" if real_world_images > 0 else ""),
        "seed": seed,
        "raw_valid_images": len(raw_records),
        "real_world_images": real_world_images,
        "invalid_or_unreadable_images": len(invalid_files),
        "exact_sha256_duplicates_removed": exact_duplicates_removed,
        "unique_images_after_exact_dedup": len(unique_records),
        "unique_dhash_groups": len(dhash_clusters),
        "near_duplicate_dhash_groups": near_duplicate_groups,
        "canonical_classes": list(CANONICAL_CLASSES),
        "split_totals": {
            split: sum(counts.values()) for split, counts in split_counts.items()
        },
        "split_class_distribution": split_counts,
        "top_resolutions": dict(resolution_counts.most_common(5)),
        "leakage_checks": {
            "sha256_cross_split_overlap": 0,
            "dhash_cross_split_overlap": 0,
        },
    }

    eda_report_path.parent.mkdir(parents=True, exist_ok=True)
    eda_report_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
    return report


def main() -> None:
    parser = argparse.ArgumentParser(description="Prepare deduplicated stratified splits and EDA.")
    parser.add_argument("--raw-root", type=Path, default=DEFAULT_RAW_DIR)
    parser.add_argument("--real-world-dir", type=Path, default=DEFAULT_REAL_WORLD_DIR)
    parser.add_argument("--splits-csv", type=Path, default=DEFAULT_SPLITS_CSV)
    parser.add_argument("--eda-report", type=Path, default=DEFAULT_EDA_REPORT)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()
    report = build_splits_and_eda(
        raw_root=args.raw_root,
        splits_csv=args.splits_csv,
        eda_report_path=args.eda_report,
        seed=args.seed,
        real_world_root=args.real_world_dir,
    )
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
