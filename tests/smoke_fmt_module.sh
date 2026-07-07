#!/usr/bin/env bash
# Smoke-test the public `fmt` module package through this checkout as a local
# mcpp path index. Validates user-facing import-only consumption (`import fmt;`).
# Mirrors tests/smoke_imgui_module.sh — the empty-namespace `fmt` package maps to
# the builtin default index (mcpplibs), which a workspace member cannot point at
# a local path, so it needs this thin driver that reseeds the default index.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MCPP_BIN="${MCPP:-}"
if [[ -z "$MCPP_BIN" ]]; then
    MCPP_BIN="$(command -v mcpp || true)"
fi
if [[ -z "$MCPP_BIN" || ! -x "$MCPP_BIN" ]]; then
    echo "FATAL: set MCPP=/path/to/mcpp or put mcpp on PATH" >&2
    exit 1
fi

TMP="$(mktemp -d)"
if [[ "${MCPP_INDEX_KEEP_SMOKE_TMP:-0}" == "1" ]]; then
    echo "KEEP: $TMP"
else
    trap 'rm -rf "$TMP"' EXIT
fi

if [[ -n "${MCPP_INDEX_SMOKE_MCPP_HOME:-}" ]]; then
    export MCPP_HOME="$MCPP_INDEX_SMOKE_MCPP_HOME"
else
    export MCPP_HOME="$TMP/mcpp-home"
fi
mkdir -p "$MCPP_HOME/registry/data/xpkgs"

USER_MCPP="${HOME}/.mcpp"
link_xpkgs() {
    local src="$1"
    [[ -d "$src" ]] || return 0
    find "$src" -mindepth 1 -maxdepth 1 -type d | while read -r pkg; do
        ln -s "$pkg" "$MCPP_HOME/registry/data/xpkgs/$(basename "$pkg")" 2>/dev/null || true
    done
}
link_xpkgs "${MCPP_INDEX_SMOKE_XPKGS_DIR:-}"
link_xpkgs "$USER_MCPP/registry/data/xpkgs"
if [[ -d "$USER_MCPP/registry/data/xim-pkgindex" ]]; then
    mkdir -p "$MCPP_HOME/registry/data/xim-pkgindex"
    cp -a "$USER_MCPP/registry/data/xim-pkgindex/." "$MCPP_HOME/registry/data/xim-pkgindex/" 2>/dev/null || true
    rm -f "$MCPP_HOME/registry/data/xim-pkgindex/.xlings-index-cache.json"
fi
if [[ -d "$USER_MCPP/registry/bin" ]]; then
    mkdir -p "$MCPP_HOME/registry"
    ln -s "$USER_MCPP/registry/bin" "$MCPP_HOME/registry/bin" 2>/dev/null || true
fi
if [[ -f "$USER_MCPP/config.toml" ]]; then
    cp -f "$USER_MCPP/config.toml" "$MCPP_HOME/config.toml" 2>/dev/null || true
fi

default_index="$MCPP_HOME/registry/data/mcpplibs"
# Reseed cleanly (see smoke_imgui_module.sh for why .git is skipped).
rm -rf "$default_index"
mkdir -p "$default_index"
( cd "$ROOT" && find . -mindepth 1 -maxdepth 1 ! -name .git -exec cp -a {} "$default_index/" \; )
rm -f "$default_index/.xlings-index-cache.json"
printf 'ok\n' > "$default_index/.mcpp-index-updated"

"$MCPP_BIN" self config --mirror "${MCPP_INDEX_MIRROR:-GLOBAL}" >/dev/null

mkdir -p "$TMP/fmt-module-smoke/src"
cd "$TMP/fmt-module-smoke"
cat > mcpp.toml <<EOF
[package]
name = "fmt-module-smoke"
version = "0.1.0"

[toolchain]
default = "${MCPP_INDEX_FMT_MODULE_TOOLCHAIN:-gcc@16.1.0}"

[dependencies]
fmt = "12.2.0"

[targets.fmt-module-smoke]
kind = "bin"
main = "src/main.cpp"
EOF

cat > src/main.cpp <<'EOF'
import std;
import fmt;

int main() {
    std::string a = fmt::format("{} + {} = {}", 2, 3, 2 + 3);
    std::string b = fmt::format("{:08.3f}", 3.14159);
    std::string c = fmt::format("{0}-{1}-{0}", "x", "y");
    std::string d = fmt::format("{:#x}", 255);

    bool ok = a == "2 + 3 = 5" && b == "0003.142" && c == "x-y-x" && d == "0xff";
    std::println("fmt module package ok: {}", a);
    return ok ? 0 : 1;
}
EOF

"$MCPP_BIN" build
"$MCPP_BIN" run
