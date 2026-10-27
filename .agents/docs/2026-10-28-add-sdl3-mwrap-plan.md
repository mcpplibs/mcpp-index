# Add mcpplibs.mwrap.sdl3 (sdl3-m 3.4.18)

## Form

- Third-party upstream [libsdl-org/SDL](https://github.com/libsdl-org/SDL), release `release-3.4.18`, zlib. The
  tarball (`c4b08b95…92665c90`) is the one compat.sdl3 3.4.18 already pins.
- Form A external mwrap module repository: [mcpplibs/sdl3-m](https://github.com/mcpplibs/sdl3-m), package
  `mcpplibs.mwrap.sdl3`. The version is upstream's (first release of the identity, no revision suffix); tag
  series `mwrap-${version}`.
- Implementation ownership: the library is compat.sdl3's (its configuration and ABI are sufficient). The
  wrapper vendors no upstream code; it retains SDL's README and license under `upstream/sdl3/` with checksums in
  `upstream/documents.json`. No implementation is linked twice.

## Modules

- `mcpplibs.mwrap.sdl3`: every function, type, struct and enumerator of `<SDL3/SDL.h>` and its closure,
  `SDL_vulkan.h`, `SDL_main.h`'s functions (included with `SDL_MAIN_HANDLED`: no `main` redefinition) and
  `SDL_revision.h`, by `export using`, each under the `#if` its header declares it under (Linux 2773, macOS 2771,
  Windows 2779 declarations). Generated from the pinned headers by `tools/gen_exports.py`.
- The 16 `SDL_FORCE_INLINE` functions (`SDL_PointInRect`, `SDL_Swap32`, `SDL_size_mul_check_overflow` …) have
  internal linkage; they are adapted under their names and signatures in `mcpplibs::mwrap::sdl3`, each calling
  upstream's.
- `mcpplibs.mwrap.sdl3.macros`: 1060 object-like macros as `inline constexpr` constants of the macro's own type
  (strings as `const char[]`: `SDL_HINT_*`, `SDL_PROP_*`), 87 function-like macros as functions whose body is
  the macro expanded in the module (`SDL_BUTTON_MASK`, `SDL_FOURCC`, `SDL_BITSPERPIXEL`, `SDL_CreateThread` …);
  the bit-extracting ones are templates, as upstream applies them to integers and enums alike.
- Stay macros, in `<mwrap/sdl3/macros.hpp>` (= `<SDL3/SDL.h>`): the assertions, `SDL_stack_alloc`,
  stringification and pasting, attributes, the `SDL_PLATFORM_*` tests, SDL 2's names; every macro is listed with
  its reason in `tools/policy.py`. Not wrapped (include directly): the Khronos GL/EGL headers SDL ships,
  `SDL_intrin.h`, the SDL_test headers.

## Verification

Wrapper CI (Linux GCC 16.1 and LLVM 23.1.3, macOS LLVM, Windows LLVM, all required): build; tests through the
module (init, properties, hints, events, timers, threads, IO, filesystem, pixels, surfaces, the software
renderer and audio on the dummy drivers, a GPU device on lavapipe / Metal / Direct3D 12, required), the macro
mappings, the header mixed with the import, `SDL_main.h` and the app callbacks; the export audit, which on each
row preprocesses the headers with the module's own compile command and requires every declaration exported,
every inline function adapted and every macro mapped or listed; and SDL's own `testautomation` (26 suites, 377
tests) compiled as C++ against the module (its SDL includes replaced by the import and the side macros) and run
as upstream's CTest runs it, with and without SIMD: 0 failures on every row. The templates job scaffolds the
default `info` template (headless) as an installed package and runs it, and builds the `window` template.

Here, with the CI-pinned mcpp 2026.10.26.1:

- `bash tests/run_members.sh sdl3-headless`: the real release archive through the candidate index; events,
  properties, the software renderer read back, an audio conversion, the mapped macros: `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.sdl3@3.4.18`: the installed archive
  and the unmodified default template.

## Mirror and updates

No `mcpp-res` access in this change, so the descriptor uses the GitHub release URL as a plain string (CN users
fall back to it); a maintainer can add the GitCode mirror with identical bytes. `extensions.autoupdate` follows
the repository's own `mwrap-${version}` tags.

## Motivation

openmui's desktop host (openmui.host.sdl3) and SDL_GPU backend (openmui.rhi.sdl) use SDL3. Through this module
their native units import SDL (`import mcpplibs.mwrap.sdl3;` and
`using namespace mcpplibs::mwrap::sdl3::macros;`) instead of including its headers.
