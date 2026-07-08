# Context Pack

Use this directory when handing the demo to another model, CI harness, or blog
automation.

## Goal

Build a reproducible Bazel demo around upstream `pydantic/monty` without
forking its source into this repository. The demo fetches a pinned Monty archive,
applies a Bazel overlay patch, builds the Rust CLI path, and demonstrates remote
cache/RBE behavior through three Islo sandboxes.

## Current Pin

- Upstream repo: `https://github.com/pydantic/monty`
- Commit: `4bcbcf5251b3a4a30b22fdfc372e5189adf4b86f`
- Archive SHA256: `f185d03ab5853b32d57145edcc2011ab7b83105c70b8a938d563e7d7365ed409`
- Bazel: `9.1.1`
- `rules_rust`: `0.71.3`
- `rules_python`: `2.2.0`

## Design Decisions

- Use an external archive plus patch overlay so the demo stays small and can be
  refreshed against upstream.
- Resolve Rust third-party crates from copied Cargo manifests and `Cargo.lock`
  in `third_party/monty`.
- Keep private remote endpoints in `.bazelrc.remote`, which is ignored by git.
- Treat Islo as reproducible execution sandboxes for the demo, not as the Bazel
  remote executor protocol implementation.
- Keep PyO3 and Node/NAPI targets documented as follow-ups unless the remote
  execution image explicitly supports their runtimes.

## Main Commands

```bash
bazelisk mod tidy
bazelisk build //:monty_cli
bazelisk test //...
./scripts/run_islo_demo.sh
```

## Remote Config Contract

Create `.bazelrc.remote` locally:

```bazelrc
build:remote-cache --remote_cache=grpcs://example.cache.endpoint
build:rbe --remote_executor=grpcs://example.executor.endpoint
build:rbe --remote_cache=grpcs://example.cache.endpoint
```

Use environment variables or provider-specific credential helpers. Do not commit
tokens, service account JSON, or user-specific paths.
