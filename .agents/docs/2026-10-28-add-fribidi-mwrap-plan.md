# Add mcpplibs.mwrap.fribidi (fribidi-m 1.0.16)

## Form

- Third-party upstream [fribidi/fribidi](https://github.com/fribidi/fribidi), release 1.0.16, LGPL-2.1-or-later.
  The tarball (`1b1cde5b…a9ea05c`) is the one compat.fribidi 1.0.16 already pins.
- Form A external mwrap module repository [mcpplibs/fribidi-m](https://github.com/mcpplibs/fribidi-m), package
  `mcpplibs.mwrap.fribidi`, version 1.0.16 (first release of the identity, no revision suffix), tag series
  `mwrap-${version}`.
- Implementation ownership: the library is compat.fribidi's (a static library; its configuration and ABI are
  sufficient). The wrapper vendors no upstream code. It retains upstream's README.md, COPYING, AUTHORS and the
  Unicode Character Database notice of the data its tables come from under `upstream/`, with checksums in
  `upstream/documents.json`, and deploys them with its own LICENSE/NOTICE (`runtime.deploy`): the LGPL travels
  with every program that links FriBidi statically.

## Modules

- `mcpplibs.mwrap.fribidi`: every type, enumerator (FriBidiCharSet, the joining types), FRIBIDI_ENTRY function
  (32, deprecated included) and variable of the headers upstream installs, by `export using`, generated from the
  pinned headers as a C++ translation unit sees them (`FriBidiCharType`/`FriBidiParType` are `uint32_t` in C++).
- `fribidi_debug_status` / `fribidi_set_debug` are declared by `fribidi-common.h` outside its `extern "C"` block,
  so a C++ call through the header does not link. They are adapted under their names in `mcpplibs::mwrap::fribidi`,
  calling the library's C functions.
- `mcpplibs.mwrap.fribidi.macros`: 171 object-like macros as `inline constexpr` of the type of their C++ expansion,
  55 function-like macros as constexpr function templates whose body is the macro itself (value, type and value
  category of the macro for every argument type; assigning macros take their argument by reference).
- Stay macros, in `<mwrap/fribidi/macros.hpp>` (= `<fribidi.h>`, with `FRIBIDI_LIB_STATIC` on Windows as the
  module has it): declaration attributes, the `extern "C"` brackets, the deprecation pragmas and the X-macro
  protocol of the `*-list.h` tables. Not mapped: the 16 include guards.

`tools/check_exports.py` fails when the generated sources are stale, a declaration is neither exported nor
adapted, or a macro is neither mapped nor listed; every mapping is checked against the raw header in a
header-mixing test.

## Verification

Wrapper CI (Linux GCC 16.1 and LLVM 23.1.3, macOS LLVM, Windows LLVM, all required): build, the four test
programs, the export audit, and FriBidi's whole test suite on `examples/fribidi` (upstream's `fribidi` program
and its two conformance runners, ported to the module): the six charset tests byte for byte, BidiTest.txt
(770,241 cases) and BidiCharacterTest.txt (91,707 cases), nothing excluded. The templates job scaffolds the
default `bidi` template as an installed package and runs it.

Here, with the CI-pinned mcpp 2026.10.26.1 and `MCPP_INDEX_MIRROR=GLOBAL`:

- `bash tests/run_members.sh fribidi-bidi`: the real release archive through the candidate index; paragraph
  levels with bracket pairs, log2vis with mirroring, Arabic shaping, the macros, and the side header beside the
  import with an X-macro table: `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.fribidi@1.0.16 --deploy`: the
  unmodified template from the real archive, then a relocated self-contained bundle whose `licenses/fribidi/`
  holds the wrapper's LICENSE/NOTICE and FriBidi's COPYING, AUTHORS, README and UCD notice byte for byte.

## Mirror and updates

No `mcpp-res` access in this change, so the descriptor uses the GitHub release URL as a plain string (CN users
fall back to it); a maintainer can add the GitCode mirror with identical bytes. `extensions.autoupdate`
follows the repository's own `mwrap-${version}` tags.

## Motivation

openmui's text engine (openmui.text) computes bidi levels with FriBidi; through this module its native unit
imports the library instead of including C headers.
