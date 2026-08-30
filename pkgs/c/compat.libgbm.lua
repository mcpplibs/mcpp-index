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
-- put libgbm on the other side of that line.
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
--    rebuild the frontend.
--
--    Contrast `compat.vulkan`, which DOES build the Khronos Vulkan-Loader from
--    source: Khronos releases the loader as a standalone project whose entire
--    purpose is to ship separately from any driver. Mesa releases no such
--    thing for GBM. Conan reaches the same conclusion by not carrying a gbm
--    recipe at all, while carrying `libdrm` and `libglvnd` as real ones.
--
-- 2. IN THIS ECOSYSTEM, MESA ALREADY HAS AN OWNER: `xim:mesa`. A source build
--    would make mcpp-index re-import libdrm + expat + xcb + a Mesa-util
--    carve-out to duplicate a dependency graph the ecosystem has already
--    resolved hermetically, and would put a second `libgbm.so.1` in processes
--    that already have one.
--
-- The measured surface of the binding:
--
--     host          0   no /usr/lib* path, and no escape-hatch variable
--     ecosystem     1   `xim:mesa`, not `xim:graphics`'s twenty-two
--     index         0   `deps = {}`; gbm.h includes only <stddef.h>/<stdint.h>
--     transitive    0   libgbm.so.1's own RUNPATH resolves entirely inside
--                       xim-x-{mesa,libdrm,expat,libllvm,glibc,…}
--
-- ─────────────────────────────────────────────────────────────────────────
-- ZERO HOST. NOT "HOST, CONVERGED" — ZERO.
--
-- This package looks at `system.subos_sysrootdir()` and nowhere else. No
-- `/usr/lib*` candidate directory and, deliberately, NO escape-hatch
-- environment variable — a stricter rule than either neighbour, since
-- `compat.glx-runtime` keeps `MCPP_HOST_GL_LIBRARY_PATH` and
-- `compat.vulkan-runtime` harvests /usr/lib/x86_64-linux-gnu outright.
--
-- Those two have a reason this one does not: a PROPRIETARY VENDOR DRIVER can
-- only come from the host. GBM has no such case — `xim:mesa` covers every host
-- shape the graphics stack covers. And host libgbm is a leak this ecosystem
-- has already CLOSED; `xim:nvidia-gl-host-link` records it by name:
--
--     "The table … was missing libm, libdrm, libgbm, libgcc_s and
--      libwayland-* -- all of which were therefore coming from the HOST,
--      silently, which is the leak this package exists to close (R7)."
--
-- If a machine ever needs NVIDIA's own GBM backend, that belongs in
-- `xim:nvidia-gl-host-link`, the layer that owns host contact.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHAT THIS PACKAGE DOES NOT DO: THE BACKEND PATH
--
-- Worth stating, because this package used to do it and no longer needs to.
--
-- libgbm is a LOADER: `gbm_create_device()` dlopens `<path>/<driver>_gbm.so`,
-- where <path> comes from `GBM_BACKENDS_PATH` or, failing that, the
-- `DEFAULT_BACKENDS_PATH` compiled into the library. Mesa is built
-- `--prefix=/usr`, so that compiled-in path is `/usr/lib/gbm` — correct on a
-- distro, where the backends really are there, and wrong the moment the
-- payload is relocated:
--
--     MESA-LOADER: failed to open dri: /usr/lib/gbm/dri_gbm.so: cannot open
--     shared object file (search paths /usr/lib/gbm, suffix _gbm)
--
-- The mechanism to fix that is MESA'S OWN and needs nothing invented here: set
-- `GBM_BACKENDS_PATH`. Every relocated stack does exactly that — Valve's
-- pressure-vessel answers the identical breakage with
-- GBM_BACKENDS_PATH=/run/host/usr/lib64/gbm (steam-runtime#797), and Nix and
-- Conda set it at environment-activation time.
--
-- In this ecosystem that job belongs to the environment too, and now holds it:
-- `xim:mesa` places its backends into the subos and declares the variable
-- through the graphics discovery layer (openxlings/xim-pkgindex#713), so every
-- consumer inherits it. So this package sets nothing, generates no TU, ships
-- no header of its own, and exposes stock `gbm.h` — which is what a libgbm
-- package should look like.
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
            -- dependency simply never installed, and the error names the
            -- missing library rather than the misplaced key.
            --
            -- `xim:mesa` and not `xim:graphics`: this package needs Mesa, not
            -- the GL dispatch and X11 halves of the twenty-two-package stack.
            --
            -- PINNED, and the pin is what makes the version below honest: GBM
            -- has no release of its own, so this package's version can only
            -- mean "the GBM in Mesa 25.0.7". With a floating `xim:mesa` that
            -- claim would quietly stop being true the day the payload moved.
            deps = { runtime = { "xim:mesa@25.0.7.2" } },
            -- Mesa's version, verbatim — no binding-revision suffix is needed
            -- here. compat.libdrm and compat.wayland carry one because their
            -- short name equals their payload's and the store's installed-check
            -- ignores namespaces; `libgbm` != `mesa`, so there is nothing to
            -- collide with. See compat.libdrm for the measured failure.
            ["25.0.7"] = {
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
                -- It was briefly Mesa's own `src/gbm/main/gbm.h`, and that was
                -- a mistake: an anchor NAMED like the header this package
                -- installs reads as though the download is the shipped header,
                -- which is the one thing it is not. A README cannot be
                -- mistaken for a payload.
                --
                -- A raw file at a tag is byte-stable, unlike a GitLab-generated
                -- archive; sha256 confirmed twice, and the CN asset re-fetched
                -- and compared byte-for-byte against GLOBAL.
                url = {
                    GLOBAL = "https://gitlab.freedesktop.org/mesa/mesa/-/raw/mesa-25.0.7/README.rst",
                    CN     = "https://gitcode.com/mcpp-res/libgbm/releases/download/25.0.7/libgbm-25.0.7.rst",
                },
                sha256 = "03f0fd62094179bb70fb885042baa4254d392f5f7bb64e4d8856bec8a5ff8386",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",

        -- Built by install(): `gbm.h` symlinked out of the subos view, so the
        -- header and the library can never come from different Mesa builds.
        include_dirs = { "mcpp_generated/libgbm/include" },

        -- An anchor so the lib target has something to compile, the
        -- compat.glx-runtime / compat.glx-headers shape. This package has no
        -- code of its own.
        generated_files = {
            ["mcpp_generated/libgbm_anchor.c"] =
                "int mcpp_compat_libgbm_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/libgbm_anchor.c" },

        -- NOT named `gbm`. A target called `gbm` would put a `libgbm.a` on the
        -- link line beside the real `libgbm.so` this package exists to
        -- deliver, and which of the two `-lgbm` picks would come down to
        -- search order.
        targets = { ["gbm_binding"] = { kind = "lib" } },

        -- The link against Mesa's libgbm itself, resolved through the farm.
        ldflags = { "-lgbm" },

        -- Zero. gbm.h includes only <stddef.h> and <stdint.h>.
        deps = {},

        runtime = {
            -- TWO DIRECTORY KEYS, TWO DIFFERENT FLAGS, and they are not
            -- interchangeable. Measured on mcpp 2026.8.27.2 by reading the
            -- emitted build.ninja:
            --
            --     library_dirs      -> -Wl,-rpath   (RUNPATH only)
            --     link_library_dirs -> -L
            --
            -- `library_dirs` ALONE is what compat.glx-runtime and
            -- compat.vulkan-runtime declare, and it is right for them: nothing
            -- links against their farms, they exist so a bare-soname `dlopen`
            -- resolves at RUN time. This package does link against its farm,
            -- so it needs the `-L` too — with only `library_dirs` the farm is
            -- complete, the rpath correct, and the build still dies at
            -- `ld: cannot find -lgbm`.
            library_dirs      = { "mcpp_generated/libgbm/lib" },
            link_library_dirs = { "mcpp_generated/libgbm/lib" },
            provides          = { "drm.gbm" },
            -- No `capabilities` entry. compat.glx-runtime declares
            -- "x11.display" because it needs the sandbox to expose a socket it
            -- does not own; there is no verified DRM counterpart in the
            -- engine's vocabulary, and coining one that may be silently
            -- ignored would document a guarantee this package cannot make.
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.log")

-- The install() hook is a blind spot by default: log.error does not reach the
-- CI log, and a call outside the sandbox's xmake-API subset terminates the
-- hook with no message at all. So the log file comes first and every step
-- announces itself before doing anything. validate.yml's failure step collects
-- `mcpp_*_build.log`, which is what this name matches.
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

function install()
    local prefix = pkginfo.install_dir()
    os.mkdir(prefix)

    log_path = path.join(prefix, "mcpp_libgbm_build.log")
    io.writefile(log_path, "compat.libgbm install()\n")

    local view = system.subos_sysrootdir()
    say("subos view: " .. tostring(view))

    local view_lib = path.join(view, "lib")
    local view_inc = path.join(view, "usr", "include")

    local root    = path.join(prefix, "mcpp_generated", "libgbm")
    local out_lib = path.join(root, "lib")
    local out_inc = path.join(root, "include")

    os.mkdir(out_lib)
    os.mkdir(out_inc)

    -- 1. The library. From the subos view and from nowhere else — see the
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

    -- No step 3. The backend search path is the ENVIRONMENT's job and
    -- `xim:mesa` now does it (openxlings/xim-pkgindex#713) — see the header
    -- comment. This package deliberately owns no part of it.
    say("done")
    return true
end
