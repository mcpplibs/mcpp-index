# Design doc: add `compat.godot-cpp` 10.0.0 (Godot 4.7 bindings)

Date: 2026-10-30

Follow-up to `.agents/docs/2026-08-04-add-godot-cpp-10.0.0-rc1.md` (rc1).
Upstream godot-cpp released `10.0.0-stable`; this adds it next to the
existing `10.0.0-rc1` (Godot 4.6 bindings) and `4.5.0`.

## Source and version

| | |
|---|---|
| Upstream | `https://github.com/godotengine/godot-cpp`, tag `10.0.0-stable` |
| Version | `10.0.0` (bare) |
| Archive | repack per `tools/godot-cpp/repack.sh` (upstream tree byte-for-byte + generated `gen/`) |
| sha256 | `85983e0bf4667080c056d2250bf7c1c90f36f7eaa6e5f939d8ab356ebdbd7325` |
| GLOBAL | `github.com/xlings-res/godot-cpp` release `10.0.0` — **publication pending, see below** |
| CN | `gitcode.com/mcpp-res/godot-cpp` release `10.0.0` — pending, same reason |
| License | MIT (unchanged) |

## ⚠️ Artifact publication is the merge gate

This machine has read-only access to `xlings-res/godot-cpp` (GitHub) and no
gitcode token, so the repacked archive cannot be published from here. The
archive in `/tmp/godot-repack/godot-cpp-10.0.0.tar.gz` (sha above) is ready;
a maintainer with write access must attach it to both mirrors under the
`10.0.0` tag, after which CI's GLOBAL fetch and `mirror-cn-reachable` go
green. Local verification ran against a byte-identical copy temporarily
published to `github.com/FarnaHerry/godot-cpp-mirror` release `10.0.0` (the
descriptor was pointed at it for the test run and restored to the canonical
xlings-res URL afterwards).

## repack.sh needed two fixes (both measured, both in this change)

1. **Per-version API JSON.** Between rc1 and stable, `gdextension/` stopped
   shipping a single `extension_api.json`; it now ships
   `extension_api-4-3.json` … `extension_api-4-7.json`, and the `api_version`
   build option selects one (cmake: `GODOTCPP_API_VERSION`; scons: no
   default, must be passed). The script hardcoded
   `gdextension/extension_api.json` and died with FileNotFoundError. It now
   dispatches on what the tag actually ships and takes the newest
   `extension_api-*.json` when the single file is absent — matching cmake's
   `GODOTCPP_DEFAULT_API_VERSION "4.7"` (CMakeLists.txt), i.e. the default
   answer a cmake consumer gets.
2. **`LC_ALL=C`.** The byte-for-byte verification greps diff(1) output for
   the English marker `Only in ...: gen`. Under this machine's zh_CN locale
   diff prints `只在 ... 中存在：gen`, the filter matches nothing, and the
   script refused a correct tree. The script now pins `LC_ALL=C`.

## What 10.0.0 changes for the descriptor

- The `mcpp` segment is unchanged: hand-written layout is the same, the
  three include roots still cover it (4.5 checks in `gdextension/`, 10.x
  generates `gdextension_interface.h` into `gen/include/`), and the source
  globs `*/src/*.cpp`, `*/src/*/*.cpp`, `*/gen/src/*.cpp`,
  `*/gen/src/*/*.cpp` sweep 1056 gen TUs + 33 hand-written ones. The one new
  hand-written TU, `src/templates/hashfuncs.cpp`, is already matched by
  `*/src/*/*.cpp` (verified in the extracted archive).
- `src/godot.cpp` still calls `realloc()`/`free()` without including
  `<cstdlib>` — the `-include cstdlib` cxxflag stays.
- **Bindings are Godot 4.7**, not 4.6: `gen/.../core/version.hpp` says
  `GODOT_VERSION_MAJOR 4 / MINOR 7`, and the class set differs (15 class
  headers exist only in the 4.7 gen tree, e.g. `AreaLight3D`,
  `AccessibilityServer`, `AwaitTweener` — `comm(1)` against rc1's gen tree).

## Version bumps

- `pkgs/c/compat.godot-cpp.lua`: `10.0.0` entries ×3 platforms, both
  mirrors named, sha above.
- `tests/examples/godot-cpp-v10`: pin `10.0.0-rc1` → `10.0.0`; the test now
  asserts `GODOT_VERSION_MINOR == 7` and uses `AreaLight3D` (new in 4.7) as
  the version-discriminating class, replacing `EditorDock` (new in 4.6).
- `godotengine.godot-cpp-m` stays at 4.5.0 — the module layer was never
  carried to 10.x (rc1 didn't add it either); out of scope here.

## Local verification (mcpp 2026.10.29.1)

- `mcpp test -p godot-cpp-v10`: first run built the full ~1056-TU library
  cleanly and failed ONLY the version assertion (`version=0`, everything
  else `1`) — the test still expected 4.6. After the test update:
  **test result ok** (see the member log; the assertion that failed is
  exactly the one that proves 4.7 bindings arrived).
- `mcpp xpkg parse pkgs/c/compat.godot-cpp.lua`: OK.
- Lint equivalents (mirror urls, platform parity, duplicate versions) pass.

## Notes

- 10.0.0 and 10.0.0-rc1 are different bindings of different engine releases
  (4.7 vs 4.6); both stay listed, same pattern as catch2/catch2-v2.
- `gen/` is generated with the same flags as rc1 (64-bit, single precision,
  template_get_node on).
