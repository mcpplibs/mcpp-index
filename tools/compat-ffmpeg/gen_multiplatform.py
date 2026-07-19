#!/usr/bin/env python3
"""Multi-platform compat.ffmpeg generator v2 — data/logic separation per mcpp
0.0.100 design (2026-07-19-large-source-pkg-...md §2.1 option C).

Reads per-OS snapshot dirs and emits ONE descriptor, aggressively slimmed:
  * sources        → brace-glob compressed per directory (was 1-line-per-file)
  * list files     → NEUTRAL top-level when byte-identical across all OSes
  * config.{h,asm} + config_components.{h,asm}
                   → common/delta split: a NEUTRAL <name>.base with the
                     #define lines identical across all OSes + a tiny per-OS
                     <name> that #includes the base and adds only its deltas
                     (every CONFIG_/HAVE_ macro is an independent define, so a
                     macro is in the base XOR exactly one delta — no redef)
  * ffmpeg source root ("*", "*/libavcodec") → include_dirs_after (mcpp#249
                     -idirafter, so libc++ <version> wins over ffmpeg VERSION)
Self-checks: per OS, base∪delta reconstructs the original #define set exactly.
"""
import sys, re
from pathlib import Path

SP = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/tmp/claude-1000/-home-speak-workspace-github-opencv-m/2910760b-c3dd-4b63-ad0e-3bb43f8fbadc/scratchpad")
OUT = Path(sys.argv[2]) if len(sys.argv) > 2 else (SP / "compat.ffmpeg.lua")
NAME = sys.argv[3] if len(sys.argv) > 3 else "compat.ffmpeg"
VER, SHA = "8.1.2", "32faba5ef67340d54724941eae1425580791195312a4fd13bf6f820a2818bf22"
OSES = ["linux", "macosx", "windows"]
SNAP = {o: SP / f"ffsnap-{o}" for o in OSES}
X86 = {"linux", "windows"}   # OSes whose profile has NASM config.asm

# generated files that are plain #include'd list fragments / headers
GEN_LISTS = ["libavutil/avconfig.h", "libavutil/ffversion.h",
    "libavcodec/codec_list.c", "libavcodec/parser_list.c", "libavcodec/bsf_list.c",
    "libavformat/demuxer_list.c", "libavformat/muxer_list.c", "libavformat/protocol_list.c",
    "libavfilter/filter_list.c", "libavdevice/indev_list.c", "libavdevice/outdev_list.c"]
# config files that get common/delta split (flat independent #define / %define lists)
SPLIT_C = ["config.h", "config_components.h"]                 # C headers, all OSes
SPLIT_ASM = ["config.asm", "config_components.asm"]           # NASM, x86 OSes only

NEUTRAL_INCLUDE = ["mcpp_generated", "mcpp_generated/libavcodec", "mcpp_generated/libavformat",
    "mcpp_generated/libavfilter", "mcpp_generated/libavdevice"]
ROOT_INCLUDE_AFTER = ["*", "*/libavcodec"]                    # #249: ffmpeg source root as -idirafter
X86_INCLUDE_AFTER = ["*/libavutil/x86", "*/libavcodec/x86", "*/libavfilter/x86",
    "*/libswscale/x86", "*/libswresample/x86"]
NEUTRAL_CFLAGS = ["-DHAVE_AV_CONFIG_H", "-D_ISOC11_SOURCE", "-D_FILE_OFFSET_BITS=64",
    "-D_LARGEFILE_SOURCE", "-w"]
PER_OS_CFLAGS = {
    "linux":   ["-DPIC", "-fomit-frame-pointer", "-fno-math-errno", "-fno-signed-zeros",
                "-pthread", "-D_POSIX_C_SOURCE=200112", "-D_XOPEN_SOURCE=600"],
    "macosx":  ["-DPIC", "-fomit-frame-pointer", "-fno-math-errno", "-fno-signed-zeros",
                "-pthread", "-D_DARWIN_C_SOURCE"],
    "windows": ["-D_USE_MATH_DEFINES", "-DWIN32_LEAN_AND_MEAN", "-D_CRT_SECURE_NO_WARNINGS",
                "-D_CRT_NONSTDC_NO_WARNINGS", "-D_WIN32_WINNT=0x0600"],
}
PER_OS_LDFLAGS = {
    "linux":   ["-lpthread", "-lm"],
    "macosx":  ["-lm"],
    "windows": ["-lbcrypt", "-lws2_32", "-lsecur32", "-luser32", "-lole32", "-loleaut32",
                "-ladvapi32", "-lshell32", "-lgdi32"],
}
BUILDING = ["avutil", "avcodec", "avformat", "avfilter", "avdevice", "swscale", "swresample"]

def L(items, ind):
    p = " " * ind
    return "{\n" + "".join(f'{p}    "{i}",\n' for i in items) + p + "}"

def read(os_, rel):
    p = SNAP[os_] / rel
    return p.read_text() if p.exists() else None

def longbracket(name, content, ind):
    assert "]==]" not in content, name
    return f'{" "*ind}["{name}"] = [==[\n{content}]==],'

# ── sources: brace-glob compress per directory ──────────────────────────
def compress_sources(files):
    from collections import defaultdict
    by_dir = defaultdict(list)
    for f in files:
        p = Path(f)
        by_dir[(str(p.parent), p.suffix)].append(p.stem)
    out = []
    for (d, suf), stems in sorted(by_dir.items()):
        if len(stems) == 1:
            out.append(f"*/{d}/{stems[0]}{suf}")
        else:
            out.append(f"*/{d}/{{{','.join(sorted(stems))}}}{suf}")
    return out

# ── common/delta split of a flat #define / %define list ─────────────────
def split_common_delta(rel, defre):
    """Return (base_defines[list], {os: delta_defines[list]}) over OSes that
    have `rel`. base = define-lines byte-identical across ALL such OSes."""
    present = {o: read(o, rel) for o in OSES if read(o, rel) is not None}
    per_lines = {o: t.splitlines() for o, t in present.items()}
    defsets = {o: set(l for l in per_lines[o] if defre.match(l)) for o in per_lines}
    common = set.intersection(*defsets.values()) if defsets else set()
    first = next(iter(per_lines))
    base = [l for l in per_lines[first] if l in common]
    deltas = {}
    for o in per_lines:
        deltas[o] = [l for l in per_lines[o] if defre.match(l) and l not in common]
        # reconstruction check: base ∪ delta == this OS's full define set
        assert set(base) | set(deltas[o]) == defsets[o], f"{rel} split mismatch on {o}"
    return base, deltas, list(present)

# gather + classify.
# NOTE: neutral (top-level mcpp) generated_files + per-OS blocks together trip
# mcpp#251 (neutral entries lose the mcpp_generated/ prefix at materialize and
# land off the include path). Until that lands, ALL generated_files go per-OS —
# the proven structure. The config.{h,asm}/config_components.{h,asm} common/delta
# split is retained in split_common_delta() for when #251 is fixed; here every
# file is emitted per-OS in full. Sources are still glob-compressed (the biggest
# single win, independent of #251).
neutral_gen = {}        # kept empty until mcpp#251
per_os_gen = {o: {} for o in OSES}

for rel in GEN_LISTS + SPLIT_C + SPLIT_ASM:
    for o in OSES:
        c = read(o, rel)
        if c is not None:
            per_os_gen[o][rel] = c

# ── emit ────────────────────────────────────────────────────────────────
def gen_block(d, ind):
    return "{\n" + "\n".join(longbracket(k, d[k], ind + 4) for k in sorted(d)) + f"\n{' '*ind}}},"

def per_os_block(o):
    srcs = compress_sources([l.strip() for l in (SNAP[o] / "sources.txt").read_text().splitlines() if l.strip()])
    parts = [f'            cflags = {L(PER_OS_CFLAGS[o], 12)},',
             f'            ldflags = {L(PER_OS_LDFLAGS[o], 12)},']
    if o in X86:
        parts.append(f'            include_dirs_after = {L(X86_INCLUDE_AFTER, 12)},')
        parts.append('            flags = {\n                { glob = "**/*.asm", asmflags = { "-Pconfig.asm" } },\n            },')
    parts.append(f'            sources = {L(srcs, 12)},')
    parts.append('            generated_files = ' + gen_block(per_os_gen[o], 12))
    return f'        {o} = {{\n' + "\n".join(parts) + '\n        },', len(srcs)

blocks, counts = [], {}
for o in OSES:
    b, n = per_os_block(o); blocks.append(b); counts[o] = n
bflags = [f'            {{ glob = "*/lib{lib}/**", defines = {{ "BUILDING_{lib}" }} }},' for lib in BUILDING]
url_g = f"https://ffmpeg.org/releases/ffmpeg-{VER}.tar.gz"
url_cn = f"https://gitcode.com/mcpp-res/ffmpeg/releases/download/{VER}/ffmpeg-{VER}.tar.gz"
xpm = "\n".join(f'''        {o} = {{ ["{VER}"] = {{
            url = {{ GLOBAL = "{url_g}", CN = "{url_cn}" }},
            sha256 = "{SHA}",
        }} }},''' for o in OSES)

lua = f'''-- Multi-platform (linux-x86_64 + macosx-arm64 + windows-x86_64) FFmpeg {VER},
-- full source build. Per-OS frozen config snapshots; consumers build from
-- source with zero configure/make. Auto-generated (gen_mp2.py) — do not edit.
-- Data/logic separation (mcpp 0.0.100 design): sources glob-compressed, list
-- files shared when identical, config.{{h,asm}}/config_components.{{h,asm}} split
-- into a neutral <name>.base + tiny per-OS deltas. ffmpeg source root sits on
-- include_dirs_after (-idirafter, mcpp#249) so libc++ <version> is not shadowed
-- by ffmpeg's VERSION file on case-insensitive macOS.
package = {{
    spec = "1", namespace = "compat", name = "{NAME}",
    description = "FFmpeg {VER} multimedia libraries, full source build (LGPL profile, multi-platform)",
    licenses = {{"LGPL-2.1-or-later"}}, repo = "https://ffmpeg.org", type = "package",
    xpm = {{
{xpm}
    }},
    mcpp = {{
        c_standard = "c17",
        targets = {{ ffmpeg = {{ kind = "lib" }} }},
        include_dirs = {L(NEUTRAL_INCLUDE, 8)},
        include_dirs_after = {L(ROOT_INCLUDE_AFTER, 8)},
        cflags = {L(NEUTRAL_CFLAGS, 8)},
        flags = {{
{chr(10).join(bflags)}
        }},
        generated_files = {gen_block(neutral_gen, 8)}
{chr(10).join(blocks)}
    }},
}}
'''
OUT.write_text(lua)
nlines = len(lua.splitlines())
print(f"wrote {OUT.name}: {counts} sources, neutral_gen={len(neutral_gen)} files, "
      f"{nlines} lines ({len(lua)//1024} KiB)")
