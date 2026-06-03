#!/usr/bin/env bash
# Smoke-test the ImGui-related compat packages through this checkout as a
# local mcpp path index.
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
SMOKE_CACHE_DIR="${MCPP_INDEX_SMOKE_CACHE_DIR:-$TMP/smoke-cache}"
SMOKE_XPKGS_DIR="${MCPP_INDEX_SMOKE_XPKGS_DIR:-}"
mkdir -p "$SMOKE_CACHE_DIR"

if [[ -n "${MCPP_INDEX_SMOKE_MCPP_HOME:-}" ]]; then
    export MCPP_HOME="$MCPP_INDEX_SMOKE_MCPP_HOME"
else
    export MCPP_HOME="$TMP/mcpp-home"
fi
mkdir -p "$MCPP_HOME"

USER_MCPP="${HOME}/.mcpp"
mkdir -p "$MCPP_HOME/registry/data/xpkgs"
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

restore_smoke_cache() {
    [[ -n "$SMOKE_CACHE_DIR" && -d "$SMOKE_CACHE_DIR" ]] || return 0
    mkdir -p .mcpp/.xlings/data/runtimedir
    find "$SMOKE_CACHE_DIR" -maxdepth 1 -type f \
        \( -name '*.tar.gz' -o -name '*.tar.xz' -o -name '*.zip' \) \
        -exec cp -f {} .mcpp/.xlings/data/runtimedir/ \;
}

save_smoke_cache() {
    [[ -n "$SMOKE_CACHE_DIR" && -d .mcpp/.xlings/data ]] || return 0
    find .mcpp/.xlings/data -type f \
        \( -name '*.tar.gz' -o -name '*.tar.xz' -o -name '*.zip' \) \
        -exec cp -n {} "$SMOKE_CACHE_DIR"/ \; 2>/dev/null || true
}

mcpp_build() {
    "$MCPP_BIN" build
    save_smoke_cache
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
default = "gcc@16.1.0"

[indices]
compat = { path = "$ROOT" }

[targets.$name]
kind = "bin"
main = "src/main.cpp"
EOF

    restore_smoke_cache
}

make_project "compat-imgui-core-smoke"
cat >> mcpp.toml <<'EOF'

[dependencies.compat]
imgui = "1.92.8"
EOF
cat > src/main.cpp <<'EOF'
#include <imgui.h>

int main() {
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize = ImVec2(320.0f, 180.0f);
    io.DeltaTime = 1.0f / 60.0f;
    unsigned char* pixels = nullptr;
    int tex_width = 0;
    int tex_height = 0;
    io.Fonts->GetTexDataAsRGBA32(&pixels, &tex_width, &tex_height);
    io.Fonts->SetTexID(1);

    ImGui::NewFrame();
    ImGui::Begin("compat imgui smoke");
    ImGui::Text("ok");
    ImGui::End();
    ImGui::Render();

    ImDrawData* draw_data = ImGui::GetDrawData();
    const bool ok = draw_data != nullptr && draw_data->Valid;
    ImGui::DestroyContext();
    return ok ? 0 : 1;
}
EOF
mcpp_build
"$MCPP_BIN" run

make_project "compat-xlibs-runtime-smoke"
cat >> mcpp.toml <<'EOF'

[dependencies.compat]
xext = "1.3.7"
xrender = "0.9.12"
xfixes = "6.0.2"
xcursor = "1.2.3"
xinerama = "1.1.6"
xrandr = "1.5.5"
xi = "1.8.3"
EOF
cat > src/main.cpp <<'EOF'
#include <X11/Xlib.h>
#include <X11/extensions/Xext.h>
#include <X11/extensions/Xrender.h>
#include <X11/extensions/Xfixes.h>
#include <X11/Xcursor/Xcursor.h>
#include <X11/extensions/Xinerama.h>
#include <X11/extensions/Xrandr.h>
#include <X11/extensions/XInput2.h>

extern "C" int XextCreateExtension(void);

int main() {
    return XextCreateExtension != nullptr &&
           XRenderQueryExtension != nullptr &&
           XFixesQueryExtension != nullptr &&
           XcursorLibraryPath != nullptr &&
           XineramaQueryExtension != nullptr &&
           XRRQueryExtension != nullptr &&
           XIQueryVersion != nullptr ? 0 : 1;
}
EOF
mcpp_build
"$MCPP_BIN" run
if command -v readelf >/dev/null 2>&1; then
    bin="$(find target -path '*/bin/compat-xlibs-runtime-smoke' -type f | head -1)"
    for lib in libXext.so.6 libXrender.so.1 libXfixes.so.3 libXcursor.so.1 libXinerama.so.1 libXrandr.so.2 libXi.so.6; do
        test -e "$(dirname "$bin")/$lib"
        readelf -d "$bin" | grep -q "Shared library: \\[$lib\\]"
    done
fi

make_project "compat-glfw-runtime-smoke"
cat >> mcpp.toml <<'EOF'

[dependencies.compat]
glfw = "3.4"
EOF
cat > src/main.cpp <<'EOF'
#include <GLFW/glfw3.h>

int main() {
    glfwSetErrorCallback(nullptr);
    const int ok = glfwInit();
    if (ok) {
        glfwTerminate();
    }
    return GLFW_VERSION_MAJOR == 3 ? 0 : 1;
}
EOF
mcpp_build
"$MCPP_BIN" run
if command -v readelf >/dev/null 2>&1; then
    bin="$(find target -path '*/bin/compat-glfw-runtime-smoke' -type f | head -1)"
    for lib in libX11.so.6 libXcursor.so.1 libXext.so.6 libXfixes.so.3 libXi.so.6 libXinerama.so.1 libXrandr.so.2 libXrender.so.1; do
        readelf -d "$bin" | grep -q "Shared library: \\[$lib\\]"
    done
fi

make_project "compat-xorg-runtime-smoke"
cat >> mcpp.toml <<'EOF'

[dependencies.compat]
xau = "1.0.12"
xdmcp = "1.1.5"
EOF
cat > src/main.cpp <<'EOF'
#include <X11/Xauth.h>
#include <X11/Xdmcp.h>

int main() {
    ARRAY8 array{};
    const int allocated = XdmcpAllocARRAY8(&array, 1);
    if (allocated) {
        XdmcpDisposeARRAY8(&array);
    }

    char* auth_file = XauFileName();
    return allocated && auth_file != nullptr ? 0 : 1;
}
EOF
mcpp_build
"$MCPP_BIN" run
if command -v readelf >/dev/null 2>&1; then
    bin="$(find target -path '*/bin/compat-xorg-runtime-smoke' -type f | head -1)"
    test -e "$(dirname "$bin")/libXau.so.6"
    test -e "$(dirname "$bin")/libXdmcp.so.6"
    readelf -d "$bin" | grep -q 'Shared library: \[libXau.so.6\]'
    readelf -d "$bin" | grep -q 'Shared library: \[libXdmcp.so.6\]'
fi

make_project "compat-xcb-runtime-smoke"
cat >> mcpp.toml <<'EOF'

[dependencies.compat]
xcb = "1.17.0"
EOF
cat > src/main.cpp <<'EOF'
#include <cstdlib>
#include <xcb/xcb.h>

int main() {
    char* host = nullptr;
    int display = -1;
    int screen = -1;
    const int ok = xcb_parse_display(":0.1", &host, &display, &screen);
    std::free(host);
    return ok && display == 0 && screen == 1 ? 0 : 1;
}
EOF
mcpp_build
"$MCPP_BIN" run
if command -v readelf >/dev/null 2>&1; then
    bin="$(find target -path '*/bin/compat-xcb-runtime-smoke' -type f | head -1)"
    test -e "$(dirname "$bin")/libxcb.so.1"
    readelf -d "$bin" | grep -q 'Shared library: \[libxcb.so.1\]'
fi

make_project "compat-x11-runtime-smoke"
cat >> mcpp.toml <<'EOF'

[dependencies.compat]
x11 = "1.8.13"
EOF
cat > src/main.cpp <<'EOF'
#include <X11/Xlib.h>
#include <X11/keysym.h>

int main() {
    const KeySym escape = XStringToKeysym("Escape");
    return X_PROTOCOL == 11 && escape == XK_Escape ? 0 : 1;
}
EOF
mcpp_build
"$MCPP_BIN" run
if command -v readelf >/dev/null 2>&1; then
    bin="$(find target -path '*/bin/compat-x11-runtime-smoke' -type f | head -1)"
    lib="$(find target -path '*/bin/libX11.so' -type f | head -1)"
    test -e "$(dirname "$bin")/libX11.so.6"
    test -e "$(dirname "$bin")/libxcb.so.1"
    readelf -d "$bin" | grep -q 'Shared library: \[libX11.so.6\]'
    readelf -d "$lib" | grep -q 'Library soname: \[libX11.so.6\]'
    readelf -d "$lib" | grep -q 'Shared library: \[libxcb.so.1\]'
fi

echo "OK"
