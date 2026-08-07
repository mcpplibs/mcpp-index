package = {
    spec        = "1",
    namespace   = "compat",
    name        = "glx-runtime",
    description = "GLVND/GLX/OpenGL runtime for mcpp Linux window applications, from the xlings graphics stack",
    licenses    = {"MIT"},
    repo        = "https://github.com/KhronosGroup/OpenGL-Registry",
    type        = "package",

    -- WHERE THE GL RUNTIME COMES FROM, AND WHY IT CHANGED
    --
    -- Until 2026.08.08 this package symlinked the HOST's libGL/libEGL out of
    -- /usr/lib*. That is the thing mcpp#352 is: the host's Mesa needs
    -- GLIBC_2.43 and mcpp's payload glibc is 2.39, so the program linked
    -- cleanly and exited 255 with no output. It is also the boundary the
    -- xlings hermetic policy names first -- any .so under /usr/lib* or /lib*.
    --
    -- The runtime now comes from `xim:graphics`, the ecosystem's own stack:
    -- 22 packages plus two sentinels that probe for a host-side userspace half
    -- they do not own (the proprietary NVIDIA driver, WSL2's D3D12) and
    -- succeed having linked nothing when it is absent. One dependency, every
    -- host shape, no conditional in this file.
    --
    -- Measured on an NVIDIA host after the change: libEGL resolves to
    -- xim-x-libglvnd/1.7.0/lib/libEGL.so.1 and GL_RENDERER is the GPU, not
    -- llvmpipe. Both halves of that matter -- "a window appeared" is a false
    -- pass, because llvmpipe renders one too.
    xpm = {
        linux = {
            -- The whole hermetic graphics stack. A RUNTIME dep, not a build
            -- one: nothing here compiles against it, the produced consumer
            -- loads it.
            --
            -- PLATFORM level, beside the version entries rather than inside
            -- one. Every other recipe in both indexes places it here, and the
            -- first attempt at this change put it inside the 2026.08.08 entry:
            -- the descriptor parsed, the stack was never installed, and the
            -- install failed on the required-library check -- an error naming
            -- libGL.so.1 rather than the misplaced key. Whether a per-version
            -- `deps` is rejected or merely unread was not determined; what is
            -- established is that it does not take effect.
            --
            -- It therefore also applies to the legacy 2026.06.03 entry below,
            -- which does not use it. That costs a consumer still pinned there
            -- a download it will not read, and the alternative -- deleting the
            -- published version -- would break them outright.
            deps = { runtime = { "xim:graphics" } },
            ["2026.08.08"] = {
                url    = {
                    GLOBAL = "https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/a30033d3e812c9bf10094f1010374a6b15e192eb/README.adoc",
                    CN     = "https://gitcode.com/mcpp-res/glx-runtime/releases/download/2026.08.08/glx-runtime-2026.08.08.adoc",
                },
                sha256 = "ea68efce197e68413ebb62c51ab4bccfb2309a2fca776d31b49d972f59f3640e",
            },
            -- Kept so already-published consumers pinned to it keep resolving.
            -- It sources libGL from the HOST and is the configuration behind
            -- mcpp#352; new consumers must not pin it.
            ["2026.06.03"] = {
                url    = {
                    GLOBAL = "https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/a30033d3e812c9bf10094f1010374a6b15e192eb/README.adoc",
                    CN     = "https://gitcode.com/mcpp-res/glx-runtime/releases/download/2026.06.03/glx-runtime-2026.06.03.adoc",
                },
                sha256 = "ea68efce197e68413ebb62c51ab4bccfb2309a2fca776d31b49d972f59f3640e",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        generated_files = {
            ["mcpp_generated/glx_runtime_empty.c"] = "int mcpp_compat_glx_runtime_anchor(void) { return 0; }\n",
        },
        sources = {"mcpp_generated/glx_runtime_empty.c"},
        targets = { ["glx_runtime"] = { kind = "lib" } },
        runtime = {
            library_dirs = { "mcpp_generated/glx_runtime/lib" },
            dlopen_libs = { "libGLX.so.0", "libGL.so.1", "libGL.so" },
            capabilities = { "x11.display", "opengl.glx.driver" },
            provides = { "opengl.glx.driver", "x11.display" },
        },
        deps = {
            ["compat.xext"] = "1.3.7",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.log")

local function sh_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function split_paths(value)
    local out = {}
    if not value or value == "" then
        return out
    end
    for item in tostring(value):gmatch("[^:]+") do
        if item ~= "" then
            table.insert(out, item)
        end
    end
    return out
end

-- Where to take the GL libraries from.
--
-- The SUBOS VIEW (`<subos>/lib`), not a payload directory. A payload path pins
-- a version, so a consumer's recorded RUNPATH would name mesa 25.0.7.1 forever
-- and stop resolving the day it is upgraded; the view is the stable
-- indirection -- the role /run/opengl-driver plays on NixOS. xlings repoints
-- it as the active version changes and this package needs no new release.
--
-- The view also carries libc.so.6, crt1.o and the rest of the C runtime, and
-- those must NEVER reach a consumer's RUNPATH: the consumer runs under mcpp's
-- payload loader, and pairing one loader with another glibc's libc.so.6 faults
-- inside the dynamic linker before main, with empty output. What keeps them
-- out is the pattern list below -- so that list is a safety boundary, not a
-- convenience, and nothing resembling `libc*` may ever be added to it.
--
-- MCPP_HOST_GL_LIBRARY_PATH still works and is now the ONLY door back to the
-- host. Using it leaves the hermetic guarantee: the libraries it names were
-- built against the host's glibc, and loading them under mcpp's payload glibc
-- is exactly the configuration mcpp#352 reports. It exists for a machine whose
-- GPU vendor the ecosystem does not cover yet.
local function candidate_dirs()
    local out = {}
    local seen = {}
    local function add(dir)
        if dir and dir ~= "" and not seen[dir] and os.isdir(dir) then
            seen[dir] = true
            table.insert(out, dir)
        end
    end

    for _, dir in ipairs(split_paths(os.getenv("MCPP_HOST_GL_LIBRARY_PATH"))) do
        log.warn("MCPP_HOST_GL_LIBRARY_PATH names %s: GL will come from the "
                 .. "host, which is the configuration behind mcpp#352", dir)
        add(dir)
    end

    add(path.join(system.subos_sysrootdir(), "lib"))
    return out
end

local host_gl_patterns = {
    "libGL.so*",
    "libGLX.so*",
    "libGLX_*.so*",
    "libGLdispatch.so*",
    "libOpenGL.so*",
    "libEGL.so*",
    "libEGL_*.so*",
    "libGLES*.so*",
    -- No libnvidia* here. The proprietary driver reaches the subos through
    -- xim:nvidia-gl-host-link, which links it under the glvnd vendor names
    -- already matched above; taking it by its own name would be a second
    -- route to the same libraries, and the two would disagree the day the
    -- driver is upgraded under us.
    "libglapi.so*",
    "libdrm*.so*",
    "libexpat.so*",
    "libxshmfence.so*",
    "libbsd.so*",
    "libmd.so*",
}

local required = {
    ["libGLX.so.0"] = false,
    ["libGL.so.1"] = false,
}

local function link_runtime_libs(outdir)
    os.mkdir(outdir)
    for _, dir in ipairs(candidate_dirs()) do
        for _, pattern in ipairs(host_gl_patterns) do
            os.exec(
                "for lib in " .. sh_quote(dir) .. "/" .. pattern ..
                "; do [ -e \"$lib\" ] || continue; " ..
                "ln -sf \"$lib\" " .. sh_quote(outdir) .. "/\"$(basename \"$lib\")\"; " ..
                "done"
            )
        end
    end

    for name, _ in pairs(required) do
        if not os.isfile(path.join(outdir, name)) then
            log.error("%s is not in this subos. The GL runtime comes from "
                      .. "`xim:graphics`; if it is declared and this still "
                      .. "fires, the stack did not finish installing", name)
            return false
        end
    end

    -- Nothing resembling a C runtime may have come along. Asserted rather
    -- than trusted: the pattern list is what keeps it out, and a pattern is
    -- one careless edit away from matching more than it meant to. The failure
    -- it prevents has no diagnostic of its own -- the consumer dies inside
    -- the dynamic linker before main, printing nothing.
    for _, bad in ipairs({"libc.so.6", "libc.so", "ld-linux-x86-64.so.2",
                          "libpthread.so.0", "libdl.so.2", "libm.so.6"}) do
        if os.isfile(path.join(outdir, bad)) then
            log.error("%s was linked into the GL runtime directory. It would "
                      .. "land on every consumer's RUNPATH and pair a second "
                      .. "libc with mcpp's loader, which faults before main "
                      .. "with no output at all", bad)
            return false
        end
    end
    return true
end

function install()
    os.tryrm(pkginfo.install_dir())
    os.mkdir(pkginfo.install_dir())

    local generated = path.join(pkginfo.install_dir(), "mcpp_generated")
    os.mkdir(generated)
    io.writefile(path.join(generated, "glx_runtime_empty.c"),
        "int mcpp_compat_glx_runtime_anchor(void) { return 0; }\n")

    return link_runtime_libs(path.join(generated, "glx_runtime", "lib"))
end
