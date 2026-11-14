# Add mcpplibs.mwrap.recastnavigation (recastnavigation-m 1.6.0)

## Form

- Third-party upstream [recastnavigation/recastnavigation](https://github.com/recastnavigation/recastnavigation), release
  v1.6.0, zlib.
- Form A external mwrap module repository [mcpplibs/recastnavigation-m](https://github.com/mcpplibs/recastnavigation-m),
  package `mcpplibs.mwrap.recastnavigation`, version 1.6.0 (the first indexed release of the identity), tag `mwrap-1.6.0`;
  release asset `recastnavigation-m-1.6.0.tar.gz` (`13382f6c…daa05`), CN mirror `gitcode.com/mcpp-res/mwrap-recastnavigation`
  with identical bytes.
- Implementation ownership: the library has no compat package in this index, so the wrapper vendors the four libraries
  (Recast, Detour, DetourCrowd, DetourTileCache: `Include/` and `Source/`) from the release archive (checksums of every
  file in `upstream/documents.json`) and builds them with `-ffp-contract=off` and no fast math, with `NDEBUG` in every
  profile (upstream declares its assert hooks only without it). DebugUtils, the demo and upstream's tests are not
  vendored. It deploys upstream's README and License.txt with its own LICENSE/NOTICE (`runtime.deploy`).

## Module

- `mcpplibs.mwrap.recastnavigation`: every name declared at global scope by the four libraries' public headers, by
  `export using ::name;` (99 types, 75 enumerators of unscoped enumerations, 170 functions).
- Internal-linkage adaptation: 52 `static const` objects (`DT_VERTS_PER_POLYGON`, `DT_SUCCESS`, `DT_FAILURE`,
  `RC_WALKABLE_AREA`, `RC_PI` …) are declared again under their names, with their types and values, in
  `mcpplibs::mwrap::recastnavigation` (an integer from the header's constant, a float from its literal).
- No `.macros` module: upstream's macros are its asserts, branch hints and `RC_SIZE_MAX`, used by its own sources.
- The export list is derived by `tools/surface.py` from the headers as clang reads them (its JSON AST), recorded in
  `tools/surface.json`, and audited in CI: the module is the record on every row, and on the Linux LLVM row the record
  is derived again and compared.

## Verification

- Wrapper CI (Linux x86_64 and arm64 with GCC 16.1 and LLVM 23.1.3, macOS LLVM, Windows LLVM, each in the dev and
  release profiles; wasm32-emscripten under node): a navigation mesh built from a floor and a wall, the same bytes
  twice; a path around the wall, its straight path, a ray along the mesh stopped by the wall; a crowd of four walked
  through the doorway; the mesh's bytes and the crowd's places pinned and the same on every row; the adapted
  constants; the export audit; the default template from an installed copy with a strict build.
- This index: consumer `tests/mwrap/recastnavigation-path` (the same pinned hashes); the installed-template check
  with `--deploy` (`STATIC_NOTICES`).
