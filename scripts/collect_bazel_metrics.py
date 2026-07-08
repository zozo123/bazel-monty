#!/usr/bin/env python3
"""Summarize Bazel BEP/profile artifacts for the Pages demo."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


def read_json_lines(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    events: list[dict[str, Any]] = []
    for line in path.read_text().splitlines():
        line = line.strip()
        if line:
            events.append(json.loads(line))
    return events


def summarize_bep(events: list[dict[str, Any]]) -> dict[str, Any]:
    tests = {"passed": 0, "failed": 0, "other": 0}
    targets: set[str] = set()
    finished = None

    for event in events:
        event_id = event.get("id", {})
        label = event_id.get("targetCompleted", {}).get("label")
        if label:
            targets.add(label)

        test_result = event.get("testResult")
        if test_result:
            status = test_result.get("status")
            if status == "PASSED":
                tests["passed"] += 1
            elif status == "FAILED":
                tests["failed"] += 1
            else:
                tests["other"] += 1

        if "buildFinished" in event:
            finished = event["buildFinished"]

    return {
        "finished": finished or {},
        "target_count": len(targets),
        "tests": tests,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", required=True, help="Run name, e.g. seed")
    parser.add_argument("--bep", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()

    args.out.parent.mkdir(parents=True, exist_ok=True)
    summary = {
        "name": args.name,
        "bep": summarize_bep(read_json_lines(args.bep)),
    }
    args.out.write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
