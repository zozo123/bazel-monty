#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="${GITHUB_REPOSITORY:-zozo123/bazel-monty}"
TARGETS="${TARGETS:-//:monty_cli //:core_tests}"
METRICS_DIR="$ROOT/docs/metrics"

mkdir -p "$METRICS_DIR"

run_stage() {
  local stage="$1"
  local sandbox="$2"
  local config="$3"
  local bep="docs/metrics/${stage}-bep.json"
  local profile="docs/metrics/${stage}-profile.json"

  echo "==> ${stage}: ${sandbox} with --config=${config}"
  islo use "$sandbox" \
    --source "github://${REPO}" \
    --workdir "/workspace/bazel-monty" \
    --env "USE_BAZEL_VERSION=9.1.1" \
    -- bazelisk test "--config=${config}" \
      --build_event_json_file="$bep" \
      --profile="$profile" \
      $TARGETS

  islo use "$sandbox" \
    --workdir "/workspace/bazel-monty" \
    -- python3 scripts/collect_bazel_metrics.py \
      --name "$stage" \
      --bep "$bep" \
      --out "docs/metrics/${stage}.json"
}

run_stage seed bazel-monty-seed remote-cache
run_stage reader bazel-monty-reader remote-cache-readonly
run_stage rbe bazel-monty-rbe rbe

echo "Metrics written under docs/metrics/ in each sandbox checkout."
