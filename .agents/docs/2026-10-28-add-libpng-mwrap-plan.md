# Add mcpplibs.mwrap.libpng (libpng-m 1.6.43)

## Form

- Third-party upstream [pnggroup/libpng](https://github.com/pnggroup/libpng), tag `v1.6.43`, PNG Reference Library
  License version 2. The tarball (`fecc95b4…f1a03a`) is the one compat.libpng 1.6.43 already pins.
- Form A external mwrap module repository: [mcpplibs/libpng-m](https://github.com/mcpplibs/libpng-m), package
  `mcpplibs.mwrap.libpng`. The version is the upstream one (first release of the identity, no revision suffix);
  tag series `mwrap-${version}`.
- Implementation ownership: the library is compat.libpng's (over compat.zlib 1.3.2; its configuration is upstream's
  `scripts/pnglibconf.h.prebuilt`, which is sufficient). The wrapper vendors no upstream code. It retains
  upstream's README and license under `upstream/libpng/`, with checksums in `upstream/documents.json`. No
  implementation is linked twice.

## Modules

- `mcpplibs.mwrap.libpng` exports, by `export using`, every type (104), struct tag (12) and function (246) that
  png.h declares in this configuration. `tools/gen_exports.py` generates the list from the pinned headers: it
  evaluates png.h's `#if` conditionals with the build's pnglibconf.h and normalises the `PNG_EXPORT*`,
  `PNG_CALLBACK` and `PNG_FUNCTION` declaration macros.
- `mcpplibs.mwrap.libpng.macros`, in `mcpplibs::mwrap::libpng::macros`, holds:
  - the constants, as `inline constexpr` of each macro's type;
  - the 177 pnglibconf.h options as `constexpr bool` (generated partition `:options`);
  - the `PNG_IMAGE_*` size computations, the Adam7 `PNG_PASS_*` helpers, `PNG_get_*` and `png_composite*`, as
    constexpr functions with the macros' results and types;
  - `png_check_sig`, `png_image_write_get_memory_size`, `png_jmpbuf` (it returns the `jmp_buf&` for the caller's
    `setjmp`) and `png_libpng_ver`.
- `<mwrap/libpng/macros.hpp>` (= png.h) remains for `#if` tests of the options and for macro-form code.
- Not exported: `png_err` and `png_set_strip_error_numbers`, which this configuration does not declare, and
  `png_get_io_chunk_name`, which is `PNG_REMOVED`.

`tools/check_exports.py` fails when a declaration is not exported, or when one of the 492 macros the headers define
here is neither mapped, nor the name of an exported function (`png_get_uint_32` …), nor excluded with a reason. It
was negative-checked by removing an export and a mapping.

## Verification

Wrapper CI runs on four rows, all required: Linux GCC 16.1, Linux LLVM 23.1.3, macOS LLVM and Windows LLVM. It
covers:

- the build;
- the gtest suites: the API through the module, the constants at compile time, and the header mixed with the import,
  with every function-like macro compared with its mapping;
- the export audit;
- conformance: libpng's `pngtest.c`, ported to C++ against the module (`examples/pngtest`). It runs on upstream's
  `tests/pngtest-all` cases, on `-m` over all of `contrib/pngsuite` and `contrib/testpngs`, and on `--strict` per
  pngsuite image: 96 cases and 167 images. Each case's exit status and output must equal those of upstream's
  `pngtest.c`, built unchanged from the same tarball against png.h. Every crasher is an expected failure, and the
  bas*.png zero-sample counts match `contrib/pngsuite/README`.

The templates job scaffolds the default `image` template as an installed package, builds it with `--strict` and runs
it.

Local checks, with the CI-pinned mcpp 2026.10.26.1 and `MCPP_INDEX_MIRROR=GLOBAL`:

- `bash tests/run_members.sh libpng-image` installs the real release archive through the candidate index. The
  consumer runs a simplified-API round trip and a low-level read with transforms. It also reads a truncated file:
  png_error longjmps to the caller's setjmp on `png_jmpbuf`. Result: `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.libpng@1.6.43` reports "Verified real
  indexed archive installation and unmodified template consumer".

## Mirror and updates

This change has no `mcpp-res` access. The descriptor therefore uses the GitHub release URL as a plain string, and CN
users fall back to it. A maintainer can add the GitCode mirror with identical bytes. `extensions.autoupdate` follows
the repository's own `mwrap-${version}` tags.

## Motivation

openmui.image encodes and decodes PNG with libpng's simplified API. Through this module its implementation unit
imports `mcpplibs.mwrap.libpng` instead of including png.h.
