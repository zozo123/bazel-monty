# Agent Brief

You are working in `zozo123/bazel-monty`, a standalone demo repo for a blog post
about Bazelizing `pydantic/monty`.

## Intent

Make the demo credible end to end:

- Build a pinned upstream Rust project with Bazel 9.1.1.
- Keep upstream source fetched as an archive, not copied into this repo.
- Use Bzlmod and current rule versions from `registry.build`.
- Demonstrate remote cache and remote execution with three Islo sandboxes.
- Provide a fully runnable local remote-cache proof with Docker and
  `bazel-remote`.
- Publish a static GitHub Pages write-up from `docs/`.

## Critical Files

- `MODULE.bazel`: dependency graph, Monty archive, Rust/Python toolchains.
- `.bazelrc`: local, remote-cache, readonly-cache, and RBE configs.
- `.bazelrc.remote.example`: provider-specific remote config template.
- `third_party/monty/patches/add-bazel-build-files.patch`: overlay added to
  upstream Monty.
- `scripts/run_islo_demo.sh`: E2E remote-cache/RBE demo.
- `scripts/run_local_demo.sh`: no-secrets local remote-cache demo.
- `docs/`: static GitHub Pages source.

## Useful Checks

```bash
bazelisk build //:monty_cli
bazelisk test //:core_tests
./scripts/run_local_demo.sh
python3 scripts/collect_bazel_metrics.py --name local --bep docs/metrics/latest-bep.local.json --out docs/metrics/local.local.json
```

If remote endpoints are missing, do not fake success. Say that local validation
passed and remote validation is pending `.bazelrc.remote`.
