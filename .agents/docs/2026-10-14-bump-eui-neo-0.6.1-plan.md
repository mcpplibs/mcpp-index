# Design doc: bump `compat.eui-neo` to 0.6.1

Date: 2026-10-14

Follow-up to `.agents/docs/2026-09-26-bump-eui-neo-0.6.0-plan.md` and commit `2863bb1` (0.6.0).
Upstream released 0.6.1; this bumps the index from 0.6.0 to 0.6.1.

## Source and version

| | |
|---|---|
| Upstream | `https://github.com/sudoevolve/EUI-NEO` |
| Version | `0.6.1` (latest release) |
| Tarball | `archive/refs/tags/v0.6.1.tar.gz` |
| sha256 | `cd0bd6bd437177db097da146fc20f4b8b01c70d0db561a6f8e26baa26dbbbf5f` (computed twice, stable) |
| Wrap dir | `EUI-NEO-0.6.1/` — absorbed by the existing `install()` hook (`normalise_layout`) |
| CN mirror | **pending** — no `mcpp-res` write access on this machine; plain-string url fallback per SOP |
| License | Apache-2.0 (unchanged) |

## What changed upstream (0.6.0 → 0.6.1)

Release notes: `docs/releases/v0.6.1.md` (window lifecycle + self-drawn windows, Linux input,
component interaction, cross-backend build stability).

- **`CORE_SOURCES` and `VULKAN_SOURCES` are byte-identical to 0.6.0** (extracted and diffed from
  both `CMakeLists.txt`). The lib's source list, deps, features and flags carry over unchanged.
- `core/window/x11_moveresize.h` is **new but header-only**: EWMH `_NET_WM_MOVERESIZE`
  move/resize delegation. libX11 is dlopen'd at runtime — the header states verbatim that "no
  build configuration gains a link-time X11 dependency", and `-ldl` is already on the linux
  ldflags (glad). It DOES add a compile-time `<X11/Xlib.h>` on linux:
  `window_backend.cpp` includes the header **unconditionally** (line 3) and the header guards
  its X11 block only on `__linux__ && !__ANDROID__`. Resolution path: the transitive
  `compat.glfw → compat.x11` dep chain (dep `include_dirs` propagate to consumers — the same
  propagation the glib `private_include_dirs` pairing exists to suppress). Verified by the
  build, not assumed — see below.
- `ime_bridge.c` grows a third arm, `#elif defined(__linux__) &&
  defined(EUI_GLFW_X11_IME_POSITION)`, the X11 IME candidate-follows-caret fix. The arm calls
  `glfwSetX11InputMethodCursorPos`, a function upstream's `scripts/patch_glfw_x11_ime.cmake`
  **adds to its bundled glfw** (`3rd/dependencies.cmake` now rewrites the bundled target's
  sources at configure time). The index builds `compat.glfw`, unpatched upstream 3.4 — the
  define is never set here, the arm is inert, and our linux IME keeps the 0.6.0 `#else` stub.
  Enabling the fix would mean patching `compat.glfw`, out of scope for a version bump.
- `3rd/dependencies.cmake` also tightens `find_package(glfw3 3.4)` — applies to upstream's
  bundled-vs-system glfw choice only; we pin `compat.glfw` 3.4.
- The rest is header/app-level — with ONE exception, found by testing rather
  than reading: in the SDL2 backend, `beginWindowMove` / `beginWindowResize`
  call `sendX11MoveResizeForWindow` **unguarded**, but the SDL2 branch's
  declaration sits inside `#if __linux__ && … && defined(SDL_VIDEO_DRIVER_X11)`
  (window_backend.cpp:223-298) — unlike the GLFW branch's copy (:608), which
  upstream hoisted out of the guard with its own `#else return false`. Three
  builds fail, all measured:
  - linux + `compat.sdl2` — its config is dummy+offscreen only, so the macro is
    absent (local eui-neo-sdl2 run): `'sendX11MoveResizeForWindow' was not
    declared` at :571.
  - **macOS and Windows** (PR #531 CI legs): `use of undeclared identifier` at
    :567/:571 — `__linux__` is false there, so NO macro can wake the
    declaration; it does not exist at all. Upstream's own CI builds the SDL2
    backend on Linux only and never sees this. The other SDL2 X11 helper,
    `x11ContentScale`, is safe — its call site is inside the same triple guard
    as its body.
- `apps/vcd_viewer` removed, new upstream tests/docs — none reach the lib or this index.

## Descriptor changes (`pkgs/e/compat.eui-neo.lua`)

- `xpm.<linux|macosx|windows>["0.6.1"]`: plain-string GLOBAL url (no CN mirror), sha256 above.
- **One functional change**, in `generated_files["mcpp_generated/mcpp_eui_backends.h"]`,
  split by platform, active only when `MCPP_FEATURE_SDL2` is on (the header is already
  force-included into every one of this package's TUs):
  - **linux**: `#define SDL_VIDEO_DRIVER_X11 1` wakes the guarded declaration. It can
    never fire at runtime — compat.sdl2 has no X11 driver, so no SDL window is ever an
    X11 window, `SDL_GetWindowWMInfo` never reports `SDL_SYSWM_X11`, and every delegation
    returns false (upstream's "unavailable → report failure" contract). The
    `<SDL_syswm.h>` / `<X11/Xresource.h>` it pulls resolve through the same transitive
    `compat.glfw → compat.x11` chain the GLFW leg already uses.
  - **macOS / Windows**: `__linux__` is false, so no macro can wake the block — instead a
    `core::window` stub `sendX11MoveResizeForWindow(void*, int)` returning false, guarded
    by `defined(__cplusplus)` so force-included C TUs (`tray_bridge.c`, `native_bridge.c`)
    do not hit `unknown type name 'namespace'`. That is
    the fallback upstream's GLFW branch (:608) and its own release notes both describe
    ("on non-X11 platforms the delegation returns false and callers keep their
    programmatic fallback"). `Handle` is `void*` in the SDL2 branch (`window_types.h`),
    so the signature matches the unguarded call sites exactly, and the real linux-only
    definition cannot exist on this branch of the `#if`, so there is no redefinition.
  - Both halves stay package-private; neither may become an interface define — consumers
    would inherit the lie on every platform (on macOS, SDL_syswm.h would then demand X11
    headers consumers don't have). The stub branch is additionally syntax-checked against
    the exact call-site pattern in both C and C++ modes.
- No source list, dep, feature-shape or flag changes otherwise.

## Test members

All seven `tests/examples/eui-neo*` members bumped to `0.6.1` (from 0.6.0). No test source
changes: the 0.6.1 surface this workspace exercises (backends, app-mains, tray, markdown,
network, window) is unchanged in shape; the new API (transparent framebuffer, delegated
move/resize, onStart/appId) is window-lifecycle surface that needs a compositor and is not
assertable headless.

## Verification

Locally, mcpp 2026.10.1.2 (same as CI `MCPP_VERSION`), Linux x86_64, `MCPP_INDEX_MIRROR=GLOBAL`:

- Index lint: `check_mirror_urls`, `check_package_name`, `check_reserved_namespace`,
  `check_cross_package_refs`, `check_platform_version_parity`, `check_duplicate_versions` —
  all clean; `mcpp xpkg parse` accepts the descriptor.
- First pass: six of seven members green, **eui-neo-sdl2 failed to compile** —
  `'sendX11MoveResizeForWindow' was not declared in this scope`
  (window_backend.cpp:571), the upstream guard asymmetry described above. That is what
  produced the `SDL_VIDEO_DRIVER_X11` shim; it is measured, not hypothetical.
- Second pass, with the shim: all seven members `mcpp test` green: eui-neo (headless),
  eui-neo-window, eui-neo-app-main, eui-neo-markdown, eui-neo-sdl2 (sdl2+network),
  eui-neo-vulkan, eui-neo-tray.
- **PR #531 CI then failed the macOS and Windows workspace legs**:
  - First CI revision: `use of undeclared identifier 'sendX11MoveResizeForWindow'`
    at :567/:571. Same root cause, worse shape: off linux the declaration does not
    exist at all, so the linux macro shim did not apply.
  - Second CI revision: the `core::window` stub was introduced, but because
    `mcpp_eui_backends.h` is force-included into all package TUs via `cflags`, C TUs
    (`tray_bridge.c`, `native_bridge.c`) failed with `error: unknown type name 'namespace'`.
  - Third revision: guarded the stub with `defined(__cplusplus)`, ensuring C TUs
    bypass the C++ namespace block while C++ TUs retain the fallback declaration.
- `compile_commands.json` (fresh, from the passing builds): the 0.6.1
  `window_backend.cpp` TU carries `compat-x-x11/1.8.13/include` via the transitive
  `compat.glfw → compat.x11` chain — `<X11/Xlib.h>` resolves with no direct dep added.
  The shim reaches the sdl2 TU through the same force-include
  (`-include mcpp_eui_backends.h`) every eui-neo TU already carries — the macro lives in
  the header, so it never appears as a `-D` on the compile line; the evidence it is in
  effect is the failed-then-passing eui-neo-sdl2 compile across the two runs.

CI status: linux legs (default + llvm×4), lint, build, select, measure, timings,
mirror-cn-reachable and graphics-side-effects passed on earlier revisions; macOS and
Windows failed on the SDL2 member only due to the unguarded C TU namespace in the stub,
which the `__cplusplus` guard (this revision) resolves.
