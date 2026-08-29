# mcpp-index

**English** | [简体中文](README.zh-CN.md)

> The default package index repository for the [`mcpp`](https://github.com/mcpp-community/mcpp) build tool.
> Browse every package online: **https://mcpplibs.github.io/mcpp-index/**

This repository hosts the C++23 packages that `mcpp` can `add` directly — both modular libraries that are ready to
`import`, and third-party C/C++ libraries built from upstream sources or headers in `compat` form. Every package maps
to one `pkgs/<initial>/<name>.lua` descriptor file.

## Usage

```bash
mcpp add ftxui@6.1.9           # add the dependency to mcpp.toml
mcpp build                     # fetch sources and build; dependencies propagate along the chain

mcpp search <keyword>          # search and refresh the index
mcpp self config --mirror CN   # switch to the CN mirror; GLOBAL upstream is the default
```

For the full package list, see the **[online index site](https://mcpplibs.github.io/mcpp-index/)**.

## Package ecosystem and contributing

Two kinds of packages live here:

- **Native mcpp module libraries**: shipped as C++23 modules and ready to `import` — `mcpplibs.*`, `nlohmann.json`,
  `imgui`, `ffmpeg`, `opencv`, plus libraries developed on top of mcpp by users and registered into the index (such as
  `tensorvia-cpu`). Their upstream usually carries its own `mcpp.toml`, so the descriptor (Form A) only declares
  metadata and a download address.
- **Third-party C/C++ libraries (`compat`)**: upstream offers no mcpp support, so the descriptor (Form B) inlines the
  build information. These come in several shapes — header-only, plain C sources, C++23 module wrapper — with optional
  components gated behind `features` and a GitCode CN mirror configured.

### Reference examples

A few descriptors worth opening first, one per common shape:

| Shape | Example | What it shows |
|------|------|------|
| Native module library (Form A) | [`mcpplibs.tinyhttps`](pkgs/t/tinyhttps.lua) · [`gzj-creator.galay`](pkgs/g/gzj-creator.galay.lua) | Upstream carries its own `mcpp.toml`; Galay also demonstrates a multi-module package with feature-scoped protocol layers |
| C-source compat | [`compat.cjson`](pkgs/c/compat.cjson.lua) | One `.c` compiled into a lib; the optional extension sits behind a `features` gate |
| Header-only | [`compat.gtl`](pkgs/c/compat.gtl.lua) | Nothing to compile — `include_dirs` and an anchor TU |
| Whole-source build + generated config | [`compat.c-ares`](pkgs/c/compat.c-ares.lua) | The config header configure would have produced is snapshotted into `generated_files` |
| Multi-component upstream flattened into one lib | [`compat.recastnavigation`](pkgs/c/compat.recastnavigation.lua) | Recast Navigation 1.6.0 — upstream is five inter-dependent CMake libraries; here the two every consumer uses are the base and the other three are `features`, all compiled into one lib. Their dependency edges have to be rebuilt by hand, which is why `debug-utils` carries `implies = { "tilecache" }`: upstream links DetourTileCache unconditionally, and without the implication a consumer asking only for debug drawing fails at link with missing `dtTileCache*` symbols. Upstream's install puts every header flat under `include/recastnavigation/` **and** keeps both that directory and its parent on the interface include path, so both `<Recast.h>` and `<recastnavigation/Recast.h>` are legal against a real install — 26 generated forwarding headers restore the second spelling for a source-tree build. `RECASTNAVIGATION_DT_POLYREF64` and `RECASTNAVIGATION_DT_VIRTUAL_QUERYFILTER` are deliberately NOT features: they change the ABI of types crossing the library boundary, and a feature's `defines` reach only the package's own TUs |
| C++23 module wrapper | [`nlohmann.json`](pkgs/n/nlohmann.json.lua) | A generated `.cppm` turns a header-only library into `import` |
| External build system | [`compat.openssl`](pkgs/c/compat.openssl.lua) | An `install()` hook drives upstream's own Perl Configure + Make |

The full catalog — every shape this index has needed, and the reasoning behind each descriptor including what it
deliberately leaves out — is in **[Descriptor examples by shape](docs/descriptor-examples.md)**.

### Adding a package

The full procedure is defined in the agent skill
[`add-mcpp-index-package`](.agents/skills/add-mcpp-index-package/SKILL.md). Hand the instruction below to an agent
(Claude Code, for example) and it will invoke that skill to write the descriptor and carry out the whole flow:

```text
Following this repo's skill `.agents/skills/add-mcpp-index-package`, add <library name / repo URL> @<version> to
mcpp-index: determine the shape; configure the CN mirror (use a plain-string upstream url when you have no mcpp-res
access); write pkgs/<initial>/<name>.lua; add a tests/examples/<lib>/ test project and register it as a workspace
member; verify locally with the same mcpp version CI pins by running `mcpp test -p <member>`; update the README and
the online index; open a PR and confirm CI is green.
```

Detailed documentation lives in [`docs/`](docs/), written for humans and agents alike:

- [Library shapes and descriptor templates](docs/package-types.md): descriptor templates and samples for each shape,
  plus how to write the minimal project.
- [Descriptor examples by shape](docs/descriptor-examples.md): the full catalog of what is already in the index, and
  why each descriptor is written the way it is.
- [The CN mirror loop](docs/cn-mirror.md): `gtc` and gitcode operations, plus the fallback when you have no
  `mcpp-res` access.
- [Repository layout, schema and CI](docs/repository-and-schema.md): field cheat-sheet, selective-run mechanics and
  local lint.
- The **authoritative** judge of a field is `mcpp xpkg parse` (exactly what CI runs: an unknown mcpp-segment field
  fails outright instead of being silently ignored); for semantics and constraints see
  [`docs/spec/`](https://github.com/mcpp-community/mcpp/tree/main/docs/spec) in the mcpp repository.

> Once a PR is open, `validate` runs lint automatically and selects the workspace members affected by the changed
> library (the whole test surface is one mcpp workspace, and the public module packages
> `imgui`/`ffmpeg`/`opencv`/`tinyhttps` are ordinary members too — the `compat` redirect is declared at the workspace
> root and inherited by members, while members that consume another namespace override it themselves, with zero shell
> driving). After the merge, `deploy-site` publishes it to the online browser.

## Related links

| Project | Description |
|------|------|
| [mcpp](https://github.com/mcpp-community/mcpp) | Modern C++23 build and package management tool |
| [xlings](https://github.com/d2learn/xlings) | The package installation engine and sandbox environment underneath mcpp |
| [xpkg V1 spec](https://github.com/d2learn/xim-pkgindex/blob/main/docs/V1/xpackage-spec.md) | Package descriptor specification |
| [mcpplibs](https://github.com/mcpplibs) | The collection of modular C++23 libraries in the mcpp ecosystem |
| [mcpp-res](https://gitcode.com/mcpp-res) | The CN mirror organization for package resources (gitcode) |

## Community

[mcpp issues](https://github.com/mcpp-community/mcpp/issues) · [d2learn forum](https://forum.d2learn.org)

## License

The package descriptors are CC0; each upstream library keeps its own license.
