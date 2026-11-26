# Add `compat.iniparser` (`ndevilla/iniparser` v4.3.2)

## Summary

Add `compat.iniparser` (`pkgs/c/compat.iniparser.lua`) wrapping `ndevilla/iniparser` release `4.3.2` (MIT license) off `upstream/main`.

## Package Architecture

- **Upstream Archive**:
  - Uses stable GitHub tag release archive `https://github.com/ndevilla/iniparser/archive/refs/tags/v4.3.2.tar.gz` across `linux`, `macosx`, and `windows` (plain string URL; CN mirrors can be added later).
  - SHA256 verified twice for stability: `e9eb6be555c30fbef87e5a07333fcff6ef8c5bbbdc5710321bbad7ebae0612a7`.
- **C99 Source Build + Generated Header**:
  - Compiles `*/src/dictionary.c` and `*/src/iniparser.c` as `c99`, exposes `*/src` and `mcpp_generated`, and generates `mcpp_generated/version.h` (matching `cmake/version.h.in` for `4.3.2`).
  - Linux adds `-D_POSIX_C_SOURCE=200809L` for `strdup` and `fmemopen`; Windows adds `-D_CRT_SECURE_NO_WARNINGS` and `-D_CRT_NONSTDC_NO_DEPRECATE`.
- **Automatic Updates**:
  - `extensions.autoupdate` tracks `ndevilla/iniparser` with `tag = "v${version}"`.

## Workspace Test Member

- `tests/examples/iniparser`: asserts `INIPARSER_VERSION_MAJOR == 4` and `MINOR >= 3`, `iniparser_load`, typed getters (`getstring`, `getint`, `getdouble`, `getboolean`), `iniparser_find_entry`, `iniparser_set`, and `iniparser_freedict`.
