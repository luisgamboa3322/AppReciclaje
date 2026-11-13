"""Download and verify the MIT-licensed TrashNet resized dataset."""

from __future__ import annotations

import argparse
import json
import urllib.request
import zipfile
from pathlib import Path

from ml.training.constants import TRASHNET_TO_PECOX

DEFAULT_RAW_DIR = Path(__file__).resolve().parent / "raw" / "trashnet"
MANIFEST_PATH = Path(__file__).resolve().parent / "manifest.json"


def download_and_extract(raw_dir: Path = DEFAULT_RAW_DIR, force: bool = False) -> Path:
    """Download TrashNet dataset-resized.zip and extract into raw_dir."""
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    url: str = manifest["archive_url"]

    raw_dir.mkdir(parents=True, exist_ok=True)
    zip_path = raw_dir / "dataset-resized.zip"
    extracted_root = raw_dir / "dataset-resized"

    if extracted_root.exists() and not force:
        expected_present = all(
            (extracted_root / cls_name).is_dir() for cls_name in TRASHNET_TO_PECOX
        )
        if expected_present:
            print(f"Dataset already present at {extracted_root}")
            return extracted_root

    if not zip_path.exists() or force:
        print(f"Downloading {url} -> {zip_path} ...")
        urllib.request.urlretrieve(url, zip_path)
        print(f"Downloaded {zip_path.stat().st_size / (1024 * 1024):.2f} MiB")

    with zipfile.ZipFile(zip_path, "r") as zf:
        bad_member = zf.testzip()
        if bad_member is not None:
            raise RuntimeError(f"Corrupted ZIP archive member detected: {bad_member}")
        zf.extractall(raw_dir)

    for cls_name in TRASHNET_TO_PECOX:
        cls_dir = extracted_root / cls_name
        if not cls_dir.is_dir():
            raise RuntimeError(f"Expected class directory missing after extraction: {cls_dir}")

    print(f"Verified and extracted TrashNet into {extracted_root}")
    return extracted_root


def main() -> None:
    parser = argparse.ArgumentParser(description="Download TrashNet resized dataset.")
    parser.add_argument("--raw-dir", type=Path, default=DEFAULT_RAW_DIR)
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()
    download_and_extract(raw_dir=args.raw_dir, force=args.force)


if __name__ == "__main__":
    main()
