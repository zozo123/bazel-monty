# Bazel Monty Demo

Standalone Bazel demo for building a pinned snapshot of
[pydantic/monty](https://github.com/pydantic/monty) with Bzlmod, remote cache,
remote execution, and Islo sandboxes.

The demo is designed for a blog post and GitHub Pages site at:

https://zozo123.github.io/bazel-monty/

## Quick Start

```bash
bazelisk build //:monty_cli
bazelisk test //...
```

## Full Local Demo

Run the whole demo locally, including a real remote cache:

```bash
./scripts/run_local_demo.sh
```

That script starts `bazel-remote` in Docker, runs a cache-seeding Bazel test
with one fresh output base, then runs a readonly-cache Bazel test with another
fresh output base. Metrics and logs are written to `docs/metrics/*.local.*`.
The cache image, port, and directories are overridable with `CACHE_IMAGE`,
`CACHE_PORT`, `CACHE_DIR`, and `OUTPUT_ROOT`.

Requirements:

- `bazelisk`
- `docker`
- `python3`
- `curl`

## Remote Provider Demo

Provider-backed remote cache and RBE endpoints are intentionally not committed.
Copy `.bazelrc.remote.example` to `.bazelrc.remote` and fill in your provider
details:

```bash
cp .bazelrc.remote.example .bazelrc.remote
bazelisk test --config=remote-cache //:core_tests
bazelisk test --config=rbe //:core_tests
```

For isolated machine-to-machine proof, use Islo:

```bash
./scripts/run_islo_demo.sh
```

For the latest Crabbox flow with Islo as a delegated-run provider:

```bash
brew upgrade openclaw/tap/crabbox
export CRABBOX_ISLO_API_KEY=ak_...
./scripts/run_crabbox_islo_demo.sh
```

Crabbox `provider=islo` does not use a Crabbox broker or SSH lease. Crabbox
syncs the repo archive and tracks the run; Islo owns sandbox lifecycle and
streams command execution. The remote bootstrap uses SDKMAN CI mode to install
Java when the sandbox image does not already provide a JDK, then installs
Bazelisk and runs the Bazel demo.

## What This Shows

- Bazel 9.1.1 + Bzlmod for a Rust workspace that normally builds with Cargo.
- `rules_rust` + `crate_universe` dependency resolution from Monty's pinned
  Cargo metadata.
- A patch overlay that adds Bazel targets to an upstream source archive without
  maintaining a long-lived fork.
- Three Islo sandbox runs: cache seed, cache reader, and RBE validation.
- GitHub Pages docs with reusable command transcripts and metrics.

## Latest Numbers

- Local remote-cache seed: `121.135s`, `756` processes, `1` test passed.
- Local readonly cache reader: `15.706s`, `432` remote cache hits out of `756`
  processes, about `57.1%`.
- Islo CLI sandbox: `//:monty_cli` built in `120.287s` across `1302`
  processes; `//:core_tests` passed in `1.719s`.
- Reference GitHub CI run: success in `5m01s`.
- Reference GitHub Pages deploy: success in `17s`.

The committed machine-readable summary is
[`docs/metrics/e2e-results.json`](docs/metrics/e2e-results.json).

## Key Files

- `MODULE.bazel` configures Bazel modules, Rust toolchains, and the pinned
  upstream Monty archive.
- `.bazelrc` defines local, local-demo-cache, remote-cache, readonly-cache, and
  RBE configs.
- `third_party/monty/` contains the upstream pin, Cargo metadata, and Bazel
  overlay patch.
- `scripts/run_local_demo.sh` runs the finish-line local remote-cache demo.
- `scripts/run_islo_demo.sh` runs the three-sandbox provider-backed demo.
- `scripts/run_crabbox_islo_demo.sh` runs the latest Crabbox delegated Islo
  provider demo.
- `context/` is a concise handoff pack for other agents and harnesses.
- `docs/` is the GitHub Pages source.

## Publishing

The public fork is:

https://github.com/zozo123/bazel-monty

GitHub Pages publishes from `docs/` using `.github/workflows/pages.yml`:

https://zozo123.github.io/bazel-monty/

The manual `.github/workflows/demo.yml` workflow runs the same local
remote-cache proof in GitHub Actions and uploads the generated metrics as an
artifact.
