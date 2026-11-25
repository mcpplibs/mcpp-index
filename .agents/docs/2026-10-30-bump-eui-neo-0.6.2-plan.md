# Design doc: bump `compat.eui-neo` to 0.6.2

Date: 2026-10-30

Follow-up to `.agents/docs/2026-10-14-bump-eui-neo-0.6.1-plan.md` and commit `725ca5d` (0.6.1).
Upstream released 0.6.2; this bumps the index from 0.6.1 to 0.6.2.

## Source and version

| | |
|---|---|
| Upstream | `https://github.com/sudoevolve/EUI-NEO` |
| Version | `0.6.2` (latest release) |
| Tarball | `archive/refs/tags/v0.6.2.tar.gz` |
| sha256 | `189d97aadb044de653237e12ac97d6fa92f1a65952854e3db6211d360f4d4124` (computed twice — local download and a second fresh download, stable) |
| Wrap dir | `EUI-NEO-0.6.2/` — absorbed by the existing `install()` hook (`normalise_layout`) |
| CN mirror | **pending** — no `mcpp-res` write access on this machine; plain-string url fallback per SOP |
| License | Apache-2.0 (unchanged) |

## What changed upstream (0.6.1 → 0.6.2)

Release notes: `docs/releases/v0.6.2.md` (SDL2 single-finger touch input,
pixel-granular `ScrollEvent::pixelX/pixelY`, Markdown viewport-only builds,
glyph-advance caching, on-demand glyph-atlas allocation, ~8 MB text-memory
win, software-renderer TODO doc).

- **`CORE_SOURCES` and `VULKAN_SOURCES` are byte-identical to 0.6.1**
  (extracted and diffed from both `CMakeLists.txt`). No new files under
  `core/`; the changed files are internals (`text.cpp/h`, `opengl_text.cpp`,
  `vulkan_text.cpp`, input headers, `render_backend.h`, `dsl_runtime.h`,
  runtime headers, `components/markdown.h`, `sdl2_app_main.cpp` + a new
  `<unordered_map>` include) and app/test/doc material. The lib's source
  list, deps, features and flags carry over unchanged.
- `components/markdown.h` still guards its body on `EUI_HAS_MD4C` — the
  `markdown` feature is unchanged.
- `sdl2_app_main.cpp` (the `app-main-sdl2` feature TU) gains one STL include
  only — no descriptor impact.
- **The one descriptor-relevant change**: upstream fixed the 0.6.1
  `sendX11MoveResizeForWindow` breakage this index worked around in
  `mcpp_eui_backends.h`. In 0.6.1 the SDL2 branch's definition sat INSIDE
  `#if __linux__ && !__ANDROID__ && defined(SDL_VIDEO_DRIVER_X11)` while
  `beginWindowMove`/`beginWindowResize` called it unguarded; 0.6.2 moved the
  `#endif` from below the definition to above it (verified by diffing
  `core/window/window_backend.cpp` across the two extracted tags), so the
  definition is now unguarded — with the X11 specifics still inside the
  guard and an `#else return false` body, exactly like the GLFW branch.

## The shim problem this creates

The 0.6.1 workaround's non-linux arm is a package-private stub:

```cpp
namespace core::window {
inline bool sendX11MoveResizeForWindow(void* window, int direction) { … }
}
```

On 0.6.2 non-linux, upstream's now-unguarded real definition reaches the
same TU → **redefinition** (measured: compile of the 0.6.2 member against
the unmodified 0.6.1-era header fails). Version-gating the generated header
from the descriptor is not expressible: the xpkg parser accepts only literal
strings in `generated_files` — a concatenated Lua value fails with
`malformed mcpp segment` (measured with a probe package on mcpp
2026.10.1.2), so `pkginfo.version()` cannot select header content, and no
per-version `mcpp` override exists in the schema.

**Fix: the stub became a function template.**

```cpp
namespace core::window {
template <typename W>
inline bool sendX11MoveResizeForWindow(W* window, int direction) { … }
}
```

- 0.6.1 non-linux: the definition is guard-hidden, the template is the only
  candidate, the unguarded uses at :567/:571 resolve to it. Compiles and
  links (weak inline symbol).
- 0.6.2 non-linux: the real non-template definition precedes the uses; the
  call is an exact-match tie between template (W deduces to void, `Handle`
  is `void*` in the SDL2 branch) and non-template — non-template wins — and
  the template goes unused. A template and a non-template of the same name
  coexist, so there is no redefinition.
- linux (both tags): the linux arm still defines `SDL_VIDEO_DRIVER_X11=1`
  for the package's own TUs. On 0.6.1 that wakes the guard holding the real
  definition (non-template wins over the template — fine). On 0.6.2 it wakes
  the self-contained `X11ResourceApi` block (which self-includes
  `<SDL_syswm.h>`/`<X11/Xresource.h>` inside the guard) and the guarded
  branch of `sendX11MoveResizeForWindow`/`x11ContentScale`; runtime-safe
  under compat.sdl2 (dummy+offscreen — no SDL window is ever an X11 window,
   and `x11ResourceApi()` fails its `available()` check without libX11).

Mechanism verified with g++ -std=c++17 mini-repros that model each tag's
exact structure (guard-hidden vs unguarded definition), force-including the
extracted shim header:

- 0.6.1 shape, simulated non-linux (`-U__linux__`): compiles+links, template
  emitted (`nm`: weak `sendX11MoveResizeForWindow<void>`), picked at runtime.
- 0.6.2 shape, simulated non-linux: compiles+links, exit code proves the
  real definition (returns true) won over the template (returns false).
- 0.6.1 linux shape (macro woken): real in-guard definition wins, exit code
  proves it.
- Negative control: 0.6.1 shape WITHOUT the shim fails to compile
  ('core' undeclared), matching the original 0.6.1 failure.

## Version bumps

- `pkgs/e/compat.eui-neo.lua`: 0.6.2 entries on linux/macosx/windows,
  plain-string GLOBAL url (no CN mirror yet), plus the file-top version note.
- Member pins `0.6.1` → `0.6.2` in all seven `tests/examples/eui-neo*`
  members (the pins are floors; resolution picked 0.6.1 over 0.6.2 until
  raised — same pattern as the 0.6.1 bump).

## Local verification (mcpp 2026.10.29.1, xlings 2026.10.26.1)

- `eui-neo-sdl2`, `eui-neo-vulkan`, `eui-neo-app-main`, `eui-neo-markdown`,
  `eui-neo-tray`, `eui-neo-window`: **test result ok** (each builds
  compat.eui-neo 0.6.2 and runs). The sdl2 member is the one that exercises
  the reworked shim path on linux.
- `eui-neo` (base member): compat.eui-neo 0.6.2 compiles and links (27
  units), but the post-link runtime-closure check fails on this machine:
  `libffi.so.8` is not on the artifact's search path. This is pre-existing
  environment rot, not a 0.6.2 regression: the 0.6.1 build fails the same
  check here (measured before the bump), the subos library view at
  `~/.mcpp/registry/subos/default/lib` still carries `libffi.so.7` while the
  index resolves `xim:libffi@3.4.4` (which ships `.so.8`), and
  `xlings install/update xim:libffi` both report "already installed" without
  repointing the view. CI's fresh containers are authoritative for the run.
- `mcpp xpkg parse` on the descriptor: OK. Lint equivalents (mirror urls,
  platform parity, duplicate versions) pass locally.

## Notes

- The `mcpp` segment stays version-independent; one header now serves every
  published tag (0.5.3 through 0.6.2).
- The 0.6.1-era comment block in the descriptor was updated, not removed —
  the template trick only makes sense with the 0.6.1 history in view.
