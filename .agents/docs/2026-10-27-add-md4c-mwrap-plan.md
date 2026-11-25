# Add mcpplibs.mwrap.md4c (md4c-m 0.5.3)

## Form

- Source: third-party upstream [mity/md4c](https://github.com/mity/md4c), latest tag `release-0.5.3`
  (`git ls-remote --tags`), MIT. The tarball (`353c346f…059b9e`) is the one compat.md4c 0.5.3 already pins.
- Form A external mwrap module repository: [mcpplibs/md4c-m](https://github.com/mcpplibs/md4c-m), package
  `mcpplibs.mwrap.md4c`, version `0.5.3` (the upstream version, first release of the identity, no revision
  suffix), tag series `mwrap-${version}`.
- Implementation ownership: the parser `md4c.c` is compat.md4c's (its configuration and ABI are sufficient).
  Upstream ships a second library, md4c-html (`md4c-html.c`, `entity.c`), which compat.md4c does not build;
  md4c-m vendors those four files byte for byte under `upstream/md4c/src` (checksums in
  `upstream/documents.json`). No implementation is linked twice.

## Modules

- `mcpplibs.mwrap.md4c` — every typedef, enum, enumerator, struct and `md_parse` of `<md4c.h>` by
  `export using`, re-exporting the two below.
- `mcpplibs.mwrap.md4c.html` — `md_html`.
- `mcpplibs.mwrap.md4c.macros` — the 23 object-like `MD_FLAG_*` / `MD_DIALECT_*` / `MD_HTML_FLAG_*` macros as
  `inline constexpr unsigned` in `mcpplibs::mwrap::md4c::macros`. md4c has no function-like or control-flow
  macros, so there is no side header; a TU that also includes `<md4c.h>` must set the macros aside to name the
  mapped constants (tested in `tests/header_mix_test.cpp`).
- `tools/check_exports.py` parses both headers and fails when a public name or flag macro is not exported
  (negative-checked by removing one export).

## Verification

md4c-m CI (Linux GCC 16.1 and LLVM 23.1.3, macOS LLVM, Windows LLVM, all required): build, gtest suites
(parser callbacks and details, renderer, header mixing, macros), the export audit, and upstream's own
`test/run-testsuite.py` over all 11 suites through the `md2html` example (CommonMark 0.31.2 spec 652/652,
extensions, regressions and coverage: 808 examples). Windows needed binary standard streams in md2html (text
mode rewrote line endings). The templates job scaffolds the default `render` template as an installed
package (`tools/test_template.py`) and runs it.

Here, with the CI-pinned mcpp 2026.10.26.1 and `MCPP_INDEX_MIRROR=GLOBAL`:

- `bash tests/run_members.sh md4c-render` — the real release archive through the candidate index; the
  consumer parses with callbacks (heading level, table cells, task item) and renders GFM HTML:
  `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.md4c@0.5.3` — `mcpp new` from the
  indexed archive, build and run of the unmodified template: "Verified real indexed archive installation and
  unmodified template consumer".
- `mcpp xpkg parse pkgs/mwrap/md4c.lua` (form A, three platforms) and the lint job's Lua checks.

## Mirror and updates

No `mcpp-res` access in this change, so the descriptor uses the GitHub release URL as a plain string (CN
users fall back to it); a maintainer can add the GitCode mirror with identical bytes. `extensions.autoupdate`
follows the repository's own `mwrap-${version}` tags.

## Motivation

openmui's Markdown component (openmui-markdown → openmui-ui-markdown) parses with md4c through this module:
its document model is checked byte for byte against `md_html` on every upstream example.
