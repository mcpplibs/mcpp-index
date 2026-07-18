#!/usr/bin/env bash
# Smoke-test the public ffmpeg module package through this checkout as a local
# mcpp path index. This validates user-facing import-only consumption:
# `[dependencies] ffmpeg = "0.0.1"` → `import ffmpeg.av;`. Linux-only (the
# package's compat.ffmpeg dependency ships a linux-x86_64 config snapshot).
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
    echo "SKIP: ffmpeg module package is linux-only for now."
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

# compat.ffmpeg carries NASM .asm sources; mcpp bootstraps nasm from the
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

mkdir -p "$TMP/ffmpeg-module-smoke/src"
cd "$TMP/ffmpeg-module-smoke"
cat > mcpp.toml <<EOF
[package]
name = "ffmpeg-module-smoke"
version = "0.1.0"

[toolchain]
default = "${MCPP_INDEX_FFMPEG_MODULE_TOOLCHAIN:-gcc@16.1.0}"

[dependencies]
ffmpeg = "0.0.1"

[targets.ffmpeg-module-smoke]
kind = "bin"
main = "src/main.cpp"
EOF

cat > src/main.cpp <<'EOF'
import std;
import ffmpeg.av;

int main() {
    unsigned v { avutil_version() };
    std::println("libavutil {}.{} module package ok", v >> 16, (v >> 8) & 0xff);
    if ((v >> 16) != 60u) {   // libavutil major of the FFmpeg 8.1.x train
        return 1;
    }

    for (auto name : { "h264", "hevc", "av1", "aac" }) {
        const AVCodec* dec { avcodec_find_decoder_by_name(name) };
        if (dec == nullptr) {
            std::println("decoder {} MISSING", name);
            return 2;
        }
    }

    void* it { nullptr };
    long demuxers { 0 };
    while (av_demuxer_iterate(&it)) ++demuxers;
    std::println("{} demuxers registered", demuxers);
    return demuxers > 300 ? 0 : 3;
}
EOF

"$MCPP_BIN" build
"$MCPP_BIN" run
