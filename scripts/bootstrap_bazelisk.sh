#!/usr/bin/env bash
set -euo pipefail

BAZEL_VERSION="${USE_BAZEL_VERSION:-9.1.1}"
INSTALL_DIR="${BAZELISK_INSTALL_DIR:-$HOME/.local/bin}"
BIN="$INSTALL_DIR/bazelisk"
SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

if ! command -v java >/dev/null 2>&1; then
  echo "Installing Java with SDKMAN"
  curl -s "https://get.sdkman.io?ci=true&rcupdate=false" | bash
  set +u
  # shellcheck disable=SC1091
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdk install java
  set -u
else
  java -version
fi

if command -v bazelisk >/dev/null 2>&1; then
  bazelisk --version
  exit 0
fi

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m)"
case "$arch" in
  x86_64 | amd64) arch="amd64" ;;
  arm64 | aarch64) arch="arm64" ;;
  *) echo "Unsupported architecture for Bazelisk: $arch" >&2; exit 1 ;;
esac

mkdir -p "$INSTALL_DIR"
url="https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-${os}-${arch}"
echo "Installing Bazelisk for Bazel ${BAZEL_VERSION} from ${url}"
curl -fsSL "$url" -o "$BIN"
chmod +x "$BIN"
export PATH="$INSTALL_DIR:$PATH"
export USE_BAZEL_VERSION="$BAZEL_VERSION"
bazelisk --version
