# Design doc: bump `compat.eui-neo` to 0.6.3

Date: 2026-11-15

Follow-up to `.agents/docs/2026-10-30-bump-eui-neo-0.6.2-plan.md` and commit `1809c8b` (0.6.2).
Upstream released 0.6.3; this bumps the index from 0.6.2 to 0.6.3.

## Source and version

| | |
|---|---|
| Upstream | `https://github.com/sudoevolve/EUI-NEO` |
| Version | `0.6.3` (latest release, 2026-11-12) |
| Tarball | `archive/refs/tags/v0.6.3.tar.gz` |
| sha256 | `08074e2fb72662c8a4c2f7d75dec558aed2c751545797e0ccccbdbe8f439b669` (computed twice from two fresh downloads, stable) |
| Wrap dir | `EUI-NEO-0.6.3/` — absorbed by the existing `install()` hook (`normalise_layout`) |
| CN mirror | **pending** — no `mcpp-res` write access on this machine; plain-string url fallback per SOP |
| License | Apache-2.0 (unchanged) |
| Auto-update | not covered by `.github/xpkgindex-update.yml` (the descriptor has `generated_files` + an `install()` hook); bumped manually |

## What changed upstream (0.6.2 → 0.6.3)

Release notes: `docs/releases/v0.6.3.md` (keyboard navigation + focus, a
backend-agnostic widget semantics snapshot, virtualized `dataTable`, system
save/directory dialogs, input undo byte budgets, line-chart sampling,
async/serial lifecycle fixes, docs reorganisation).

- **`CORE_SOURCES` and `VULKAN_SOURCES` are byte-identical to 0.6.2**
  (extracted and diffed from both `CMakeLists.txt`). Every changed core file
  is already in the source list (`async.cpp`, `platform.cpp`, `primitive.cpp`,
  runtime headers, `window_backend.cpp`); the only new headers are
  `core/accessibility.h` and `include/eui/accessibility.h`, both header-only
  and re-exported by `include/eui_neo.h`.
- **The one link-line change**: upstream's Windows block grew
  `ole32 comdlg32 uuid` (`target_link_libraries(eui_neo PUBLIC …)`), for
  `platform.cpp`'s new directory picker (`CoCreateInstance(CLSID_FileOpenDialog,
  … IID_PPV_ARGS)`, `SHCreateItemFromParsingName`). This descriptor already
  named ole32/comdlg32 from the 0.6.1 CI work; `-luuid` is the new name (the
  `IID_*`/`CLSID_*` GUID symbols). The linux implementation shells out to
  zenity/kdialog and the macOS one to osascript, so neither leg gains a
  link-time dependency.
- **New optional module with a TU**: `modules/serial/` ships
  `serial.cpp`/`serial.h` and CMake builds it as `eui::module_serial`, a
  separate target linking `eui::neo` — it is NOT part of `CORE_SOURCES`, and
  the only in-tree consumer is the `serial_tool` example and the `serial_port`
  unit test (which compiles the TU per-test). Exposed here as the `serial`
  feature (see below). `modules/keyboard/` is a single header with no TU, so
  it needs no feature entry — the `*` include root already serves it.
- The SDL2 branch of `window_backend.cpp` keeps 0.6.2's hoisted
  `sendX11MoveResizeForWindow` definition (`#endif` position unchanged across
  0.6.2 → 0.6.3, diffed), so the 0.6.1-era package-private template stub in
  `mcpp_eui_backends.h` stays inert on non-linux and the linux
  `SDL_VIDEO_DRIVER_X11` define stays a practical no-op. **No shim change.**
- No build-config macro changed: the `EUI_*` macro set extracted from
  `core/`, `include/` and `components/` is identical between 0.6.1 and 0.6.3.

## Descriptor changes (`pkgs/e/compat.eui-neo.lua`)

- `xpm.<linux|macosx|windows>["0.6.3"]`: plain-string GLOBAL url (no CN
  mirror yet), sha256 above.
- Windows `ldflags`: `-luuid` added, with the rationale next to it.
- New `serial` feature: `sources = { "*/modules/serial/serial.cpp" }` —
  source-gated exactly like `app-main`; a consumer that names it includes
  `<modules/serial/serial.h>` through the existing `*` include root.
- File-top version note for 0.6.3; the `CORE_SOURCES` recipe reference moved
  to `v0.6.3`.

## Test members

- All seven `tests/examples/eui-neo*` members: pin `0.6.2` → `0.6.3`.
- **New member `tests/examples/eui-neo-serial`** (registered in the root
  `mcpp.toml` workspace): asserts the feature at link time (SerialPort ctor/
  dtor/open/isOpen come from `serial.cpp`) and at runtime opens a device path
  that cannot exist, so `!open().ok`, `!isOpen()`, and move-ownership leaving
  the moved-from object closed — no hardware, no privileges.

## Verification

Local Linux x86_64, mcpp **2026.11.15.1** (the CI `MCPP_VERSION`, downloaded
as the release tarball), `MCPP_INDEX_MIRROR=GLOBAL`, every member cold
(`target/` and `.mcpp/` removed) before its run:

| Member | Result |
|---|---|
| `eui-neo` | `test result ok` — `compat.eui-neo smoke test: ok (parsed eui-neo v3, markdown gated off)` |
| `eui-neo-window` | `test result ok` — own-main loop linked, window run opt-in |
| `eui-neo-app-main` | `test result ok` — package-supplied `main()` linked |
| `eui-neo-markdown` | `test result ok` — `markdown: ok (2 blocks, h1 = 'Heading')` |
| `eui-neo-tray` | `test result ok` — `linux tray backend verified over a private session bus` |
| `eui-neo-vulkan` | `test result ok` — `backend=vulkan, loader api 1.4.357` |
| `eui-neo-sdl2` | `test result ok` — `SDL driver=dummy, curl 8.21.0-DEV ssl=OpenSSL/3.5.1` |
| `eui-neo-serial` | `test result ok` — feature on: link + runtime assertions pass |

Negative verification for `serial`: with the feature removed from the
member's dependency declaration, the cold build fails at link with
`undefined reference to 'core::serial::SerialPort::SerialPort()'` (and
`isOpen`, `open`, the move ctor, `close`, the dtor) — the gating is real, not
a default. Restoring the feature returns the member to `test result ok`.

Index lint: `check_mirror_urls`, `check_package_name`,
`check_reserved_namespace`, `check_cross_package_refs`,
`check_platform_version_parity`, `check_duplicate_versions` — all clean;
`mcpp xpkg parse` reports `features 7`, `parse OK`.

Known local noise (pre-existing, not caused by this bump): the sdl2 member's
link prints mcpp's "one library, two providers" note for zlib
(`compat.zlib` vs glib's runtime `libz.so.1`, mcpp#519). The descriptor
already documents why libz is not staged.

## CI status

PR #804 (run `43730038159`), all legs green: `lint`, `select`, `build`, `scan`,
`mirror-cn-reachable`, `graphics install: no side effects on unrelated
members`, workspace linux default + llvm 0–3/4, macOS, Windows, and the
`candidate (compat:eui-neo 0.6.3)` install/build legs on linux
default/llvm, macosx and windows. The Windows candidate + workspace legs are
what validate `-luuid` and `serial.cpp`'s `windows.h` branch; the macOS leg
validates the termios branch and the framework links.

## Notes

- macOS and Windows legs are unverified locally; the CI `workspace` legs are
  authoritative for `-luuid` and for `serial.cpp`'s `windows.h`/termios
  branches.
- The `serial` feature is new surface, so the 0.6.3 bump is two things at
  once: three version entries and the first descriptor-level exposure of
  upstream's module system. If CI finds a platform-specific break in
  `serial.cpp`, the version entries stand on their own and the feature can be
  reverted without touching them.
