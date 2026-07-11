#!/usr/bin/env bash
# The builtin mcpplibs namespace cannot be overridden by a workspace path index.
# Reseed that index from this checkout, then exercise the checked-in example.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MCPP_BIN="${MCPP:-$(command -v mcpp || true)}"
if [[ -z "$MCPP_BIN" || ! -x "$MCPP_BIN" ]]; then
    echo "FATAL: set MCPP=/path/to/mcpp or put mcpp on PATH" >&2
    exit 1
fi

MCPP_HOME="${MCPP_HOME:-$HOME/.mcpp}"
export MCPP_HOME
default_index="$MCPP_HOME/registry/data/mcpplibs"
rm -rf "$default_index"
mkdir -p "$default_index"
cp -a "$ROOT/pkgs" "$default_index/"
rm -f "$default_index/.xlings-index-cache.json"
printf 'ok\n' > "$default_index/.mcpp-index-updated"

"$MCPP_BIN" self config --mirror "${MCPP_INDEX_MIRROR:-GLOBAL}" >/dev/null
rm -rf "$ROOT/tests/examples/tinyhttps/target" "$ROOT/tests/examples/tinyhttps/.mcpp"
cd "$ROOT/tests/examples/tinyhttps"
"$MCPP_BIN" test
