#!/usr/bin/env bash
# Build a minimal Dear ImGui + GLFW + OpenGL window program through this
# checkout as a local mcpp path index. Runtime execution is opt-in because it
# requires a live X11/GLX display, but when enabled it must run through mcpp
# without test-local library shims.
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

glfw_pkg="$ROOT/pkgs/c/compat.glfw.lua"
grep -q 'dlopen_libs' "$glfw_pkg" || {
    echo "FATAL: compat.glfw missing GLX/OpenGL dlopen runtime metadata" >&2
    exit 1
}
grep -q 'opengl.glx.driver' "$glfw_pkg" || {
    echo "FATAL: compat.glfw missing OpenGL GLX system capability metadata" >&2
    exit 1
}

TMP="$(mktemp -d)"
if [[ "${MCPP_INDEX_KEEP_SMOKE_TMP:-0}" == "1" ]]; then
    echo "KEEP: $TMP"
else
    trap 'rm -rf "$TMP"' EXIT
fi
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

mkdir -p "$TMP/compat-imgui-window-smoke/src"
cd "$TMP/compat-imgui-window-smoke"
cat > mcpp.toml <<EOF
[package]
name = "compat-imgui-window-smoke"
version = "0.1.0"

[toolchain]
default = "gcc@16.1.0"

[indices]
compat = { path = "$ROOT" }

[dependencies.compat]
imgui = "1.92.8"
glfw = "3.4"

[build]
ldflags = ["-ldl"]

[targets.compat-imgui-window-smoke]
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
#include <cstdio>

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <imgui.h>
#include <imgui_impl_glfw.h>
#include <imgui_impl_opengl3.h>

#include "imgui_impl_glfw.cpp"
#include "imgui_impl_opengl3.cpp"

int main() {
    glfwSetErrorCallback([](int code, const char* message) {
        std::fprintf(stderr, "GLFW error %d: %s\n", code, message ? message : "");
    });

    if (!glfwInit()) {
        return 10;
    }

    glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);

    GLFWwindow* window = glfwCreateWindow(320, 180, "mcpp compat imgui", nullptr, nullptr);
    if (!window) {
        glfwTerminate();
        return 11;
    }

    glfwMakeContextCurrent(window);

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize = ImVec2(320.0f, 180.0f);
    io.DeltaTime = 1.0f / 60.0f;

    if (!ImGui_ImplGlfw_InitForOpenGL(window, true)) {
        ImGui::DestroyContext();
        glfwDestroyWindow(window);
        glfwTerminate();
        return 12;
    }
    if (!ImGui_ImplOpenGL3_Init("#version 110")) {
        ImGui_ImplGlfw_Shutdown();
        ImGui::DestroyContext();
        glfwDestroyWindow(window);
        glfwTerminate();
        return 13;
    }

    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplGlfw_NewFrame();
    ImGui::NewFrame();
    ImGui::Begin("compat imgui");
    ImGui::Text("hello from mcpp");
    ImGui::End();
    ImGui::Render();
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();
    glfwDestroyWindow(window);
    glfwTerminate();
    return 0;
}
EOF

"$MCPP_BIN" build

bin="$(find target -path '*/bin/compat-imgui-window-smoke' -type f | head -1)"
if [[ -z "$bin" ]]; then
    echo "FATAL: built binary not found" >&2
    exit 1
fi

if command -v readelf >/dev/null 2>&1; then
    for lib in \
        libX11.so.6 \
        libXcursor.so.1 \
        libXext.so.6 \
        libXfixes.so.3 \
        libXi.so.6 \
        libXinerama.so.1 \
        libXrandr.so.2 \
        libXrender.so.1; do
        readelf -d "$bin" | grep -q "Shared library: \\[$lib\\]"
    done
fi

if [[ "${MCPP_INDEX_RUN_WINDOW_SMOKE:-0}" != "1" ]]; then
    echo "SKIP: set MCPP_INDEX_RUN_WINDOW_SMOKE=1 to run the GLX/OpenGL window smoke"
    echo "OK"
    exit 0
fi
if [[ -z "${DISPLAY:-}" ]]; then
    echo "FATAL: DISPLAY is required for MCPP_INDEX_RUN_WINDOW_SMOKE=1" >&2
    exit 1
fi

"$MCPP_BIN" run
echo "OK"
