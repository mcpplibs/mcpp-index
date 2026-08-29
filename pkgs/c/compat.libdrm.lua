-- compat.libdrm — libdrm, the userspace wrapper over the kernel's DRM ioctls:
-- `drmOpen`/`drmGetVersion`, the whole `drmMode*` KMS family (connectors, CRTCs,
-- framebuffers, page flips), PRIME import/export, and the `drm.h` /
-- `drm_mode.h` / `drm_fourcc.h` uapi headers.
--
-- It is the layer directly under compat.libgbm: GBM allocates a buffer, and
-- libdrm is what turns that buffer into something a display controller
-- scans out (`drmModeAddFB2` + `drmModeSetCrtc`). Without it a consumer can
-- allocate and never present.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SHAPE: the compat.libgbm binding, and the criterion is the same
--
-- The index's rule is "build it from source", and the question is always
-- whether upstream ships the thing as a separable unit. libdrm PASSES that
-- test — it is an independent freedesktop project with its own releases, and
-- Conan carries it as a real recipe rather than a `system` virtual package.
-- So a source build would be legitimate here, unlike compat.libgbm where the
-- library is a target inside Mesa.
--
-- It is nevertheless a BINDING, for the second criterion rather than the
-- first: `xim:libdrm` already exists, mesa depends on it, and it is already
-- installed in any subos that has a graphics stack. Building a second copy
-- would put two `libdrm.so.2` in reach of one process — and this is the one
-- library where that matters most, because Mesa's own payload
-- (`libgbm.so.1`, `libgallium`, the Vulkan ICDs) has DT_NEEDED on the
-- ecosystem's copy. A consumer linking ours while Mesa loads the ecosystem's
-- would get two DRM handle tables in one address space.
--
-- Measured surface, the same four axes compat.libgbm reports:
--
--     host          0   no /usr/lib* path, no escape-hatch variable
--     ecosystem     1   `xim:libdrm` — not `xim:mesa`, which would drag the
--                       whole GL stack in for a consumer that only wants ioctls
--     index         0   `deps = {}`
--     transitive    0   libdrm.so.2 needs only libc/libm, both from the payload
--
-- ─────────────────────────────────────────────────────────────────────────
-- TWO INCLUDE ROOTS, AND THIS IS THE ONE THING THAT BITES
--
-- libdrm installs its public headers at the include ROOT (`xf86drm.h`,
-- `xf86drmMode.h`, `libsync.h`) but the uapi headers they include in a
-- `libdrm/` SUBDIRECTORY (`drm.h`, `drm_mode.h`, `drm_fourcc.h`, …). And
-- `xf86drm.h` line 40 is a bare `#include <drm.h>`.
--
-- So one include root is not enough. Measured while writing compat.libgbm's
-- test, which tried exactly that:
--
--     xf86drm.h:40:10: fatal error: drm.h: No such file or directory
--
-- Upstream's own `libdrm.pc` says `Cflags: -I${includedir}/libdrm`, and the
-- root is on the path by default, so a pkg-config consumer gets both. This
-- package therefore exposes BOTH directories — the root for `<xf86drm.h>`
-- and `libdrm/` for the `<drm.h>` it pulls in.
--
-- The vendor libraries (`libdrm_amdgpu`, `libdrm_intel`, `libdrm_nouveau`,
-- `libdrm_radeon`) are deliberately NOT harvested. They are separate `-l`
-- names with their own headers, only meaningful to code targeting one GPU
-- family, and nothing in the generic KMS path touches them. Adding them would
-- put four more sonames on every consumer's link line for no one's benefit.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libdrm",
    description = "libdrm — userspace DRM/KMS ioctl wrapper, bound to the ecosystem's xim:libdrm",
    licenses    = {"MIT"},
    repo        = "https://gitlab.freedesktop.org/mesa/drm",
    type        = "package",

    xpm = {
        linux = {
            -- PLATFORM level, beside the version entries rather than inside
            -- one: compat.glx-runtime established that a per-version `deps`
            -- parses fine and never installs.
            deps = { runtime = { "xim:libdrm" } },
            ["2026.08.30"] = {
                -- Inert anchor. Nothing downloaded here is read — the payload
                -- is what install() links out of the subos view. The xpm schema
                -- wants a url + sha256 per version, and a README cannot be
                -- mistaken for a shipped header (compat.libgbm learned that one
                -- the hard way by anchoring on a `.h`).
                url = {
                    GLOBAL = "https://gitlab.freedesktop.org/mesa/drm/-/raw/libdrm-2.4.123/README.rst",
                    CN     = "https://gitcode.com/mcpp-res/libdrm/releases/download/2026.08.30/libdrm-2026.08.30.rst",
                },
                sha256 = "46183785b2f012d0773646d1974374cbfc754f043d1a423afb0ffea0af2569c1",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",

        -- Both roots, for the reason in the header comment: `<xf86drm.h>` from
        -- the first, the `<drm.h>` it includes from the second.
        include_dirs = {
            "mcpp_generated/libdrm/include",
            "mcpp_generated/libdrm/include/libdrm",
        },

        generated_files = {
            ["mcpp_generated/libdrm_anchor.c"] =
                "int mcpp_compat_libdrm_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/libdrm_anchor.c" },

        -- NOT named `drm`: a target called `drm` would put a `libdrm.a` on the
        -- link line beside the real `libdrm.so`, and which one `-ldrm` picks
        -- would come down to search order. Same rule as compat.libgbm's
        -- `gbm_binding`.
        targets = { ["drm_binding"] = { kind = "lib" } },

        ldflags = { "-ldrm" },
        deps    = {},

        runtime = {
            -- Two keys, two flags, not interchangeable: `library_dirs` renders
            -- as `-Wl,-rpath` and `link_library_dirs` as `-L`. A package that
            -- is LINKED against needs both — with only the first, the farm is
            -- complete, the rpath correct, and the build dies at
            -- `ld: cannot find -ldrm`. (compat.glx-runtime and
            -- compat.vulkan-runtime declare only `library_dirs` because
            -- nothing links against their farms.)
            library_dirs      = { "mcpp_generated/libdrm/lib" },
            link_library_dirs = { "mcpp_generated/libdrm/lib" },
            provides          = { "drm.libdrm" },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.log")

-- install() is a blind spot by default: log.error does not reach the CI log
-- and a call outside the sandbox's xmake-API subset kills the hook silently.
-- So the log comes first and every step announces itself. validate.yml's
-- failure step collects `mcpp_*_build.log`, which is what this name matches.
local log_path = nil

local function say(msg)
    if log_path == nil then return end
    local prev = io.readfile(log_path) or ""
    io.writefile(log_path, prev .. msg .. "\n")
end

local function fail(msg)
    say("FAILED: " .. msg)
    log.error("[libdrm] %s", msg)
    return false
end

local function sh_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function link_matching(srcdir, pattern, outdir)
    os.exec(
        "for f in " .. sh_quote(srcdir) .. "/" .. pattern ..
        "; do [ -e \"$f\" ] || continue; " ..
        "ln -sf \"$f\" " .. sh_quote(outdir) .. "/\"$(basename \"$f\")\"; " ..
        "done"
    )
end

function install()
    local prefix = pkginfo.install_dir()
    os.mkdir(prefix)

    log_path = path.join(prefix, "mcpp_libdrm_build.log")
    io.writefile(log_path, "compat.libdrm install()\n")

    local view = system.subos_sysrootdir()
    say("subos view: " .. tostring(view))

    local view_lib = path.join(view, "lib")
    local view_inc = path.join(view, "usr", "include")

    local root     = path.join(prefix, "mcpp_generated", "libdrm")
    local out_lib  = path.join(root, "lib")
    local out_inc  = path.join(root, "include")
    local out_uapi = path.join(out_inc, "libdrm")

    os.mkdir(out_lib)
    os.mkdir(out_inc)
    os.mkdir(out_uapi)

    -- 1. The library. From the subos view and nowhere else. `libdrm.so*` only:
    --    the vendor variants are separate sonames nobody on the generic KMS
    --    path links, and the glob is anchored so `libdrm_amdgpu.so` cannot
    --    match it.
    say("linking libdrm.so* from " .. view_lib)
    link_matching(view_lib, "libdrm.so*", out_lib)

    for _, required in ipairs({"libdrm.so", "libdrm.so.2"}) do
        if not os.isfile(path.join(out_lib, required)) then
            return fail(required .. " is not in this subos. libdrm comes from "
                        .. "`xim:libdrm`, which this package declares as a "
                        .. "runtime dependency; if it is declared and this "
                        .. "still fires, that install did not finish")
        end
    end
    say("libdrm.so and libdrm.so.2 present")

    -- The glob cannot match a C runtime, but compat.glx-runtime's rule is to
    -- ASSERT rather than trust: a stray libc here faults inside the dynamic
    -- linker before main with no output at all.
    for _, bad in ipairs({"libc.so.6", "libm.so.6", "ld-linux-x86-64.so.2"}) do
        if os.isfile(path.join(out_lib, bad)) then
            return fail(bad .. " was linked into the libdrm farm; it would "
                        .. "reach every consumer's RUNPATH and pair a second "
                        .. "libc with mcpp's loader")
        end
    end

    -- 2. The public headers, at the root where upstream installs them.
    say("linking public headers from " .. view_inc)
    for _, h in ipairs({"xf86drm.h", "xf86drmMode.h", "libsync.h"}) do
        link_matching(view_inc, h, out_inc)
    end
    if not os.isfile(path.join(out_inc, "xf86drm.h")) then
        return fail("xf86drm.h is not in this subos (expected "
                    .. path.join(view_inc, "xf86drm.h") .. ")")
    end

    -- 3. The uapi headers, in the `libdrm/` subdirectory the public ones
    --    include from. Without this, `<xf86drm.h>` parses down to line 40 and
    --    fails on `#include <drm.h>`.
    say("linking uapi headers from " .. path.join(view_inc, "libdrm"))
    link_matching(path.join(view_inc, "libdrm"), "*.h", out_uapi)
    if not os.isfile(path.join(out_uapi, "drm.h")) then
        return fail("libdrm/drm.h is not in this subos; <xf86drm.h> would fail "
                    .. "to parse at its own `#include <drm.h>`")
    end
    say("headers present")

    say("done")
    return true
end
