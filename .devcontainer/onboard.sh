#!/usr/bin/env bash
# Run any time you want Claude to analyze the repo and propose a devcontainer.json.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

claude "$(cat <<'PROMPT'
You are helping set up a dev container for this repository. Analyze the codebase to detect the primary language(s), runtimes, toolchain versions, and any relevant config files.

Then present your findings and a proposed devcontainer.json to the user, and ask whether they'd like you to write it. Do not write any files until the user confirms.
PROMPT
)"
