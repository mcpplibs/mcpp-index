# Add `compat.thorvg` 1.1.3

Date: 2026-11-25

## Summary

Add `compat.thorvg` `1.1.3` (MIT) to `mcpp-index` as a Form B source-built static library (`kind = "lib"`), exposing ThorVG's CPU software rasterizer (`SwCanvas`) and raw + Lottie loaders (`LottieLoader`), plus the workspace verification member `tests/examples/thorvg`.

## Package Design

- **Identity & source**: `namespace = "compat"`, `name = "thorvg"`, version `"1.1.3"`, URL `https://github.com/thorvg/thorvg/archive/refs/tags/v1.1.3.tar.gz`, SHA256 `ba9957aeeadb4151d4486f11c638ae118c00210fa4906daa7b30143aa341e690` (double-verified across two independent downloads; `thorvg-1.1.3/` top-level wrap; MIT `LICENSE`).
- **Mirroring**: Bare upstream GitHub archive URL across `linux`, `macosx`, and `windows` (no local `mcpp-res` write credentials; CN mirror can be added later without changing the SHA256).
- **`extensions.autoupdate`**: `tag = "v${version}"`, `url = "https://github.com/thorvg/thorvg/archive/refs/tags/${tag}.tar.gz"`.
- **Source subset (40 TUs)**: Explicitly lists the `.cpp` units under `src/common/` (3), `src/renderer/` (14), `src/renderer/cpu_engine/` (12), `src/loaders/raw/` (1), and `src/loaders/lottie/` (10). Deliberately excludes `src/renderer/cpu_engine/tvgSwRasterSimd.cpp` and `src/loaders/lottie/jerryscript/**` (and avoids `**` globs).
- **Include isolation**: Base `include_dirs = { "*/inc" }` exposes only `<thorvg.h>` to consumers. Internal directories (`mcpp_generated`, `*/src/common`, `*/src/renderer`, `*/src/renderer/cpu_engine`, `*/src/loaders/raw`, `*/src/loaders/lottie`) are declared in both `include_dirs` and `private_include_dirs` inside each platform block (`linux`, `macosx`, `windows`).
- **Configuration header (`mcpp_generated/config.h`)**: Defines `THORVG_VERSION_STRING "1.1.3"`, `THORVG_CPU_ENGINE_SUPPORT 1`, and `THORVG_LOTTIE_LOADER_SUPPORT 1`.
- **Static linkage macro (`TVG_STATIC`)**: `inc/thorvg.h` applies `__declspec(dllimport)` on `_WIN32` unless `TVG_STATIC` is defined. Because base-level `defines` applies only to the package's own TUs while active feature `defines` propagates to both the package and its consumers, `TVG_STATIC` is published via `features = { ["default"] = { implies = { "staticlib" } }, ["staticlib"] = { defines = { "TVG_STATIC" } } }`.
- **Platform flags & libraries**:
  - `linux`: `-fPIC`, `-fvisibility=hidden`; `ldflags = { "-lm", "-lpthread" }`.
  - `macosx`: `-fPIC`, `-fvisibility=hidden`; `ldflags = { "-lm" }`.
  - `windows`: `-DNOMINMAX`, `-DWIN32_LEAN_AND_MEAN`.

## Verification

- `tests/examples/thorvg`: Checks `TVG_STATIC` propagation, verifies private headers do not leak into consumer include paths, exercises `Initializer::init(0)` / `version()` / `term()`, renders a red `Shape` via `SwCanvas`, loads a Lottie animation JSON (`Animation::gen()`, `picture()->load(..., "lottie", ...)`), renders frame 0 and seeks to frame 30 with pixel assertions, and verifies malformed/empty Lottie payloads return non-`Success`.
- Local checks: `mcpp xpkg parse`, `validate.yml` lint suite, `tests/select_members.py`, `tests/run_members.sh thorvg`, and `xpkgindex_update` (`audit`, `inspect`, `check`).
