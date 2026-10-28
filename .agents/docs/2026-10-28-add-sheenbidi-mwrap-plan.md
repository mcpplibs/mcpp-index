# Add mcpplibs.mwrap.sheenbidi (sheenbidi-m 3.0.0)

## Form

- Third-party upstream [Tehreer/SheenBidi](https://github.com/Tehreer/SheenBidi), release v3.0.0 (Unicode 17.0.0),
  Apache-2.0. The tag archive (`86c56014…f786`) is the one compat.sheenbidi 3.0.0 pins (the parent change).
- Form A external mwrap module repository [mcpplibs/sheenbidi-m](https://github.com/mcpplibs/sheenbidi-m), package
  `mcpplibs.mwrap.sheenbidi`, version 3.0.0 (first release of the identity, no revision suffix), tag series
  `mwrap-${version}`; release asset `sheenbidi-m-3.0.0.tar.gz` (`76a0b0fe…3c41`), CN mirror
  `gitcode.com/mcpp-res/mwrap-sheenbidi` with identical bytes.
- Implementation ownership: the library is compat.sheenbidi's (a static library from upstream's unity source; its
  configuration and ABI are sufficient). The wrapper vendors no upstream code. It retains upstream's README.md and
  LICENSE under `upstream/sheenbidi/` and the Unicode License v3 under `upstream/unicode/`, with checksums in
  `upstream/documents.json`, and deploys them with its own LICENSE/NOTICE (`runtime.deploy`).

## Modules

- `mcpplibs.mwrap.sheenbidi`: every type (32), struct tag (11) and `SB_PUBLIC` function (51) of the headers upstream
  installs, by `export using`, generated from the pinned headers. The experimental text API is compiled out
  (compat.sheenbidi does not define `SB_CONFIG_EXPERIMENTAL_TEXT_API`, as upstream's default builds do not).
- `mcpplibs.mwrap.sheenbidi.macros`: 12 object-like macros as `inline constexpr` of the type of their expansion, 16
  function-like macros as constexpr function templates whose body is the macro, and the 236 enumerators of the
  headers' unnamed enums (TU-local, so not exportable as they are) as constants of the typedef the header gives their
  values (`SBBidiType`, `SBGeneralCategory`, `SBScript`, `SBStringEncoding`, `SBBoolean`).
- Stay macros, in `<mwrap/sheenbidi/macros.hpp>` (= `<SheenBidi/SheenBidi.h>`): `SB_PUBLIC`, `SB_DEPRECATED`,
  `SB_EXTERN_C_BEGIN` / `SB_EXTERN_C_END`. Not mapped: the 22 include guards.

`tools/check_exports.py` fails when the generated sources are stale, a declaration is not exported, an enumerator is
not mapped, or a macro is neither mapped nor listed; every mapping is checked against the raw header in a
header-mixing test.

## Verification

Wrapper CI (Linux x86_64 GCC 16.1 and LLVM 23.1.3, Linux arm64 GCC 16.1, macOS LLVM, Windows LLVM, all required):
build, the four test programs, the export audit, and Unicode 17.0.0's conformance tests on `examples/sheenbidi`
(programs written against the module), the files taken from the release and checked byte for byte against
unicode.org's: BidiTest.txt (770,241 cases) and BidiCharacterTest.txt (91,707 cases, with the mirrored characters
against BidiMirroring.txt), 0 errors, nothing excluded. The templates job scaffolds the default `bidi` template as an
installed package and runs it. Until compat.sheenbidi is on this index's main, the wrapper's CI resolves the compat
namespace from the parent change's branch (`tools/candidate_index.py`, a no-op once published).

Here, with the CI-pinned mcpp 2026.10.26.1:

- `bash tests/run_members.sh sheenbidi-bidi`: the real release archive through the candidate index; UAX #9's N0
  bracket-pair example, a line's visual order with mirrored brackets, the mirror and script locators, Unicode 17.0's
  Sidetic, the macros, and the side header beside the import: `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.sheenbidi@3.0.0 --deploy`: the unmodified
  template from the real archive, then a relocated self-contained bundle whose `licenses/sheenbidi/` holds the
  wrapper's LICENSE/NOTICE, SheenBidi's README and LICENSE and the Unicode license byte for byte.

## Motivation

openmui's text engine computes bidi levels; SheenBidi through this module replaces FriBidi there, whose
LGPL-2.1 does not fit a statically linked, permissively licensed framework.
