#!/usr/bin/env python3
"""gen_descriptor.py — emit pkgs/c/compat.opencv.lua from the reference build.

Inputs: <opencv-src> <cmake-build-dir> <version> <sha256> <out.lua>
The build dir must contain ninja-cmds.log (`ninja -t commands`) and the
completed generator outputs (see gen_config.sh). When the reference build was
configured WITH_FFMPEG=ON (gen_config.sh does this via a local static FFmpeg
prefix), pass its prefix via env FFMPEG_PREFIX so its include dirs can be
translated to the compat.ffmpeg dependency.

Descriptor anatomy (v2, "full source-build + build.mcpp synthesis", mcpp >=
0.0.97):
- xpm: official GitHub tag tarball + gitcode CN mirror, sha256-pinned.
- generated_files: the small frozen config snapshot (cvconfig.h,
  cv_cpu_config.h, dispatch stubs, simd_declarations, 3rdparty configs …),
  plus build.mcpp (consumer-side synthesizer: fonts, OpenCL kernel
  embeddings, and the jpeg12/jpeg16 re-compile stubs) and tu_manifest.txt
  (now only drives the jpeg12/16 stubs).
- sources: REAL tarball paths (mcpp 0.0.97 fixed the obj-path collision
  #233 and spacey defines #234, so the v1 whole-build forwarding-stub layer
  is gone) + the snapshot dispatch-stub .cpp + the NASM .asm units. Only
  the BITS_IN_JSAMPLE=12/16 same-source re-compiles still need stubs (one
  source, three compiles — inexpressible as plain sources), with
  group-prefixed unique basenames (dodges mcpp#239 abs-path obj escape).
- flags: layered per-glob entries over real paths — per-group dirs
  (**/modules/<mod>/**, **/3rdparty/<lib>/**), per-ISA suffixes
  (**/*.avx2.cpp …), per-file extras; verified by exact reconstruction
  against every reference compile command. Spacey defines ride directly
  (#234 fixed).
- deps: compat.ffmpeg when the profile has HAVE_FFMPEG (videoio backend).
"""
import os, re, shlex, sys
from collections import defaultdict
from pathlib import Path

SRC = Path(sys.argv[1]).resolve()
BLD = Path(sys.argv[2]).resolve()
VERSION = sys.argv[3]
SHA256 = sys.argv[4]
OUT = Path(sys.argv[5])
HERE = Path(__file__).resolve().parent
FF_PREFIX = os.environ.get("FFMPEG_PREFIX", "")
BASE_BLD = Path(os.environ["BASE_BLD"]).resolve() if os.environ.get("BASE_BLD") else None
FFMPEG_DEP_VERSION = os.environ.get("FFMPEG_DEP_VERSION", "8.1.2")

def rel_posix(child, parent):
    """child relative to parent as a forward-slashed str, or None if not under
    parent. Separator-agnostic — Windows clang-cl command paths mix '/' and '\\',
    so plain str.startswith(str(SRC)) comparisons fail; go through pathlib."""
    c, p = Path(child), Path(parent)
    if c == p:
        return ""
    try:
        return c.relative_to(p).as_posix()
    except ValueError:
        return None

# ── parse `ninja -t commands` ───────────────────────────────────────────
compiles = []
DRIVE_ABS = re.compile(r"^[A-Za-z]:[\\/]")
for raw in (BLD / "ninja-cmds.log").read_text().splitlines():
    raw = raw.strip()
    if not raw:
        continue
    # Windows (clang-cl / win64 nasm) lines carry backslash paths that shlex's
    # POSIX mode would treat as escapes; normalise to forward slashes first (no
    # meaningful backslash-escapes appear in these commands). Linux/macOS lines
    # have no backslashes so this is a no-op for them.
    is_win = ("clang-cl" in raw.lower()) or bool(re.search(r"[A-Za-z]:\\", raw))
    line = raw.replace("\\", "/") if is_win else raw
    try:
        toks = shlex.split(line)
    except ValueError:
        continue
    if not toks:
        continue
    tool_raw = Path(toks[0].strip('"')).name.lower()
    if tool_raw.endswith(".exe"):
        tool_raw = tool_raw[:-4]
    if tool_raw == "clang-cl":
        tool = "g++"          # clang-cl builds .c and .cpp; source extension decides downstream
    elif tool_raw == "nasm":
        tool = "nasm"
    elif tool_raw in ("g++", "gcc", "cc", "c++", "clang", "clang++"):
        tool = "g++" if tool_raw in ("g++", "c++", "clang++") else "gcc"
    else:
        continue
    src = None; defs = set(); mflags = []; incs = []; std = None
    skip = False
    for i in range(1, len(toks)):
        t = toks[i]
        if skip: skip = False; continue
        # gnu depfile/output flags that consume the next token (never on clang-cl,
        # where -MT is the *runtime* selector, not a depfile target)
        if not is_win and t in ("-o", "-MF", "-MT", "-MQ"): skip = True; continue
        if tool == "nasm" and t == "-o": skip = True; continue
        if t == "-MD":
            if tool == "nasm": skip = True
            continue
        if t == "-c": continue
        if is_win:
            if t.startswith(("/Fo", "/Fd", "/Fi", "/Fa", "/Fp")): continue   # output artifacts
            if t.startswith("-clang:"): continue                             # depfile passthrough (-clang:-MD/-MF/-MT)
            if t in ("/D", "/I", "/U"):                                       # msvc space-separated define/include
                if i + 1 < len(toks):
                    nx = toks[i + 1].strip('"')
                    if t == "/D": defs.add("-D" + nx)
                    elif t == "/I": incs.append(nx)
                    skip = True
                continue
            if t.startswith("/D"): defs.add("-D" + t[2:]); continue
            if t.startswith("/I"): incs.append(t[2:].strip('"')); continue
            if t.startswith("-imsvc"):                                        # clang-cl system include
                d = t[len("-imsvc"):].strip('"')
                if d: incs.append(d)
                elif i + 1 < len(toks): incs.append(toks[i + 1].strip('"')); skip = True
                continue
            if t.startswith(("/std:", "-std:")): std = "-std=" + t.split(":", 1)[1]; continue  # clang-cl -std:c++17 -> canonical
            # msvc codegen/warning/runtime flags mcpp supplies itself — drop
            if t.startswith("/") or t in ("-TP", "-TC") or t.startswith(("-W", "-Q")): continue
        if t == "-isystem":
            if i + 1 < len(toks): incs.append(toks[i + 1].strip('"'))
            skip = True; continue
        if t.startswith("-std="): std = t; continue
        if t.startswith("-D"): defs.add(t); continue
        if t.startswith("-I"): incs.append(t[2:].strip('"')); continue
        if t.startswith("-m") or t in ("-O3", "-O2"): mflags.append(t); continue
        if re.search(r"\.(c|cc|cpp|cxx|asm|S)$", t, re.I) and not t.startswith("-"):
            src = t
    if src is None:
        continue
    is_abs = src.startswith("/") or bool(DRIVE_ABS.match(src))
    src_abs = src if is_abs else str(BLD / src)
    compiles.append((tool, src_abs, frozenset(defs), tuple(mflags), incs, std))
assert compiles, "no compile commands parsed"
print(f"parsed {len(compiles)} compiles")

ISA_RE = re.compile(r"\.(sse4_1|sse4_2|avx512_skx|avx2|avx|fp16)\.cpp$")
MODS = ("core", "imgproc", "imgcodecs", "highgui", "videoio", "flann", "geometry", "dnn")
# groups that belong to the additive `dnn` feature (sources gated; flags
# entries stay unconditional — harmless when the feature is off)
FEATURE_DNN_GROUPS = ("dnn", "protobuf", "mlas", "mlasgemm")

have_ffmpeg = any("cap_ffmpeg" in c[1] for c in compiles)
print(f"HAVE_FFMPEG in profile: {have_ffmpeg}")
if have_ffmpeg:
    assert FF_PREFIX, "reference build has cap_ffmpeg TUs but FFMPEG_PREFIX unset"

def dir_key(src_abs, defs):
    s = src_abs
    if "3rdparty/libjpeg-turbo" in s:
        if s.endswith(".asm"): return "jpeg-asm"
        if "-DBITS_IN_JSAMPLE=12" in defs: return "jpeg12"
        if "-DBITS_IN_JSAMPLE=16" in defs: return "jpeg16"
        return "jpeg"
    if "3rdparty/libpng" in s: return "png"
    if "3rdparty/zlib" in s: return "zlib"
    if "3rdparty/protobuf" in s: return "protobuf"
    if "3rdparty/mlas" in s: return "mlas"
    if "-DMLAS_GEMM_ONLY=1" in defs: return "mlasgemm"   # the mlas-lib re-compile of modules/dnn/…/mlas_threading.cpp
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

# per-(group, ISA) overlays: dnn's per-ISA define sets differ from the base
# modules', so the overlay is keyed by group too and emitted with
# group-scoped globs (**/modules/<mod>/**/*.<isa>.cpp)
isa_defs, isa_m = {}, {}
for (dk, isa), cs in sorted(groups.items(), key=lambda kv: (kv[0][0], kv[0][1] or "")):
    if not isa: continue
    for c in cs:
        extra = c[2] - dir_defs[dk]
        extram = tuple(f for f in c[3] if f not in dir_m[dk])
        key = (dk, isa)
        if key not in isa_defs:
            isa_defs[key], isa_m[key] = extra, extram
        else:
            assert isa_defs[key] == extra and isa_m[key] == extram, \
                f"ISA overlay mismatch for {key}: {c[1]}"

# exact reconstruction check
for tool, src_abs, defs, mflags, incs, std in compiles:
    dk = dir_key(src_abs, defs)
    isa = ISA_RE.search(src_abs)
    want = set(dir_defs[dk]) | (set(isa_defs[(dk, isa.group(1))]) if isa else set()) \
         | set(file_extras.get(src_abs, ()))
    assert want == set(defs), f"reconstruction failed for {src_abs}: {want ^ set(defs)}"
print("exact flag reconstruction: OK")

# feature-off soundness: the base (non-feature) TU set must be EXACTLY the
# non-dnn reference build's TU set (same parser over its ninja-cmds.log)
if BASE_BLD is not None:
    base_tus = set()
    for line in (BASE_BLD / "ninja-cmds.log").read_text().splitlines():
        try: toks = shlex.split(line.strip())
        except ValueError: continue
        if not toks or Path(toks[0]).name not in ("g++","gcc","cc","c++","clang","clang++","nasm"): continue
        for t in toks[1:]:
            if re.search(r"\.(c|cc|cpp|cxx|asm|S)$", t) and not t.startswith("-"):
                src2 = t if t.startswith("/") else str(BASE_BLD / t)
                base_tus.add(src2.replace(str(BASE_BLD), "<BLD>").replace(str(SRC), "<SRC>"))
    this_base = { c[1].replace(str(BLD), "<BLD>").replace(str(SRC), "<SRC>")
                  for c in compiles if dir_key(c[1], c[2]) not in FEATURE_DNN_GROUPS }
    assert this_base == base_tus, \
        f"base TU set drifted vs BASE_BLD: {sorted(this_base ^ base_tus)[:6]}"
    print(f"feature-off TU set == non-dnn reference build: OK ({len(base_tus)} TUs)")

# common -m flags across every non-asm group must agree (baseline)
baselines = {dir_m[dk] for dk in dir_defs if dk != "jpeg-asm" and dk not in FEATURE_DNN_GROUPS}
assert len(baselines) == 1, f"baseline -m flags differ between groups: {baselines}"
baseline_m = [f for f in next(iter(baselines)) if f.startswith("-m")]

# ── group glob table (v2: real paths; jpeg12/16 stay stub dirs) ─────────
# `**/modules/<mod>/**` deliberately matches BOTH the tarball tree
# (*/modules/<mod>/…) and the snapshot dispatch stubs
# (mcpp_generated/modules/<mod>/…) — same group, same flags in the
# reference build (asserted below by reconstruction).
GROUP_GLOB = {
    "jpeg":   "**/3rdparty/libjpeg-turbo/**",
    "png":    "**/3rdparty/libpng/**",
    "zlib":   "**/3rdparty/zlib/**",
    "jpeg12": "**/tu/jpeg12/**",
    "jpeg16": "**/tu/jpeg16/**",
    "protobuf": "**/3rdparty/protobuf/**",
    "mlas":     "**/3rdparty/mlas/**",
    "mlasgemm": "**/tu/mlasgemm/**",
}
for mod in MODS:
    GROUP_GLOB[mod] = f"**/modules/{mod}/**"

# ── sources (real paths) + tu manifest (jpeg12/16 only) ─────────────────
def wrap_rel(src_abs):
    return Path(src_abs).relative_to(SRC).as_posix()

manifest, sources_real, sources_asm, kernel_files, seen = [], [], [], [], set()
sources_dnn = []
per_file_flag_entries = []
for tool, src_abs, defs, mflags, incs, std in compiles:
    dk = dir_key(src_abs, defs)
    if tool == "nasm":
        e = f"*/{wrap_rel(src_abs)}"
        if e not in seen:
            seen.add(e); sources_asm.append(e)
        continue
    if dk in ("jpeg12", "jpeg16", "mlasgemm"):
        # same-source re-compiles: inexpressible as plain sources -> tu stub.
        # mlasgemm only exists under the dnn feature ("?dnn" guard).
        tgt = wrap_rel(src_abs)
        key = (dk, tgt)
        if key not in seen:
            seen.add(key)
            manifest.append((f"?dnn\t{dk}\t{tgt}") if dk == "mlasgemm" else f"{dk}\t{tgt}")
        continue
    if rel_posix(src_abs, SRC) is not None:
        e = f"*/{wrap_rel(src_abs)}"
    elif "opencl_kernels_" in src_abs:
        # synthesized by build.mcpp on the consumer (clsrc/…); flags via
        # per-file globs below, source via mcpp:generated= — skip here
        m = re.search(r"opencl_kernels_(\w+)\.cpp$", src_abs)
        kernel_files.append((m.group(1), dir_key(src_abs, defs)))
        continue
    else:
        # snapshot file compiled from the build dir (dispatch stubs)
        e = f"mcpp_generated/{rel_posix(src_abs, BLD)}"
    if e in seen: continue
    seen.add(e)
    (sources_dnn if dk in FEATURE_DNN_GROUPS else sources_real).append(e)
    if src_abs in file_extras:
        per_file_flag_entries.append((e, file_extras[src_abs]))
n_tus = len(sources_real) + len([l for l in manifest]) + len(kernel_files)
print(f"sources: {len(sources_real)} real C/C++ + {len(sources_asm)} asm; "
      f"jpeg12/16 stubs: {len(manifest)}; kernels: {len(kernel_files)}")

# compress the real-source list: whole-directory globs where the compiled
# set equals every same-extension file in that directory of the tarball
def compress(entries):
    by_dir = defaultdict(list)
    for e in entries:
        if e.startswith("*/"):
            p = Path(e[2:])
            by_dir[("*", p.parent.as_posix(), p.suffix)].append(p.name)  # as_posix: forward slashes on windows
        else:  # mcpp_generated/...
            p = Path(e)
            by_dir[("g", p.parent.as_posix(), p.suffix)].append(p.name)
    out = []
    for (kind, d, suf), names in sorted(by_dir.items()):
        if kind == "*":
            on_disk = sorted(x.name for x in (SRC / d).glob(f"*{suf}"))
            if sorted(names) == on_disk and len(names) > 1:
                out.append(f"*/{d}/*{suf}")
                continue
            base = f"*/{d}"
        else:
            base = d
        if len(names) == 1:
            out.append(f"{base}/{names[0]}")
        else:
            stems = ",".join(sorted(n[: -len(suf)] for n in names))
            out.append(f"{base}/{{{stems}}}{suf}")
    return out

sources_out = compress(sources_real)
sources_dnn_out = compress(sources_dnn)
print(f"sources compressed: {len(sources_real)} base files -> {len(sources_out)} globs; "
      f"{len(sources_dnn)} dnn-feature files -> {len(sources_dnn_out)} globs")

# ── snapshot files (exclude synthesized classes) ────────────────────────
def rewrite(text):
    out = text
    # neutralize build-dir/source-tree paths in both separator conventions
    # (Windows generated headers may carry backslash OR forward-slash paths)
    for root in (str(SRC), Path(SRC).as_posix()):
        out = out.replace(f'"{root}/', '"').replace(f'{root}/', '')
    for root in (str(BLD), Path(BLD).as_posix()):
        out = out.replace(f'"{root}/', '"').replace(f'{root}/', '')
    out = (out.replace(str(BLD), "<build>").replace(Path(BLD).as_posix(), "<build>")
              .replace(str(SRC), "<src>").replace(Path(SRC).as_posix(), "<src>"))
    if FF_PREFIX:
        assert FF_PREFIX not in out, "ffmpeg prefix path leaked into snapshot"
    return out

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
    rel = p.relative_to(BLD).as_posix()
    content = rewrite(p.read_text(errors="replace"))
    assert "]==]" not in content, f"lua long-bracket collision in {rel}"
    assert len(content) < 200_000, f"unexpectedly large snapshot file {rel}"
    snapshot[f"mcpp_generated/{rel}"] = content

# Three files differ between the feature-off and dnn reference builds, all
# benignly: opencv_data_config.hpp only in the (now neutralized) build-dir
# path; opencv_modules.hpp in the HAVE_OPENCV_DNN line (NO compiled TU in
# either profile reads that macro — it rides features.dnn.defines instead);
# version_string.inc in the cosmetic build-info string. Ship the FEATURE-OFF
# (BASE_BLD) copy of all three; assert everything else is byte-identical.
BASE_PREFERRED = ("modules/core/version_string.inc",
                  "opencv2/opencv_modules.hpp",
                  "opencv_data_config.hpp")
if BASE_BLD is not None:
    def base_rewrite(text):
        return (text.replace(f'"{SRC}/', '"').replace(f'{SRC}/', '')
                    .replace(f'"{BASE_BLD}/', '"').replace(f'{BASE_BLD}/', '')
                    .replace(str(BASE_BLD), "<build>").replace(str(SRC), "<src>"))
    drift = []
    for k in list(snapshot):
        rel = k[len("mcpp_generated/"):]
        bp = BASE_BLD / rel
        if rel in BASE_PREFERRED:
            snapshot[k] = base_rewrite(bp.read_text(errors="replace"))
            continue
        if bp.exists():
            if base_rewrite(bp.read_text(errors="replace")) != snapshot[k] and not rel.startswith("modules/dnn"):
                drift.append(rel)
    assert not drift, f"unexpected snapshot drift vs BASE_BLD: {drift}"
    print("snapshot: base-preferred trio applied; rest identical across profiles")
print(f"snapshot: {len(snapshot)} files, {sum(len(v) for v in snapshot.values())//1024} KiB inline")

build_mcpp_src = (HERE / "build_mcpp_template.cpp").read_text()
assert "]==]" not in build_mcpp_src

# ── include dirs ────────────────────────────────────────────────────────
incdirs, iseen = ["mcpp_generated", "*"], {"mcpp_generated", "*"}
for c in compiles:
    for i in c[4]:
        if FF_PREFIX and i.startswith(FF_PREFIX):
            continue    # served by the compat.ffmpeg dependency's include dirs
        rs, rb = rel_posix(i, SRC), rel_posix(i, BLD)
        if rs is not None:
            r = "*" if rs == "" else "*/" + rs
        elif rb is not None:
            r = "mcpp_generated" if rb == "" else "mcpp_generated/" + rb
        else:
            continue
        if r not in iseen:
            iseen.add(r); incdirs.append(r)

# ── emit lua ────────────────────────────────────────────────────────────
def D(x): return x[2:]
def lua_list(items, ind):
    return ("\n" + ind).join(f'"{i}",' for i in items)

def defines_lua(defset):
    return "defines = { " + ", ".join(f'"{D(f)}"' for f in sorted(defset)) + " }"

# base flag-globs vs dnn-feature flag-globs. Flag-globs for the dnn groups
# (mlas/mlasgemm/protobuf/dnn) only match a source when the `dnn` feature is
# on; kept in the base `flags` they glob nothing in the default (feature-off)
# profile -> mcpp 0.0.101 warns "[build].flags glob matched no source file".
# mcpp#253 per-feature flags let them ride WITH the feature (features.dnn.flags),
# so they resolve exactly when their sources do.  (dnn-group flag-globs are
# arch-specific for the per-ISA entries -> they land per-OS via merge_opencv.lua.)
flags_entries = []
dnn_flags_entries = []
def is_dnn_glob(g):
    return any(m in g for m in ("3rdparty/mlas", "3rdparty/protobuf",
                                "modules/dnn", "tu/mlasgemm"))
# curated exception: mlas/lib/platform.cpp calls syscall(2); glibc hides it
# under __STRICT_ANSI__ (-std=c++NN). The reference build's gcc13 tolerated
# this only because ninja -k discards the object; consumers must compile it,
# so the mlas group carries _GNU_SOURCE.
dir_defs["mlas"] = frozenset(dir_defs.get("mlas", frozenset())) | {"-D_GNU_SOURCE=1"} \
    if "mlas" in dir_defs else dir_defs.get("mlas")
for dk in sorted(dir_defs):
    if dk == "jpeg-asm": continue
    key = "cflags" if dk in ("zlib", "png", "jpeg", "jpeg12", "jpeg16") else "cxxflags"
    parts = [f'glob = "{GROUP_GLOB[dk]}"']
    if dir_defs[dk]: parts.append(defines_lua(dir_defs[dk]))
    (dnn_flags_entries if dk in FEATURE_DNN_GROUPS else flags_entries).append(
        "{ " + ", ".join(parts) + " },")
if ("jpeg-asm", None) in groups:
    cs = groups[("jpeg-asm", None)]
    common = frozenset.intersection(*[c[2] for c in cs])
    flags_entries.append('{ glob = "**/*.asm", ' + defines_lua(common) + " },")
for (dk, isa) in sorted(isa_defs):
    ds = ", ".join(f'"{D(f)}"' for f in sorted(isa_defs[(dk, isa)]))
    ms = ", ".join(f'"{m}"' for m in isa_m[(dk, isa)])
    g = GROUP_GLOB[dk]
    g = (g[:-3] if g.endswith("/**") else g) + f"/**/*.{isa}.cpp"
    (dnn_flags_entries if dk in FEATURE_DNN_GROUPS else flags_entries).append(
        f'{{ glob = "{g}", defines = {{ {ds} }}, cxxflags = {{ {ms} }} }},')
# NOTE: no per-file flags for clsrc/opencl_kernels_<m>.cpp. build.mcpp writes
# them (cl2cpp) but leaves them INERT — OpenCL is OFF in this headless profile,
# so they are never registered as compiled sources (no `mcpp:generated=`). A
# flag-glob for them therefore matches nothing and mcpp 0.0.101 warns
# "[build].flags glob '**/clsrc/opencl_kernels_*.cpp' matched no source file".
# (kernel_files is still tracked for the TU count above.)
for g, extra in sorted(per_file_flag_entries):
    (dnn_flags_entries if is_dnn_glob(g) else flags_entries).append(
        f'{{ glob = "{g}", ' + defines_lua(extra) + " },")
# curated exception #2: mlas/lib/platform.cpp calls syscall(2) but includes
# only <sys/syscall.h> (the prototype lives in <unistd.h>; upstream
# toolchains leak it transitively, the hermetic glibc does not).
dnn_flags_entries.append('{ glob = "*/3rdparty/mlas/lib/platform.cpp", cxxflags = { "-include", "unistd.h" } },')

# upstream reference uses -std=c++17; the index floor is c++23 and the whole
# TU set builds green under gcc16 -std=c++23 (validated by the O0 spike).
cxx_std = {c[5] for c in compiles if c[0] == "g++" and c[5]}
assert cxx_std == {"-std=c++17"}, f"unexpected upstream C++ std set: {cxx_std}"

deps_line = ""
profile_note = "V4L2 videoio"
if have_ffmpeg:
    deps_line = f'        deps = {{ ["compat.ffmpeg"] = "{FFMPEG_DEP_VERSION}" }},\n'
    profile_note = "V4L2 + FFmpeg videoio (compat.ffmpeg dependency)"

# curated exception #3: the vendored mlas tree DECLARES MlasHGemmSupported
# (mlas.h) and calls it (compute.cpp) but ships no definition — upstream's
# static-archive selective linking never notices; mcpp links every dep
# object, so the consumer link does. Provide the semantically-correct stub
# (fp16 HGemm unsupported -> callers fall back), gated with the feature.
snapshot["mcpp_generated/mlas_hgemm_stub.cpp"] = (
    "// compat.opencv curated stub: the vendored mlas subset declares and\n"
    "// calls MlasHGemmSupported but does not vendor its definition (it\n"
    "// lives in onnxruntime's full mlas). False = fp16 HGemm unsupported,\n"
    "// which is the truth for this subset; callers fall back.\n"
    "#include \"mlas.h\"\n"
    "bool MLASCALL MlasHGemmSupported(CBLAS_TRANSPOSE, CBLAS_TRANSPOSE) { return false; }\n")
sources_dnn_out.append("mcpp_generated/mlas_hgemm_stub.cpp")

dnn_sources_lua = lua_list(sources_dnn_out, " " * 20)
dnn_flags_lua = ("\n" + " " * 20).join(dnn_flags_entries)
n_dnn = len(sources_dnn)
L = []
L.append(f"""-- Auto-generated by tools/compat-opencv/gen_descriptor.py — do not edit by hand.
-- Recipe: OpenCV {VERSION} built FROM SOURCE by mcpp (no CMake at build
-- time). Scope: core imgproc imgcodecs highgui videoio (+ flann, geometry
-- dependency closure); hermetic profile (all external probes OFF, vendored
-- zlib/libpng/libjpeg-turbo incl. NASM SIMD units, headless highgui,
-- {profile_note}, WITH_UNIFONT=OFF); SIMD runtime
-- dispatch KEPT (per-ISA glob flags). Sources are the real tarball paths
-- (mcpp >= 0.0.97: obj-path disambiguation #233 + quoted spacey defines
-- #234 made the v1 forwarding-stub layer obsolete); only the libjpeg-turbo
-- BITS_IN_JSAMPLE=12/16 re-compiles and the build-time generators (fonts,
-- OpenCL kernel embeddings) are synthesized on the consumer by the embedded
-- build.mcpp — byte-faithful ports verified against the reference CMake
-- build. Regenerate: sh tools/compat-opencv/gen_config.sh (this repo).
package = {{
    spec        = "1",
    namespace   = "compat",
    name        = "compat.opencv",
    description = "OpenCV {VERSION} (core/imgproc/imgcodecs/highgui/videoio incl. FFmpeg backend), full source build with SIMD dispatch",
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
{deps_line}        include_dirs = {{
            {lua_list(incdirs, " " * 12)}
        }},
        cxxflags = {{ {", ".join([f'"{m}"' for m in baseline_m] + ['"-w"'])} }},
        cflags   = {{ {", ".join([f'"{m}"' for m in baseline_m] + ['"-w"'])} }},
        flags = {{
            {("\n" + " " * 12).join(flags_entries)}
        }},
        targets = {{
            opencv = {{ kind = "lib" }},
        }},
        -- `unifont`: Unicode/CJK putText coverage. Pulls the font asset
        -- package and defines HAVE_UNIFONT (drawing_text.cpp gates on it);
        -- build.mcpp sees MCPP_FEATURE_UNIFONT=1 and hex-embeds the font
        -- (builtin_font_uni.h). Not part of the reference profile — the
        -- embed machinery is byte-faithful to cmake's ocv_blob2hdr either way.
        -- `dnn`: the deep-learning module as an ADDITIVE feature — its
        -- sources ({n_dnn} TUs: modules/dnn + vendored protobuf + mlas incl.
        -- .S kernels) join the same lib; HAVE_OPENCV_DNN arrives via the
        -- build.mcpp-selected opencv_modules.hpp variant, no extra deps.
        features = {{
            ["unifont"] = {{
                deps    = {{ ["compat.opencv-unifont"] = "1.0.0" }},
                defines = {{ "HAVE_UNIFONT" }},
            }},
            ["dnn"] = {{
                defines = {{ "HAVE_OPENCV_DNN" }},
                flags = {{
                    {dnn_flags_lua}
                }},
                sources = {{
                    {dnn_sources_lua}
                }},
            }},
        }},
        linux = {{
            ldflags = {{ "-lpthread", "-ldl" }},
        }},
        sources = {{
            {lua_list(sources_out + sources_asm, " " * 12)}
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
OUT.write_text("".join(L), encoding="utf-8")  # explicit: windows locale is cp1252 and mangles the em-dash
kb = OUT.stat().st_size // 1024
print(f"gen_descriptor: {OUT} written — {len(sources_out)} source globs "
      f"(+{len(sources_asm)} asm), {len(manifest)} jpeg12/16 stub TUs, "
      f"{len(snapshot)} inline snapshot files, {kb} KiB")
