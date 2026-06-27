#!/usr/bin/env bash
# Build + run one minimal example project under tests/examples/<pkg>/.
#
# Each example is a self-contained mcpp project whose `[indices]` point at
# this repo (relative `../../..`), so it exercises the real package
# descriptor through the real mcpp build pipeline — fetch, generate, compile,
# link, run. CI calls this once per *changed* package (see validate.yml);
# a human can equivalently `cd tests/examples/<pkg> && mcpp run`.
#
# Usage:   tests/run_example.sh <example-dir-name>
#   e.g.   tests/run_example.sh cjson
#          tests/run_example.sh nlohmann.json
set -euo pipefail

pkg="${1:?usage: run_example.sh <example-dir-name>}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dir="$ROOT/tests/examples/$pkg"
[[ -d "$dir" ]] || { echo "FATAL: no example project at tests/examples/$pkg" >&2; exit 2; }

MCPP_BIN="${MCPP:-}"
[[ -z "$MCPP_BIN" ]] && MCPP_BIN="$(command -v mcpp || true)"
[[ -n "$MCPP_BIN" && -x "$MCPP_BIN" ]] || {
    echo "FATAL: set MCPP=/path/to/mcpp or put mcpp on PATH" >&2; exit 1; }

cd "$dir"
# Hermetic: drop any prior build/fetch state so the example is exercised from
# scratch (the index descriptor, not a stale cache).
rm -rf target .mcpp

echo "==> [$pkg] mcpp build"
"$MCPP_BIN" build
echo "==> [$pkg] mcpp run"
"$MCPP_BIN" run
echo "OK: $pkg"
