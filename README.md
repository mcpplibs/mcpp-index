# mcpp-index

**English** | [简体中文](README.zh-CN.md)

> The default package index for the [`mcpp`](https://github.com/mcpp-community/mcpp) build tool.
> Browse every package online: **https://mcpplibs.github.io/mcpp-index/**

The C++23 packages `mcpp` can `add` directly: modular libraries ready to `import`, and third-party C/C++ libraries
built from upstream sources in `compat` form. Each package is one `pkgs/<initial>/<name>.lua` descriptor.

> **Requires mcpp 2026.9.18.3 or later** (`min_mcpp` in [`index.toml`](index.toml)). Older engines silently misbuild
> `[c-abi]` packages such as `openkal-musl`. Upgrade: `xlings install mcpp --force`.

## Usage

```bash
mcpp add ftxui@6.1.9           # add the dependency to mcpp.toml
mcpp build                     # fetch sources and build; dependencies propagate along the chain

mcpp search <keyword>          # search and refresh the index
mcpp self config --mirror CN   # switch to the CN mirror; GLOBAL upstream is the default
```

## Package kinds

- **Native mcpp module libraries** (Form A): upstream carries its own `mcpp.toml`; the descriptor only declares
  metadata and a download address. `mcpplibs.*`, `nlohmann.json`, `imgui`, `opencv`, `tensorvia-cpu`, …
- **Third-party C/C++ libraries** (`compat`, Form B): upstream has no mcpp support, so the descriptor inlines the build.
  Header-only, C/C++ sources, or a C++23 module wrapper; optional parts sit behind `features`; a GitCode CN mirror
  serves the same bytes.

### Reference examples

One descriptor per common shape:

| Shape | Example |
|------|------|
| Native module library (Form A) | [`mcpplibs.tinyhttps`](pkgs/t/tinyhttps.lua) · [`gzj-creator.galay`](pkgs/g/gzj-creator.galay.lua) |
| C sources + `features` | [`compat.cjson`](pkgs/c/compat.cjson.lua) |
| C++ sources, several versions | [`compat.yaml-cpp`](pkgs/c/compat.yaml-cpp.lua) |
| Header-only | [`compat.gtl`](pkgs/c/compat.gtl.lua) |
| Generated config header | [`compat.c-ares`](pkgs/c/compat.c-ares.lua) |
| C++23 module wrapper | [`nlohmann.json`](pkgs/n/nlohmann.json.lua) |
| C++23 module shipped by upstream | [`khronos.vulkan-hpp`](pkgs/k/khronos.vulkan-hpp.lua) |
| External build system (`install()`) | [`compat.openssl`](pkgs/c/compat.openssl.lua) |

Every other shape, and why each descriptor is written the way it is, is in
**[Descriptor examples by shape](docs/descriptor-examples.md)**.

### Adding a package

The procedure is the agent skill [`add-mcpp-index-package`](.agents/skills/add-mcpp-index-package/SKILL.md). Hand an
agent (Claude Code, for example) this instruction:

```text
Following this repo's skill `.agents/skills/add-mcpp-index-package`, add <library name / repo URL> @<version> to
mcpp-index: determine the shape; configure the CN mirror (use a plain-string upstream url when you have no mcpp-res
access); write pkgs/<initial>/<name>.lua; add a tests/examples/<lib>/ test project and register it as a workspace
member; verify locally with the same mcpp version CI pins by running `mcpp test -p <member>`; update the README and
the online index; open a PR and confirm CI is green.
```

A PR runs lint and tests only the workspace members that depend on the changed descriptors; after the merge,
`deploy-site` publishes the site.

## Documentation

- [Library shapes and descriptor templates](docs/package-types.md)
- [Descriptor examples by shape](docs/descriptor-examples.md)
- [The CN mirror loop](docs/cn-mirror.md)
- [openkal compatibility](docs/openkal-compat.md): the `openkal-ecosystem` / `openkal-compat` labels on the site
- [Repository layout, schema and CI](docs/repository-and-schema.md)
- The authoritative check of a field is `mcpp xpkg parse`, which CI runs; semantics are in mcpp's
  [`docs/spec/`](https://github.com/mcpp-community/mcpp/tree/main/docs/spec).

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
