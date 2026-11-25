# Add mcpplibs.mwrap.meshoptimizer (meshoptimizer-m 1.3) and mcpplibs.mwrap.cgltf (cgltf-m 1.15)

## Form

- Third-party upstreams [zeux/meshoptimizer](https://github.com/zeux/meshoptimizer), release v1.3, MIT, and
  [jkuhlmann/cgltf](https://github.com/jkuhlmann/cgltf), release v1.15, MIT (it embeds jsmn, MIT).
- Form A external mwrap module repositories [mcpplibs/meshoptimizer-m](https://github.com/mcpplibs/meshoptimizer-m) and
  [mcpplibs/cgltf-m](https://github.com/mcpplibs/cgltf-m); packages `mcpplibs.mwrap.meshoptimizer` 1.3 and
  `mcpplibs.mwrap.cgltf` 1.15 (first releases of both identities), tags `mwrap-1.3` and `mwrap-1.15`; release assets
  `meshoptimizer-m-1.3.tar.gz` (`5172030f…4e7e`) and `cgltf-m-1.15.tar.gz` (`242d90c6…070b`), CN mirrors
  `gitcode.com/mcpp-res/mwrap-meshoptimizer` and `gitcode.com/mcpp-res/mwrap-cgltf` with identical bytes.
- Implementation ownership: neither library has a compat package in this index, so each wrapper vendors its upstream
  from the release archive (checksums in `upstream/documents.json`) and builds it itself: meshoptimizer's `src/*.cpp`
  unchanged; cgltf's two headers unchanged, their implementation in one C translation unit of the package
  (`port/cgltf.c`) with upstream's defaults. Both deploy upstream's README and license with their own LICENSE/NOTICE
  (`runtime.deploy`).

## Modules

- `mcpplibs.mwrap.meshoptimizer`: every public name of `<meshoptimizer.h>` (9 types, 20 enumerators, 89 functions) by
  `export using`, in the global namespace where upstream declares them; `mcpplibs.mwrap.meshoptimizer.macros`:
  `MESHOPTIMIZER_VERSION` as a constant.
- `mcpplibs.mwrap.cgltf`: every public name of `<cgltf.h>` (72 types, 102 enumerators, 37 functions), re-exporting
  `mcpplibs.mwrap.cgltf.write` (`<cgltf_write.h>`: `cgltf_write`, `cgltf_write_file`). Neither header's public part
  has an object-like constant, so there is no `.macros` module; the configuration macros (`CGLTF_MALLOC` …) are fixed
  at upstream's defaults by the package's one implementation.
- Both export lists are derived from the headers by each repository's `tools/surface.py` and audited in CI
  (`tools/check_exports.py`).

## Verification

- Wrapper CI (Linux x86_64 GCC 16.1 and LLVM 23.1.3, macOS LLVM, Windows LLVM): the module tests, header mixing, the
  export check, and the default template from an installed copy with a strict build.
- This index: consumers `tests/mwrap/meshoptimizer-simplify` (indexing, vertex cache order, simplification, meshlets,
  both codecs) and `tests/mwrap/cgltf-inspect` (parse, load, validate, accessors, a node's transform, the writer, the
  reasons broken documents are refused with); the installed-template check with `--deploy` for both
  (`STATIC_NOTICES`).
- `tests/mwrap/check_installed_template.py` reads the generated manifest's dependency whether its key is quoted or
  dotted: both templates write the dotted form (mcpp 2026.11.8.1 warns on a quoted key that needs none, and the check
  builds with `--strict`).
