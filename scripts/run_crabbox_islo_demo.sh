#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGETS="${TARGETS:-//:monty_cli //:core_tests}"
ISLO_IMAGE="${CRABBOX_ISLO_IMAGE:-ghcr.io/islo-labs/islo-runner:latest}"
ISLO_VCPUS="${CRABBOX_ISLO_VCPUS:-8}"
ISLO_MEMORY_MB="${CRABBOX_ISLO_MEMORY_MB:-16384}"
ISLO_DISK_GB="${CRABBOX_ISLO_DISK_GB:-80}"
KEEP_FLAG="${CRABBOX_KEEP_FLAG:-}"
RUN_LOG="$ROOT/docs/metrics/crabbox-islo.local.log"

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_auth() {
  if [ -z "${CRABBOX_ISLO_API_KEY:-}" ] && [ -z "${ISLO_API_KEY:-}" ]; then
    cat >&2 <<'EOF'
Missing Islo auth for Crabbox.

Set one of:
  export CRABBOX_ISLO_API_KEY=ak_...
  export ISLO_API_KEY=ak_...

Crabbox reads these directly for provider=islo. The Islo CLI login state alone
does not authenticate Crabbox runs.
EOF
    exit 2
  fi
}

main() {
  require crabbox
  require curl
  require_auth

  mkdir -p "$ROOT/docs/metrics"
  echo "==> Crabbox $(crabbox --version)"
  echo "==> Provider: islo"
  echo "==> Image: ${ISLO_IMAGE}"
  echo "==> Targets: ${TARGETS}"

  # Islo is a delegated provider, so Crabbox uploads the repo archive and runs
  # this shell command through Islo's streaming exec API.
  remote_cmd="./scripts/bootstrap_bazelisk.sh && bazelisk build //:monty_cli && bazelisk test //:core_tests"

  set +e
  crabbox run \
    --provider islo \
    --target linux \
    --label bazel-monty-crabbox-islo \
    --islo-image "$ISLO_IMAGE" \
    --islo-vcpus "$ISLO_VCPUS" \
    --islo-memory-mb "$ISLO_MEMORY_MB" \
    --islo-disk-gb "$ISLO_DISK_GB" \
    $KEEP_FLAG \
    --shell \
    -- bash -lc "$remote_cmd" 2>&1 | tee "$RUN_LOG"
  status="${PIPESTATUS[0]}"
  set -e

  echo "Crabbox+Islo log: $RUN_LOG"
  return "$status"
}

main "$@"
