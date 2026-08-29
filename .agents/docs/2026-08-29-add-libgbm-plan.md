# Adding `compat.libgbm` — GBM bound to the ecosystem's Mesa

> ## ⚠ SUPERSEDED IN PART — read this first
>
> This is the FIRST-ROUND design record, and its central mechanism no longer
> exists. It describes a constructor in a generated TU that set
> `GBM_BACKENDS_PATH`, a `lib/gbm/` backend farm, and an `mcpp_gbm.h`. **All
> three are gone.**
>
> Setting that variable was always Mesa's own mechanism and the ENVIRONMENT's
> job. `xim:mesa` now declares it through the graphics discovery layer
> (openxlings/xim-pkgindex#713), so the package sets nothing, generates no TU
> and ships no header of its own — 598 lines down to 303. What this document
> calls "the part that is actual work" turned out to be a workaround for a
> missing declaration one layer down.
>
> What still holds: the shape decision (a binding, not a source build) and the
> evidence behind it; the zero-host rule; the two-directory-key finding; and
> the test design. For the current state and the three rounds of correction
> that produced it, see
> [2026-08-30-gbm-cross-repo-closed-loop-plan.md](2026-08-30-gbm-cross-repo-closed-loop-plan.md)
> — especially §12.1, §16 and §17.


Date: 2026-08-29 · Package: `compat.libgbm@2026.08.29` · Member: `tests/examples/libgbm`

## What GBM is, and what had to be decided

GBM (Generic Buffer Management) is the API a program uses to get scanout-capable buffers out of a
DRM device — `gbm_device`, `gbm_bo`, `gbm_surface`. It sits under EGL on a KMS console, under a
Wayland compositor's back end, and under headless GPU rendering with no X server.

The only real decision was the shape, and the first answer was wrong. The criterion that settled it
is not "which is less work" but **how much dependency surface the ecosystem takes on, and how much
of it touches the host**.

## Shape: why this is a binding, not a source build

### 1. Upstream does not ship libgbm as a separable unit

Measured against Mesa 26.2.1. `src/gbm/meson.build`:

```meson
libgbm = shared_library(libgbm_name, files_gbm,
  link_with    : [libloader],
  dependencies : [dep_libdrm, idep_xmlconfig], …)
```

and `src/loader/meson.build` in turn:

```meson
libloader = static_library('loader', ['loader_dri_helper.c', 'loader.c', sha1_h],
  c_args       : ['-DUSE_DRICONF'],
  dependencies : [idep_mesautil, dep_libdrm, dep_thread, dep_xcb, dep_xcb_xrandr], …)
```

`idep_mesautil` is the whole of Mesa's internal util library — ~120 TUs plus Python-generated
tables — and libgbm reaches it for exactly **one** function, `loader_open_driver_lib`. `loader.c`
itself pulls `GL/gl.h`, `mesa_interface.h`, `util/xmlconfig.h` (expat), `drm-uapi/nouveau_drm.h`,
`pci_id_driver_map.h` and a generated `git_sha1.h`.

This is not a recent refactor to route around: `main/backend.c` has included `loader.h` since at
least Mesa 23.3.6 (checked 23.3.6, 25.0.7, 26.2.1).

GBM's frontend/backend `dlopen` split exists so **vendors can ship backends** — NVIDIA contributed
it in 2021 — not as an invitation to rebuild the frontend. Vendoring it means forking Mesa's
internals.

The contrast with `compat.vulkan` is the point, and it is not a double standard: Khronos releases
the Vulkan-Loader as a **standalone project** whose entire purpose is to ship separately from any
driver. Mesa releases no such thing for GBM.

### 2. In this ecosystem, Mesa already has an owner

`xim:mesa` is a package, and `xim-x-mesa/25.0.7.2` already carries `lib/libgbm.so{,.1,.1.0.0}`,
`include/gbm.h` and `lib/gbm/dri_gbm.so`. Its `config()` declares `lib` into `<subos>/lib` and
`include` into `<subos>/usr/include`.

So a source build would make mcpp-index re-import **libdrm + expat + xcb + a Mesa-util carve-out**
— four or more new packages — to duplicate a dependency graph the ecosystem has already resolved
hermetically. That grows the dependency surface in order to shrink nothing.

### Measured surface of the chosen shape

| surface | count | note |
|---|---|---|
| host | **0** | no `/usr/lib*` path, no `MCPP_HOST_*` override — see below |
| ecosystem | **1** | `xim:mesa`, not `xim:graphics`'s twenty-two |
| index | **0** | `deps = {}`; `gbm.h` includes only `<stddef.h>`/`<stdint.h>` |
| transitive | **0** | `libgbm.so.1`'s RUNPATH resolves entirely inside `xim-x-{mesa,libdrm,expat,libllvm,glibc,…}` |

## Zero host — not "host, converged"

This package reads `system.subos_sysrootdir()` and nothing else. That is stricter than either
neighbour: `compat.glx-runtime` keeps `MCPP_HOST_GL_LIBRARY_PATH` as "the ONLY door back to the
host", and `compat.vulkan-runtime` harvests `/usr/lib/x86_64-linux-gnu` outright.

Those two have a reason this one does not: a **proprietary vendor driver** can only come from the
host. GBM has no such case — `xim:mesa` covers every host shape the graphics stack covers
(llvmpipe, radeonsi, iris, nouveau, zink, d3d12, RADV).

And host libgbm specifically is a leak the ecosystem has already closed. From
`xim:nvidia-gl-host-link`:

> The table was a list of what someone thought of, and it was missing libm, libdrm, **libgbm**,
> libgcc_s and libwayland-* — all of which were therefore coming from the HOST, silently, which is
> the leak this package exists to close (R7).

Reopening it here would undo that. If a machine ever needs NVIDIA's own GBM backend, that belongs
in `xim:nvidia-gl-host-link` — the ecosystem's host-link layer, which owns host contact — and not
in this descriptor.

## The part that is actual work: backend reachability

Harvesting `libgbm.so` and `gbm.h` is the easy half and produces a package you can link and cannot
use. libgbm is a **loader**: every `gbm_create_device()` dlopens `<path>/<driver>_gbm.so`, and the
path Mesa compiles in is `/usr/lib/gbm` (its `gbm.pc` says `gbmbackendspath=/usr/lib/gbm`), which
does not exist inside the sandbox. Measured before this package existed:

```
MESA-LOADER: failed to open dri: /usr/lib/gbm/dri_gbm.so: cannot open shared object file
(search paths /usr/lib/gbm, suffix _gbm)
```

`xim:mesa` declares `lib` into the view, but `lib/gbm/` is a **subdirectory** and does not follow.
Closing that is this package's real content, and it is why the shape is not a copy of
`compat.glx-runtime`.

### The repair has to be invisible

The first version of this package exposed a header, `mcpp_gbm.h`, and asked the consumer to call
`mcpp_gbm_use_sibling_backends()` before creating a device. That was wrong, and not merely
stylistically: **libgbm is mostly called from inside other libraries.** SDL2's KMSDRM backend,
wlroots and ffmpeg's VAAPI hwcontext all call `gbm_create_device()` out of their own sources, and
none of them will ever call a helper of ours. A design that only works for callers who have read
this descriptor leaves the important consumers exactly as broken as they were.

So the package exposes stock `gbm.h`, and the path is wired from a **constructor** in the
package's own TU. Nothing has to be included, called, or known about.

What makes that reliable is a property of mcpp that is usually a nuisance: a dependency's objects
enter the consumer's link *eagerly*, rather than being lazily selected the way an archive member
would be. Confirmed in the emitted `build.ninja`, which names the object on the link line:

```
build bin/gbm : cxx_link obj/gbm.o obj/compat_libgbm/mcpp_generated/gbm_backends.o
```

so the constructor cannot be dropped. Priority 101 — the first value not reserved for the
implementation — puts it ahead of default-priority constructors in case a consumer creates a
device from one. An already-set `GBM_BACKENDS_PATH` is left alone: this is a default, not an
override.

### This is what every other ecosystem does, and none of them use an API

| ecosystem | how the backend path is made right |
|---|---|
| Debian (`libgbm1`/`libgbm-dev`), Fedora (`mesa-libgbm`) | libgbm is a **binary package split out of the mesa source package**; one system-wide prefix makes Mesa's compiled-in `$libdir/gbm` correct by construction. Nothing to set. |
| Valve pressure-vessel (Steam Runtime) | Hit exactly this bug when Mesa 24.3 split the backends out — [steam-runtime#797](https://github.com/ValveSoftware/steam-runtime/issues/797) — and answers with `GBM_BACKENDS_PATH=/run/host/usr/lib64/gbm` **in the container environment**. |
| NixOS / Conda / AppImage | Same variable, set at environment-activation / wrapper level. |
| Anyone controlling the build | Mesa's own [`-Dgbm-backends-path=`](https://cgit.freedesktop.org/mesa/mesa/commit/?id=7f615c66fbdd0a7aa7a513d011956dcc6c0ac2e6) meson option, added for precisely this. |

Every one of them is *environment* or *build-time*. None is "call our function". This package is
in the sandboxed case and cannot set a container-wide environment, so the constructor is the
in-process equivalent: same variable, same don't-override rule, scoped to processes that actually
link libgbm.

**Where this really belongs.** The distro answer is the right one and it is one layer down:
`xim:mesa` either building with `-Dgbm-backends-path=` pointing into the subos view, or declaring
`lib/gbm/` into it the way it already declares `lib` and `include`. Then this package would carry
no constructor at all. Worth filing against `xim:mesa`; until then the wiring lives here, where it
is at least tested.

### How the path is found, without pinning anything

The farm is laid out so the backend directory is the sibling of the libgbm that actually loaded:

```
mcpp_generated/libgbm/lib/libgbm.so{,.1,.1.0.0}   -> <subos>/lib/*
mcpp_generated/libgbm/lib/gbm/dri_gbm.so          -> mesa payload lib/gbm/
mcpp_generated/libgbm/include/{gbm.h,mcpp_gbm.h}
```

and `mcpp_gbm_use_sibling_backends()` resolves it at runtime: `dlsym(RTLD_DEFAULT)` a gbm symbol,
`dladdr` it, take the directory, append `/gbm`.

Verified experimentally that `dladdr` reports the **farm** path and not the realpath — a library
loaded through a symlink on the RUNPATH reports the name the loader used — so the sibling lands
inside this package's own payload:

```
dli_fname            = …/farmtest/lib/libgbm.so.1
derived backends dir = …/farmtest/lib/gbm
```

and with `GBM_BACKENDS_PATH` set from it, the loader's own diagnostic confirms it searches there:
`(search paths …/farmtest/lib/gbm, suffix _gbm)`.

The alternative — baking an absolute path into a generated header at install time — works and pins
the package to whichever mesa payload existed on install day, which is exactly what
`compat.glx-runtime`'s header comment warns about ("a payload path pins a version … and stops
resolving the day it is upgraded"). Runtime derivation has no such cost and puts no absolute path
in the descriptor at all.

`RTLD_DEFAULT` rather than `&gbm_format_get_name`: the address of an imported function is the
consumer's own PLT stub, and `dladdr` would report the consumer.

## Two mechanism findings worth keeping

**`runtime.library_dirs` does not put `-L` on the link line.** The index README and the descriptor
catalog both said it did. Reading the emitted `build.ninja` on mcpp 2026.8.27.2:

| key | renders as |
|---|---|
| `runtime.library_dirs` | `-Wl,-rpath` |
| `runtime.link_library_dirs` | `-L` |
| `runtime.transitive_needed_dirs` | `-Wl,-rpath-link` |

`compat.glx-runtime` and `compat.vulkan-runtime` are unaffected — nothing links against their
farms, they exist so a bare-soname `dlopen` resolves at run time. This package does link against
its farm, and with `library_dirs` alone the farm is complete, the rpath correct, and the build dies
at `ld: cannot find -lgbm`. Both catalog rows have been corrected in this change.

**`c_standard = "gnu11"` is still silently ignored** (mcpp 2026.8.27.2 emits `-std=c11` anyway), so
`dladdr`/`RTLD_DEFAULT` are reached with `cflags = { "-D_GNU_SOURCE" }`, exactly as `compat.libaio`
found for `syscall()`/`sigset_t`.

## Target naming

The lib target is `gbm_binding`, not `gbm`. A target called `gbm` would put a `libgbm.a` on the
link line beside the real `libgbm.so` the package exists to deliver, and which one `-lgbm` picked
would come down to search order.

## Test member

`tests/examples/libgbm`, linux-gated, no-op `main()` elsewhere (the `compat.libaio` /
`compat.wil` pattern). **Two binaries**, and the split is the point:

- `tests/stock_usage.cpp` includes **stock `<gbm.h>` and nothing else** — no `mcpp_gbm.h`, no
  helper declaration, no knowledge that this package exists. It is what a ported consumer looks
  like, and what a third-party library looks like from the inside. If the backend path ever
  regresses to something the application must opt into, this file fails while `gbm.cpp` could
  still pass. That asymmetry is why it exists.
- `tests/gbm.cpp` covers the rest, including the optional introspection header.

`gbm.cpp`'s first assertion reads `GBM_BACKENDS_PATH` **before the program has called anything**,
which is the direct check that the constructor did its job. Its last one re-execs the binary with
the variable already set and asserts the child still sees the inherited value — the only way to
observe the don't-override rule, since by the time `main` runs the constructor is finished.

All checks run with no GPU:

- `gbm_format_get_name` over four fourccs — `XRGB8888`→`XR24`, `ARGB8888`→`AR24`, `NV12`→`NV12`,
  `ABGR2101010`→`AB30`.
- The two **legacy enumerators**, which are the assertions that matter: `GBM_BO_FORMAT_XRGB8888`
  is the value `0`, and only the library's own `format_canonicalize()` turns it into `"XR24"`. A
  header-only reimplementation would pass the fourcc cases and fail these.
- Six `dlsym(RTLD_DEFAULT, …)` checks, so a header from a different Mesa than the library surfaces
  here rather than as a link error.
- `gbm_create_device(-1) == nullptr`.
- **Backend reachability**: the derived directory exists and holds at least one `*_gbm.so`. This is
  the assertion the package exists for and it needs no `/dev/dri`.
- `GBM_BACKENDS_PATH` is already set on entry to `main`, and an inherited one survives (checked in
  a re-exec'd child).

Real device creation is opt-in behind `MCPP_RUN_GBM_DEVICE=1` plus a working `/dev/dri`, following
`tests/examples/imgui-window`'s `MCPP_RUN_WINDOW=1`.

## Verification

With the CI-pinned mcpp (2026.8.27.2), after `rm -rf` of the member's `target/`, `.mcpp/` and the
package's build-cache entry:

```
   Compiling compat.libgbm v2026.08.29
   Compiling gbm (test)
     Running bin/gbm
GBM_BACKENDS_PATH is set on entry to main (nothing called) ok
…
an inherited GBM_BACKENDS_PATH survives the constructor    ok
0 check(s) failed
stock_usage ... ok
a <gbm.h>-only consumer inherits GBM_BACKENDS_PATH         ok
  ... and it is a directory                                ok
  ... holding a backend libgbm can actually dlopen         ok
0 check(s) failed
 test result ok. 2 passed; 0 failed; finished in 45.69s
```

Also verified outside mcpp, as an independent check of the mechanism: a consumer compiled against
stock `gbm.h` and linked with no knowledge of the package prints the wired path before `main`.

- `mcpp xpkg parse pkgs/c/compat.libgbm.lua` → `parse OK` (no unknown mcpp-segment keys).
- All eight lint gates reproduced locally (syntax, required fields, no leading `v`, mirror urls,
  package name, cross-package refs, platform parity, duplicate versions) → clean.
- **Assertions confirmed failable**: moving `dri_gbm.so` out of the farm turns the reachability
  check to `FAILED` and both binaries exit 1.
- The linked binary is honest: `NEEDED libgbm.so.1` with the farm on `RPATH` and **no host path
  anywhere** on it.
- CN mirror published at `gitcode.com/mcpp-res/libgbm@2026.08.29`, fetched back and confirmed
  byte-identical to GLOBAL (`95f3b4a6…`, 19165 bytes). GLOBAL sha computed twice before use.

## Known, and not this package's defect

On a host whose `xim-x-mesa` is 25.0.7.2 against `xim-x-glibc` 2.39, the backend is found and then
fails to load:

```
MESA-LOADER: failed to open dri: …/xim-x-glibc/2.39/lib64/libm.so.6: version `GLIBC_2.43' not
found (required by …/libgallium-25.0.7.so) (search paths …/lib/gbm, suffix _gbm)
```

Note the search path: the reachability gap **is** closed, and what remains is a glibc skew inside
the ecosystem's own Mesa build — the shape of mcpp#352, upstream of this package. It is why the
test asserts the backend is *present* at the derived path rather than that it *loads*: that
assertion is meaningful on a GPU-less runner and does not go green by accident when the stack is
broken. Worth reporting against `xim:mesa` separately.

## What was deliberately left out

- **No `capabilities` entry.** `compat.glx-runtime` declares `"x11.display"` because it needs the
  sandbox to expose a socket it does not own. There is no verified DRM counterpart in the engine's
  vocabulary, and coining one that may be silently ignored would document a guarantee this package
  cannot make.
- **No `libraries` block.** Only `ldflags`. A name containing a dot in `libraries` is treated as a
  package-relative path; the neutral block is only needed by `cl.exe` consumers.
- **No features.** There are no optional compilable components — the package has exactly one TU of
  its own.
- **No non-linux `xpm` section.** GBM is the DRM buffer API; there is no port to declare, so
  consumers gate it with `[target.'cfg(linux)'.dependencies]`.
