#!/usr/bin/env bash
# run_workspace.sh — drive the self-referential mcpp workspace: build + run every
# member declared in the root mcpp.toml [workspace].members. Each member is a
# per-library example/test project that consumes THIS repo's pkgs/ via a local
# [indices] path, so this exercises the real package descriptors through the real
# mcpp pipeline — and dogfoods mcpp's own [workspace]. The member list is the
# single source of truth (no hardcoded duplication).
# Usage: MCPP=/path/to/mcpp tests/run_workspace.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MCPP_BIN="${MCPP:-$(command -v mcpp || true)}"
[ -n "$MCPP_BIN" ] && [ -x "$MCPP_BIN" ] || { echo "FATAL: set MCPP=/path/to/mcpp" >&2; exit 1; }

# Read [workspace].members from the root mcpp.toml (one "path" per line).
members=$(awk '
  /^\[workspace\]/ {inws=1; next}
  /^\[/ && !/^\[workspace\]/ {inws=0}
  inws && /"/ { gsub(/[",[:space:]]/,""); if ($0!="members=[" && $0!="") print $0 }
' "$ROOT/mcpp.toml" | sed 's/members=\[//;s/\]//' | grep -v '^$')

[ -n "$members" ] || { echo "FATAL: no [workspace].members in $ROOT/mcpp.toml" >&2; exit 1; }
echo "workspace members:"; echo "$members" | sed 's/^/  /'

for m in $members; do
    dir="$ROOT/$m"
    [ -d "$dir" ] || { echo "FATAL: member dir missing: $m" >&2; exit 1; }
    echo "==> [$m] mcpp build + run"
    ( cd "$dir"
      rm -rf target .mcpp           # hermetic: exercise the index descriptor, not a stale cache
      "$MCPP_BIN" build
      "$MCPP_BIN" run )
    echo "OK: $m"
done
echo "ALL WORKSPACE MEMBERS OK"
