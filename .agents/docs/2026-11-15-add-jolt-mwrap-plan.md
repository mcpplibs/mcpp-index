# Add mcpplibs.mwrap.jolt (jolt-m 5.6.0)

## Form

- Third-party upstream [jrouwe/JoltPhysics](https://github.com/jrouwe/JoltPhysics), release v5.6.0, MIT.
- Form A external mwrap module repository [mcpplibs/jolt-m](https://github.com/mcpplibs/jolt-m), package
  `mcpplibs.mwrap.jolt`, version 5.6.0 (the first indexed release of the identity), tag `mwrap-5.6.0`; release asset
  `jolt-m-5.6.0.tar.gz` (`ea4b7052…9c49`), CN mirror `gitcode.com/mcpp-res/mwrap-jolt` with identical bytes.
- Implementation ownership: the library has no compat package in this index, so the wrapper vendors `Jolt/` from the
  release archive (checksums of every file in `upstream/documents.json`) and builds it as upstream's CMake build does
  with `CROSS_PLATFORM_DETERMINISTIC` on (`JPH_CROSS_PLATFORM_DETERMINISTIC`, `-ffp-contract=off`, no fast math),
  with `JPH_NO_DEBUG` (the same library and module names in every profile: upstream turns on its asserts and
  debug-only members when `NDEBUG` is not defined), and without the parts upstream builds only in its Debug and
  Release configurations or as options: no debug renderer, profiler, object stream or GPU compute backend (DX12,
  Vulkan, Metal and their CPU emulation are not vendored). The SIMD level is the target's baseline. It deploys
  upstream's README and LICENSE with its own LICENSE/NOTICE (`runtime.deploy`). On wasm32 it links with a 1 MiB stack
  and growing memory.

## Module

- `mcpplibs.mwrap.jolt`: every name declared at namespace scope in `JPH` and its nested namespaces by the headers under
  `<Jolt/…>` (the debug renderer's, the compute shaders' shared C++/HLSL headers and a list of macro invocations
  excepted), by `using` in the namespace upstream declares it in — `JPH` (450 types, 127 functions and operators, 6
  objects), `ClosestPoint`, `HalfFloatConversion`, `ScaleHelpers`, `StreamUtils`, `literals`.
- Internal-linkage adaptation: 50 `static` or non-`inline` `constexpr` objects (`cMaxPhysicsJobs`,
  `cMaxPhysicsBarriers`, `cDefaultConvexRadius`, `JPH_PI`, the half-float layout, the height field's constants …) are
  declared again under their names, with their types and values, in `mcpplibs::mwrap::jolt` and its nested namespaces
  of the same names; a constant array as a `std::array` of its elements. Two `static` narrow-phase helpers
  (`ActiveEdges::FixNormal`, `IsEdgeActive`) are not exported.
- A name declared on some targets only is exported under upstream's own condition: `JPH::FPControlWord` (SSE and Arm,
  not wasm32).
- No `.macros` module: Jolt's macros are configuration switches and code generation (`JPH_DECLARE_RTTI_*`,
  `JPH_OVERRIDE_NEW_DELETE`, `JPH_ASSERT`).
- The export list is derived by `tools/surface.py` from the headers as clang reads them (its JSON AST), recorded in
  `tools/surface.json`, and audited in CI: the module is the record on every row, and on the Linux LLVM row the record
  is derived again and compared.

## Verification

- Wrapper CI (Linux x86_64 and arm64 with GCC 16.1 and LLVM 23.1.3, macOS LLVM, Windows LLVM, each in the dev and
  release profiles; wasm32-emscripten under node): a stack knocked down by a ball, a ray and a point query, a world
  saved and restored running on to the uninterrupted run's bits, a scene's hash after 200 steps pinned and the same
  on every row with 0, 1 and 4 workers; the adapted constants; header mixing; the export audit; the default template
  from an installed copy with a strict build.
- This index: consumer `tests/mwrap/jolt-world`; the installed-template check with `--deploy` (`STATIC_NOTICES`).
