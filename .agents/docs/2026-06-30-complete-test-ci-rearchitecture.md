# mcpp-index: complete test + CI rearchitecture (zero shell)

Supersedes the heredoc smoke scripts and their bespoke CI jobs. The index's
**entire** library-test surface becomes a mcpp `[workspace]` of real per-library
test projects, run by `mcpp test --workspace` per platform. No `.sh` drivers.

## Why now / what unblocks it

The old `smoke_compat_portable.sh` carried a bash harness only because it had to
synthesize per-OS toolchains + ldflags at runtime. **mcpp 0.0.74+ shipped
`[target.'cfg(...)']`** (conditional build flags 0.0.74, conditional deps 0.0.75),
and 0.0.79 added workspace-aware `mcpp test`. So per-OS config is now declarative
in static `mcpp.toml`, and the whole matrix runs as one command — the shell
harness has no remaining job.

## Member taxonomy (the complete test surface)

Each member is `tests/<name>/` = `[package]` + `[dependencies] compat.<lib>` +
`tests/*.cpp` behavioral assertions (no `src/`). Migrated faithfully from the
smoke scripts' heredoc projects.

| member | libraries (compat.*) | what it asserts | platforms |
|---|---|---|---|
| `cjson` | cjson | parse/serialize round-trip | all |
| `eigen` | eigen | header-only linear algebra | all |
| `nlohmann.json` | nlohmann.json (module) | dump/parse round-trip | all |
| `core` | gtest, ftxui, lua, mbedtls, opengl, khrplatform | gtest TEST, lua eval=42, mbedtls SHA256("abc"), ftxui in-memory render, GL constants | all (per-OS ldflags via cfg) |
| `archive` | libarchive, zlib, bzip2, lz4, xz, zstd | version probes + compress→decompress round-trip per codec | all |
| `imgui` | imgui (compat source) | in-memory ImGui frame → valid draw data | all |
| `imgui-module` | imgui (C++23 module) | `import imgui.core` + backend symbols + render | all (llvm pin) |
| `gui-stack` | glfw + xext/xrender/xfixes/xcursor/xinerama/xrandr/xi/xau/xdmcp/xcb/x11 | symbol linkage + `glfwInit` (tolerant) + version constants | linux (cfg) |
| `imgui-window` | imgui, glfw | **build+link only** (window run is opt-in, not headless CI) | linux (cfg) |
| `openblas` | openblas | cfg(windows) cblas_dgemm `[19 22;43 50]` | windows (cfg) |
| `build-mcpp` | — | build.mcpp generated source + define | all |

### Cross-platform via cfg (no bash)
- **Toolchain**: cross-platform members **omit `[toolchain]`** → mcpp auto-selects
  the platform default (linux→gcc, macOS/Windows→llvm). `imgui-module` keeps an
  llvm pin (C++23 modules). `gui-stack`/`imgui-window` are gcc-on-linux.
- **Per-OS link flags**: `[target.'cfg(linux)'.build] ldflags = ["-ldl","-lm"]`,
  `[target.'cfg(macos)'.build] ldflags = ["-lm"]` (was `write_build_ldflags()`).
- **Platform-only members**: linux-only (`gui-stack`, `imgui-window`) gate their
  deps under `[target.'cfg(linux)'.dependencies]` and compile a no-op `main()`
  off-linux — the same pattern `openblas` uses for windows. So one
  `mcpp test --workspace` runs everywhere; each member self-selects.

## CI (validate.yml) — rebuilt around `mcpp test`

Replace `smoke-full-linux` / `smoke-portable` / `smoke-examples` / `smoke-workspace`
with **one matrix job per OS**, each:
```yaml
- run: mcpp test --workspace        # members self-gate by cfg
```
- **linux / macOS / windows** runners each run the whole workspace; platform-only
  members no-op where inapplicable.
- **`detect`** still narrows PRs: a changed `pkgs/<lib>.lua` or `tests/<member>/**`
  → `mcpp test -p <member>` for just that member; push/schedule → full `--workspace`.
- **`smoke_compat_*.sh` deleted**; the registry/smoke download caches stay (keyed
  the same).
- The display/GL **window run** is not part of headless CI; `imgui-window` builds +
  links (the recipe-build is the test). An opt-in job may later run it under xvfb.

## Migration provenance (faithful)
Every assertion is lifted from the corresponding smoke heredoc:
`core`←smoke_compat_core, `archive`←smoke_compat_archive (both sub-projects),
`imgui`+`gui-stack`←smoke_compat_imgui (6 sub-projects split by concern),
`imgui-window`←smoke_compat_imgui_window, `imgui-module`←smoke_imgui_module,
and `smoke_compat_portable` dissolves into the cross-platform members above
(its per-OS logic → cfg).

## Known follow-ups (recorded, not blocking)
- Feature-built dependency objects not linking into test binaries (eigen_blas
  `dgemm_`) — eigen tests header-only until fixed in mcpp.
- The actual GLFW/OpenGL **window** run needs a display; kept opt-in.
- macOS/Windows `gui-stack` equivalents (Cocoa/Win32) are out of scope (the X11
  stack is linux-specific by nature).
