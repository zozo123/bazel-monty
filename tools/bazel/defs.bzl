"""Small helpers shared by the Bazel Monty demo.

The upstream overlay is intentionally plain BUILD syntax. These helpers live in
the demo repository for future local targets and docs examples.
"""

MONTY_COMMIT = "4bcbcf5251b3a4a30b22fdfc372e5189adf4b86f"
MONTY_VERSION = "0.0.18"
BAZEL_VERSION = "9.1.1"
RULES_RUST_VERSION = "0.71.3"
RULES_PYTHON_VERSION = "2.2.0"

def monty_context():
    return {
        "bazel": BAZEL_VERSION,
        "monty_commit": MONTY_COMMIT,
        "monty_version": MONTY_VERSION,
        "rules_python": RULES_PYTHON_VERSION,
        "rules_rust": RULES_RUST_VERSION,
    }
