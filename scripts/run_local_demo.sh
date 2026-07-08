#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGETS="${TARGETS:-//:monty_cli //:core_tests}"
METRICS_DIR="$ROOT/docs/metrics"
OUTPUT_ROOT="${OUTPUT_ROOT:-/tmp/bazel-monty-demo-output-base}"
DEMO_RUN_ID="${DEMO_RUN_ID:-$(date +%Y%m%d%H%M%S)-$$}"
CACHE_DIR="${CACHE_DIR:-/tmp/bazel-monty-remote-cache}"
CACHE_CONTAINER="${CACHE_CONTAINER:-bazel-monty-cache}"
CACHE_IMAGE="${CACHE_IMAGE:-quay.io/bazel-remote/bazel-remote}"
CACHE_PORT="${CACHE_PORT:-9090}"
CACHE_URL="http://127.0.0.1:${CACHE_PORT}"

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

wait_for_cache() {
  for _ in $(seq 1 30); do
    if curl -fsS "${CACHE_URL}/status" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "Remote cache did not become ready at ${CACHE_URL}" >&2
  docker logs "$CACHE_CONTAINER" >&2 || true
  exit 1
}

start_cache() {
  mkdir -p "$CACHE_DIR"

  if docker ps --format '{{.Names}}' | grep -qx "$CACHE_CONTAINER"; then
    echo "==> Reusing running cache container ${CACHE_CONTAINER}"
    wait_for_cache
    return 0
  fi

  if docker ps -a --format '{{.Names}}' | grep -qx "$CACHE_CONTAINER"; then
    docker rm -f "$CACHE_CONTAINER" >/dev/null
  fi

  echo "==> Pulling ${CACHE_IMAGE}"
  docker pull "$CACHE_IMAGE"

  echo "==> Starting local bazel-remote cache on ${CACHE_URL}"
  docker run --rm -d \
    --name "$CACHE_CONTAINER" \
    -u "$(id -u):$(id -g)" \
    -v "${CACHE_DIR}:/data" \
    -p "127.0.0.1:${CACHE_PORT}:8080" \
    "$CACHE_IMAGE" \
    --max_size 5 >/dev/null

  wait_for_cache
}

run_bazel_stage() {
  local stage="$1"
  local config="$2"
  local output_base="$OUTPUT_ROOT/$DEMO_RUN_ID/$stage"
  local bep="$METRICS_DIR/${stage}-bep.local.json"
  local profile="$METRICS_DIR/${stage}-profile.local.json"
  local log="$METRICS_DIR/${stage}.local.log"
  local summary="$METRICS_DIR/${stage}.local.json"

  mkdir -p "$output_base"

  echo "==> ${stage}: bazelisk test --config=${config} ${TARGETS}"
  set +e
  bazelisk --output_base="$output_base" test \
    "--config=${config}" \
    "--remote_cache=${CACHE_URL}" \
    "--build_event_json_file=${bep}" \
    "--profile=${profile}" \
    $TARGETS 2>&1 | tee "$log"
  local status="${PIPESTATUS[0]}"
  set -e

  python3 "$ROOT/scripts/collect_bazel_metrics.py" \
    --name "$stage" \
    --bep "$bep" \
    --log "$log" \
    --out "$summary"

  return "$status"
}

main() {
  require bazelisk
  require curl
  require docker
  require python3

  mkdir -p "$METRICS_DIR"
  start_cache

  run_bazel_stage local-seed demo-cache
  run_bazel_stage local-reader demo-cache-readonly

  echo
  echo "Demo complete."
  echo "Cache status: ${CACHE_URL}/status"
  echo "Metrics:"
  echo "  ${METRICS_DIR}/local-seed.local.json"
  echo "  ${METRICS_DIR}/local-reader.local.json"
}

main "$@"
