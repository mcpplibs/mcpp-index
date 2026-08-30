# Library shapes and descriptor templates

**English** | [简体中文](zh/package-types.md)

Before writing a descriptor, work out which shape the library belongs to, then pick the matching template. Every path
inside `mcpp = {}` is a **GLOB relative to verdir**: a leading `*` absorbs the `<repo>-<tag>/` wrap layer of a tarball;
`*` matches a single segment and `**` matches across segments (so `*/blas/*.cpp` is legal).

A–D are the four **basic** shapes — judge by them first; E–G are treatments layered on top of a basic shape, to be
combined as needed.

| Shape | Characteristics | Samples | Key fields |
|---|---|---|---|
| **A. C-source compat** | plain C or a handful of sources; the user writes `#include <foo.h>` | `pkgs/c/compat.cjson.lua`, `compat.zlib.lua`, `compat.gtest.lua` | `sources` and `c_standard` |
| **B. header-only** | headers only, nothing to compile | `pkgs/c/compat.eigen.lua`, `compat.opengl.lua`, `compat.khrplatform.lua` | `include_dirs` and an anchor source |
| **C. C++23 module** | exposes `import x.y;` | `pkgs/n/nlohmann.json.lua` | `modules` plus `generated_files` or a source `.cppm` |
| **D. External Form-A module repo** | upstream ships its own mcpp descriptor in a separate repository — or the build needs something an inline descriptor cannot express (`build.mcpp`, a workspace, a code generator that must be compiled first) | `pkgs/i/imgui.lua`, `pkgs/m/mcpplibs.*`, `pkgs/f/freedesktop.wayland*.lua` (four entries out of one fork) | `mcpp = "<repo path>"` (Form A) |
| **E. Whole-source direct build with a generated config** | upstream generates its config header through configure/CMake; here a snapshot of it lands in `generated_files` | `pkgs/c/compat.libpng.lua`, `compat.curl.lua`, `compat.sdl2.lua`, `compat.ffmpeg.lua` | `generated_files` + `include_dirs` |
| **F. Shared-library compat** | has to be the **only** copy of that `.so` in the process — either because third parties `dlopen` it, or because the ecosystem payload links the same soname | the X11 family such as `pkgs/c/compat.x11.lua`, `compat.vulkan.lua`, `compat.libdrm.lua`, `compat.libffi.lua`, `compat.expat.lua` | `targets = { kind = "shared", soname = … }` |
| **G. Host runtime adaptation** | things that cannot be vendored, such as drivers — only a symlink farm plus metadata | `pkgs/c/compat.glx-runtime.lua`, `compat.vulkan-runtime.lua` | `runtime.library_dirs` / `capabilities` |
| **H. Host tool provider** | the upstream tarball also holds a **code generator** consumers run at build time | `pkgs/c/compat.protobuf.lua` (`protoc`) | a `targets` entry with `kind = "bin"` + `main`, plus `required_features` |
| **I. Ecosystem-stack binding** | the library is an internal build target of a project the **ecosystem already owns** and upstream ships no separable unit, so vendoring it would fork that project. NOT for libraries that merely coexist with a payload — see below | `pkgs/c/compat.libgbm.lua` (Mesa's GBM, via `xim:mesa`) | `xpm.<plat>.deps.runtime = { "xim:<pkg>" }` + a farm from `system.subos_sysrootdir()`, with `runtime.library_dirs` **and** `link_library_dirs` |

### Source build or binding: the criterion is separability, and only that

The index's default is to build from source. The only question is whether
upstream ships the thing as a **separable unit** — its own releases, buildable
without forking the project it lives in.

`compat.libgbm` fails that test and is shape I: GBM is a target inside Mesa
(`src/gbm/meson.build` is `link_with: [libloader]`, and `libloader` pulls
`idep_mesautil` — ~120 TUs of Mesa's internal util library for one function),
and it is a loader whose backends are Mesa's own. `compat.libdrm` PASSES it and
is shape F, even though the ecosystem's Mesa payload also carries a
`libdrm.so.2`.

**"The payload already has one" is not a reason to bind.** That was believed
here and is wrong, measured on mcpp 2026.8.29.1:

- Examined alone, Mesa's `libgbm.so.1` resolves `libdrm.so.2` through its own
  ABSOLUTE RUNPATH into `xim-x-libdrm/<ver>/lib`.
- In a real consumer process that links `compat.libdrm`, the same `libgbm.so.1`
  binds to the CONSUMER's copy instead, and exactly one `libdrm.so.2` is
  mapped. Mesa's GBM then allocated a buffer through it.

A DT_NEEDED soname already present in the link map is REUSED — ld.so never
searches again, so it never consults the payload's RUNPATH. The consumer links
the library directly, so it is mapped first and everything else follows it.

This only holds for `kind = "shared"` with the canonical soname. Built as this
index's default `kind = "lib"` (objects merged into the consumer) there is no
`.so` to reuse: the payload's copy loads for Mesa and the consumer keeps its
own merged one, so the library's file-static state exists twice over one set of
handles. That is the failure the soname prevents, and why these packages set it.

For the complete sample index, see [Descriptor examples by shape](descriptor-examples.md).

Shapes A, B and C share this skeleton (the `package` header and `xpm`):

```lua
package = {
    spec        = "1",
    namespace   = "compat",          -- dotted hierarchical path; compat / nlohmann / mcpplibs / …, decides the import prefix and the dependency key
    name        = "<lib>",           -- a single atomic segment; never repeats the namespace (SPEC-001 §3.2)
    description = "…",
    licenses    = {"MIT"},           -- SPDX
    repo        = "https://…",
    type        = "package",

    xpm = {  -- all three platforms must be declared; pure-source or pure-header packages share one url and sha256 across them
        linux   = { ["1.2.3"] = { url = { GLOBAL = "https://…/v1.2.3.tar.gz",
                                          CN     = "https://gitcode.com/mcpp-res/<slug>/releases/download/1.2.3/<slug>-1.2.3.tar.gz" },
                                  sha256 = "<computed>" } },
        macosx  = { ["1.2.3"] = { url = { GLOBAL = "…", CN = "…" }, sha256 = "…" } },
        windows = { ["1.2.3"] = { url = { GLOBAL = "…", CN = "…" }, sha256 = "…" } },
    },

    mcpp = { … see each shape below … },
}
```

Identity is the `(namespace, name)` pair: hierarchy always goes in `namespace`, and `name` carries exactly one segment.
The file name plays no part in resolution; `pkgs/<initial>/<namespace>.<name>.lua` is recommended (it hits mcpp's fast
path). See [Repository layout and schema](repository-and-schema.md#package-identity-namespace-name) for details.

---

## A. C-source compat (`compat.cjson` / `compat.zlib`)

Compile the C sources into a lib, expose the headers through `include_dirs`, and gate optional components behind
`features`.

```lua
mcpp = {
    language     = "c++23",   -- aligned with the existing compat packages; actual C behavior comes from c_standard
    import_std   = false,
    c_standard   = "c99",     -- or c11
    include_dirs = { "*" },           -- expose the top-level headers (*/foo.h)
    sources      = { "*/cJSON.c" },   -- core sources, always compiled
    targets      = { ["cjson"] = { kind = "lib" } },
    features     = {                  -- optional extras, not compiled by default
        ["utils"] = { sources = { "*/cJSON_Utils.c" } },
    },
    deps         = { },
}
```

Notes: with many sources you can either list them one by one (`compat.zlib` lists 15 `.c` files) or use a glob; when a
config header is needed, synthesize it with `generated_files` (`compat.zlib` uses
`mcpp_generated/include/mcpp_zlib_config.h` together with `cflags = {"-include …"}`).

## B. header-only (`compat.eigen` / `compat.opengl`)

These libraries have no compilable sources: `include_dirs` exposes the headers, and a trivial anchor `.c` is added so
there is a buildable lib target.

```lua
mcpp = {
    language     = "c++23",
    import_std   = false,
    c_standard   = "c11",
    include_dirs = { "*" },           -- or something tighter, "*/include" / "*/api"
    generated_files = {
        ["mcpp_generated/<lib>_anchor.c"] = "int mcpp_compat_<lib>_anchor(void) { return 0; }\n",
    },
    sources      = { "mcpp_generated/<lib>_anchor.c" },
    targets      = { ["<lib>"] = { kind = "lib" } },
    -- a component that does carry extra compilable sources (i.e. is not header-only) can become a source-gated feature:
    features     = {
        ["blas"] = { sources = { "*/blas/*.cpp", "*/blas/f2c/*.c" } },  -- the eigen case
    },
    deps         = { },
}
```

Careful: an optional part that is header-only cannot be hidden (it shares the include root with the core), so do not
force a feature around it; only extra compilable sources can be gated (`compat.eigen`'s `blas` consists of C++ and
f2c-converted C, needs no Fortran, and therefore can be gated).

## C. C++23 module (`nlohmann.json`)

Lets users write `import x.y;`. There are two ways to get there:

1. **Upstream already ships a `.cppm`**: point straight at it with `sources = { "*/path/to/unit.cppm" }`.
2. **The upstream release does not include one** (the common case): synthesize a wrapper through `generated_files`
   (`#include <header>`, `export module x.y;`, `export using …`), with the base header pinned to a published tag.
   Reuse upstream's official wrapper verbatim rather than inferring the symbol list yourself.

```lua
mcpp = {
    schema       = "0.1",
    language     = "c++23",
    import_std   = false,                 -- the wrapper includes upstream headers, and enabling import std invites conflicts
    modules      = { "nlohmann.json" },
    include_dirs = { "*/single_include" }, -- makes the #include <…> inside the wrapper resolvable
    generated_files = {
        ["mcpp_generated/nlohmann.json.cppm"] = "module;\n#include <nlohmann/json.hpp>\nexport module nlohmann.json;\n…",
    },
    sources      = { "mcpp_generated/nlohmann.json.cppm" },
    targets      = { ["nlohmann_json"] = { kind = "lib" } },
    deps         = { },
}
```

Careful: the mcpp segment parser does not support Lua long brackets `[[ … ]]`, so `generated_files` content must use
double-quoted strings with `\n` and `\"` escaped — otherwise you get `malformed mcpp segment`. On the consumer side,
do not mix `import x.y;` with a textual `#include <string>` (it conflicts with GCC modules); pair it with `import std;`
instead.

## D. External Form-A module repo (`imgui` / `mcpplibs.*`)

Upstream, or a separate repository, ships its own mcpp descriptor, and this repository is only a pointer:
`mcpp = "<relative or remote path>"` (Form A, rather than the inline Form B). A newly added standalone library usually
belongs to another repository (`mcpplibs/imgui-m`, for example) and this repository only registers it. See
`pkgs/i/imgui.lua` and `pkgs/x/xpkg.lua` for how to write one.

---

## E. Whole-source direct build with a generated config (`compat.curl` / `compat.sdl2`)

Upstream generates a config header through configure or CMake, whereas what this repository wants is "list the .c
files". That works because libraries of this kind compile the **unselected backends into empty TUs** (curl's
`vtls/gtls.c` is one big `#ifdef USE_GNUTLS` from top to bottom, and SDL's `src/video/windows/*.c` likewise), so the
source list can be a plain glob and all the configuration lands in one `generated_files` snapshot.

Generate one only on the platforms where **upstream leaves a gap**: curl checks in `lib/config-win32.h` (Windows needs
nothing generated), and SDL checks in `SDL_config_windows.h` / `SDL_config_macosx.h` (only linux falls through to the
useless `SDL_config_minimal.h`). When generating, be sure to run configure with **this index's toolchain** — a curl
config generated with the host `cc` once asserted that `ssize_t` does not exist, and curl then failed to compile
against its own config.

## F. Shared-library compat (the `compat.x11` family / `compat.vulkan`)

When a library gets `dlopen`ed by third parties, it must be the **only** copy in the process; static linking breaks.

```lua
targets = { ["vulkan"] = { kind = "shared", soname = "libvulkan.so.1" } },
```

`soname` is not optional: SDL2's `SDL_CreateWindow(SDL_WINDOW_VULKAN)` calls `dlopen("libvulkan.so.1")` and resolves
surface creation through it. With a static loader, the application ends up with two loaders — its own creating the
instance and SDL's creating the surface — and `createSurface` fails on an instance the other side has never seen.

Where you declare it matters too: `kind = "shared"` propagates `-fPIC` to consumers, and clang rejects that option
outright for msvc targets. So `compat.vulkan` declares it **inside the linux block**, while Windows takes another
route (linking a pre-generated import library). A `targets` inside a platform block overrides the top-level
declaration; `compat.ffmpeg` does the same.

## G. Host runtime adaptation (`compat.glx-runtime` / `compat.vulkan-runtime`)

GPU drivers cannot be packaged — an ICD has to match the kernel driver on the machine. This repository's settled
position is to model that as a **host capability** rather than pretend vendor drivers are ordinary redistributable
packages (see `.agents/docs/2026-06-03-gl-runtime-packages-plan.md`). Packages of this kind vendor nothing and are
just a symlink farm plus metadata:

```lua
runtime = {
    library_dirs = { "mcpp_generated/<name>/lib" },
    capabilities = { "vulkan.icd.driver" },
},
```

Why it is needed: mcpp's binaries run under a **bundled glibc** (`interp` points at `xim-x-glibc`, and the rpath only
covers mcpp's own tree), so a bare-soname `dlopen` does not search the host library paths at all — the loader finds
every ICD manifest and yet cannot open a single driver.

Two details that keep biting:

- **Put only versioned sonames in the farm** (`lib*.so.*`). A bare `libxcb.so` shadowed this repository's own
  `compat.xcb` and the link failed with `undefined reference to XauDisposeAuth` (mcpp#304). Versioned names are
  invisible to the linker and are exactly what `dlopen` asks for, so this remains the rule.
- **Know which directory key produces which flag** — they are not interchangeable, and the split is what makes the
  point above version-dependent. Read off the emitted `build.ninja` on mcpp 2026.8.27.2:

  | key | renders as |
  |---|---|
  | `runtime.library_dirs` | `-Wl,-rpath` |
  | `runtime.link_library_dirs` | `-L` |
  | `runtime.transitive_needed_dirs` | `-Wl,-rpath-link` |

  So on this pin `library_dirs` alone does **not** put the farm on the link line (the separate `-L` key arrived in
  2026.8.10.3; mcpp#304 predates it). Shape G packages want exactly that — nothing links against their farms, they
  exist so a bare-soname `dlopen` resolves at run time. A package that *is* linked against needs
  `link_library_dirs` too, or the build dies at `ld: cannot find -l<name>` with a farm that is perfectly correct;
  see shape I.
- **The closure has to be complete.** A farm holding `libxcb.so.1` but not the `libXau.so.6` it depends on shadows the
  host copy that would otherwise have resolved, and the executable simply fails to start.

## H. Host tool provider (`compat.protobuf`'s `protoc`)

Some tarballs hold both a library and the code generator that emits code against it. Declare the generator as a second
target, and consumers ask for it with `tools = [...]` (mcpp 2026.8.5.1+):

```lua
targets = {
    ["protobuf"] = { kind = "lib" },
    ["protoc"]   = { kind = "bin",
                     main = "*/src/google/protobuf/compiler/main.cc",
                     required_features = { "protoc", "upb" } },
},
features = {
    ["protoc"] = { sources = { … the compiler's own sources … } },
},
```

```toml
# consumer side — one dependency, two roles
compat.protobuf = { version = "35.1", tools = ["protoc"] }
```

mcpp then builds that target **for the build machine** in a nested sub-build and hands the path to the consumer's
`build.mcpp` through `mcpp::dep_bin("protobuf", "protoc")`. This is the whole reason the shape is worth naming: the
tool's version **is** the dependency's version, so a generator/runtime mismatch — a *runtime* failure everywhere else,
and the classic protobuf footgun — is not expressible. Under `mcpp build --target <triple>` the tool is still built for
the host, because a code generator has to run here.

Four things to get right:

- **Gate the compiler's sources behind a feature**, and name it in the target's `required_features`. Consumers who only
  link the library must not pay for the generator's TUs; consumers who ask for the tool must not have to know which
  features it needs. `compat.protobuf`'s `protoc` also requires `upb`, because libprotoc's upb generator links the upb
  runtime — get that wrong and it fails at **link** time with missing `upb_*` symbols.
- **Transcribe the source list from upstream**, exactly as for a library — protobuf's 138 entries come from
  `libprotoc_srcs` in its own `src/file_lists.cmake`.
- **`main` needs the same `*/` wrap glob as `sources`**; it is expanded the same way.
- **A generator that reads data files at runtime still needs a path to them.** protoc does not embed the well-known
  types: `import "google/protobuf/timestamp.proto"` is read from disk. Consumers derive that directory from
  `mcpp::dep_dir("protobuf")` — see `tests/examples/protobuf-protoc/build.mcpp`.

The matching member is `tests/examples/protobuf-protoc`, and it is the complement of `tests/examples/protobuf`: that
one deliberately uses no generated code, this one is generated code end to end.

---

## The minimal project (`tests/examples/<short>/`)

`mcpp.toml` (pick either the short or the long dependency form):

```toml
[package]
name = "<short>-example"
version = "0.1.0"
[toolchain]
default = "gcc@16.1.0"
# `compat` is inherited from the workspace root's [indices], so members need not repeat it;
# declare one here only when consuming another namespace, e.g. `[indices] fmtlib = { path = "../../.." }`
# — a member-level declaration **replaces** the root-level table rather than merging with it
# (which is exactly how a single project index repo is maintained).
[dependencies.compat]
<short> = "1.2.3"                          # or: <short> = { version = "1.2.3", features = ["…"] }
[targets.<short>-example]
kind = "bin"
main = "src/main.cpp"                      # C libraries may use .c
```

`src/main.cpp` should carry real assertions and `return ok ? 0 : 1`, not merely print output. Module libraries use
`import std; import x.y;`; header-only and C libraries use textual `#include`.
