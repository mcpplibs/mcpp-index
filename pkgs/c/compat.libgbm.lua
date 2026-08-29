-- compat.libgbm — GBM (Generic Buffer Management), the buffer-allocation API a
-- program uses to get scanout-capable buffers out of a DRM device: gbm_device,
-- gbm_bo, gbm_surface. It is what sits under EGL on a KMS console, under a
-- Wayland compositor's back end, and under headless GPU rendering with no X
-- server anywhere.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY THIS IS A BINDING AND NOT A SOURCE BUILD
--
-- The rule this index otherwise follows is "build it from source". Two facts
-- put libgbm on the other side of that line, and the second is the decisive
-- one.
--
-- 1. UPSTREAM DOES NOT SHIP IT AS A SEPARABLE UNIT. libgbm is a build target
--    inside Mesa, not a project. `src/gbm/meson.build` is
--
--        link_with    : [libloader]
--        dependencies : [dep_libdrm, idep_xmlconfig]
--
--    and `libloader` in turn wants `idep_mesautil` — the whole of Mesa's
--    internal util library, ~120 TUs plus Python-generated tables — for
--    exactly ONE function, `loader_open_driver_lib`. Add `-DUSE_DRICONF`
--    (expat), libdrm, xcb and xcb-randr. The GBM frontend/backend dlopen split
--    exists so VENDORS CAN SHIP BACKENDS; it was never an invitation to
--    rebuild the frontend. Vendoring it means forking Mesa's internals.
--
--    Contrast `compat.vulkan`, which DOES build the Khronos Vulkan-Loader from
--    source. That is not the same situation: Khronos releases the loader as a
--    standalone project whose entire purpose is to ship separately from any
--    driver. Mesa releases no such thing for GBM.
--
-- 2. IN THIS ECOSYSTEM, MESA ALREADY HAS AN OWNER: `xim:mesa`. So a source
--    build would make mcpp-index re-import libdrm + expat + xcb + a Mesa-util
--    carve-out — four or more new packages — to duplicate a dependency graph
--    the ecosystem has already resolved hermetically. That grows the
--    dependency surface to shrink nothing.
--
-- The measured surface of the binding, by contrast:
--
--     host          0   (see below — this is the whole point)
--     ecosystem     1   `xim:mesa`, not `xim:graphics`'s twenty-two
--     index         0   `deps = {}`; gbm.h includes only <stddef.h>/<stdint.h>
--     transitive    0   libgbm.so.1's own RUNPATH resolves entirely inside
--                       xim-x-{mesa,libdrm,expat,libllvm,glibc,…}. Mesa's
--                       build already placed libdrm/expat/LLVM in the
--                       ecosystem; nothing is asked of us or of the host.
--
-- ─────────────────────────────────────────────────────────────────────────
-- ZERO HOST. NOT "HOST, CONVERGED" — ZERO.
--
-- This package looks at `system.subos_sysrootdir()` and NOWHERE else. It has
-- no `/usr/lib*` candidate directory and, deliberately, NO escape-hatch
-- environment variable. That is a stricter rule than either neighbour:
-- `compat.glx-runtime` keeps `MCPP_HOST_GL_LIBRARY_PATH` as "the ONLY door
-- back to the host", and `compat.vulkan-runtime` harvests
-- /usr/lib/x86_64-linux-gnu outright.
--
-- Those two have a reason this one does not: a PROPRIETARY VENDOR DRIVER can
-- only come from the host. GBM has no such case — `xim:mesa` covers every host
-- shape the graphics stack covers (llvmpipe, radeonsi, iris, nouveau, zink,
-- d3d12, RADV).
--
-- And host libgbm specifically is a leak this ecosystem has already CLOSED.
-- `xim:nvidia-gl-host-link` records it by name:
--
--     "The table … was missing libm, libdrm, libgbm, libgcc_s and
--      libwayland-* -- all of which were therefore coming from the HOST,
--      silently, which is the leak this package exists to close (R7)."
--
-- Reopening it here would undo that. If a machine ever needs NVIDIA's own GBM
-- backend, that belongs in `xim:nvidia-gl-host-link` — the ecosystem's
-- host-link layer, which owns host contact — and not in this descriptor.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE PART THAT IS ACTUAL WORK: THE BACKEND IS UNREACHABLE IN THE SANDBOX
--
-- Harvesting libgbm.so and gbm.h is the easy half and would produce a package
-- you can link and cannot use. libgbm is a LOADER: every gbm_create_device()
-- dlopens `<path>/<driver>_gbm.so`. The path compiled into Mesa is
-- `/usr/lib/gbm` (`gbmbackendspath` in its gbm.pc), which does not exist
-- inside the sandbox. Measured, before this package existed:
--
--     MESA-LOADER: failed to open dri: /usr/lib/gbm/dri_gbm.so: cannot open
--     shared object file: No such file or directory
--     (search paths /usr/lib/gbm, suffix _gbm)
--
-- `xim:mesa`'s config() declares `lib` into `<subos>/lib` and `include` into
-- `<subos>/usr/include`, so libgbm.so and gbm.h both reach the view — but
-- `lib/gbm/` is a SUBDIRECTORY and does not. Closing that is this package's
-- real content, and it is why the shape is not a copy of compat.glx-runtime.
--
-- THE FIX MUST BE INVISIBLE. This is the constraint that decides the design,
-- and getting it wrong produces a package that passes its own tests and fails
-- its real consumers.
--
-- A libgbm consumer writes `#include <gbm.h>` and calls `gbm_create_device()`.
-- That is the whole API, and it has to keep working unchanged — because the
-- consumers that matter most are not the ones reading this file. SDL2's
-- KMSDRM backend, wlroots and ffmpeg's VAAPI hwcontext all call
-- gbm_create_device() from INSIDE a third-party library. Any scheme that
-- requires the application to call a helper first is unreachable for exactly
-- those callers, and would leave them as broken as they were.
--
-- So the package exposes stock `gbm.h` and wires the backend path from a
-- CONSTRUCTOR in its own TU (mcpp_generated/gbm_backends.c). By the time any
-- code runs, GBM_BACKENDS_PATH is already set; nothing has to be included,
-- called or known about. Verified with a consumer compiled against gbm.h alone
-- and linked with no knowledge of this package.
--
-- What makes that reliable is a property of mcpp that is usually a nuisance: a
-- dependency's objects enter the consumer's link EAGERLY, all of them, rather
-- than being lazily selected the way an archive member would be. Confirmed in
-- the emitted build.ninja, which names our object on the link line directly:
--
--     build bin/gbm : cxx_link obj/gbm.o obj/compat_libgbm/…/gbm_backends.o
--
-- so the constructor cannot be dropped. Priority 101 (the first value not
-- reserved for the implementation) puts it ahead of default-priority
-- constructors, in case a consumer creates a device from one.
--
-- HOW THE PATH IS FOUND, WITHOUT PINNING ANYTHING. The farm is laid out so the
-- backend directory is the SIBLING of the libgbm that actually got loaded:
--
--     mcpp_generated/libgbm/lib/libgbm.so{,.1,.1.0.0}   -> <subos>/lib/*
--     mcpp_generated/libgbm/lib/gbm/dri_gbm.so          -> mesa payload
--
-- and the constructor resolves it at RUNTIME: dlsym(RTLD_DEFAULT) a gbm
-- symbol, dladdr it, take the directory, append "/gbm". Verified that dladdr
-- reports the FARM path rather than the realpath — a library loaded through a
-- symlink on the RUNPATH reports the name the loader used — so the sibling
-- lands inside this package's own payload.
--
-- The alternative was to bake an absolute path into a generated header at
-- install time. That works and it pins the package to whichever mesa payload
-- existed on the day it was installed, which is precisely the failure
-- compat.glx-runtime's header comment warns about ("a payload path pins a
-- version … and stops resolving the day it is upgraded"). Runtime derivation
-- has no such cost and no absolute path anywhere in the descriptor.
--
-- An already-set GBM_BACKENDS_PATH is left alone: this is a default, not an
-- override, and a user who has pointed it somewhere deliberately outranks us.
--
-- THIS IS WHAT EVERY OTHER ECOSYSTEM DOES, and none of them do it with an API.
-- Distributions (Debian's libgbm1/libgbm-dev, Fedora's mesa-libgbm) split
-- libgbm out of the mesa SOURCE package and never touch the path, because one
-- system-wide prefix makes Mesa's compiled-in `$libdir/gbm` correct by
-- construction. Relocated and sandboxed stacks cannot rely on that and set the
-- environment variable instead — Valve's pressure-vessel hit precisely this
-- bug when Mesa 24.3 split the backends out (steam-runtime#797) and answers
-- with GBM_BACKENDS_PATH=/run/host/usr/lib64/gbm; Nix, Conda and AppImage do
-- the same at environment-activation time. Mesa itself offers the third route,
-- `-Dgbm-backends-path=`, for packagers who control the build.
--
-- This package is in the sandboxed case and cannot set a container-wide
-- environment, so the constructor is the in-process equivalent: same effect,
-- same variable, same "don't override an explicit value" rule, scoped to
-- processes that actually link libgbm.
--
-- WHERE THIS REALLY BELONGS, AND WHEN THIS CODE GOES AWAY. The distro answer is
-- the right one and it is one layer down. That is now DONE rather than
-- proposed: openxlings/xim-pkgindex#713 adds `GBM_BACKENDS_PATH` to the
-- graphics discovery table, so `xim:mesa` declares it into the subos and every
-- consumer inherits it — measured in a fresh subos, `4 env var(s) from 1
-- package(s)` where it used to be 3, and a real `gbm_bo_create` on card0.
--
-- THE REMOVAL CONDITION IS MECHANICAL, not a judgement call:
-- `tests/stock_usage.cpp` includes stock `<gbm.h>` and nothing else and
-- asserts the variable is already set. Delete this TU, the `lib/gbm/` farm and
-- `mcpp_gbm.h`, and re-run it. If it stays green, the ecosystem is supplying
-- the value and none of this is needed any more.
--
-- As of 2026-08-30 it is NOT yet green without the constructor: the value
-- arrives only in a home whose installed `xim:mesa` was configured by an index
-- carrying #713, which means after that PR merges and the artifact is
-- republished. Until then this is the only thing that makes
-- `gbm_create_device()` work for an mcpp consumer, and it is deliberately the
-- narrowest possible mechanism — one constructor, one variable, no override of
-- an explicit value.
--
-- WHY THE FARM CARRIES THE UNVERSIONED `libgbm.so`, when compat.vulkan-runtime
-- is emphatic that its farm must hold versioned sonames only. That rule exists
-- because `runtime.library_dirs` joins the LINK line too, so a bare
-- `libxcb.so` there would shadow this index's own compat.xcb. Here the
-- unversioned name is exactly what is wanted — it is how `-lgbm` resolves —
-- and there is nothing to shadow, because no other package in this index
-- provides gbm.
--
-- ─────────────────────────────────────────────────────────────────────────
-- KNOWN, AND NOT THIS PACKAGE'S DEFECT. On a host whose xim-x-mesa is 25.0.7.2
-- against xim-x-glibc 2.39, the backend is found and then fails to load:
--
--     MESA-LOADER: failed to open dri: …/xim-x-glibc/2.39/lib64/libm.so.6:
--     version `GLIBC_2.43' not found (required by …/libgallium-25.0.7.so)
--     (search paths …/lib/gbm, suffix _gbm)
--
-- Note the search path: the reachability gap IS closed, and what remains is a
-- glibc skew inside the ecosystem's own Mesa build. That is why the test
-- member asserts the backend is PRESENT at the derived path rather than that
-- it loads — an assertion that is meaningful on a CI runner with no GPU, and
-- that does not go green by accident when the stack is broken.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libgbm",
    description = "GBM buffer management API (Mesa), bound to the ecosystem's xim:mesa — zero host dependency",
    licenses    = {"MIT"},
    repo        = "https://gitlab.freedesktop.org/mesa/mesa",
    type        = "package",

    xpm = {
        linux = {
            -- PLATFORM level, beside the version entries rather than inside
            -- one. compat.glx-runtime paid a CI cycle to establish this: a
            -- per-version `deps` leaves the descriptor parsing fine and the
            -- dependency simply never installed, and the error you get names
            -- the missing library rather than the misplaced key.
            --
            -- `xim:mesa` and not `xim:graphics`: this package needs Mesa, not
            -- the GL dispatch and X11 halves of the twenty-two-package stack.
            deps = { runtime = { "xim:mesa" } },
            ["2026.08.29"] = {
                -- NOTHING DOWNLOADED HERE IS EVER READ, and the file is chosen
                -- so that cannot be misread.
                --
                -- Both halves of this package's payload come from the SUBOS:
                -- install() symlinks `gbm.h` out of `<subos>/usr/include` and
                -- `libgbm.so*` out of `<subos>/lib`. The xpm schema still wants
                -- a url + sha256 per version, so this is a stable, inert
                -- anchor and nothing more — exactly what compat.glx-runtime
                -- does with an OpenGL-Registry README and compat.vulkan-runtime
                -- with a Vulkan-Loader README.
                --
                -- It used to be Mesa's own `src/gbm/main/gbm.h`, on the theory
                -- that the anchor may as well record which header the package
                -- was written against. That was a mistake: an anchor NAMED
                -- like the header this package installs reads as though the
                -- download is the shipped header, which is the one thing it is
                -- not — and the first reader to see it asked exactly that. A
                -- README cannot be mistaken for a payload.
                --
                -- A raw file at a tag is byte-stable, unlike a GitLab-generated
                -- archive; sha256 confirmed twice, and the CN asset re-fetched
                -- and compared byte-for-byte against GLOBAL.
                url = {
                    GLOBAL = "https://gitlab.freedesktop.org/mesa/mesa/-/raw/mesa-25.0.7/README.rst",
                    CN     = "https://gitcode.com/mcpp-res/libgbm/releases/download/2026.08.29/libgbm-2026.08.29.rst",
                },
                sha256 = "03f0fd62094179bb70fb885042baa4254d392f5f7bb64e4d8856bec8a5ff8386",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",

        -- Both built by install(): gbm.h symlinked out of the subos view (so
        -- header and library can never be from different Mesa builds) and
        -- mcpp_gbm.h, this package's own two declarations.
        include_dirs = { "mcpp_generated/libgbm/include" },

        -- dladdr and RTLD_DEFAULT live behind __USE_GNU. `c_standard =
        -- "gnu11"` is the spelling that looks right and is a trap — mcpp
        -- 2026.8.27.2 accepts the string and still emits `-std=c11`
        -- (compat.libaio's header comment records the same finding), so the
        -- define is what actually takes effect.
        cflags = { "-D_GNU_SOURCE" },

        sources = { "mcpp_generated/gbm_backends.c" },

        -- NOT named `gbm`. A target called `gbm` would put a `libgbm.a` on the
        -- link line beside the real `libgbm.so` this package exists to
        -- deliver, and which of the two `-lgbm` picks would come down to
        -- search order.
        targets = { ["gbm_binding"] = { kind = "lib" } },

        -- The link against Mesa's libgbm itself. It resolves through the farm,
        -- which `runtime.library_dirs` puts on the link line as well as the
        -- runtime path. `-ldl` is belt-and-braces: glibc >= 2.34 folds libdl
        -- into libc and xim-x-glibc is 2.39, but the flag costs nothing.
        ldflags = { "-lgbm", "-ldl" },

        -- Zero. gbm.h includes <stddef.h> and <stdint.h>; the generated TU
        -- includes <dlfcn.h>, <stdlib.h> and <string.h>.
        deps = {},

        runtime = {
            -- THREE DIRECTORY KEYS, THREE DIFFERENT LINKER FLAGS, and they are
            -- not interchangeable. Measured on mcpp 2026.8.27.2 by reading the
            -- emitted build.ninja:
            --
            --     library_dirs          -> -Wl,-rpath           (RUNPATH only)
            --     link_library_dirs     -> -L
            --     transitive_needed_dirs-> -Wl,-rpath-link
            --
            -- `library_dirs` ALONE is what compat.glx-runtime and
            -- compat.vulkan-runtime declare, and it is right for them: they
            -- exist so a bare-soname `dlopen` resolves at RUN time, and
            -- nothing links against their farms. This package does link
            -- against its farm, so it needs the `-L` too — with only
            -- `library_dirs` the farm is complete, the rpath is correct, and
            -- the build still dies at `ld: cannot find -lgbm`.
            --
            -- (The docs used to say "library_dirs also joins the link line",
            -- which mcpp#304 observed for real. The separate `-L` key landed
            -- in 2026.8.10.3 and the pinned mcpp no longer behaves that way,
            -- so the claim is version-dependent; docs/package-types.md now
            -- carries the table above rather than the bare assertion.)
            library_dirs      = { "mcpp_generated/libgbm/lib" },
            link_library_dirs = { "mcpp_generated/libgbm/lib" },
            provides          = { "drm.gbm" },
            -- No `capabilities` entry. compat.glx-runtime declares
            -- "x11.display" because it needs the sandbox to expose a socket it
            -- does not own; there is no verified DRM counterpart in the
            -- engine's vocabulary, and coining one that may be silently
            -- ignored would document a guarantee this package cannot make.
        },

        -- No `generated_files`. The one TU and the two headers are written by
        -- install() below, which is the only writer — a `generated_files` copy
        -- of the same C source would be a second copy to keep in sync, and the
        -- parser takes only literals so it could not share one.
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.log")

-- The install() hook is a blind spot by default: log.error does not reach the
-- CI log, and a call outside the sandbox's xmake-API subset terminates the
-- hook with no message at all. So the log file comes first and every step
-- announces itself before doing anything. validate.yml's failure step
-- collects `mcpp_*_build.log`, which is what this name matches.
local log_path = nil

local function say(msg)
    if log_path == nil then
        return
    end
    local prev = io.readfile(log_path) or ""
    io.writefile(log_path, prev .. msg .. "\n")
end

local function fail(msg)
    say("FAILED: " .. msg)
    log.error("[libgbm] %s", msg)
    return false
end

local function sh_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

-- Link every file matching `pattern` in `srcdir` into `outdir`, by basename.
local function link_matching(srcdir, pattern, outdir)
    os.exec(
        "for f in " .. sh_quote(srcdir) .. "/" .. pattern ..
        "; do [ -e \"$f\" ] || continue; " ..
        "ln -sf \"$f\" " .. sh_quote(outdir) .. "/\"$(basename \"$f\")\"; " ..
        "done"
    )
end

-- Where mesa's own lib directory is, derived from the view rather than named.
-- `<subos>/lib/libgbm.so.1` is a symlink into the xim-x-mesa payload, so its
-- realpath gives the payload's lib dir and with it `lib/gbm/`, which the view
-- does not carry. Doing it this way keeps the descriptor free of any mesa
-- version. os.exec's return value is not trustworthy, so the answer is taken
-- from the file it writes.
local function mesa_libdir(prefix, view_lib)
    local probe = path.join(prefix, "mcpp_libgbm_realpath.txt")
    os.exec("readlink -f " .. sh_quote(path.join(view_lib, "libgbm.so.1")) ..
            " > " .. sh_quote(probe) .. " 2>/dev/null || true")

    local real = io.readfile(probe)
    if real == nil then
        return nil
    end
    real = real:gsub("%s+$", "")
    if real == "" then
        return nil
    end

    local slash = real:match("^(.*)/[^/]*$")
    return slash
end

local consumer_header = [[
#ifndef MCPP_COMPAT_LIBGBM_H
#define MCPP_COMPAT_LIBGBM_H

/* compat.libgbm -- OPTIONAL. You do not need this header.
 *
 * The way to use this package is the way you would use libgbm anywhere else:
 *
 *     #include <gbm.h>
 *     struct gbm_device *dev = gbm_create_device(fd);
 *
 * Mesa's compiled-in backend search path (/usr/lib/gbm) does not exist inside
 * an mcpp sandbox, but the package repairs that from a constructor in its own
 * translation unit, before any of your code runs. Nothing has to be called and
 * nothing has to be included -- which is the point: libgbm is mostly called
 * from INSIDE other libraries (SDL2's KMSDRM backend, wlroots, ffmpeg's VAAPI
 * hwcontext), and those will never call a helper of ours.
 *
 * What is below is introspection for diagnostics and for this package's own
 * tests. Reach for it when you want to report which backend directory was
 * chosen, or to override the choice explicitly.
 */

#include <gbm.h>

#ifdef __cplusplus
extern "C" {
#endif

/* The backend directory, derived from the loaded libgbm. NULL if libgbm is not
   in this process. Does not test whether the directory exists. */
const char *mcpp_gbm_backends_dir(void);

/* Point GBM_BACKENDS_PATH at that directory unless it is already set. The
   constructor has already done this; calling it again is harmless. Returns
   non-zero on success. */
int mcpp_gbm_use_sibling_backends(void);

#ifdef __cplusplus
}
#endif

#endif /* MCPP_COMPAT_LIBGBM_H */
]]

-- Kept identical to the generated_files entry above; install() does not wipe
-- the payload, so whichever of the two lands second writes the same bytes.
local backends_tu = [[
/* compat.libgbm -- point GBM_BACKENDS_PATH at the backends shipped beside this
 * package's libgbm, automatically and before anything else runs.
 *
 * WHY A CONSTRUCTOR. Mesa compiles `/usr/lib/gbm` in as its backend search
 * path and that directory does not exist inside an mcpp sandbox, so
 * gbm_create_device() finds nothing. Repairing it through a function the
 * application must call would not work: libgbm is mostly called from inside
 * OTHER libraries -- SDL2's KMSDRM backend, wlroots, ffmpeg's VAAPI hwcontext
 * -- and none of them will ever call ours. A constructor reaches all of them,
 * and keeps `#include <gbm.h>` the whole of the API.
 *
 * Priority 101 is the first value not reserved for the implementation, so this
 * runs ahead of default-priority constructors in case one creates a device.
 *
 * The path is derived, never stored: dlsym the loaded libgbm, dladdr it, and
 * take the sibling `gbm/` directory. dladdr reports the path the loader used
 * -- this package's farm -- rather than the realpath, so the answer stays
 * correct without pinning a mesa version.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>

static char mcpp_gbm_dir_buf[4096];

const char *mcpp_gbm_backends_dir(void)
{
    Dl_info info;
    const char *slash;
    void *sym;
    size_t n;

    if (mcpp_gbm_dir_buf[0] != '\0')
        return mcpp_gbm_dir_buf;

    /* RTLD_DEFAULT rather than &gbm_format_get_name: the address of an
       imported function is this object's own PLT stub, and dladdr would
       report the CONSUMER instead of libgbm. */
    sym = dlsym(RTLD_DEFAULT, "gbm_format_get_name");
    if (sym == NULL)
        return NULL;

    if (dladdr(sym, &info) == 0 || info.dli_fname == NULL)
        return NULL;

    slash = strrchr(info.dli_fname, '/');
    if (slash == NULL)
        return NULL;

    n = (size_t)(slash - info.dli_fname);
    if (n + sizeof("/gbm") > sizeof(mcpp_gbm_dir_buf))
        return NULL;

    memcpy(mcpp_gbm_dir_buf, info.dli_fname, n);
    memcpy(mcpp_gbm_dir_buf + n, "/gbm", sizeof("/gbm"));
    return mcpp_gbm_dir_buf;
}

int mcpp_gbm_use_sibling_backends(void)
{
    const char *dir;

    /* An explicit GBM_BACKENDS_PATH is the caller's decision and is left
       alone -- this is a default, not an override. Same rule the sandboxed
       stacks that set this variable follow (pressure-vessel, Nix, Conda). */
    if (getenv("GBM_BACKENDS_PATH") != NULL)
        return 1;

    dir = mcpp_gbm_backends_dir();
    if (dir == NULL)
        return 0;

    return setenv("GBM_BACKENDS_PATH", dir, 1) == 0;
}

__attribute__((constructor(101)))
static void mcpp_gbm_wire_backends(void)
{
    mcpp_gbm_use_sibling_backends();
}
]]

function install()
    local prefix = pkginfo.install_dir()
    os.mkdir(prefix)

    log_path = path.join(prefix, "mcpp_libgbm_build.log")
    io.writefile(log_path, "compat.libgbm install()\n")

    local view = system.subos_sysrootdir()
    say("subos view: " .. tostring(view))

    local view_lib = path.join(view, "lib")
    local view_inc = path.join(view, "usr", "include")

    local generated = path.join(prefix, "mcpp_generated")
    local root      = path.join(generated, "libgbm")
    local out_lib   = path.join(root, "lib")
    local out_inc   = path.join(root, "include")
    local out_bk    = path.join(out_lib, "gbm")

    os.mkdir(generated)
    os.mkdir(out_lib)
    os.mkdir(out_inc)
    os.mkdir(out_bk)

    say("writing mcpp_generated/gbm_backends.c")
    io.writefile(path.join(generated, "gbm_backends.c"), backends_tu)

    say("writing include/mcpp_gbm.h")
    io.writefile(path.join(out_inc, "mcpp_gbm.h"), consumer_header)

    -- 1. The library. From the subos view and from nowhere else -- see the
    --    header comment: this package has no host path and no override.
    say("linking libgbm.so* from " .. view_lib)
    link_matching(view_lib, "libgbm.so*", out_lib)

    for _, required in ipairs({"libgbm.so", "libgbm.so.1"}) do
        if not os.isfile(path.join(out_lib, required)) then
            return fail(required .. " is not in this subos. libgbm comes from "
                        .. "`xim:mesa`, which this package declares as a "
                        .. "runtime dependency; if it is declared and this "
                        .. "still fires, that install did not finish")
        end
    end
    say("libgbm.so and libgbm.so.1 present")

    -- The farm glob is `libgbm.so*` and cannot match a C runtime, but
    -- compat.glx-runtime's rule is to ASSERT rather than trust: the failure a
    -- stray libc here produces is a fault inside the dynamic linker before
    -- main, with no output at all, and the glob is one careless edit from
    -- matching more than it meant to.
    for _, bad in ipairs({"libc.so.6", "libm.so.6", "ld-linux-x86-64.so.2"}) do
        if os.isfile(path.join(out_lib, bad)) then
            return fail(bad .. " was linked into the libgbm farm; it would "
                        .. "reach every consumer's RUNPATH and pair a second "
                        .. "libc with mcpp's loader")
        end
    end

    -- 2. The header, from the same view, so it is necessarily the one that
    --    matches the library above.
    say("linking gbm.h from " .. view_inc)
    link_matching(view_inc, "gbm.h", out_inc)
    if not os.isfile(path.join(out_inc, "gbm.h")) then
        return fail("gbm.h is not in this subos (expected "
                    .. path.join(view_inc, "gbm.h") .. ")")
    end
    say("gbm.h present")

    -- 3. The backends. NOT required: a Mesa built without the dri backend is a
    --    legitimate configuration, and so is a machine that will only ever use
    --    the pure-function half of the API. The test member reports what it
    --    finds rather than assuming.
    local mesa_lib = mesa_libdir(prefix, view_lib)
    if mesa_lib == nil then
        say("NOTE: could not resolve the mesa payload lib dir; no backends linked")
        return true
    end

    local src_bk = path.join(mesa_lib, "gbm")
    say("mesa payload lib dir: " .. mesa_lib)
    if not os.isdir(src_bk) then
        say("NOTE: " .. src_bk .. " does not exist; no backends linked")
        return true
    end

    say("linking *_gbm.so from " .. src_bk)
    link_matching(src_bk, "*_gbm.so", out_bk)
    say("done")

    return true
end
