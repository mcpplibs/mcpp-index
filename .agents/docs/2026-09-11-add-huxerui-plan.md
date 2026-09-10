# Adding `huxerui.huxerui` 0.3.0 to mcpp-index

> 2026-09-11 · Form A (shape D, external Form-A module repo) · PR: add HuxerUI + a CI pin that follows the engine

## 1. Shape

Source category (b) — a library developed **on** mcpp. Upstream carries its own
`mcpp.toml` (`[lib] path = "modules/huxerui.cppm"`, `[build-dependencies]` for
two code generators and a rule module, `build.mcpp` driving them), so this is
**Form A**: the descriptor declares metadata plus a download address, and every
build fact comes from the source's own manifest.

No `mcpp` segment. `mcpp emit xpkg` prints a table-form one aimed at the publish
flow; pasting it here makes the parser read the descriptor as an **inline
Form B** and refuse it:

```
error: synthesised manifest missing sources (mcpp segment must declare `sources = { ... }`)
```

Omitting it lets mcpp's default lookup find `<verdir>/*/mcpp.toml`, which the
tag archive provides at `HuxerUI-0.3.0/mcpp.toml`. `imgui.lua` carries the same
note. `mcpp xpkg parse` then reports `form A — no mcpp segment`.

## 2. Source and hash

v0.3.0's release publishes SDK **binaries** only — no source asset — so the
url is GitHub's tag archive, the same form `imgui-m` uses:

```
https://github.com/HuxerUI/HuxerUI/archive/refs/tags/v0.3.0.tar.gz
sha256 8b326d95015e92925229fdc1ababe4fdf32515e75764472591645622c1cfbb08
```

Downloaded twice, sha identical both times (9 946 045 bytes). Wrap layer is
`HuxerUI-0.3.0/`, absorbed by the default lookup.

## 3. Two fields that deliberately disagree with `emit xpkg`

Emit produces `licenses = {"Apache-2.0"}` and
`repo = "https://github.com/Sunrisepeak/HuxerUI"`. Both are wrong at the source:

* The v0.3.0 tree's `LICENSE` is the **MIT** License verbatim, and
  xim-pkgindex's entry for the same SDK has always said MIT. Upstream's
  `license = "Apache-2.0"` is a typo shared by seven manifests in that repo and
  is being corrected separately. An index must not restate a licence its own
  artifact contradicts.
* `Sunrisepeak/HuxerUI` is the author's personal remote; the canonical
  repository — the one publishing the releases this descriptor downloads — is
  `HuxerUI/HuxerUI`.

The descriptor is therefore hand-maintained and does **not** carry emit's
"AUTO-GENERATED / do not edit by hand" banner. Re-emitting over it would
reintroduce both. (`aimol.tensorvia-cpu` is the cautionary case: it still
carries that banner while having been hand-edited.)

Naming follows mcpp#278 (INV-NAME): `namespace = "huxerui"` **and** the
fully-qualified `name = "huxerui.huxerui"`. The split form — namespace plus a
bare name — parses but can never be installed.

## 4. `xpm.linux.deps`, and why it is written out by hand

Upstream declares the GTK4 stack on the **target axis**:

```toml
[target.'cfg(linux)'.xlings.workspace]
"xim:gtk4" = "4.16.13"      # …36 entries, the transitive .pc closure
```

which is the form mcpp recommends for anything the produced code links against,
and which a descriptor structurally cannot carry. `emit xpkg` says exactly that:

```
[target.'cfg(linux)'] declares tools (xim:cairo@1.18.4, …) and the descriptor
carries no edge for them: its blocks are per platform, and a selector is not a
platform.
```

A descriptor has three platform blocks; a cfg selector is not one of them.
Consumer edges therefore come from this file. Omitted, a consumer would resolve
huxerui, build it, and die at link on the GTK sonames.

The closure is transcribed at **PLATFORM level** — a per-version `deps` is
inert, the finding `compat.eui-neo` and `compat.glx-runtime` both record. All 36
entries and their pins are copied verbatim from the v0.3.0 tag's own manifest
(diffed against the working tree to confirm they match). They are what the
package's build compiles against *and* what a consumer must have, so no
`runtime = { … }` split applies.

Keeping this in step with upstream is manual until mcpp can derive consumer
dependencies from the target axis. A missing entry surfaces as
`Package <x> was not found in the pkg-config search path`, which names it.

macOS needs no payloads (`[runtime] frameworks`, supplied by the system SDK).
windows keeps `xim:wix@5.0.2` exactly as emitted — upstream declares it on the
host axis, because wix.exe runs on the build machine, and the host axis *is*
emitted.

## 5. The CI pin moves with this PR

`mcpp/huxerui-build-rules` calls `mcpp::package_name()` and
`mcpp::package_namespace()` — mcpp#587, merged 2026-09-08, first released in
**v2026.9.7.1**. The pin was 2026.9.6.3, one release short, so the host module
did not compile at all:

```
error: dependency 'huxerui': host module 'huxerui.rules' compile failed (exit 1)
rules.cppm:274:61: error: 'package_name' is not a member of 'mcpp'
```

This is the situation #361 established the pattern for — *"A package whose build
program uses a current engine API is not a defect; a CI that cannot run current
engines is."* — so `MCPP_VERSION` moves to **2026.9.10.2** (current) in the same
PR, and the comment records why.

`index.toml` `min_mcpp` does **not** move, for the reason that entry gives: the
floor is about descriptor **grammar**. Verified — `mcpp xpkg parse` accepts this
descriptor under 2026.8.27.2 (the floor), 2026.9.6.3 and 2026.9.10.2 alike. A
client on the floor keeps resolving the whole index; only building *this*
package from source needs the newer engine.

The pin move pays the cold-cache cost the workflow comment warns about
(~12 shards, still cold after 50 minutes), so any other descriptor waiting on a
newer engine should ride along.

## 6. Verification

Member `tests/examples/huxerui-module`, one `[indices] huxerui = { path = "../../.." }`.

```
$ mcpp test -p huxerui-module            # 2026.9.10.2
   Compiling huxerui.huxerui v0.3.0
   Compiling runtime (test)
     Running bin/runtime
runtime ... ok (0.02s)
 test result ok. 1 passed; 0 failed; finished in 8.21s
```

Negative check — the assertion is live, not a no-op:

```
$ sed -i 's/Color::Rgb(255, 128, 0)/Color::Rgb(1, 2, 3)/' …/runtime.cpp
$ mcpp test -p huxerui-module
runtime ... FAIL (exit 1, 0.02s)
error: test result: FAILED. 0 passed; 1 failed
```

The test deliberately opens no window. `Rect`/`Color` are header-attached
entities the module re-exports and would compile even if the library had never
been built; `FlatLightThemeSpec()`/`FlatDarkThemeSpec()` are out-of-line
definitions inside libhuxerui, so reaching them is what proves the link.

Old pin still fails, as expected:

```
$ mcpp-2026.9.6.3 test -p huxerui-module
rules.cppm:274:61: error: 'package_name' is not a member of 'mcpp'
```

## 7. A path-length trap found on the way, and left upstream

At a deep checkout the same member fails on **mcpp**, not on this descriptor:

```
build.mcpp declared an action whose arguments did not fit
payload: {"id":"hrc:builtin", … "overflow":true}
```

`mcpp::action` uses fixed buffers (`inputs_[8192]`) and `hrc:builtin` enumerates
all 44 files under `resources/` as inputs. Measured:

| unpack prefix | inputs | result |
|---|---|---|
| 149 chars (deep local checkout) | 8 131 B + ~106 B for the hrc path | **overflows 8 192** |
| 109 chars (ordinary path) | 6 371 B | builds |
| in-tree, relative | 1 531 B | builds, 21.45 s |

So it is driven by the unpack prefix, not the file count, and it overflows by
roughly 45 bytes. That is worse than a clean failure: whether a consumer builds
depends on how deep their project sits on disk. mcpp's own error names the fix —
declare the resources **directory** as one input instead of enumerating it —
and it belongs in `huxerui-build-rules`, not here. Filed as a follow-up against
HuxerUI; this index is not the place to work around it.

## 8. CN mirror

`mcpp-res/huxerui`, release `0.3.0`, asset `huxerui-0.3.0.tar.gz` — the same
bytes as GLOBAL.

```
CN http=200  size=9946045
GLOBAL sha 8b326d95015e92925229fdc1ababe4fdf32515e75764472591645622c1cfbb08
CN     sha 8b326d95015e92925229fdc1ababe4fdf32515e75764472591645622c1cfbb08
BYTE-IDENTICAL
```

## 9. Lint

`check_mirror_urls`, `check_package_name`, `check_duplicate_versions`,
`check_platform_version_parity`, `check_cross_package_refs` — all pass on the
new descriptor, and the first three pass across `pkgs/*/*.lua` to confirm the
addition does not disturb anything else.
