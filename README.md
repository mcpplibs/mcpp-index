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

### Reference examples (`.lua` descriptors)

| Shape | Examples |
|------|------|
| Native module library (Form A) | [`mcpplibs.xpkg`](pkgs/x/xpkg.lua) · [`mcpplibs.tinyhttps`](pkgs/t/tinyhttps.lua) · [`tensorvia-cpu`](pkgs/t/tensorvia-cpu.lua) · [`ffmpeg`](pkgs/f/ffmpeg.lua) (module layer; sources compiled directly through `compat.ffmpeg`) · [`opencv`](pkgs/o/opencv.lua) (single repository: the module layer and the full OpenCV 5 source build both live in the package, and only this descriptor stays on the index side) |
| C-source compat (with `features`) | [`compat.cjson`](pkgs/c/compat.cjson.lua) · [`compat.zlib`](pkgs/c/compat.zlib.lua) |
| header-only (with `features`) | [`compat.eigen`](pkgs/c/compat.eigen.lua) |
| Runtime loader compat (pure sources, sidestepping upstream codegen/asm) | [`compat.vulkan`](pkgs/c/compat.vulkan.lua) (the Khronos loader: `loader/generated/` is checked in, and the assembly path degrades to plain C through `UNKNOWN_FUNCTIONS_SUPPORTED`, so no CMake/Python/assembler is needed; windows deferred) · [`compat.vulkan-headers`](pkgs/c/compat.vulkan-headers.lua) |
| Whole-source direct build + generated config (only where a platform lacks one) | [`compat.curl`](pkgs/c/compat.curl.lua) (win32 uses upstream's checked-in config, unix generates one) · [`compat.sdl2`](pkgs/c/compat.sdl2.lua) (win/mac use upstream's checked-in config; linux generates one and enables X11 by hand) |
| Header package filling a gap in the index | [`compat.glx-headers`](pkgs/c/compat.glx-headers.lua) (libglvnd's `GL/glx.h`, absent from the Khronos registry and required by SDL's X11 backend) |
| C++ application framework compat (dependencies reuse packages already in the index) | [`compat.eui-neo`](pkgs/e/compat.eui-neo.lua) (upstream's `3rd/` ships 8 vendored dependencies; none of them is compiled here — all are redirected to the same-version `compat.*` packages in this index) |
| Mutually exclusive backends (one of several inside one package) | [`compat.eui-neo`](pkgs/e/compat.eui-neo.lua): `vulkan` / `sdl2` each **replace** the default OpenGL / GLFW, and the default backend is expressed by *naming no feature at all* — there is no `opengl`/`glfw` feature. A `default` feature cannot express exclusivity: its own `defines`/`sources`/`deps` have no effect whatsoever, while its `implies` always applies and cannot be overridden by a named feature (which is, conversely, exactly the solution for the "always-on interface define" row below). The workable answer is to read the `-DMCPP_FEATURE_<NAME>` mcpp passes anyway and decide up front in a force-included header. Note also that `cflags` only reaches C TUs — C++ needs `cxxflags`, so a backend define written only into `cflags` never reaches any `.cpp` |
| Host runtime adaptation (drivers are not vendored) | [`compat.glx-runtime`](pkgs/c/compat.glx-runtime.lua) · [`compat.vulkan-runtime`](pkgs/c/compat.vulkan-runtime.lua) (mcpp binaries run against a bundled glibc, so a bare-soname `dlopen` never reaches the host drivers; a symlink farm plus `runtime.library_dirs` bridges that. Note the farm holds only versioned sonames — `library_dirs` also joins the link line) |
| Always-on interface define | `CURL_STATICLIB` in [`compat.curl`](pkgs/c/compat.curl.lua): `cflags` is always on but package-private, while a feature's `defines` reaches consumers yet has to be named — `default = { implies = … }` applies unconditionally and happens to give both |
| Multiple majors in one package (shape switches with the version) | [`compat.catch2`](pkgs/c/compat.catch2.lua) (3.x compiles `src/catch2/` into a static library; 2.x goes header-only through `single_include/`) |
| External build system (`install()` builds from source) | [`compat.openblas`](pkgs/c/compat.openblas.lua) (Make) · [`compat.openssl`](pkgs/c/compat.openssl.lua) (Perl Configure + Make, static libssl/libcrypto) |
| Whole-source direct build (config snapshot + source list, no external build system) | [`compat.ffmpeg`](pkgs/c/compat.ffmpeg.lua) (2281 TUs including NASM assembly, declared through 28 directory globs) |
| C++23 module wrapper | [`nlohmann.json`](pkgs/n/nlohmann.json.lua) · [`marzer.tomlplusplus`](pkgs/m/marzer.tomlplusplus.lua) · [`neargye.magic_enum`](pkgs/n/neargye.magic_enum.lua) · [`boost-ext.ut`](pkgs/b/boost-ext.ut.lua) (upstream's own `include/boost/ut.cppm` reproduced verbatim but for one `__argc`/`__argv` shim that Clang-on-MSVC needs; namespace `boost-ext` since it is NOT an official Boost library) |

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
