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

Remote cache and RBE endpoints are intentionally not committed. Copy
`.bazelrc.remote.example` to `.bazelrc.remote` and fill in your provider
details.

## What This Shows

- Bazel 9.1.1 + Bzlmod for a Rust workspace that normally builds with Cargo.
- `rules_rust` + `crate_universe` dependency resolution from Monty's pinned
  Cargo metadata.
- A patch overlay that adds Bazel targets to an upstream source archive without
  maintaining a long-lived fork.
- Three Islo sandbox runs: cache seed, cache reader, and RBE validation.
- GitHub Pages docs with reusable command transcripts and metrics.

## Key Files

- `MODULE.bazel` configures Bazel modules, Rust toolchains, and the pinned
  upstream Monty archive.
- `.bazelrc` defines local, remote-cache, remote-cache-readonly, and RBE
  configs.
- `third_party/monty/` contains the upstream pin, Cargo metadata, and Bazel
  overlay patch.
- `context/` is a concise handoff pack for other agents and harnesses.
- `docs/` is the GitHub Pages source.
