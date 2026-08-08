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
| Native module library (Form A) | [`mcpplibs.xpkg`](pkgs/x/xpkg.lua) · [`mcpplibs.tinyhttps`](pkgs/t/tinyhttps.lua) · [`tensorvia-cpu`](pkgs/t/tensorvia-cpu.lua) · [`ffmpeg`](pkgs/f/ffmpeg.lua) (module layer; sources compiled directly through `compat.ffmpeg`) · [`opencv`](pkgs/o/opencv.lua) (single repository: the module layer and the full OpenCV 5 source build both live in the package, and only this descriptor stays on the index side) · [`mcpplibs.grpc`](pkgs/g/grpc.lua) (gRPC 1.83.0 — the one library here that CANNOT be a compat descriptor: upstream publishes no self-contained source artifact, its tag archive carrying abseil/protobuf/re2/boringssl/zlib as empty submodule placeholders, so [grpc-m](https://github.com/mcpplibs/grpc-m)'s release tarball IS that artifact. It vendors only gRPC's own source and takes the five dependencies from this index, so a consumer that also uses protobuf links one copy rather than two) |
| C-source compat (with `features`) | [`compat.cjson`](pkgs/c/compat.cjson.lua) · [`compat.zlib`](pkgs/c/compat.zlib.lua) · [`compat.hiredis`](pkgs/c/compat.hiredis.lua) (the classic 1.2.0 — a 7-TU C build whose flat tarball headers get `hiredis/`-prefixed wrapper headers via `generated_files`, so consumers write `#include <hiredis/hiredis.h>` exactly like upstream's install layout) · [`compat.sqlite3`](pkgs/c/compat.sqlite3.lua) (plain C-source, no features: the single `sqlite3.c` amalgamation; 3.45.3, the final maintenance release of the most widely deployed 3.45.x line) |
| C++-source compat, one depending on the other | [`compat.abseil`](pkgs/c/compat.abseil.lua) (151 TUs; a wildcard over `absl/**` trimmed by upstream's test/benchmark naming conventions) · [`compat.protobuf`](pkgs/c/compat.protobuf.lua) (the libprotobuf runtime, 79 TUs transcribed from upstream's own `src/file_lists.cmake`; declares `compat.abseil` as a dependency because protobuf's public headers include `absl/…`, and its `gzip` feature defines `HAVE_ZLIB` and pulls `compat.zlib`, while `upb` adds protobuf's 64-TU C runtime out of the same tarball. It also exposes **`protoc`** as a `kind = "bin"` target, so a consumer writing `tools = ["protoc"]` gets the compiler built for its own machine out of the same package it links — making a generator/runtime version mismatch inexpressible) · [`compat.re2`](pkgs/c/compat.re2.lua) (22 TUs, upstream's own `RE2_SOURCES`) · [`compat.redis-plus-plus`](pkgs/c/compat.redis-plus-plus.lua) (redis++ 1.3.13 — the sync client, 17 TUs + `patterns/redlock.cpp`, depends on `compat.hiredis`; the one header CMake would generate, `hiredis_features.h`, is snapshotted via `generated_files`, and the async/TLS TUs are left out so the base build stays a two-package pair. Two versions, one on each side of the source-structure watershed, share this ONE source list: 1.3.13 (modern 17-TU layout) and 1.3.3 (pre-`redis_uri.cpp`/`redlock` 15-TU layout) — the union works because 1.3.3's TUs are a strict subset, so exactly two globs match nothing there (a warning, not an error; same trick as compat.catch2)) |
| C++-source compat, zero-dep client + optional components | [`compat.websocket`](pkgs/c/compat.websocket.lua) (IXWebSocket 12.0.1 — a pure RFC 6455 client compiled from upstream's `IXWEBSOCKET_SOURCES` minus the four server TUs, so the **base build has zero external dependencies**: TLS off (the OpenSSL/MbedTLS/AppleSSL TUs aren't built) and `IXWEBSOCKET_USE_ZLIB` unset, so the gzip codec compiles to a no-op. Two optional features add on top: `server` (the four server TUs — `IXWebSocketServer`, `IXSocketServer`, `IXHttpServer`, `IXWebSocketProxyServer` — needing nothing external, and it **implies `zlib`** because upstream's server advertises permessage-deflate by default, which the transport negotiates regardless of the define) and `zlib` (deps `compat.zlib` and turns the codec into real per-message-deflate compression). The default-feature test brings its own minimal RFC 6455 echo server on loopback sockets (handshake, masking, fragmentation and close all exercised offline); a second member, `websocket-features`, runs a real `ix::WebSocketServer` and asserts the compression is observable on the wire — a 64 KiB repeated payload round-trips with `wireSize` = 80) |
| header-only (with `features`) | [`compat.eigen`](pkgs/c/compat.eigen.lua) |
| header-only, nothing to gate | [`compat.CLI11`](pkgs/c/compat.CLI11.lua) (a command line parser whose every definition is `CLI11_INLINE`, so the package is `*/include` plus an anchor TU. Upstream's two extras stay out: `src/Precompile.cpp` only means anything when `CLI11_COMPILE` also reaches the CONSUMER's translation units — an interface define, not a sources-only gate — and `src/modules/CLI11.cppm` is a module layer, which is a package shape of its own rather than a feature of the compat package) |
| Runtime loader compat (pure sources, sidestepping upstream codegen/asm) | [`compat.vulkan`](pkgs/c/compat.vulkan.lua) (the Khronos loader: `loader/generated/` is checked in, and the assembly path degrades to plain C through `UNKNOWN_FUNCTIONS_SUPPORTED`, so no CMake/Python/assembler is needed; windows deferred) · [`compat.vulkan-headers`](pkgs/c/compat.vulkan-headers.lua) |
| Whole-source direct build + generated config (only where a platform lacks one) | [`compat.curl`](pkgs/c/compat.curl.lua) (win32 uses upstream's checked-in config, unix generates one) · [`compat.sdl2`](pkgs/c/compat.sdl2.lua) (win/mac use upstream's checked-in config; linux generates one and enables X11 by hand) · [`compat.c-ares`](pkgs/c/compat.c-ares.lua) (91 TUs; the release tarball already ships `ares_build.h` and a Windows config, so only `ares_config.h` is snapshotted per OS) |
| Upstream codegen frozen into the mirror archive | [`compat.godot-cpp`](pkgs/c/compat.godot-cpp.lua) (two versions: `4.5.0` = the `godot-4.5-stable` bindings, `10.0.0-rc1` = godot-cpp's own 10.x line, whose bindings target Godot 4.6. The ~1000 GDExtension classes under `gen/` exist in no upstream tag archive — upstream's `binding_generator.py` emits them at build time. Running it once offline and publishing upstream's tree byte-for-byte **plus** `gen/` keeps Python off the consumer side entirely; `tools/godot-cpp/repack.sh` reproduces the archive deterministically and refuses to publish if any upstream file differs) |
| Header package filling a gap in the index | [`compat.glx-headers`](pkgs/c/compat.glx-headers.lua) (libglvnd's `GL/glx.h`, absent from the Khronos registry and required by SDL's X11 backend) |
| C++ application framework compat (dependencies reuse packages already in the index) | [`compat.eui-neo`](pkgs/e/compat.eui-neo.lua) (upstream's `3rd/` ships 8 vendored dependencies; none of them is compiled here — all are redirected to the same-version `compat.*` packages in this index) |
| Mutually exclusive backends (one of several inside one package) | [`compat.eui-neo`](pkgs/e/compat.eui-neo.lua): `vulkan` / `sdl2` each **replace** the default OpenGL / GLFW, and the default backend is expressed by *naming no feature at all* — there is no `opengl`/`glfw` feature. A `default` feature cannot express exclusivity: its own `defines`/`sources`/`deps` have no effect whatsoever, while its `implies` always applies and cannot be overridden by a named feature (which is, conversely, exactly the solution for the "always-on interface define" row below). The workable answer is to read the `-DMCPP_FEATURE_<NAME>` mcpp passes anyway and decide up front in a force-included header. Note also that `cflags` only reaches C TUs — C++ needs `cxxflags`, so a backend define written only into `cflags` never reaches any `.cpp` |
| Host runtime adaptation (drivers are not vendored) | [`compat.glx-runtime`](pkgs/c/compat.glx-runtime.lua) · [`compat.vulkan-runtime`](pkgs/c/compat.vulkan-runtime.lua) (mcpp binaries run against a bundled glibc, so a bare-soname `dlopen` never reaches the host drivers; a symlink farm plus `runtime.library_dirs` bridges that. Note the farm holds only versioned sonames — `library_dirs` also joins the link line) |
| Always-on interface define | `CURL_STATICLIB` in [`compat.curl`](pkgs/c/compat.curl.lua): `cflags` is always on but package-private, while a feature's `defines` reaches consumers yet has to be named — `default = { implies = … }` applies unconditionally and happens to give both |
| Multiple majors in one package (shape switches with the version) | [`compat.catch2`](pkgs/c/compat.catch2.lua) (3.x compiles `src/catch2/` into a static library; 2.x goes header-only through `single_include/`) |
| External build system (`install()` builds from source) | [`compat.openblas`](pkgs/c/compat.openblas.lua) (Make) · [`compat.openssl`](pkgs/c/compat.openssl.lua) (Perl Configure + Make, static libssl/libcrypto) |
| Whole-source direct build (config snapshot + source list, no external build system) | [`compat.ffmpeg`](pkgs/c/compat.ffmpeg.lua) (2281 TUs including NASM assembly, declared through 28 directory globs) |
| Module layer over a compat source build (external Form-A repo) | [`godotengine.godot-cpp-m`](pkgs/g/godotengine.godot-cpp-m.lua) (two versions tracking upstream: `10.0.0-rc1` = Godot 4.6, `4.5.0` = Godot 4.5. `import godot_cpp;` re-exports the whole `godot` namespace, ~1800 names GENERATED from the headers rather than curated; the 1022-TU build stays in `compat.godot-cpp`, so the index carries only this descriptor. Macros — `GDCLASS`, `GDREGISTER_CLASS`, `memnew`, `ERR_*` — are the one thing a named module cannot export, so the package ships a side header to include next to the import. It also ships a generated `hashfuncs.hpp` shim — upstream's header minus `static` on two functions whose bodies declare an unnamed union — without which GCC refuses the module interface outright, a hard error no `-W` flag reaches) |
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
