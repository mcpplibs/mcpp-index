# Design doc: bump `compat.eui-neo` to 0.5.9

Date: 2026-09-04

Follow-up to `.agents/docs/2026-08-10-bump-eui-neo-0.5.6-plan.md` and commit `32de619` (0.5.8).
Upstream released 0.5.9; this bumps the index from 0.5.8 to 0.5.9.

## Source and version

| | |
|---|---|
| Upstream | `https://github.com/sudoevolve/EUI-NEO` |
| Version | `0.5.9` (latest release) |
| Tarball | `archive/refs/tags/v0.5.9.tar.gz` |
| sha256 | `370d1da706d94bbbb144fa1634e1d9796a8a1ffd58b696fbb801296aef15703d` (verified twice, stable) |
| Wrap dir | `EUI-NEO-0.5.9/` — absorbed by the standard `*/` glob prefix, no `install()` hook |
| CN mirror | **pending** — no `mcpp-res` write access on this machine; plain-string url fallback per SOP |
| License | Apache-2.0 (unchanged) |

## What changed upstream (0.5.8 → 0.5.9)

- `CORE_SOURCES` is **byte-identical** to 0.5.8, so the lib shape and source count (26 sources) remain unchanged.
- Upstream removed xmake integration and the unused `EUI_APP_RUNNER` stub from `eui_neo.h`.
- Hardened render cache optimizations (text batch vertex/flush stats, backdrop blur capture tracking and invalidation, dirty rect pass estimation heuristic).
- Streamlined external CMake app setup via global properties.
- `3rd/` vendored dependencies, dependencies, features, and flags carry over unchanged.
- `-fno-char8_t` remains required as upstream still handles UTF-8 string conversions similarly.

## Descriptor changes (`pkgs/e/compat.eui-neo.lua`)

1. `xpm.{linux,macosx,windows}` each gain a `["0.5.9"]` entry (plain-string fallback url, matching 0.5.8).
2. Header comments updated to note v0.5.9 upstream tracking and wrap layer absorption.

## CN mirror status

Per `docs/cn-mirror.md` and the SOP, without `mcpp-res` credentials or `gtc`, plain-string GLOBAL upstream URL is used. CI's `check_mirror_urls.lua` exempts plain strings.

## Test members verification

All 7 workspace members consuming `compat.eui-neo` were bumped to `0.5.9`:
1. `tests/examples/eui-neo`: passed (`smoke test: ok`, finished in 186.96s)
2. `tests/examples/eui-neo-window`: passed (`compat.eui-neo[own main]: linked`, finished in 167.48s)
3. `tests/examples/eui-neo-app-main`: passed (`compat.eui-neo[app-main]: linked`, finished in 35.38s)
4. `tests/examples/eui-neo-markdown`: passed (`compat.eui-neo[markdown]: ok`, finished in 30.75s)
5. `tests/examples/eui-neo-sdl2`: passed (`compat.eui-neo[sdl2,network]: ok`, finished in 41.40s)
6. `tests/examples/eui-neo-tray`: passed (`linux tray backend verified`, finished in 23.07s)
7. `tests/examples/eui-neo-vulkan`: passed (`compat.eui-neo[vulkan]: ok`, finished in 37.41s)

Full repo lints (`check_mirror_urls.lua`, `check_package_name.lua`, `check_cross_package_refs.lua`, `check_platform_version_parity.lua`, `check_duplicate_versions.lua`, and `mcpp xpkg parse`) passed with status 0.
