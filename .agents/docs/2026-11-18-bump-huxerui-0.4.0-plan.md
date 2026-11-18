# Design doc: bump `huxerui.huxerui` to 0.4.0

Date: 2026-11-18

Follow-up to `18dfa0b` (0.3.0). Upstream released v0.4.0 on 2026-11-13; this
bumps the index from 0.3.0 to 0.4.0 and makes the package eligible for the
daily updater.

## Source and version

| | |
|---|---|
| Upstream | `https://github.com/HuxerUI/HuxerUI` |
| Version | `0.4.0` (latest release, 2026-11-13) |
| Tarball | `archive/refs/tags/v0.4.0.tar.gz` |
| sha256 | `46631651105b4da2fa6651c842ce4d276334b3e06b27f93bb9c26167ec16fc38` (computed twice from two fresh downloads, stable; the pinned updater independently produced the same digest and size 10,348,921) |
| Wrap dir | `HuxerUI-0.4.0/` — Form A default lookup finds `HuxerUI-0.4.0/mcpp.toml` |
| CN mirror | **pending** — no `mcpp-res` write access on this machine; plain-string GLOBAL url fallback per SOP |
| License | MIT (unchanged; upstream's `mcpp.toml` still says Apache-2.0) |
| Auto-update | **newly declared** (`tag = "v${version}"`, GitHub archive URL) |

## What changed upstream (0.3.0 → 0.4.0)

`mcpp.toml` diff, generated after extracting both tag archives:

- `sources` gains `!src/runtime/profiling.cpp` and `defines` drops
  `HUXERUI_ENABLE_PROFILING=1`; the release turns the profiling runtime into a
  build-time option rather than a default-on define.
- `[runtime] frameworks` on macOS grows `Contacts`, `CoreBluetooth`,
  `CoreLocation`, `EventKit` and `Photos`.
- No change to the Linux target dependency table: all 36 `xim` pins are
  byte-identical to 0.3.0 (the only diff in that section is one comment line).
- `standard = "c++20"` is unchanged, so the consumer member keeps its c++20
  baseline.

Release notes describe desktop multi-window support, dockable workspaces,
paragraph layout APIs for custom editors, side-by-side installed SDK versions,
and Android static linking. None of it changes the index contract.

Form A means none of the upstream build changes are restated here: mcpp reads
the downloaded archive's own `mcpp.toml`. The descriptor only carries the
consumer-side Linux dependency closure, and that closure did not move.

## Descriptor changes (`pkgs/h/huxerui.huxerui.lua`)

- Shared `local versions` table (the updater's standard shape for one asset
  used by every platform) holds the 0.4.0 URL and sha256.
- `xpm.<linux|macosx|windows>["0.4.0"] = versions["0.4.0"]`; the 0.3.0 blocks
  keep their original `{ GLOBAL, CN }` table untouched.
- `extensions.autoupdate` declared for the first time. The package is a public
  GitHub tag release with a stable archive template and no build recipe to
  edit, so future versions need only a version block. GitHub-only on purpose:
  no mirror asset exists yet for 0.4.0, and a new version may name GitHub
  directly. The updater's `check` now answers `up-to-date` for 0.4.0.
- File-top note records the 0.4.0 manifest delta and why it does not reach the
  descriptor; the licence/repository corrections (MIT, `HuxerUI/HuxerUI`) are
  still needed at v0.4.0 and keep their rationale.

## Updater run (official flow)

Pinned `openxlings/xpkgindex-update@6c0bee2` from
`.github/workflows/xpkgindex-update.yml`:

- `inspect --package huxerui:huxerui.huxerui` → one declaration, `direct`
  empty before 0.4.0, no error.
- `check` → `update-ready`, candidate `0.4.0`, tag `v0.4.0`, upstream commit
  `4d573263e81af07e193efc2ea43fb34ab6050b33`, sha256 as above.
- `apply` → `appended`; generated the shared table plus the three references.
- `check` again → `up-to-date`, `existing_versions = ["0.3.0", "0.4.0"]`.
- `tests/autoupdate/ci.py audit --base HEAD` → 107 updateable GitHub-direct
  descriptors declared; all existing versions preserved.

### Candidate matrix: legacy fully-qualified name

The first PR CI run failed `scan` with `no candidate consumer:
huxerui:huxerui.huxerui`. `direct_member` looked for the declared leaf
`huxerui.huxerui`, but mcpp's consumer spelling is
`[dependencies.huxerui] huxerui = "0.4.0"` — the fully-qualified leaf asks for
`huxerui.huxerui.huxerui` and is refused (verified against the pinned engine).
`tests/autoupdate/ci.py` now derives the short leaf from a legacy
fully-qualified `name` for `direct_member`, `names_dependency`,
`replace_candidate` and lock verification; the no-member fallback manifest uses
the short leaf too. This is what lets the updater test huxerui at all — without
it, every future version of this package would fail the candidate scan. The
new unit test `test_legacy_fully_qualified_name_finds_the_short_consumer_key`
covers detection and the prepared consumer; the matrix now selects
`huxerui-module` for linux default/llvm, macOS and Windows.

## Test member

`tests/examples/huxerui-module/mcpp.toml`: dependency pin `0.3.0` → `0.4.0`.
No source change needed: `Rect::Contains`, `Color::Rgba32`,
`FlatLightThemeSpec` and `FlatDarkThemeSpec` all still exist in the 0.4.0
headers/sources. The test keeps its deliberate no-window shape and its
link-time assertion through the out-of-line theme specs.

## Verification

Local Linux x86_64, mcpp **2026.11.15.1** (the CI `MCPP_VERSION`, downloaded as
the release tarball), `MCPP_INDEX_MIRROR=GLOBAL`, cold member home
`target/package-validation-home`.

```sh
bash tests/run_members.sh huxerui-module
```

Result: `test result ok. 1 passed; 0 failed; finished in 301.36s
(plan 255.11s · build 46.24s · run 0.01s)`. The run resolved
`huxerui.huxerui@0.4.0` from the index, installed the unchanged GTK closure,
built the SDK (including its `hcg`/`hrc` host tools), linked the consumer and
executed the runtime assertions.

Descriptor lint (`lua` 5.4.8, the same scripts `validate.yml` runs) passes:
syntax, mirror URLs, package-name shape, reserved namespace, platform version
parity, duplicate versions, cross-package references. `mcpp xpkg parse
pkgs/h/huxerui.huxerui.lua` under the pinned engine reports Form A and the
0.3.0/0.4.0 versions.

macOS and Windows legs remain CI-authoritative. The new macOS frameworks are
read from upstream's manifest, not this descriptor; the Windows `wix` decision
is unchanged.

## Notes / risks

- The four direct Linux dependencies and their pins are unchanged, so the
  package's install closure does not move with 0.4.0.
- Future upstream releases that change the target dependency table still
  require a manual `xpm.linux.deps` update. CI's Linux candidate build would
  fail loudly (`Package <x> was not found in the pkg-config search path`), and
  the updater PR is reviewed before merge.
- No CN mirror is declared for 0.4.0; `mirror-cn-reachable` only checks
  declared CN URLs, and the 0.3.0 mirror entry is untouched.
