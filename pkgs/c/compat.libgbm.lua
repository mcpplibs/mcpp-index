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
-- HOW THE PATH IS FOUND, WITHOUT PINNING ANYTHING. The farm is laid out so the
-- backend directory is the SIBLING of the libgbm that actually got loaded:
--
--     mcpp_generated/libgbm/lib/libgbm.so{,.1,.1.0.0}   -> <subos>/lib/*
--     mcpp_generated/libgbm/lib/gbm/dri_gbm.so          -> mesa payload
--
-- so `mcpp_gbm_use_sibling_backends()` below resolves it at RUNTIME:
-- dlsym(RTLD_DEFAULT) a gbm symbol, dladdr it, take the directory, append
-- "/gbm". Verified that dladdr reports the FARM path rather than the realpath
-- — a library loaded through a symlink on the RUNPATH reports the name the
-- loader used — so the sibling lands inside this package's own payload.
--
-- The alternative was to bake an absolute path into a generated header at
-- install time. That works and it pins the package to whichever mesa payload
-- existed on the day it was installed, which is precisely the failure
-- compat.glx-runtime's header comment warns about ("a payload path pins a
-- version … and stops resolving the day it is upgraded"). Runtime derivation
-- has no such cost and no absolute path anywhere in the descriptor.
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
                -- Nothing downloaded is used. The payload is what install()
                -- builds out of the subos view, so this is only a stable,
                -- well-formed anchor for the xpm entry — the trick
                -- compat.glx-runtime plays with an OpenGL-Registry README.
                --
                -- Mesa's own gbm.h at the tag the ecosystem's mesa ships, so
                -- the anchor at least records which header this package was
                -- written against. A raw file at a tag is byte-stable, unlike
                -- a GitLab-generated archive; sha256 confirmed twice.
                url = {
                    GLOBAL = "https://gitlab.freedesktop.org/mesa/mesa/-/raw/mesa-25.0.7/src/gbm/main/gbm.h",
                    CN     = "https://gitcode.com/mcpp-res/libgbm/releases/download/2026.08.29/libgbm-2026.08.29.h",
                },
                sha256 = "95f3b4a6ee5175c7cc5d47368d4efb100063fe49e5a6f5b19030ac2ceed73b81",
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

        generated_files = {
            -- Resolves GBM_BACKENDS_PATH from whichever libgbm is actually
            -- loaded. See the header comment for why this is derived at
            -- runtime instead of baked in at install time.
            --
            -- Declared here AND written by install(); install() does not wipe
            -- the payload, so the two never race — this entry is what
            -- guarantees the TU exists whatever order the two run in.
            ["mcpp_generated/gbm_backends.c"] =
[[
/* compat.libgbm — locate the GBM backend directory without pinning a path.
 *
 * Mesa compiles `/usr/lib/gbm` in as its default backend search path, which
 * does not exist inside an mcpp sandbox. This package's farm instead places
 * the backends in `gbm/` NEXT TO the libgbm it ships, so the directory can be
 * derived from the loaded library itself and no absolute path is ever stored.
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
       alone -- this is a default, not an override. */
    if (getenv("GBM_BACKENDS_PATH") != NULL)
        return 1;

    dir = mcpp_gbm_backends_dir();
    if (dir == NULL)
        return 0;

    return setenv("GBM_BACKENDS_PATH", dir, 1) == 0;
}
]],
        },
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

/* compat.libgbm — Mesa's gbm.h plus the two helpers this package adds.
 *
 * Mesa's compiled-in backend search path (/usr/lib/gbm) does not exist inside
 * an mcpp sandbox, so gbm_create_device() would find no backend. Call
 * mcpp_gbm_use_sibling_backends() once before creating a device; it points
 * GBM_BACKENDS_PATH at the backends shipped beside this package's libgbm, and
 * leaves an explicitly set GBM_BACKENDS_PATH alone.
 */

#include <gbm.h>

#ifdef __cplusplus
extern "C" {
#endif

/* The backend directory, derived from the loaded libgbm. NULL if libgbm is not
   in this process. Does not test whether the directory exists. */
const char *mcpp_gbm_backends_dir(void);

/* Set GBM_BACKENDS_PATH to that directory unless it is already set.
   Returns non-zero on success. */
int mcpp_gbm_use_sibling_backends(void);

#ifdef __cplusplus
}
#endif

#endif /* MCPP_COMPAT_LIBGBM_H */
]]

-- Kept identical to the generated_files entry above; install() does not wipe
-- the payload, so whichever of the two lands second writes the same bytes.
local backends_tu = [[
/* compat.libgbm — locate the GBM backend directory without pinning a path.
 *
 * Mesa compiles `/usr/lib/gbm` in as its default backend search path, which
 * does not exist inside an mcpp sandbox. This package's farm instead places
 * the backends in `gbm/` NEXT TO the libgbm it ships, so the directory can be
 * derived from the loaded library itself and no absolute path is ever stored.
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
       alone -- this is a default, not an override. */
    if (getenv("GBM_BACKENDS_PATH") != NULL)
        return 1;

    dir = mcpp_gbm_backends_dir();
    if (dir == NULL)
        return 0;

    return setenv("GBM_BACKENDS_PATH", dir, 1) == 0;
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
