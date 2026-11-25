# Add `compat.arrow-adbc` (Apache Arrow ADBC 25)

## Summary

Add `compat.arrow-adbc` at release version `"25"` (`apache-arrow-adbc-25`, upstream internal `ADBC_VERSION = 1.13.0`, Apache-2.0) in its own independent PR against `upstream/main`.

## Package Architecture

- **Upstream archive**: `https://github.com/apache/arrow-adbc/releases/download/apache-arrow-adbc-25/apache-arrow-adbc-25.tar.gz` (plain GitHub string URL; autoupdate uses `tag = "apache-arrow-adbc-${version}"`).
- **Core target (`adbc_driver_manager`)**:
  - 4 C++20/23 source files under `*/c/driver_manager/` (`adbc_driver_manager.cc`, `adbc_driver_manager_api.cc`, `adbc_driver_manager_driver_loading.cc`, `adbc_driver_manager_profiles.cc`), zero external dependencies.
  - Exposes `*/c/include` publicly; private headers (`*/c`, `*/c/vendor`, `*/c/driver`, `mcpp_generated`) are scoped inside each platform block's `include_dirs` + `private_include_dirs`.
- **Static-API export macro (`ADBC_EXPORT=`)**:
  - `c/include/arrow-adbc/adbc.h` defines `#define ADBC_EXPORT __declspec(dllimport)` on `_WIN32` when neither `ADBC_EXPORT` nor `ADBC_EXPORTING` is defined.
  - Because top-level `defines` is package-private, we follow the index convention (`default` -> `staticlib` feature) and put `ADBC_EXPORT=` in `features.staticlib.defines`, which propagates to both package TUs and consumer TUs so Windows static builds avoid `__declspec(dllimport)` mismatches.
- **Optional `sqlite` feature (`features.sqlite`)**:
  - Off by default so minimal driver-manager consumers pull zero dependencies.
  - When enabled, compiles the 6 upstream SQLite driver/common/framework/nanoarrow TUs (`sqlite.cc`, `statement_reader.c`, `utils.c`, `objects.cc`, `utility.cc`, `nanoarrow.c`), generates `mcpp_generated/driver/sqlite/config.h` (`SQLITE_DRIVER_VERSION_STRING "1.13.0"`), supplies per-TU defines (`ADBC_NO_COMMON_ENTRYPOINTS` on `sqlite.cc`, `SIZEOF_TIME_T=8` on `statement_reader.c`), and depends on `compat.sqlite3` (`3.45.3`) and `compat.fmt` (`12.2.0`).

## Verification Plan

1. Lua syntax/lint checks + `"$MCPP" xpkg parse pkgs/c/compat.arrow-adbc.lua` (`mcpp 2026.11.22.1`).
2. `tests/run_members.sh arrow-adbc arrow-adbc-sqlite` under both GCC (`gcc@16.1.0`) and LLVM (`llvm@<ver>` / libc++ 23) with cold `MCPP_HOME`.
3. Negative check verifying default consumer `arrow-adbc` does not pull `compat.sqlite3` or `compat.fmt`.
4. Positive end-to-end SQLite query & Arrow `ArrowArrayStream` assertion in `arrow-adbc-sqlite`.
5. `xpkgindex_update` unit tests, `ci.py audit --base upstream/main`, `inspect`, and `check --package compat:arrow-adbc`.
