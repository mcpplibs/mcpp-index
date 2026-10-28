# Add mcpplibs.mwrap.box2d (box2d-m 3.2.0)

## Form

- Third-party upstream [erincatto/box2d](https://github.com/erincatto/box2d), release v3.2.0 (2026-10-19), MIT.
  The tag archive (`ffec747b…180d`) is the one compat.box2d 3.2.0 pins (the parent change).
- Form A external mwrap module repository [mcpplibs/box2d-m](https://github.com/mcpplibs/box2d-m), package
  `mcpplibs.mwrap.box2d`, version 3.2.0 (first release of the identity, no revision suffix), tag series
  `mwrap-${version}` on the merged main commit (`361aa31`); release asset `box2d-m-3.2.0.tar.gz` (`a7b448ea…7572`),
  CN mirror `gitcode.com/mcpp-res/mwrap-box2d` with identical bytes.
- Implementation ownership: the library is compat.box2d's (a static library of every src/*.c, single precision,
  `-ffp-contract=off`, upstream's default SIMD selection; its configuration and ABI are sufficient). The wrapper vendors
  no upstream code. It retains upstream's README.md and LICENSE under `upstream/box2d/`, with checksums in
  `upstream/documents.json`, and deploys them with its own LICENSE/NOTICE (`runtime.deploy`).

## Modules

- `mcpplibs.mwrap.box2d`: by `export using`, generated from the pinned installed headers (`BOX2D_API_FILES`): 110
  types, 3 opaque structs, 176 enumerators, 506 `B2_API` functions (`b2InternalAssert` under the header's own
  `!defined(NDEBUG) || defined(B2_ENABLE_ASSERT)`), 91 inline functions (`B2_INLINE` / `B2_FORCE_INLINE` /
  `B2_ID_INLINE` are `inline` in C++: external linkage, exportable), 8 C++ vector operators and
  `b2_lengthUnitsPerMeter`. The 13 `static const` objects (internal linkage: `b2_nullBodyId`, `b2Rot_identity`,
  `b2Vec2_zero` …) are `inline constexpr` of the same type and initializer in `mcpplibs::mwrap::box2d`.
- `mcpplibs.mwrap.box2d.macros`: 20 object-like macros as `inline constexpr` of the type of their expansion; the 5 that
  read `b2_lengthUnitsPerMeter` (`B2_HUGE`, `B2_LINEAR_SLOP`, `B2_SPECULATIVE_DISTANCE`, `B2_CONTACT_RECYCLE_DISTANCE`,
  `B2_MAX_AABB_MARGIN`) as functions of no arguments, since `b2SetLengthUnitsPerMeter` changes them at run time; and
  `B2_IS_NULL`, `B2_IS_NON_NULL`, `B2_ID_EQUALS` as constexpr function templates whose body is the macro.
- Stay macros, in `<mwrap/box2d/macros.hpp>` (= `<box2d/box2d.h>`): `BOX2D_EXPORT`, `B2_API`, `B2_INLINE`,
  `B2_FORCE_INLINE`, `B2_ID_INLINE`, `B2_ALIGN_AS`, `B2_LITERAL`, `B2_ZERO_INIT`, `B2_NULL_ID`, `B2_ASSERT`,
  `B2_VALIDATE`, `B2_BREAKPOINT`.

`tools/check_exports.py` fails when the generated sources are stale, a declaration is not exported, a static constant
not adapted, or a macro neither mapped nor listed; every mapping is checked against the raw header in a header-mixing
test.

## Determinism

Wrapper CI (Linux x86_64 GCC 16.1 and LLVM 23.1.3, Linux arm64 GCC 16.1 and LLVM 23.1.3, macOS LLVM, Windows LLVM,
and wasm32-emscripten under node; all required) runs, in the dev and the release profile, upstream's falling-hinges
scene and a 20-row pyramid struck by a ball (600 steps, sleep off) under 1, 2, 4 and 8 workers of the built-in
scheduler, 4 workers of a user task system and the SSE2 fallback. Every row gives the same values: falling hinges
asleep at step 299, transform hash `0x465F3DF4` (upstream's pin), event hash `0xD019CCFF`, state hash
`0x8BD019D8675ACE67`; pyramid transform hash `0x790D7C28`, event hash `0xE8B80415`, state hash `0xE4E1D89FFCE4C43E`.
Built with `-mfma -ffp-contract=fast` instead, an optimized x86_64 build gives 256 / `0xD513C6E1` and `0x1F3DD87B`:
the flag is what the hashes hold.

## Verification

Here, with the CI-pinned mcpp 2026.10.26.1:

- `bash tests/run_members.sh box2d-physics`: the real release archive through the candidate index; a box that falls,
  rests and sleeps, a ray cast, the macros and constants, and the struck pyramid's hash `0x790D7C28` in a consumer
  compiled without any floating-point flag; and the side header beside the import: `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.box2d@3.2.0 --deploy`: the unmodified
  default `physics` template from the real archive, then a relocated self-contained bundle whose `licenses/box2d/`
  holds the wrapper's LICENSE/NOTICE and Box2D's README and LICENSE byte for byte.

## Motivation

openmui's game physics (mgame.physics) needs a deterministic 2D engine whose results are the same on every row of
its CI, the Web included, with pinned hashes; Box2D v3 is that engine, and this module is how openmui imports it.
