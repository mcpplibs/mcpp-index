#!/usr/bin/env bash
# Smoke-test core third-party compat packages through this checkout as a local
# mcpp path index. The test intentionally uses upstream-style headers and APIs.
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
trap 'rm -rf "$TMP"' EXIT
SMOKE_CACHE_DIR="${MCPP_INDEX_SMOKE_CACHE_DIR:-}"
SMOKE_XPKGS_DIR="${MCPP_INDEX_SMOKE_XPKGS_DIR:-}"

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
        [[ "$(basename "$pkg")" == compat-x-* ]] && continue
        ln -s "$pkg" "$MCPP_HOME/registry/data/xpkgs/$(basename "$pkg")" 2>/dev/null || true
    done
}
link_xpkgs "$SMOKE_XPKGS_DIR"
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

mkdir -p "$TMP/compat-core-smoke/src"
cd "$TMP/compat-core-smoke"
cat > mcpp.toml <<EOF
[package]
name = "compat-core-smoke"
version = "0.1.0"

[toolchain]
default = "gcc@16.1.0"

[indices]
compat = { path = "$ROOT" }

[dependencies.compat]
gtest = { version = "1.15.2", features = ["main"] }
ftxui = "6.1.9"
lua = "5.4.7"
mbedtls = "3.6.1"
opengl = "2026.05.31"
khrplatform = "2026.05.31"

[build]
ldflags = ["-ldl", "-lm"]

[targets.compat-core-smoke]
kind = "bin"
main = "src/main.cpp"
EOF

if [[ -n "$SMOKE_CACHE_DIR" && -d "$SMOKE_CACHE_DIR" ]]; then
    mkdir -p .mcpp/.xlings/data/runtimedir
    find "$SMOKE_CACHE_DIR" -maxdepth 1 -type f \
        \( -name '*.tar.gz' -o -name '*.tar.xz' -o -name '*.zip' \) \
        -exec cp -f {} .mcpp/.xlings/data/runtimedir/ \;
fi

cat > src/main.cpp <<'EOF'
#include <array>
#include <string>

#include <GL/gl.h>
#include <KHR/khrplatform.h>
#include <ftxui/dom/elements.hpp>
#include <ftxui/screen/screen.hpp>
#include <gtest/gtest.h>
#include <mbedtls/sha256.h>

extern "C" {
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
}

TEST(CompatGTest, BasicAssertion) {
    EXPECT_EQ(2 + 2, 4);
}

static bool check_ftxui() {
    using namespace ftxui;
    Element document = hbox({text("compat"), separator(), text("ftxui")});
    Screen screen = Screen::Create(Dimension::Fit(document), Dimension::Fit(document));
    Render(screen, document);
    const std::string rendered = screen.ToString();
    return rendered.find("compat") != std::string::npos &&
           rendered.find("ftxui") != std::string::npos;
}

static bool check_lua() {
    lua_State* state = luaL_newstate();
    if (!state) {
        return false;
    }
    luaL_openlibs(state);
    const int rc = luaL_dostring(state, "return 20 + 22");
    const bool ok = rc == LUA_OK && lua_isinteger(state, -1) &&
                    lua_tointeger(state, -1) == 42;
    lua_close(state);
    return ok;
}

static bool check_mbedtls() {
    const unsigned char input[] = "abc";
    std::array<unsigned char, 32> out{};
    mbedtls_sha256(input, 3, out.data(), 0);
    return out[0] == 0xba && out[1] == 0x78 &&
           out[30] == 0x15 && out[31] == 0xad;
}

static bool check_opengl_headers() {
    const GLenum texture = GL_TEXTURE_2D;
    const khronos_uint32_t one = 1;
    return texture == 0x0DE1 && one == 1;
}

TEST(CompatCore, UpstreamHeadersAndMinimalRuntime) {
    EXPECT_TRUE(check_ftxui());
    EXPECT_TRUE(check_lua());
    EXPECT_TRUE(check_mbedtls());
    EXPECT_TRUE(check_opengl_headers());
}
EOF

"$MCPP_BIN" build
"$MCPP_BIN" run
echo "OK"
