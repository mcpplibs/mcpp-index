#!/usr/bin/env bash
# Cross-platform smoke tests for compat packages that should not depend on
# Linux/X11 runtime libraries.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MCPP_BIN="${MCPP:-}"
if [[ -z "$MCPP_BIN" ]]; then
    MCPP_BIN="$(command -v mcpp || true)"
fi

to_native_path() {
    if [[ "${OS:-}" == "Windows_NT" ]] && command -v cygpath >/dev/null 2>&1; then
        cygpath -m "$1"
    else
        printf '%s\n' "$1"
    fi
}

to_posix_path() {
    if [[ "${OS:-}" == "Windows_NT" ]] && command -v cygpath >/dev/null 2>&1; then
        cygpath -u "$1"
    else
        printf '%s\n' "$1"
    fi
}

MCPP_BIN_POSIX=""
if [[ -n "$MCPP_BIN" ]]; then
    MCPP_BIN_POSIX="$(to_posix_path "$MCPP_BIN")"
fi
if [[ -z "$MCPP_BIN_POSIX" || ! -f "$MCPP_BIN_POSIX" ]]; then
    echo "FATAL: set MCPP=/path/to/mcpp or put mcpp on PATH" >&2
    exit 1
fi

platform="$(uname -s)"
if [[ "${OS:-}" == "Windows_NT" ]]; then
    platform="Windows_NT"
fi

case "$platform" in
    Windows_NT|Darwin)
        TOOLCHAIN="${MCPP_INDEX_PORTABLE_TOOLCHAIN:-llvm@20.1.7}"
        ;;
    *)
        TOOLCHAIN="${MCPP_INDEX_PORTABLE_TOOLCHAIN:-gcc@16.1.0}"
        ;;
esac

TMP="$(mktemp -d)"
if [[ "${MCPP_INDEX_KEEP_SMOKE_TMP:-0}" == "1" ]]; then
    echo "KEEP: $TMP"
else
    trap 'rm -rf "$TMP"' EXIT
fi

MCPP_HOME_POSIX="$TMP/mcpp-home"
mkdir -p "$MCPP_HOME_POSIX"
export MCPP_HOME="$(to_native_path "$MCPP_HOME_POSIX")"

INDEX_ROOT="$(to_native_path "$ROOT")"
SMOKE_CACHE_DIR="${MCPP_INDEX_SMOKE_CACHE_DIR:-}"

USER_MCPP="${MCPP_INDEX_USER_MCPP_HOME:-${HOME}/.mcpp}"
mkdir -p "$MCPP_HOME_POSIX/registry/data/xpkgs"
link_xpkgs() {
    local src="$1"
    [[ -d "$src" ]] || return 0
    find "$src" -mindepth 1 -maxdepth 1 -type d | while read -r pkg; do
        [[ "$(basename "$pkg")" == compat-x-* ]] && continue
        ln -s "$pkg" "$MCPP_HOME_POSIX/registry/data/xpkgs/$(basename "$pkg")" 2>/dev/null || true
    done
}
link_xpkgs "${MCPP_INDEX_SMOKE_XPKGS_DIR:-}"
link_xpkgs "$USER_MCPP/registry/data/xpkgs"
if [[ -d "$USER_MCPP/registry/data/xim-pkgindex" ]]; then
    mkdir -p "$MCPP_HOME_POSIX/registry/data/xim-pkgindex"
    cp -a "$USER_MCPP/registry/data/xim-pkgindex/." "$MCPP_HOME_POSIX/registry/data/xim-pkgindex/" 2>/dev/null || true
    rm -f "$MCPP_HOME_POSIX/registry/data/xim-pkgindex/.xlings-index-cache.json"
fi
if [[ -d "$USER_MCPP/registry/bin" ]]; then
    mkdir -p "$MCPP_HOME_POSIX/registry"
    ln -s "$USER_MCPP/registry/bin" "$MCPP_HOME_POSIX/registry/bin" 2>/dev/null || true
fi
if [[ -f "$USER_MCPP/config.toml" ]]; then
    cp -f "$USER_MCPP/config.toml" "$MCPP_HOME_POSIX/config.toml" 2>/dev/null || true
fi

"$MCPP_BIN_POSIX" self config --mirror "${MCPP_INDEX_MIRROR:-GLOBAL}"

copy_smoke_cache() {
    [[ -n "$SMOKE_CACHE_DIR" && -d "$SMOKE_CACHE_DIR" ]] || return 0
    mkdir -p .mcpp/.xlings/data/runtimedir
    find "$SMOKE_CACHE_DIR" -maxdepth 1 -type f \
        \( -name '*.tar.gz' -o -name '*.tar.xz' -o -name '*.zip' \) \
        -exec cp -f {} .mcpp/.xlings/data/runtimedir/ \;
}

write_build_ldflags() {
    case "$platform" in
        Linux)
            cat <<'EOF'

[build]
ldflags = ["-ldl", "-lm"]
EOF
            ;;
        Darwin)
            cat <<'EOF'

[build]
ldflags = ["-lm"]
EOF
            ;;
    esac
}

make_project() {
    local name="$1"
    mkdir -p "$TMP/$name/src"
    cd "$TMP/$name"
    cat > mcpp.toml <<EOF
[package]
name = "$name"
version = "0.1.0"

[toolchain]
default = "$TOOLCHAIN"

[indices]
compat = { path = "$INDEX_ROOT" }

[targets.$name]
kind = "bin"
main = "src/main.cpp"
EOF
    copy_smoke_cache
}

make_project "compat-portable-core-smoke"
cat >> mcpp.toml <<'EOF'

[dependencies.compat]
gtest = "1.15.2"
ftxui = "6.1.9"
lua = "5.4.7"
mbedtls = "3.6.1"
opengl = "2026.05.31"
khrplatform = "2026.05.31"
EOF
write_build_ldflags >> mcpp.toml
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

TEST(CompatPortableCore, UpstreamHeadersAndRuntime) {
    using namespace ftxui;
    Element document = hbox({text("compat"), separator(), text("ftxui")});
    Screen screen = Screen::Create(Dimension::Fit(document), Dimension::Fit(document));
    Render(screen, document);
    const std::string rendered = screen.ToString();
    EXPECT_NE(rendered.find("compat"), std::string::npos);
    EXPECT_NE(rendered.find("ftxui"), std::string::npos);

    lua_State* state = luaL_newstate();
    ASSERT_NE(state, nullptr);
    luaL_openlibs(state);
    ASSERT_EQ(luaL_dostring(state, "return 20 + 22"), LUA_OK);
    EXPECT_TRUE(lua_isinteger(state, -1));
    EXPECT_EQ(lua_tointeger(state, -1), 42);
    lua_close(state);

    const unsigned char input[] = "abc";
    std::array<unsigned char, 32> out{};
    mbedtls_sha256(input, 3, out.data(), 0);
    EXPECT_EQ(out[0], 0xba);
    EXPECT_EQ(out[1], 0x78);
    EXPECT_EQ(out[30], 0x15);
    EXPECT_EQ(out[31], 0xad);

    EXPECT_EQ(GL_TEXTURE_2D, 0x0DE1);
    EXPECT_EQ(static_cast<khronos_uint32_t>(1), 1u);
}
EOF
"$MCPP_BIN_POSIX" build
"$MCPP_BIN_POSIX" run

make_project "compat-portable-archive-smoke"
cat >> mcpp.toml <<'EOF'

[dependencies.compat]
libarchive = "3.8.7"
EOF
cat > src/main.cpp <<'EOF'
#include <archive.h>
#include <archive_entry.h>
#include <bzlib.h>
#include <lz4.h>
#include <lzma.h>
#include <zlib.h>
#include <zstd.h>

int main() {
    archive* writer = archive_write_new();
    if (!writer) return 1;
    archive_write_free(writer);

    archive_entry* entry = archive_entry_new();
    if (!entry) return 2;
    archive_entry_free(entry);

    if (!archive_version_string()) return 3;
    if (!zlibVersion()) return 4;
    if (!BZ2_bzlibVersion()) return 5;
    if (LZ4_versionNumber() <= 0) return 6;
    if (ZSTD_versionNumber() == 0) return 7;
    if (lzma_version_number() == 0) return 8;
    return 0;
}
EOF
"$MCPP_BIN_POSIX" build
"$MCPP_BIN_POSIX" run

make_project "compat-portable-imgui-glfw-smoke"
cat >> mcpp.toml <<'EOF'

[dependencies.compat]
imgui = "1.92.8"
glfw = "3.4"
EOF
cat > src/main.cpp <<'EOF'
#include <cstdlib>

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <imgui.h>
#include <imgui_impl_glfw.h>
#include <imgui_impl_opengl3.h>

#include "imgui_impl_glfw.cpp"
#include "imgui_impl_opengl3.cpp"

static int run_glfw_window_smoke() {
    if (!glfwInit()) {
        return 10;
    }

    glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);

    GLFWwindow* window = glfwCreateWindow(64, 64, "mcpp compat glfw", nullptr, nullptr);
    if (!window) {
        glfwTerminate();
        return 11;
    }

    glfwMakeContextCurrent(window);
    glfwDestroyWindow(window);
    glfwTerminate();
    return 0;
}

int main() {
    if (std::getenv("MCPP_INDEX_RUN_GLFW_WINDOW_SMOKE")) {
        return run_glfw_window_smoke();
    }

    const char* glfw = glfwGetVersionString();
    const char* imgui = ImGui::GetVersion();
    return glfw && imgui &&
           GLFW_VERSION_MAJOR == 3 &&
           IMGUI_VERSION_NUM >= 19200 ? 0 : 1;
}
EOF
"$MCPP_BIN_POSIX" build
"$MCPP_BIN_POSIX" run

echo "OK"
