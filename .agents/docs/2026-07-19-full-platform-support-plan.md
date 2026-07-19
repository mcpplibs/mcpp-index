# Full-platform (macOS + Windows) support for `compat.ffmpeg` & `compat.opencv` — plan

> Date: 2026-07-19 · Scope: multi-repo (mcpp-index = compat descriptors + generators + snapshot CI; opencv-m / ffmpeg-m = module packages + `platforms`). · Baseline: mcpp **0.0.99**.
>
> Companion pointers: `opencv-m/.agents/docs/2026-07-19-full-platform-support.md`, `ffmpeg-m/.agents/docs/2026-07-19-full-platform-support.md` (thin, cross-reference this doc).

## 0. Goal & current state

Deliver **easy-to-use + all-platform (linux✓ / macOS-arm64 / Windows-x86_64) + full-functionality** `import opencv.cv;` / `import ffmpeg.av;` in the mcpp ecosystem.

Today both `compat.opencv` and `compat.ffmpeg` are **linux-x86_64 only**: each inlines a *frozen* `cmake`/`./configure` snapshot (config headers as `generated_files`, the `make -n` / ninja-commands source list as globs, per-glob SIMD/asm flags) — all of it x86/linux-specific. `xpm` has only a `linux` key; `ffmpeg-m`/`opencv-m` declare `platforms = ["linux"]`.

## 1. Architecture decision — one descriptor, per-platform *frozen* snapshots, cfg-selected, NO configure at build time

We evaluated three shapes (evidence: mcpp v0.0.99 source + the ecosystem's own design docs):

- **(i) `build.mcpp` runs `configure`/`cmake` at consumer build time** (the tempting "one descriptor solves everything"). **Rejected.** `build.mcpp` *can* shell out unsandboxed (`process.cppm` inherits full PATH) and *append* sources + emit **global** flags (`cxxflag/cflag/cfg/link-lib/link-search/generated`, `build_program.cppm:113-121`), but it **cannot emit per-file / per-glob flags** — and OpenCV SIMD (`*.avx2.cpp` → `-mavx2`) and FFmpeg per-lib flags *require* per-file flags, which exist only as the static descriptor `[build].flags` feature. It also can't *subtract* the static source set, would reintroduce a hard `cmake`/`bash`+`msys2` consumer dependency, make every first build slow + non-hermetic, and the config headers *are* configure's frozen probe decisions — un-derivable without re-running configure (`opencv-m/.agents/docs/2026-07-18-roadmap-r-series-plan.md:79-82`). This is exactly the "prebuilt / run-upstream-buildsystem" form the project set out to avoid.
- **(ii) three separate frozen descriptors** — hermetic + correct, but triples the maintenance surface. Unnecessary: mcpp carries all platforms in one descriptor and selects at build time.
- **(iii) ONE descriptor, per-platform frozen snapshots, cfg/platform-selected, zero configure at build time.** **Chosen.** Hermetic AND single-descriptor. This is the project's own stated intent ("每平台一份参考构建快照 + cfg 选择", `roadmap-r-series-plan.md:74`).

`build.mcpp`'s only role stays a *leaf* one: at most a trivial `build.mcpp` that reads `MCPP_TARGET` and emits `cxxflag=-I<gen/target-dir>` to pick the embedded snapshot's include dir (needed because cfg-conditional `include_dirs` is not in the grammar). Its existing platform-neutral synthesis (fonts blob2hdr, cl2cpp, jpeg12/16 stubs, unifont font embed) is unchanged.

## 2. Structural mechanics — the three traps

1. **xpm keys are coarse: exactly `linux` / `macosx` / `windows`** (no arch suffix; one `macosx` block serves whatever arch the host is; consumer cfg spelling is `cfg(macos)` but the xpkg key is `macosx`). The **same source tarball serves all three** `xpm` keys → no new artifacts, no CN re-mirroring; just add `xpm.macosx`/`xpm.windows` pointing at the identical url+sha256.
2. **`mcpp.<platform>` sub-tables APPEND.** At synthesis, mcpp textually splices the *host's* `mcpp.<os>` sub-block into the segment and parses; list keys (`sources`, `flags`, `cflags`, `cxxflags`, `include_dirs`, `ldflags`) **accumulate** onto whatever is at top level (`xpkg.cppm:801-805`, `:871-1268`). ⇒ **Anything platform-specific must NOT sit at top level** (it would leak onto every OS). The whole per-platform snapshot moves under `mcpp.linux` / `mcpp.macosx` / `mcpp.windows`; only genuinely-neutral keys (`language`, `deps`, `targets`, `features`) stay top-level.
3. **`generated_files` uses `emplace` — NO overwrite** (`xpkg.cppm:925`, `types.cppm:155`): the *first-parsed* (global) same-path entry wins; a per-OS block cannot override a global `config.h`. ⇒ **The entire config snapshot must be per-OS with ZERO global `generated_files`.** A single stray global `config.h`/`cvconfig.h` silently poisons the other two platforms. **Sharpest correctness trap.**

Precedent that this works: `compat.openblas.lua` ships per-OS `mcpp.{linux,macosx,windows}` with `ldflags`/`runtime`/`generated_files`; `compat.zstd` source-builds on all three; `compat.mbedtls` uses `windows={ldflags=-lbcrypt}`. mcpp#229 (cfg-conditional dep sources not expanding when consumed as a dependency) is **fixed in 0.0.97** — the actual unblock, since these are consumed as deps.

## 3. Per-platform toolchain (mcpp-managed via xlings; NOT the runner's system compiler)

| Host | mcpp default toolchain | Family / ABI | Notes |
|---|---|---|---|
| linux-x86_64 | `gcc@16.1.0` (glibc) | GCC | native |
| macOS-arm64 | `llvm@20.1.7` | LLVM/Clang, Xcode SDK | `-lc++`, deploy floor 14.0, no full-static |
| windows-x86_64 | `llvm@20.1.7` | **LLVM/Clang, MSVC ABI** (`*-pc-windows-msvc`) | NOT mingw, NOT cl.exe by default |

Consequence: the default Clang runs in **GCC-driver mode** → GCC-style *compile* flags (`-D`, `-w`, `-msse3`, `-mavx2`, `-include`) are accepted on all three OSes (big simplifier — the per-ISA cxxflags largely port). Only **link** conventions differ on Windows (import libs / `.lib`, no GNU `-l<syslib>`; handled in `mcpp.windows.ldflags`). NASM object format is auto-selected per target (`triple.cppm`: elf64 / macho64 / win64).

## 4. The load-bearing de-risking fact

**The consumer side already works on macOS + Windows.** `validate.yml`'s `workspace` job already runs a 3-OS matrix (`ubuntu-latest` / `macos-15` / `windows-latest`) and today source-builds multi-platform compat packages there with mcpp's vendored `llvm@20.1.7` clang — e.g. `core-tests` pulls `compat.mbedtls` (108 `.c` + `-lbcrypt` on Windows), plus `spdlog-compiled`, `openblas` (Windows). So *mcpp compiling a compat package on mac/win is proven*. **The only missing piece is generating the per-platform snapshots** — which is a maintainer-time job we can run **on the same `macos-15` / `windows-latest` runners** (they ship cmake+ninja+python3+bash; Windows has MSYS2 at `C:\msys64`; nasm preinstalled on ubuntu/windows).

## 5. Per-package plans

### 5.1 `compat.ffmpeg`

Platform-specific surface (all frozen linux-x86_64 today): `config.h` (`OS_NAME linux`, `ARCH_X86_64=1`, x86 SIMD `HAVE_*`, `PTHREADS=1/W32THREADS=0`, `MEMALIGN`/`ALIGNED_MALLOC`, `UNISTD_H`/`WINDOWS_H`), `config.asm`/`config_components.asm` (NASM-only, x86-only), `avconfig.h`, 157 x86 `.asm` units + `x86/*_init.c`, Linux device sources (`v4l2`/`oss`/`fbdev`), POSIX cflags (`-pthread`, `-D_POSIX_C_SOURCE`…), `mcpp.linux.ldflags = {-lpthread,-lm}`.

- **macOS-arm64**: `./configure --cc=clang --disable-autodetect` runs fine (clang supported). SIMD becomes **aarch64 GAS `.S`** (`libav*/aarch64/*.S`, no NASM); mcpp assembles `.S` via the C driver (documented since 0.0.95 but **unproven in this repo** — must verify `-DHAVE_AV_CONFIG_H` + `-I` reach `.S` TUs so `#include "config.h"` resolves). Drop `config.asm`/`config_components.asm` (NASM-only). Device sources → avfoundation (or none under hermetic config). `ldflags = {-lm}` (+ frameworks only if devices survive). Feasible; the tractable target.
- **Windows-x86_64**: **highest risk.** `./configure` needs **MSYS2/bash**; configure with an MSVC-ABI target (`--toolchain=msvc`/clang-cl equivalent) → `HAVE_W32THREADS=1`, MSVC `compat/*` sources, win64 NASM (auto object format). The unknown is **clang-MSVC compiling ~2100 FFmpeg C TUs** — no precedent in this index (opencv/openblas sidestep Windows with prebuilt artifacts). **Spike-gate before committing.**

### 5.2 `compat.opencv`

Platform-specific surface: `cv_cpu_config.h` (x86 SSE/AVX baseline+dispatch), per-ISA flag groups (`*.avx2.cpp`→`-mavx2` …), x86 NASM libjpeg-turbo SIMD, `cvconfig.h` `HAVE_PTHREAD`, glibc `HAVE_MALLOC_H/MEMALIGN/GETAUXVAL`, `-lpthread -ldl`, videoio V4L2+FFmpeg. **`build.mcpp` + the `unifont` feature are platform-neutral** (fonts/cl2cpp/jpeg12-16 are arch-independent); the **`dnn` feature is x86-specific** (mlas `x86_64/*.S` + avx stubs) and regenerates per-platform like the base.

- **macOS-arm64 (headless first)**: cmake+clang emits a NEON `cv_cpu_config.h` + NEON dispatch set. The snapshot *already carries* neon/neon_fp16/neon_dotprod stubs (their `MODES_ALL` lists NEON) → stub bodies likely reusable; what changes is `cv_cpu_config.h` + the sources selection + flags. **Videoio has no backend on mac without FFmpeg ported** (AVFoundation is `.mm`, unproven) ⇒ first cut = **headless** (core/imgproc/imgcodecs/highgui-headless), video parity follows `compat.ffmpeg`-macOS.
- **Windows-x86_64**: hardest — asm object format, ldflags, allocator (`_aligned_malloc`), and OpenCV's `#ifdef _WIN32` paths all flip; greenness under clang-MSVC unproven. Spike-gate.

## 6. Sequencing & dependency ordering

1. **compat.ffmpeg macOS-arm64** (unblocks opencv videoio on macOS + is the smaller/cleaner configure). ← first real target
2. **compat.opencv macOS-arm64 headless**, then + FFmpeg videoio once (1) lands.
3. **compat.ffmpeg Windows spike** (go/no-go: does clang-MSVC compile the FFmpeg C set?).
4. **compat.opencv Windows** (gated on 3 + its own spike).
5. Widen `ffmpeg-m` / `opencv-m` `platforms` + their CI as each compat platform lands; the `dnn`/`unifont` features regenerate per-platform.

macOS is the value-dense, low-risk path; Windows is a spike-gated stretch. Be honest per platform (§11).

## 7. CI-driven snapshot generation (the key infrastructure)

A **new, separate** workflow (not the validate matrix) in mcpp-index, one job per target:

```
job snapshot  (matrix: {os: macos-15, plat: macosx}, {os: windows-latest, plat: windows})
  - checkout
  - ensure cmake+ninja+python3 (+ MSYS2 bash on windows; nasm via brew only if x86)
  - download mcpp + vendored xlings (same steps as validate.yml) and point the
    reference cmake/configure CC/CXX at mcpp's llvm clang → HAVE_* fidelity vs the
    consumer compiler
  - run the ADAPTED gen_config for that target → writes a scratch out/<plat>/ snapshot
    (config headers + sources.txt + ninja-cmds.log), NOT overwriting pkgs/*.lua
  - upload out/<plat>/ as an artifact
compose (manual/local): download the 3 platform artifacts → run gen_descriptor.py in
  MULTI-PLATFORM mode → emit ONE descriptor with xpm.{linux,macosx,windows} +
  mcpp.<os> sub-blocks (each carrying that OS's generated_files/sources/include_dirs/
  flags/ldflags, ZERO global generated_files) → lint/parse gate → human review.
```

Keep generate and compose separate so a human reviews the large machine-generated per-platform diffs (matches the current `-- do not edit by hand` flow).

## 8. Generator rewrites (mcpp-index `tools/compat-*/`)

Both generators are single-platform/linux-hardcoded and *overwrite* the descriptor. Required changes:

- **compat-ffmpeg/gen_descriptor.py**: emit all 3 `xpm` keys; emit per-OS `mcpp.<os>` blocks; drop `config.asm`/`config_components.asm` from `GEN_FILES` on non-x86; arch-correct `INCLUDE_DIRS` (`x86` vs `aarch64`); split cflags (neutral global vs `-pthread`/POSIX per-OS vs MSVC per-OS); per-OS ldflags. Accept 3 `(target, builddir)` snapshots + a merge mode.
- **compat-opencv/gen_descriptor.py**: extend `ISA_RE` (currently `sse4_1|sse4_2|avx512_skx|avx2|avx|fp16`) with `neon|neon_fp16|neon_dotprod` (+ arm baseline) — **hard blocker for arm64** (the exact-reconstruction assert fires otherwise); add arm jpeg `simd/arm/*.S` group + win64 NASM group; per-OS ldflags/frameworks; per-OS key emission; `--target`/multi-snapshot mode.
- **gen_config.sh (both)**: add platform branches (V4L2/FFmpeg vs AVFoundation vs MSMF; `nproc`→`sysctl`/`%NUMBER_OF_PROCESSORS%`); fix the `macos`→`macosx` key spelling; on Windows run under MSYS2 bash.

## 9. Testing strategy (temp PRs + workspace CI as the mac/win build host)

- Per platform: a **temporary PR** whose `validate.yml` workspace members exercise the new platform. The existing `opencv`/`opencv-dnn`/`opencv-unifont`/`ffmpeg`/`ffmpeg-module` members are currently `cfg(linux)`-gated → widen their `cfg` to `linux+macos` (then `+windows`) as each platform's snapshot lands, so `mcpp test --workspace` on `macos-15`/`windows-latest` actually builds + runs them. Keep the member tests import-only (`import std; import ffmpeg.av;` / `import opencv.cv;`) so they run on every OS.
- The CI runner IS the macOS/Windows build host we lack — a green `workspace (macos)` / `workspace (windows)` leg is the acceptance signal.
- Gate each platform behind its own PR so a red Windows spike never blocks macOS delivery.

## 10. Module packages (opencv-m / ffmpeg-m)

Thin consumers of the compat packages. Per platform that lands: widen `platforms` in `mcpp.toml` (`["linux"]` → `["linux","macos"]` → `+"windows"`), widen the member/example `cfg` gates + the repo CI matrix (add `macos-15`/`windows-latest` jobs mirroring `validate.yml`). The module `.cppm` layer itself is platform-neutral (it wraps headers); the one caveat is **MSVC C++20-modules bugs** (GMF template-specialization) flagged for the Windows *consumer* layer — verify the module layer compiles under clang-MSVC (likely fine since it's clang, not cl.exe).

## 11. Risks / unknowns / go-no-go gates

| # | Risk | Severity | Gate |
|---|---|---|---|
| R1 | **Windows: clang-MSVC compiling ~2100 FFmpeg + hundreds of OpenCV C/C++ TUs** — no precedent | HIGH | POC spike before committing Windows; may be partial/infeasible |
| R2 | macOS aarch64 `.S`/GAS path unproven in this repo (only x86 NASM exercised) | MED | verify in the first macOS ffmpeg spike |
| R3 | `generated_files` emplace-no-overwrite → any global config header poisons other OSes | MED | enforce zero-global-generated_files in gen_descriptor + a lint check |
| R4 | opencv-m `ISA_RE` x86-only → arm reconstruction assert | MED | deterministic fix, mandatory for macOS |
| R5 | macOS/Windows videoio backend (AVFoundation `.mm` / MSMF) is new source sets | MED | headless-first; video is a follow-on workstream |
| R6 | cfg-conditional `include_dirs` absent → need thin MCPP_TARGET build.mcpp or per-OS mcpp block | LOW | per-OS `mcpp.<os>.include_dirs` already appends; use that |

## 12. Concrete first steps (this effort)

1. **macOS ffmpeg snapshot spike** — a temp PR adding a `snapshot (macos)` CI job that runs `./configure --cc=<mcpp-clang> --disable-autodetect` on `macos-15` + `make -n`, and **just tries to compile a handful of aarch64 `.S` + core `.c` TUs with mcpp** to prove R2. Output: the arm64 `config.h` + source list as an artifact. ← highest-value de-risk.
2. If (1) green → generate the full macosx snapshot, restructure `compat.ffmpeg.lua` to per-OS blocks (§2/§8), widen the `ffmpeg`/`ffmpeg-module` members to `linux+macos`, prove `workspace (macos)` green.
3. Repeat for `compat.opencv` macOS-headless.
4. Windows: run the R1 spike PR; decide go/no-go honestly.

---

*Prior art this supersedes/extends: `opencv-m/.agents/docs/2026-07-18-roadmap-r-series-plan.md` (§ macOS "one snapshot per platform + cfg", deferred), `2026-07-18-mcpp-0097-adoption-plan.md` (#229 unblock). This doc is the concrete, evidence-backed execution plan.*
