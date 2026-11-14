"""Inspect user-confirmed classifications to prioritize real-world photo curation."""

from __future__ import annotations

import argparse
import json
import sqlite3
from collections import Counter
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

from ml.training.constants import CANONICAL_CLASSES, DEFAULT_IDENTIFIED_THRESHOLD

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
DEFAULT_SQLITE_PATH = REPO_ROOT / "services" / "api" / "pecox_dev.db"
DEFAULT_OUTPUT_PATH = (
    Path(__file__).resolve().parent.parent
    / "evaluation"
    / "reports"
    / "feedback_curation_report.json"
)
DEFAULT_REAL_WORLD_DIR = Path(__file__).resolve().parent / "real_world"

FEEDBACK_QUERY = """
SELECT
    predicted_material,
    confirmed_material,
    confidence,
    model_version
FROM classifications
WHERE confirmed_material IS NOT NULL
"""


def _fetch_confirmed_rows_sqlite(
    sqlite_path: Path,
) -> list[tuple[str, str, float | None, str]]:
    if not sqlite_path.is_file():
        raise FileNotFoundError(f"SQLite database not found: {sqlite_path}")
    conn = sqlite3.connect(sqlite_path)
    try:
        cursor = conn.execute(FEEDBACK_QUERY)
        return [
            (
                str(row[0]),
                str(row[1]),
                float(row[2]) if row[2] is not None else None,
                str(row[3]),
            )
            for row in cursor.fetchall()
        ]
    finally:
        conn.close()


def _fetch_confirmed_rows_url(
    database_url: str,
) -> list[tuple[str, str, float | None, str]]:
    try:
        from sqlalchemy import create_engine, text  # type: ignore[import-not-found]
    except ImportError as exc:
        raise RuntimeError(
            "SQLAlchemy is required for non-SQLite database URLs; pass --sqlite-path for SQLite."
        ) from exc

    engine = create_engine(database_url)
    try:
        with engine.connect() as conn:
            result = conn.execute(text(FEEDBACK_QUERY))
            return [
                (
                    str(row[0]),
                    str(row[1]),
                    float(row[2]) if row[2] is not None else None,
                    str(row[3]),
                )
                for row in result.fetchall()
            ]
    finally:
        engine.dispose()


def build_feedback_report(
    rows: list[tuple[str, str, float | None, str]],
    real_world_dir: Path = DEFAULT_REAL_WORLD_DIR,
    confidence_threshold: float = DEFAULT_IDENTIFIED_THRESHOLD,
) -> dict[str, Any]:
    """Summarize confirmed predictions, user corrections, and class curation priorities."""
    total_confirmed = len(rows)
    correction_pairs: Counter[str] = Counter()
    corrected_targets: Counter[str] = Counter()
    low_confidence_classes: Counter[str] = Counter()
    model_versions: Counter[str] = Counter()
    exact_matches = 0
    corrections_total = 0

    for predicted, confirmed, confidence, model_version in rows:
        model_versions[model_version] += 1
        if predicted == confirmed:
            exact_matches += 1
        else:
            corrections_total += 1
            correction_pairs[f"{predicted} -> {confirmed}"] += 1
            corrected_targets[confirmed] += 1
        if confidence is not None and confidence < confidence_threshold:
            low_confidence_classes[confirmed] += 1

    # Priority score combines direct user corrections and sub-threshold predictions per true class.
    priority_ranking = []
    for cls_name in CANONICAL_CLASSES:
        missed = corrected_targets[cls_name]
        uncertain = low_confidence_classes[cls_name]
        existing_dir = real_world_dir / cls_name
        local_samples = (
            sum(1 for p in existing_dir.iterdir() if p.is_file())
            if existing_dir.is_dir()
            else 0
        )
        priority_ranking.append(
            {
                "pecox_label": cls_name,
                "user_corrections_into_class": missed,
                "sub_threshold_predictions": uncertain,
                "curation_priority_score": (missed * 2) + uncertain,
                "existing_real_world_images": local_samples,
                "target_directory": str(existing_dir),
            }
        )

    priority_ranking.sort(
        key=lambda item: (item["curation_priority_score"], -item["existing_real_world_images"]),
        reverse=True,
    )

    agreement_rate = round(exact_matches / total_confirmed, 4) if total_confirmed > 0 else None
    return {
        "generated_at_utc": datetime.now(UTC).isoformat(),
        "privacy_note": "Aggregate metrics only; PECOX does not persist raw uploaded user photos.",
        "confidence_threshold_reference": confidence_threshold,
        "total_confirmed_classifications": total_confirmed,
        "exact_model_matches": exact_matches,
        "user_corrections_total": corrections_total,
        "observed_agreement_rate": agreement_rate,
        "model_version_counts": dict(model_versions.most_common()),
        "top_confusion_pairs": dict(correction_pairs.most_common()),
        "class_curation_priority": priority_ranking,
    }


def export_feedback_report(
    sqlite_path: Path = DEFAULT_SQLITE_PATH,
    database_url: str | None = None,
    output_path: Path = DEFAULT_OUTPUT_PATH,
    real_world_dir: Path = DEFAULT_REAL_WORLD_DIR,
) -> dict[str, Any]:
    """Read confirmed classifications from the database and save a curation report."""
    if database_url:
        rows = _fetch_confirmed_rows_url(database_url)
    else:
        rows = _fetch_confirmed_rows_sqlite(sqlite_path)

    report = build_feedback_report(rows, real_world_dir=real_world_dir)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
    return report


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Export aggregate user-correction report for real-world photo curation."
    )
    parser.add_argument("--sqlite-path", type=Path, default=DEFAULT_SQLITE_PATH)
    parser.add_argument(
        "--database-url",
        type=str,
        default=None,
        help="Optional SQLAlchemy URL (for production PostgreSQL; overrides --sqlite-path).",
    )
    parser.add_argument("--output-path", type=Path, default=DEFAULT_OUTPUT_PATH)
    parser.add_argument("--real-world-dir", type=Path, default=DEFAULT_REAL_WORLD_DIR)
    args = parser.parse_args()

    report = export_feedback_report(
        sqlite_path=args.sqlite_path,
        database_url=args.database_url,
        output_path=args.output_path,
        real_world_dir=args.real_world_dir,
    )
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
