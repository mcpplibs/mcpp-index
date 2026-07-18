#!/usr/bin/env python3
"""gen_descriptor.py — emit pkgs/c/compat.opencv5.lua from the reference build.

Inputs: <opencv-src> <cmake-build-dir> <version> <sha256> <out.lua>
The build dir must contain ninja-cmds.log (`ninja -t commands`) and the
completed generator outputs (see gen_config.sh).

Descriptor anatomy (the "full source-build + build.mcpp synthesis" shape):
- xpm: official GitHub tag tarball + gitcode CN mirror, sha256-pinned.
- generated_files: the small frozen config snapshot (cvconfig.h,
  cv_cpu_config.h, dispatch stubs, simd_declarations, 3rdparty configs …
  ~60 KB), plus build.mcpp (consumer-side synthesizer) and tu_manifest.txt
  (drives the forwarding-TU layer).
- sources: only the NASM .asm units — every C/C++ TU enters the build as a
  build.mcpp `mcpp:generated=` forwarding stub (unique basenames, see
  mcpp#233; BITS_IN_JSAMPLE re-compiles; spacey defines via prelude,
  mcpp#234).
- flags: layered per-glob entries — per-group dirs (**/tu/<grp>/**),
  per-ISA suffixes (**/*.avx2.cpp …), per-file extras; verified by exact
  reconstruction against every reference compile command.
"""
import re, shlex, sys
from collections import defaultdict
from pathlib import Path

SRC = Path(sys.argv[1]).resolve()
BLD = Path(sys.argv[2]).resolve()
VERSION = sys.argv[3]
SHA256 = sys.argv[4]
OUT = Path(sys.argv[5])
HERE = Path(__file__).resolve().parent

# ── parse `ninja -t commands` ───────────────────────────────────────────
compiles = []
for line in (BLD / "ninja-cmds.log").read_text().splitlines():
    line = line.strip()
    if not line:
        continue
    try:
        toks = shlex.split(line)
    except ValueError:
        continue
    if not toks:
        continue
    tool = Path(toks[0]).name
    if tool not in ("g++", "gcc", "cc", "c++", "clang", "clang++", "nasm"):
        continue
    tool = "nasm" if tool == "nasm" else ("g++" if tool in ("g++", "c++", "clang++") else "gcc")
    src = None; defs = set(); mflags = []; incs = []; std = None
    skip = False
    for i in range(1, len(toks)):
        t = toks[i]
        if skip: skip = False; continue
        if t in ("-o", "-MF", "-MT", "-MQ"): skip = True; continue
        if t == "-MD":
            if tool == "nasm": skip = True
            continue
        if t == "-c" or t == "-isystem": continue
        if t.startswith("-std="): std = t; continue
        if t.startswith("-D"): defs.add(t); continue
        if t.startswith("-I"): incs.append(t[2:].strip('"')); continue
        if t.startswith("-m") or t in ("-O3", "-O2"): mflags.append(t); continue
        if re.search(r"\.(c|cc|cpp|cxx|asm)$", t) and not t.startswith("-"):
            src = t
    if src is None:
        continue
    src_abs = src if src.startswith("/") else str(BLD / src)
    compiles.append((tool, src_abs, frozenset(defs), tuple(mflags), incs, std))
assert compiles, "no compile commands parsed"
print(f"parsed {len(compiles)} compiles")

ISA_RE = re.compile(r"\.(sse4_1|sse4_2|avx512_skx|avx2|avx|fp16)\.cpp$")
MODS = ("core", "imgproc", "imgcodecs", "highgui", "videoio", "flann", "geometry")

def dir_key(src_abs, defs):
    s = src_abs
    if "3rdparty/libjpeg-turbo" in s:
        if s.endswith(".asm"): return "jpeg-asm"
        if "-DBITS_IN_JSAMPLE=12" in defs: return "jpeg12"
        if "-DBITS_IN_JSAMPLE=16" in defs: return "jpeg16"
        return "jpeg"
    if "3rdparty/libpng" in s: return "png"
    if "3rdparty/zlib" in s: return "zlib"
    for mod in MODS:
        if f"modules/{mod}/" in s: return mod
    raise SystemExit(f"unclassified source: {s}")

groups = defaultdict(list)
for c in compiles:
    isa = ISA_RE.search(c[1])
    groups[(dir_key(c[1], c[2]), isa.group(1) if isa else None)].append(c)

dir_defs, dir_m, file_extras = {}, {}, {}
for (dk, isa), cs in groups.items():
    if isa: continue
    common = frozenset.intersection(*[c[2] for c in cs])
    dir_defs[dk], dir_m[dk] = common, cs[0][3]
    for c in cs:
        if c[2] - common:
            file_extras[c[1]] = c[2] - common

isa_defs, isa_m = {}, {}
for (dk, isa), cs in sorted(groups.items(), key=lambda kv: (kv[0][0], kv[0][1] or "")):
    if not isa: continue
    for c in cs:
        extra = c[2] - dir_defs[dk]
        extram = tuple(f for f in c[3] if f not in dir_m[dk])
        if isa not in isa_defs:
            isa_defs[isa], isa_m[isa] = extra, extram
        else:
            assert isa_defs[isa] == extra and isa_m[isa] == extram, \
                f"ISA overlay mismatch for {isa}: {c[1]}"

# exact reconstruction check
for tool, src_abs, defs, mflags, incs, std in compiles:
    dk = dir_key(src_abs, defs)
    isa = ISA_RE.search(src_abs)
    want = set(dir_defs[dk]) | (set(isa_defs[isa.group(1)]) if isa else set()) \
         | set(file_extras.get(src_abs, ()))
    assert want == set(defs), f"reconstruction failed for {src_abs}: {want ^ set(defs)}"
print("exact flag reconstruction: OK")

# common -m flags across every non-asm group must agree (baseline)
baselines = {dir_m[dk] for dk in dir_defs if dk != "jpeg-asm"}
assert len(baselines) == 1, f"baseline -m flags differ between groups: {baselines}"
baseline_m = [f for f in next(iter(baselines)) if f.startswith("-m")]

# spacey defines → stub preludes (mcpp#234)
preludes = defaultdict(list)
for dk in sorted(dir_defs):
    keep = set()
    for f in dir_defs[dk]:
        body = f[2:]
        if " " in body:
            name, _, val = body.partition("=")
            preludes[dk].append(f"#define {name} {val}")
        else:
            keep.add(f)
    dir_defs[dk] = frozenset(keep)
for k in list(file_extras):
    assert all(" " not in f[2:] for f in file_extras[k]), f"spacey per-file define: {k}"

# ── tu manifest + per-file extra globs ──────────────────────────────────
def target_of(src_abs):
    """include-target: wrap-relative (via -I *) or snapshot-relative (via -I mcpp_generated)"""
    if src_abs.startswith(str(SRC)):
        return str(Path(src_abs).relative_to(SRC))
    return str(Path(src_abs).relative_to(BLD))

manifest, sources_asm, extra_glob_entries, seen = [], [], [], set()
for dk in sorted(preludes):
    for l in sorted(preludes[dk]):
        manifest.append(f"!prelude\t{dk}\t{l}")
for tool, src_abs, defs, mflags, incs, std in compiles:
    dk = dir_key(src_abs, defs)
    if tool == "nasm":
        rel = Path(src_abs).relative_to(SRC)
        e = f"*/{rel}"
        if e not in seen:
            seen.add(e); sources_asm.append(e)
        continue
    tgt = target_of(src_abs)
    key = (dk, tgt)
    if key in seen: continue
    seen.add(key)
    manifest.append(f"{dk}\t{tgt}")
    if src_abs in file_extras:
        mangled = tgt.replace("/", "_")
        extra_glob_entries.append((f"**/tu/{dk}/{mangled}", file_extras[src_abs]))
# kernel TUs are synthesized by build.mcpp (clsrc/…) — route them through
# the manifest too, replacing their reference-build originals
manifest = [l for l in manifest if "opencl_kernels_" not in l or l.startswith("!")]
for m in ("core", "imgproc", "geometry"):
    if (SRC / "modules" / m / "src" / "opencl").exists():
        manifest.append(f"{m}\tclsrc/opencl_kernels_{m}.cpp")
n_tus = sum(1 for l in manifest if not l.startswith('!'))
print(f"manifest: {n_tus} TUs; asm sources: {len(sources_asm)}")

# ── snapshot files (exclude synthesized classes) ────────────────────────
def rewrite(text):
    return (text.replace(f'"{SRC}/', '"').replace(f'{SRC}/', '')
                .replace(f'"{BLD}/', '"').replace(f'{BLD}/', ''))

snapshot = {}
for p in sorted(BLD.rglob("*")):
    if p.is_dir() or "CMakeFiles" in p.parts:
        continue
    if p.name.startswith(("CMake", "cmake_", "CPack", ".ninja", "ninja")):
        continue
    if p.suffix not in (".h", ".hpp", ".inc", ".cpp", ".c", ".asm"):
        continue
    if "builtin_font" in p.name or "opencl_kernels" in p.name:
        continue    # build.mcpp synthesizes these
    rel = p.relative_to(BLD)
    content = rewrite(p.read_text(errors="replace"))
    assert "]==]" not in content, f"lua long-bracket collision in {rel}"
    assert len(content) < 200_000, f"unexpectedly large snapshot file {rel}"
    snapshot[f"mcpp_generated/{rel}"] = content
print(f"snapshot: {len(snapshot)} files, {sum(len(v) for v in snapshot.values())//1024} KiB inline")

build_mcpp_src = (HERE / "build_mcpp_template.cpp").read_text()
assert "]==]" not in build_mcpp_src

# ── include dirs ────────────────────────────────────────────────────────
incdirs, iseen = ["mcpp_generated", "*"], {"mcpp_generated", "*"}
for c in compiles:
    for i in c[4]:
        if i.startswith(str(SRC)):
            r = "*/" + str(Path(i).relative_to(SRC)) if i != str(SRC) else "*"
        elif i.startswith(str(BLD)):
            r = "mcpp_generated/" + str(Path(i).relative_to(BLD)) if i != str(BLD) else "mcpp_generated"
        else:
            continue
        if r not in iseen:
            iseen.add(r); incdirs.append(r)

# ── emit lua ────────────────────────────────────────────────────────────
def D(x): return x[2:]
def lua_list(items, ind):
    return ("\n" + ind).join(f'"{i}",' for i in items)

flags_entries = []
for dk in sorted(dir_defs):
    if dk == "jpeg-asm": continue
    key = "cflags" if dk in ("zlib", "png", "jpeg", "jpeg12", "jpeg16") else "cxxflags"
    parts = [f'glob = "**/tu/{dk}/**"']
    ds = sorted(D(f) for f in dir_defs[dk])
    if ds: parts.append("defines = { " + ", ".join(f'"{d}"' for d in ds) + " }")
    flags_entries.append("{ " + ", ".join(parts) + " },")
if ("jpeg-asm", None) in groups:
    cs = groups[("jpeg-asm", None)]
    ds = sorted(D(f) for f in frozenset.intersection(*[c[2] for c in cs]))
    flags_entries.append('{ glob = "**/*.asm", defines = { ' + ", ".join(f'"{d}"' for d in ds) + " } },")
for isa in sorted(isa_defs):
    ds = sorted(D(f) for f in isa_defs[isa])
    ms = list(isa_m[isa])
    flags_entries.append(
        f'{{ glob = "**/*.{isa}.cpp", defines = {{ ' + ", ".join(f'"{d}"' for d in ds)
        + ' }, cxxflags = { ' + ", ".join(f'"{m}"' for m in ms) + " } },")
for g, extra in sorted(extra_glob_entries):
    ds = sorted(D(f) for f in extra)
    flags_entries.append(f'{{ glob = "{g}", defines = {{ ' + ", ".join(f'"{d}"' for d in ds) + " } },")

# upstream reference uses -std=c++17; the index floor is c++23 and the whole
# TU set builds green under gcc16 -std=c++23 (validated by the O0 spike).
cxx_std = {c[5] for c in compiles if c[0] == "g++" and c[5]}
assert cxx_std == {"-std=c++17"}, f"unexpected upstream C++ std set: {cxx_std}"

L = []
L.append(f"""-- Auto-generated by tools/compat-opencv5/gen_descriptor.py — do not edit by hand.
-- Recipe: OpenCV {VERSION} built FROM SOURCE by mcpp (no CMake at build
-- time). v0.1 scope: core imgproc imgcodecs highgui videoio (+ flann,
-- geometry dependency closure); hermetic profile (all external probes OFF,
-- vendored zlib/libpng/libjpeg-turbo incl. 27 NASM SIMD units, headless
-- highgui, V4L2 videoio, WITH_UNIFONT=OFF); SIMD runtime dispatch KEPT
-- (per-ISA glob flags). Small config snapshot inlined below; the large
-- build-time products (font hex headers, OpenCL kernel embeddings, the
-- forwarding-TU layer) are synthesized on the consumer by the embedded
-- build.mcpp — byte-faithful ports verified against the reference CMake
-- build. Regenerate: sh tools/compat-opencv5/gen_config.sh (this repo).
package = {{
    spec        = "1",
    namespace   = "compat",
    name        = "compat.opencv5",
    description = "OpenCV {VERSION} (core/imgproc/imgcodecs/highgui/videoio), full source build with SIMD dispatch",
    licenses    = {{"Apache-2.0"}},
    repo        = "https://github.com/opencv/opencv",
    type        = "package",

    xpm = {{
        -- linux-x86_64 only for now: the config snapshot is target-specific.
        linux = {{
            ["{VERSION}"] = {{
                url    = {{
                    GLOBAL = "https://github.com/opencv/opencv/archive/refs/tags/{VERSION}.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/{VERSION}/opencv-{VERSION}.tar.gz",
                }},
                sha256 = "{SHA256}",
            }},
        }},
    }},

    mcpp = {{
        language     = "c++23",  -- upstream min c++17; c++23 spike-validated (457 TU green)
        include_dirs = {{
            {lua_list(incdirs, " " * 12)}
        }},
        cxxflags = {{ {", ".join(f'"{m}"' for m in baseline_m)}, "-w" }},
        cflags   = {{ {", ".join(f'"{m}"' for m in baseline_m)}, "-w" }},
        flags = {{
            {("\n" + " " * 12).join(flags_entries)}
        }},
        targets = {{
            opencv5 = {{ kind = "lib" }},
        }},
        linux = {{
            ldflags = {{ "-lpthread", "-ldl" }},
        }},
        sources = {{
            {lua_list(sources_asm, " " * 12)}
        }},
        generated_files = {{
""")
L.append(f'        ["build.mcpp"] = [==[\n{build_mcpp_src}]==],\n')
L.append('        ["mcpp_generated/tu_manifest.txt"] = [==[\n' + "\n".join(manifest) + "\n]==],\n")
for rel in sorted(snapshot):
    L.append(f'        ["{rel}"] = [==[\n{snapshot[rel]}]==],\n')
L.append("""        },
    },
}
""")
OUT.write_text("".join(L))
kb = OUT.stat().st_size // 1024
print(f"gen_descriptor: {OUT} written — {n_tus} TUs via build.mcpp, "
      f"{len(sources_asm)} asm sources, {len(snapshot)} inline snapshot files, {kb} KiB")
