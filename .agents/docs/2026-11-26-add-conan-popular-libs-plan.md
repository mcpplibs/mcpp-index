# Add Popular ConanCenter Libraries (`compat.pugixml`, `compat.simdjson`, `compat.utfcpp`, `compat.iniparser`)

## Summary

Add four popular C/C++ libraries from ConanCenter (`https://conan.io/center`) to `mcpp-index` on branch `feat/add-conan-popular-libs` off `upstream/main`:

1. `compat.pugixml` (`1.16`, `zeux/pugixml`, MIT) — lightweight C++ XML parser with XPath support.
2. `compat.simdjson` (`5.3.0`, `simdjson/simdjson`, Apache-2.0 / MIT) — SIMD-accelerated C++ JSON parser.
3. `compat.utfcpp` (`5.0.0`, `nemtrif/utfcpp`, BSL-1.0) — header-only UTF-8 / UTF-16 C++ library.
4. `compat.iniparser` (`4.3.2`, `ndevilla/iniparser`, MIT) — C99 INI file parser.

## Package Architecture

- **Upstream Archives & Mirror Fallback**:
  - All four packages use stable GitHub tag release tarballs (`archive/refs/tags/v<ver>.tar.gz`) across `linux`, `macosx`, and `windows`.
  - SHA256 hashes were computed twice to confirm tarball stability:
    - `compat.pugixml` `1.16`: `357bcab8877dc9943f355d3a72daba1b053238ba955f50fa81586afb65090219`
    - `compat.simdjson` `5.3.0`: `5e59df8bd3fa760937e6a2ca68193399c85b52b5042716700b149a734737dced`
    - `compat.utfcpp` `5.0.0`: `42c36e1ef1307b1186996e4644f9999970e26325670b99019f3408bf0d3c952a`
    - `compat.iniparser` `4.3.2`: `e9eb6be555c30fbef87e5a07333fcff6ef8c5bbbdc5710321bbad7ebae0612a7`
  - Plain upstream URL strings are used because no local gitcode `mcpp-res` credentials are configured; CN mirrors can be added later without changing SHA256.

- **Descriptors & Morphology**:
  - `pkgs/c/compat.pugixml.lua`: C++ source compat (`include_dirs = { "*/src" }`, `sources = { "*/src/pugixml.cpp" }`, `license_files = { "*/LICENSE.md" }`).
  - `pkgs/c/compat.simdjson.lua`: C++ source compat using upstream's official amalgamation (`include_dirs = { "*/singleheader" }`, `sources = { "*/singleheader/simdjson.cpp" }`, `license_files = { "*/LICENSE", "*/LICENSE-MIT" }`). `features.default` implies `threads` (`defines = { "SIMDJSON_THREADS_ENABLED=1" }`), and `linux.ldflags = { "-lpthread" }`. Consumers opting out via `default-features = false` build without `SIMDJSON_THREADS_ENABLED=1`.
  - `pkgs/c/compat.utfcpp.lua`: Header-only Shape B (`include_dirs = { "*/source" }`, anchor TU `mcpp_generated/utfcpp_anchor.c`, `license_files = { "*/LICENSE" }`).
  - `pkgs/c/compat.iniparser.lua`: C99 source compat + generated config (`sources = { "*/src/dictionary.c", "*/src/iniparser.c" }`, `generated_files["mcpp_generated/version.h"]` matching `cmake/version.h.in`, `include_dirs = { "*/src", "mcpp_generated" }`, `license_files = { "*/LICENSE" }`). Linux sets `-D_POSIX_C_SOURCE=200809L` for `strdup`/`fmemopen`; Windows sets `-D_CRT_SECURE_NO_WARNINGS` and `-D_CRT_NONSTDC_NO_DEPRECATE`.

- **Automatic Updates**:
  - All four descriptors declare `package.extensions.autoupdate` tracking `v${version}` GitHub tag archives.

## Workspace Test Members

1. `tests/examples/pugixml`: asserts `PUGIXML_VERSION == 1160`, DOM traversal, XPath query (`/catalog/book[@id='2']/title`), node mutation + serialization, and malformed XML rejection.
2. `tests/examples/simdjson`: asserts `SIMDJSON_THREADS_ENABLED`, On-Demand parser, DOM parser, active implementation, and invalid JSON rejection.
3. `tests/examples/simdjson-nothreads`: `default-features = false`, asserts `SIMDJSON_THREADS_ENABLED` is omitted on non-Windows targets and On-Demand parsing succeeds.
4. `tests/examples/utfcpp`: asserts `utf8::is_valid`, `utf8::distance`, `utf8::utf8to16`/`utf8::utf16to8` round-trip, `utf8::find_invalid`, and `utf8::replace_invalid`.
5. `tests/examples/iniparser`: asserts `INIPARSER_VERSION_MAJOR == 4` / `MINOR >= 3`, `iniparser_load`, typed getters (`getstring`, `getint`, `getdouble`, `getboolean`), `iniparser_find_entry`, `iniparser_set`, and `iniparser_freedict`.

## Verification (`mcpp 2026.11.23.1`)

- All repo lints (`check_mirror_urls.lua`, `check_package_name.lua`, `check_reserved_namespace.lua`, `check_mplugin_layout.lua`, `check_cross_package_refs.lua`, `check_platform_version_parity.lua`, `check_duplicate_versions.lua`, `check_capability_providers.lua`, `check_quill_install.lua`, `tools/platform_rows.py check`, `test_check_mplugin.py`, `test_check_capability_providers.py`, `tests/openkal/compat.py selftest`, `tests/red_members.py selftest`) passed.
- `mcpp xpkg parse` passed for all four new descriptors.
- `tests/select_members.py --base upstream/main ...` selected `pugixml simdjson simdjson-nothreads utfcpp iniparser`.
- Cold `MCPP_HOME` (`target/conan-validation-home`) `tests/run_members.sh pugixml simdjson simdjson-nothreads utfcpp iniparser` passed under `gcc@16.2.0` (1 test passed per member).
- `tests/autoupdate/ci.py audit --base upstream/main`, `xpkgindex_update inspect`, and authenticated `xpkgindex_update check` confirmed `up-to-date` for all four packages.
