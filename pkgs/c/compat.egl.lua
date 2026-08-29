-- compat.egl — EGL 1.5, the window-system binding layer: `eglGetPlatformDisplay`,
-- `eglCreateContext`, `eglCreateWindowSurface`, `eglMakeCurrent`, and the
-- `eglCreateImage` / dmabuf import path.
--
-- It is the piece that makes compat.libgbm useful for RENDERING rather than
-- only for allocation. The canonical headless-GPU sequence is
--
--     int fd = open("/dev/dri/renderD128", O_RDWR);
--     struct gbm_device *gbm = gbm_create_device(fd);           // compat.libgbm
--     EGLDisplay dpy = eglGetPlatformDisplay(EGL_PLATFORM_GBM_KHR, gbm, NULL);
--
-- and without EGL the first two lines have nowhere to go. Together with
-- compat.libdrm (which turns the resulting buffer into a scanout via
-- `drmModeAddFB2`) these three are the whole KMS/DRM stack.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SHAPE: a binding, and the provider is libglvnd rather than Mesa
--
-- EGL is a Khronos SPECIFICATION; the thing you link is a vendor-neutral
-- dispatch library, and on Linux that is libglvnd's `libEGL.so.1`, which
-- dlopens the actual vendor implementation. `xim:libglvnd` already ships it —
-- and it MUST be the only one in the process, because glvnd's whole job is to
-- be the single dispatch point. Building a second `libEGL.so.1` here would be
-- the `compat.vulkan-runtime` mistake ("one loader per process is the whole
-- point") applied to EGL.
--
-- Measured surface:
--
--     host          0   no /usr/lib* path, no escape-hatch variable
--     ecosystem     1   `xim:libglvnd`
--     index         1   `compat.khrplatform` — see below, it is not optional
--     transitive    0   libEGL.so.1 resolves inside xim-x-{libglvnd,glibc}
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHAT IS DELIBERATELY NOT SHIPPED
--
-- libglvnd's include tree carries `EGL/`, `GL/`, `GLES2/`, `GLES3/`, `KHR/`
-- and `glvnd/`. This package exposes ONLY `EGL/`.
--
-- `GL/` is the reason. `compat.opengl` and `compat.glx-headers` already
-- provide it, and compat.glx-headers' own comment records the consequence of
-- two providers: "Depend on ONE of the two, not both, or the winner depends on
-- include-dir order." Shipping a third `GL/` would make that a three-way race
-- for every consumer that wants EGL and GL together — which is most of them.
--
-- `KHR/` is left out for the same reason and solved properly instead:
-- `EGL/eglplatform.h` opens with `#include <KHR/khrplatform.h>`, so the header
-- genuinely needs it, and `compat.khrplatform` is the index's existing
-- provider (from the Khronos EGL-Registry, the same upstream). Hence the one
-- index dependency, and it is load-bearing rather than decorative: without it
-- `#include <EGL/egl.h>` does not parse.
--
-- X11 IS NOT A DEPENDENCY, and that is worth stating because it usually is.
-- `eglplatform.h` reaches for `<X11/Xlib.h>` only under `#elif defined(USE_X11)`
-- (line 106 of the shipped header), so the default path needs nothing from
-- Xorg. A consumer that defines `USE_X11` must add `compat.x11` and
-- `compat.xorgproto` itself — this package cannot know, and forcing the X11
-- stack on every EGL user (including the GBM/headless ones, who have no
-- display at all) would be exactly wrong.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "egl",
    description = "EGL 1.5 window-system binding (libglvnd dispatch), bound to the ecosystem's xim:libglvnd",
    licenses    = {"MIT"},
    repo        = "https://github.com/NVIDIA/libglvnd",
    type        = "package",

    xpm = {
        linux = {
            deps = { runtime = { "xim:libglvnd" } },
            ["2026.08.30"] = {
                -- Inert anchor; nothing downloaded is read. See
                -- compat.libgbm for why this is a README and not a header.
                url = {
                    GLOBAL = "https://raw.githubusercontent.com/NVIDIA/libglvnd/v1.7.0/README.md",
                    CN     = "https://gitcode.com/mcpp-res/egl/releases/download/2026.08.30/egl-2026.08.30.md",
                },
                sha256 = "f84a3eca98cc5bdf5318741124c38c5e877f856df8c7e229ee5065e5c61038c2",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",

        include_dirs = { "mcpp_generated/egl/include" },

        generated_files = {
            ["mcpp_generated/egl_anchor.c"] =
                "int mcpp_compat_egl_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/egl_anchor.c" },

        -- NOT named `egl`: a target called `egl` would put a `libegl.a` beside
        -- the real `libEGL.so` and let search order decide. Same rule as
        -- compat.libgbm's `gbm_binding`.
        targets = { ["egl_binding"] = { kind = "lib" } },

        ldflags = { "-lEGL" },

        -- Load-bearing: EGL/eglplatform.h includes <KHR/khrplatform.h>.
        deps = {
            ["compat.khrplatform"] = "2026.05.31",
        },

        runtime = {
            -- Both keys: `library_dirs` renders as -Wl,-rpath and
            -- `link_library_dirs` as -L, and this package IS linked against.
            library_dirs      = { "mcpp_generated/egl/lib" },
            link_library_dirs = { "mcpp_generated/egl/lib" },
            provides          = { "egl.dispatch" },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.log")

local log_path = nil

local function say(msg)
    if log_path == nil then return end
    local prev = io.readfile(log_path) or ""
    io.writefile(log_path, prev .. msg .. "\n")
end

local function fail(msg)
    say("FAILED: " .. msg)
    log.error("[egl] %s", msg)
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

    log_path = path.join(prefix, "mcpp_egl_build.log")
    io.writefile(log_path, "compat.egl install()\n")

    local view = system.subos_sysrootdir()
    say("subos view: " .. tostring(view))

    local view_lib = path.join(view, "lib")
    local view_inc = path.join(view, "usr", "include")

    local root    = path.join(prefix, "mcpp_generated", "egl")
    local out_lib = path.join(root, "lib")
    local out_inc = path.join(root, "include")
    local out_egl = path.join(out_inc, "EGL")

    os.mkdir(out_lib)
    os.mkdir(out_inc)
    os.mkdir(out_egl)

    -- 1. The dispatch library, from the subos view and nowhere else.
    say("linking libEGL.so* from " .. view_lib)
    link_matching(view_lib, "libEGL.so*", out_lib)

    for _, required in ipairs({"libEGL.so", "libEGL.so.1"}) do
        if not os.isfile(path.join(out_lib, required)) then
            return fail(required .. " is not in this subos. libEGL comes from "
                        .. "`xim:libglvnd`, which this package declares as a "
                        .. "runtime dependency; if it is declared and this "
                        .. "still fires, that install did not finish")
        end
    end
    say("libEGL.so and libEGL.so.1 present")

    for _, bad in ipairs({"libc.so.6", "libm.so.6", "ld-linux-x86-64.so.2"}) do
        if os.isfile(path.join(out_lib, bad)) then
            return fail(bad .. " was linked into the EGL farm; it would reach "
                        .. "every consumer's RUNPATH and pair a second libc "
                        .. "with mcpp's loader")
        end
    end

    -- 2. ONLY the EGL headers. GL/, GLES2/, GLES3/ and KHR/ stay behind — see
    --    the header comment for why a second provider of any of them is a bug
    --    rather than a convenience.
    say("linking EGL/*.h from " .. path.join(view_inc, "EGL"))
    link_matching(path.join(view_inc, "EGL"), "*.h", out_egl)
    if not os.isfile(path.join(out_egl, "egl.h")) then
        return fail("EGL/egl.h is not in this subos (expected "
                    .. path.join(view_inc, "EGL", "egl.h") .. ")")
    end
    say("EGL headers present")

    say("done")
    return true
end
