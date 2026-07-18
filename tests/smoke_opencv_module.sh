#!/usr/bin/env bash
# Smoke-test the public opencv module package through this checkout as a local
# mcpp path index. This validates user-facing import-only consumption:
# `[dependencies] opencv = "0.0.2"` → `import opencv.cv;`. Linux-only (the
# package's compat.ffmpeg dependency ships a linux-x86_64 config snapshot).
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
    echo "SKIP: opencv module package is linux-only for now."
    exit 0
fi

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

# compat.opencv5 carries NASM .asm sources; mcpp bootstraps nasm from the
# sandbox package index. Release archives vendor a pre-xim-pkgindex#398
# snapshot whose nasm.lua "installs" empty (mcpp#232) — refresh BEFORE
# reseeding the default index below so the update can't clobber the reseed.
"$MCPP_BIN" index update

default_index="$MCPP_HOME/registry/data/mcpplibs"
# Reseed cleanly (see smoke_imgui_module.sh for why .git is skipped).
rm -rf "$default_index"
mkdir -p "$default_index"
( cd "$ROOT" && find . -mindepth 1 -maxdepth 1 ! -name .git -exec cp -a {} "$default_index/" \; )
rm -f "$default_index/.xlings-index-cache.json"
printf 'ok\n' > "$default_index/.mcpp-index-updated"

"$MCPP_BIN" self config --mirror "${MCPP_INDEX_MIRROR:-GLOBAL}" >/dev/null

mkdir -p "$TMP/opencv-module-smoke/src"
cd "$TMP/opencv-module-smoke"
cat > mcpp.toml <<EOF
[package]
name = "opencv-module-smoke"
version = "0.1.0"

[toolchain]
default = "${MCPP_INDEX_OPENCV_MODULE_TOOLCHAIN:-gcc@16.1.0}"

[dependencies]
opencv = "0.0.2"

[targets.opencv-module-smoke]
kind = "bin"
main = "src/main.cpp"
EOF

cat > src/main.cpp <<'EOF'
import std;
import opencv.cv;

int main() {
    if (cv::getVersionString() != "5.0.0") return 1;

    cv::Mat img(64, 64, cv::CV_8UC3, cv::Scalar(30, 60, 90));
    cv::circle(img, {32, 32}, 20, {255, 255, 255}, -1);
    cv::Mat big, gray;
    cv::resize(img, big, {128, 128}, 0, 0, cv::INTER_CUBIC);
    cv::cvtColor(big, gray, cv::COLOR_BGR2GRAY);
    if (gray.size() != cv::Size(128, 128)) return 2;

    for (const char* ext : { ".png", ".jpg" }) {
        std::vector<unsigned char> buf;
        if (!cv::imencode(ext, big, buf)) return 3;
        cv::Mat back = cv::imdecode(buf, cv::IMREAD_COLOR);
        if (back.empty() || back.size() != big.size()) return 4;
    }

    if (cv::videoio_registry::getBackends().empty()) return 5;
    std::println("OpenCV {} module package ok", cv::getVersionString());
    return 0;
}
EOF

"$MCPP_BIN" build
"$MCPP_BIN" run
