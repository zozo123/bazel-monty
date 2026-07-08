# GitHub Pages And Fork Context

Target repository:

```text
https://github.com/zozo123/bazel-monty
```

Target Pages URL:

```text
https://zozo123.github.io/bazel-monty/
```

This demo publishes the `docs/` directory directly with GitHub's Pages Actions:

- `.github/workflows/pages.yml` uploads `docs/` as a static artifact.
- No Jekyll, npm, or frontend build step is required.
- `docs/index.html` is the landing page.
- `docs/blog/bazel-monty.html` is the long-form end-to-end article.
- `docs/metrics/*.example.json` are committed placeholders.
- Real local outputs from Bazel runs use `*.local.json` and stay ignored.

## Publishing Steps

```bash
git remote add origin git@github.com:zozo123/bazel-monty.git
git push -u origin main
```

Then enable GitHub Pages for Actions in the repository settings if it is not
already enabled.

## Repository Description

Standalone Bazel 9 demo for building pydantic/monty with rules_rust, remote
cache, remote execution, Islo sandboxes, and GitHub Pages docs.
