"""PyTorch Dataset backed by PECOX canonical split CSV."""

from __future__ import annotations

import csv
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageOps
from torch.utils.data import Dataset

from ml.training.constants import CLASS_TO_IDX


@dataclass(frozen=True)
class SplitSample:
    path: Path
    label_idx: int
    pecox_label: str


class RecyclingSplitDataset(Dataset):
    """Dataset reading images and canonical PECOX class indices from splits.csv."""

    def __init__(
        self,
        splits_csv: Path,
        split: str,
        ml_root: Path | None = None,
        transform: Callable | None = None,
    ) -> None:
        if split not in {"train", "val", "test"}:
            raise ValueError(f"Unsupported split '{split}'. Expected train, val, or test.")
        self.ml_root = ml_root or Path(__file__).resolve().parent.parent
        self.transform = transform
        self.samples: list[SplitSample] = []

        with splits_csv.open("r", newline="", encoding="utf-8") as fh:
            reader = csv.DictReader(fh)
            for row in reader:
                if row["split"] != split:
                    continue
                pecox_label = row["pecox_label"]
                canonical_idx = CLASS_TO_IDX[pecox_label]
                if int(row["label_idx"]) != canonical_idx:
                    raise ValueError(
                        f"Split CSV label_idx mismatch for {pecox_label}: "
                        f"{row['label_idx']} != {canonical_idx}"
                    )
                self.samples.append(
                    SplitSample(
                        path=self.ml_root / row["relative_path"],
                        label_idx=canonical_idx,
                        pecox_label=pecox_label,
                    )
                )

        if not self.samples:
            raise RuntimeError(f"No samples loaded for split='{split}' from {splits_csv}")

    def __len__(self) -> int:
        return len(self.samples)

    def __getitem__(self, index: int) -> tuple[object, int, str]:
        sample = self.samples[index]
        with Image.open(sample.path) as img:
            rgb = ImageOps.exif_transpose(img).convert("RGB")
        tensor = self.transform(rgb) if self.transform is not None else rgb
        return tensor, sample.label_idx, sample.path.as_posix()

    def class_counts(self) -> list[int]:
        counts = [0] * len(CLASS_TO_IDX)
        for sample in self.samples:
            counts[sample.label_idx] += 1
        return counts
