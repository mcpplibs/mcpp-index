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
    "mcpp_generated/libavfilter", "mcpp_generated/libavdevice", "*/libavcodec"]
# ONLY the ffmpeg source root ('*') goes on include_dirs_after (-idirafter): it
# holds the VERSION file that shadows libc++ <version> on case-insensitive macOS
# (#249). '*/libavcodec' must stay on regular -I — ffmpeg's relative "parser.h"
# style includes need it there (on -idirafter, windows clang-MSVC fails to find
# them, e.g. opus/parser.c → ParseContext undefined).
ROOT_INCLUDE_AFTER = ["*"]
X86_INCLUDE = ["*/libavutil/x86", "*/libavcodec/x86", "*/libavfilter/x86",
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
                "-ladvapi32", "-lshell32", "-lgdi32",
                # libavdevice dshow capture backend: strmiids (DirectShow
                # CLSID_/IID_/MEDIATYPE_ GUIDs) + uuid; + shlwapi
                # (SHCreateStreamOnFileA). vfwcap dropped (avicap32.lib absent).
                "-lstrmiids", "-luuid", "-lshlwapi"],
}
BUILDING = ["avutil", "avcodec", "avformat", "avfilter", "avdevice", "swscale", "swresample"]

def L(items, ind):
    p = " " * ind
    return "{\n" + "".join(f'{p}    "{i}",\n' for i in items) + p + "}"

# Windows: the vfwcap (Video-for-Windows) capture indev needs avicap32.lib,
# which the mcpp clang-MSVC toolchain's SDK subset doesn't ship (dshow's
# strmiids IS present). vfwcap is a legacy niche capture backend — drop it:
# source excluded, indev_list entry removed, CONFIG_VFWCAP_INDEV → 0.
WIN_DROP_SOURCES = {"libavdevice/vfwcap.c"}

def read(os_, rel):
    p = SNAP[os_] / rel
    if not p.exists():
        return None
    c = p.read_text()
    if os_ == "windows":
        if rel == "config_components.h":
            c = c.replace("#define CONFIG_VFWCAP_INDEV 1", "#define CONFIG_VFWCAP_INDEV 0")
        elif rel == "libavdevice/indev_list.c":
            c = "\n".join(l for l in c.splitlines() if "vfwcap" not in l) + "\n"
    return c

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

# gather + classify (data/logic separation, mcpp 0.0.100 design doc §2.1-C)
neutral_gen = {}        # relpath -> content (identical across OSes + common bases)
per_os_gen = {o: {} for o in OSES}

# 1) list files: neutral if identical across all OSes that have them; else per-OS
for rel in GEN_LISTS:
    have = {o: read(o, rel) for o in OSES if read(o, rel) is not None}
    vals = set(have.values())
    if len(vals) == 1:
        neutral_gen[rel] = next(iter(vals))
    else:
        for o, c in have.items():
            per_os_gen[o][rel] = c

# 2) config.{h} + config_components.{h}: common/delta split (C headers)
CDEF = re.compile(r'^#define ')
for rel in SPLIT_C:
    base, deltas, present = split_common_delta(rel, CDEF)
    stem, ext = rel.rsplit(".", 1)
    base_name = f"{stem}.base.{ext}"
    neutral_gen[base_name] = "\n".join(base) + "\n"
    guardname = "FFMPEG_" + re.sub(r'[^A-Z0-9]', '_', rel.upper())
    for o in present:
        body = (f"/* mcpp: per-OS delta over {base_name} (data/logic split) */\n"
                f"#ifndef {guardname}\n#define {guardname}\n"
                f'#include "{Path(base_name).name}"\n'
                + "\n".join(deltas[o]) + ("\n" if deltas[o] else "")
                + f"#endif /* {guardname} */\n")
        per_os_gen[o][rel] = body

# 3) config.asm + config_components.asm: common/delta split (NASM), x86 OSes
ADEF = re.compile(r'^%define ')
for rel in SPLIT_ASM:
    base, deltas, present = split_common_delta(rel, ADEF)
    stem = rel.rsplit(".", 1)[0]
    base_name = f"{stem}.base.asm"
    neutral_gen[base_name] = "\n".join(base) + "\n"
    for o in present:
        body = (f"; mcpp: per-OS delta over {base_name} (data/logic split)\n"
                f'%include "{Path(base_name).name}"\n'
                + "\n".join(deltas[o]) + ("\n" if deltas[o] else ""))
        per_os_gen[o][rel] = body

# ── emit ────────────────────────────────────────────────────────────────
def gen_block(d, ind):
    # generated_files keys MUST carry the mcpp_generated/ prefix so they
    # materialize under <builddir>/mcpp_generated/ (on the -I include path).
    return "{\n" + "\n".join(longbracket("mcpp_generated/" + k, d[k], ind + 4)
                             for k in sorted(d)) + f"\n{' '*ind}}},"

def read_sources(o):
    out = [l.strip().removeprefix("src/")
           for l in (SNAP[o] / "sources.txt").read_text().splitlines()
           if l.strip() and not l.strip().removeprefix("src/").startswith("-")]
    if o == "windows":
        out = [l for l in out if l not in WIN_DROP_SOURCES]
    return out

# Reference (dir set per basename) from the OSes that build clean (linux+macosx).
# FFmpeg's shared sources (file_open.c, log2_tab.c, …) are compiled into EACH lib
# by upstream's build; the windows make-n snapshot captured them per-lib, but on
# mcpp's single-lib build those per-lib copies collide (LNK2005 ff_open already
# defined). linux/macosx snapshots list each shared source once (at its real
# dir), so restrict any OS's shared-source basenames to the dirs the clean OSes
# use. Genuinely-distinct same-basename files (libavcodec/4xm.c vs
# libavformat/4xm.c) appear in multiple dirs in the reference too, so both stay.
from collections import defaultdict as _dd
_ref = _dd(set)
for _o in ("linux", "macosx"):
    for _l in read_sources(_o):
        _ref[Path(_l).name].add(str(Path(_l).parent))

def per_os_block(o):
    raw = []
    for l in read_sources(o):
        base, d = Path(l).name, str(Path(l).parent)
        if base in _ref and d not in _ref[base]:
            continue   # shared-source per-lib duplicate not present in clean OSes
        raw.append(l)
    srcs = compress_sources(raw)
    parts = [f'            cflags = {L(PER_OS_CFLAGS[o], 12)},',
             f'            ldflags = {L(PER_OS_LDFLAGS[o], 12)},']
    if o in X86:
        parts.append(f'            include_dirs = {L(X86_INCLUDE, 12)},')
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
