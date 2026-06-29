#!/usr/bin/env bash
# Smoke-test the public imgui module package through this checkout as a local
# mcpp path index. This validates user-facing import-only consumption.
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
# Reseed cleanly. The smoke jobs share one MCPP_HOME across several scripts, so
# an earlier smoke may already have populated mcpplibs/.git with read-only pack
# objects; `cp -a "$ROOT/."` over those then fails with "Permission denied".
# Remove the destination first, and skip the repo's own .git — its pack objects
# are read-only and irrelevant to the package index (which only needs pkgs/),
# and are the sole reason the copy ever conflicts.
rm -rf "$default_index"
mkdir -p "$default_index"
( cd "$ROOT" && find . -mindepth 1 -maxdepth 1 ! -name .git -exec cp -a {} "$default_index/" \; )
rm -f "$default_index/.xlings-index-cache.json"
printf 'ok\n' > "$default_index/.mcpp-index-updated"

"$MCPP_BIN" self config --mirror "${MCPP_INDEX_MIRROR:-GLOBAL}" >/dev/null

mkdir -p "$TMP/imgui-module-smoke/src"
cd "$TMP/imgui-module-smoke"
cat > mcpp.toml <<EOF
[package]
name = "imgui-module-smoke"
version = "0.1.0"

[toolchain]
default = "${MCPP_INDEX_IMGUI_MODULE_TOOLCHAIN:-llvm@20.1.7}"

[dependencies]
imgui = "0.0.1"

[targets.imgui-module-smoke]
kind = "bin"
main = "src/main.cpp"
EOF

cat > src/main.cpp <<'EOF'
import std;
import imgui.core;
import imgui.backend.glfw_opengl3;

int main() {
    auto init = &ImGui::Backend::GlfwOpenGL3::Init;
    auto shutdown = &ImGui::Backend::GlfwOpenGL3::Shutdown;
    if (init == nullptr || shutdown == nullptr) {
        return 1;
    }

    ImGuiContext* context = ImGui::CreateContext();
    if (context == nullptr) {
        return 2;
    }
    ImGui::SetCurrentContext(context);

    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize = ImVec2 { 320.0f, 240.0f };
    unsigned char* pixels = nullptr;
    int width = 0;
    int height = 0;
    io.Fonts->GetTexDataAsRGBA32(&pixels, &width, &height);
    if (pixels == nullptr || width <= 0 || height <= 0) {
        ImGui::DestroyContext(context);
        return 3;
    }

    ImGui::NewFrame();
    bool open = true;
    ImGui::Begin("mcpp-index imgui smoke", &open);
    ImGui::TextUnformatted("import imgui.core");
    ImGui::End();
    ImGui::Render();

    std::println("Dear ImGui {} module package ok", ImGui::GetVersion());
    ImGui::DestroyContext(context);
    return 0;
}
EOF

"$MCPP_BIN" build
"$MCPP_BIN" run
