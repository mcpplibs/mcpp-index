# Add mcpplibs.mwrap.manifold (manifold-m 3.5.5.1)

## Form

- Third-party upstream [elalish/manifold](https://github.com/elalish/manifold), release v3.5.5, Apache-2.0 (its
  `linalg.h` derives from Sterling Orsten's public-domain library).
- Form A external mwrap module repository [mcpplibs/manifold-m](https://github.com/mcpplibs/manifold-m), package
  `mcpplibs.mwrap.manifold`, version 3.5.5.1 (wrapper revision 1 of upstream 3.5.5; the first indexed release of the
  identity), tag `mwrap-3.5.5.1`; release asset `manifold-m-3.5.5.1.tar.gz` (`d80aa82f…7d3a`), CN mirror
  `gitcode.com/mcpp-res/mwrap-manifold` with identical bytes. The repository's `mwrap-3.5.5` release is not indexed:
  it was built without `-ffp-contract=off`, which upstream's own build sets (a fused multiply-add changes results).
- Implementation ownership: the library has no compat package in this index, so the wrapper vendors `src/*.cpp`,
  `src/*.h` and `include/manifold/` from the release archive (checksums in `upstream/documents.json`) and builds them
  as upstream's default build does (floating-point contraction off), save two choices: one thread (`MANIFOLD_PAR=-1`, no oneTBB) and no `CrossSection`
  (`MANIFOLD_CROSS_SECTION` off: upstream's class needs Clipper2, and the backend without it,
  `cross_section_boolean2.cpp`, is a stub in 3.5.5 — every operation gives nothing — so it is not vendored and
  `<manifold/cross_section.h>` is not exported). It deploys upstream's README, LICENSE and AUTHORS with its own
  LICENSE/NOTICE (`runtime.deploy`).

## Module

- `mcpplibs.mwrap.manifold`: every public name of `<manifold/manifold.h>` and `<manifold/polygon.h>` by `using` in the
  namespace upstream declares it in — `manifold` (36 types, 10 functions, the alias `la`), `manifold::math` (16
  functions), `linalg` (10 types, 116 functions and operators).
- Internal-linkage adaptation: seven `constexpr` objects at namespace scope are not `inline` (`kPi`, `kTwoPi`,
  `kHalfPi`, `DEFAULT_SEGMENTS`, `DEFAULT_ANGLE`, `DEFAULT_LENGTH`, `linalg::identity`); a module cannot export
  them, so they are declared again under their names, with their types and values, in `mcpplibs::mwrap::manifold`.
- No `.macros` module: the public headers define no object-like constant; `DEBUG_ASSERT` and `ASSERT` are upstream's
  own control-flow macros, empty in this configuration. `<manifold/mesh.h>` names `std::istream` and `std::ostream`
  without their header; the module's global fragment includes `<istream>` and `<ostream>` first.
- The export list is derived by `tools/surface.py` from the headers as clang reads them (its JSON AST), recorded in
  `tools/surface.json`, and audited in CI: the module is the record on every row, and on the Linux LLVM row the
  record is derived again and compared.

## Verification

- Wrapper CI (Linux x86_64 GCC 16.1 and LLVM 23.1.3, macOS LLVM, Windows LLVM): the module tests (solids, booleans
  and their volumes, the same input giving the same mesh, the same triangles on every row — every corner bit for bit,
  by a pinned hash; the order they come in follows the standard library's sort and differs between libstdc++ and
  libc++ — meshes in and out, hull, decomposition and splitting,
  linalg, outlines extruded, revolved, sliced and projected, header mixing), the export audit, and the default
  template from an installed copy with a strict build.
- This index: consumer `tests/mwrap/manifold-boolean`; the installed-template check with `--deploy`
  (`STATIC_NOTICES`).
