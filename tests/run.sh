#!/usr/bin/env bash
set -e
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$ROOT_DIR/setup.sh" "$ROOT_DIR"/lib/*.sh "$ROOT_DIR"/scripts/runner.sh "$ROOT_DIR"/scripts/**/*.sh
"$ROOT_DIR/tests/test.sh"

"$ROOT_DIR/setup.sh" --dry-run --component spotify | grep -q -- '- base'
"$ROOT_DIR/setup.sh" --dry-run --component spotify | grep -q -- '- spotify'
printf '%s\n' "runner dry-run: ok"
