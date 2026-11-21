# Build plugins: `<owner>.mplugin.<name>`

A **build plugin** is a package whose modules a project's `build.mcpp` imports
(`host-module`): code generators, tool wrappers, rule sets. This page is the
naming and layout rule for them; the design record is
`.agents/docs/2026-11-21-mcpp-build-plugin-naming-plan.md`.

[简体中文](zh/build-plugins.md)

## One name, three spellings

A build plugin's id is `<owner>.mplugin.<name>`. Its module and its C++
namespace are that id:

| Spelling | Form | Example |
|---|---|---|
| package (namespace + name) | `<owner>.mplugin` + `<name>` | `mcpplibs.mplugin.slint` |
| module | the id; sub-modules `<id>.<sub>` | `mcpplibs.mplugin.slint` |
| C++ namespace | the id with `::` | `mcpplibs::mplugin::slint` |

```cpp
// build.mcpp
import mcpp;
import mcpplibs.mplugin.slint;
int main() {
    mcpplibs::mplugin::slint::options o;
    o.sources = {"ui/app.slint"};
    return mcpplibs::mplugin::slint::compile(o) ? 0 : 1;
}
```

`mplugin` is the kind segment, as `mwrap` is for wrappers
(`mcpplibs.mwrap.slint` is the wrapper, `mcpplibs.mplugin.slint` its build
plugin). Because the namespace is `<owner>::mplugin::<name>` and not
`<owner>::mcpp::<name>`, code inside a plugin writes the engine as `mcpp::…`
and nothing shadows it.

Rules:

1. `<owner>` and `<name>` are lower-case identifiers, `[a-z][a-z0-9_]*`: words
   are joined with `_`, never `-` (a module name needs an identifier;
   `mcpplibs.mwrap.godot_cpp` is the same rule).
2. `<owner>` is who maintains the package. `mcpplibs` is for packages the
   mcpplibs organization maintains; anyone else uses their own name.
3. `<owner>` is not `mcpp`, not one of the mcpp project's reserved names
   (`core`, `plugins`, `deps`, `rules`, `dist`, `tools`, `platforms`) and not a
   kind segment (`mwrap`, `mplugin`). A new official package name joins the
   reserved names; the check that no owner already has it is part of adding it.
4. The main interface module is exactly the id; every other module of the
   package starts with `<id>.`.
5. A package whose first segment is `mcpp` is maintained by the mcpp project
   and is not of this form (`mcpp.plugins`, `mcpp.platforms`).
6. For a rule tied to one library, `<name>` is the library (`slint`, `grpc`,
   `protobuf`), with no `gen` or `-bind` suffix; several rules for one library
   are functions of one package. A general tool takes the tool's name
   (`clangtidy`).

## Where a rule lives

| Kind | Lives in | A project writes |
|---|---|---|
| tied to one library | the `rules/` sub-package of that library's `-m` repository; the descriptor says `mcpp = "*/rules/mcpp.toml"`; the wrapper's root manifest has `<id> = { path = "rules", host-module = true, reexport = true }` | only the wrapper |
| a general tool | its own repository | `[build-dependencies] <id> = { version = "…", host-module = true }` |
| engine-level, across ecosystems | the mcpp project's `mcpp.plugins` | a feature of `mcpp.plugins` |

A rule package's own dependencies are in its `[dependencies]` (mcpp
2026.10.11.1 and later). A feature that claims a file extension does not pass
through `reexport`, so a rule tied to a library takes its inputs as `options`
fields (`options::sources` of `mcpplibs.mplugin.slint`).

## Index layout

- The descriptor is `pkgs/mcpp/<full id>.lua`, one flat directory: the
  official `pkgs/mcpp/mcpp.plugins.lua`, the plugins
  `pkgs/mcpp/mcpplibs.mplugin.slint.lua`. The directory is the packages mcpp
  itself loads; the identity is what the descriptor declares (`namespace =
  "<owner>.mplugin"`, `name = "<name>"`), as for `pkgs/mwrap/`. The directory
  does not say what a package is: `mcpp.platforms` is platform data, not a
  plugin.
- A descriptor whose namespace is `<owner>.mplugin` is in `pkgs/mcpp/`; a file
  in `pkgs/mcpp/` has namespace `mcpp` or `<owner>.mplugin` (lint
  `tests/check_mplugin_layout.lua`).
- **A build plugin and its library are tested apart.** A plugin's member
  checks what `build.mcpp` can do with it (what the rule produces from a small
  input, that a generated module compiles, that an edited input regenerates);
  how the library behaves is the wrapper's member and installed-template
  check. A plugin tied to a library is tested at first through the wrapper's
  member (`tests/mwrap/…`); a plugin of its own gets `tests/mcpp/<owner>-<name>/`.

## Versions

Each package has its own line: the first release is the upstream version it is
built for, a revision appends `.N`, and a tag never moves. A rule tied to a
library is released with the wrapper: its descriptor row points at the
wrapper's tag archive (same bytes, same sha256, GLOBAL and CN), and the rule's
own `rules/mcpp.toml` version equals that row; it need not equal the wrapper's
revision (`mcpplibs.mplugin.slint@1.19.0` is in the archive of
`mcpplibs.mwrap.slint@1.19.0.3`). Such a descriptor has no `autoupdate`: its
rows are added with the wrapper's.

## Older packages

Build rules published before this page keep working: `mcpplibs.slintgen`,
`mcpplibs.grpcgen`, `mcpplibs.protogen`, `mcpplibs.clangtidy`,
`mcpplibs.openkal-bind` follow the earlier rule (module
`mcpp.<namespace>.<name>`, SPEC-007 §9) and are not wrong. Their descriptors
and archives stay; a published row never changes.

- A package moves to the new form when it next needs a new version: the new id
  is published in `pkgs/mcpp/`, the old descriptor is frozen (no `autoupdate`,
  `FROZEN: superseded by <id>` in its description) and gets no more versions.
  There is no forwarding module.
- The id is the identity, so the old id cannot take the new module name: a
  project that wrote `x = "1"` would be moved to a new module name on update.
- A project that wrote the old id keeps its versions and moves by changing the
  dependency name.

| Old id | New id | Moved |
|---|---|---|
| `mcpplibs.slintgen` | `mcpplibs.mplugin.slint` | 1.19.0 |
| `mcpplibs.grpcgen` | `mcpplibs.mplugin.grpc` | with grpc-m's next release |
| `mcpplibs.protogen` | `mcpplibs.mplugin.protobuf` | with protobuf-m's next release |
| `mcpplibs.clangtidy` | `mcpplibs.mplugin.clangtidy` | with its next release |
| `mcpplibs.openkal-bind` | `mcpplibs.mplugin.openkal_bind` | with openkal's next release |

`mcpplibs.rules-cuda` is a stub that points at `mcpp.rules.cuda`; it stays as
it is.

## Checks

| Check | Where |
|---|---|
| namespace is not a reserved second segment of `mcpp.`; an owner is not `mcpp`, a reserved name or a kind segment | `tests/check_reserved_namespace.lua` |
| layout: `<owner>.mplugin` ↔ `pkgs/mcpp/`; owner and name are identifiers | `tests/check_mplugin_layout.lua` |
| a member's build prints no engine warning about a reserved module name | `tests/run_members.sh` |
| the module is the package id | the rule's own repository CI (the index cannot read the archive's sources) |

A build plugin runs code on the machine that builds: it is reviewed as a
package that executes code. `mplugin` does not mean audited; who an owner is,
and names that imitate `mcpplibs`, are for review.
