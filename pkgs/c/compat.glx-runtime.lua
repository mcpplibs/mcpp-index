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
            -- 2026.09.10: the farm answers for what its own members need.
            -- Nothing new is taken from the host: a soname a member needs is
            -- filled from an installed payload, and otherwise recorded as a
            -- dangling link. A new key because install() output is baked into
            -- the installed payload -- without one, a host that already holds
            -- 2026.08.08 keeps a farm 30 sonames short of closed.
            --
            -- The anchor is 2026.08.08's, deliberately: the URL is a
            -- well-formedness anchor and nothing more, and reusing it means no
            -- new mirror asset has to exist for a key that changes only
            -- install() behaviour.
            -- 2026.09.11: install() changed again after 2026.09.10 was
            -- published -- an absolute `DT_NEEDED` is no longer treated as a
            -- soname, and a missing `readelf` now says so instead of reading
            -- as "no gaps". Behaviour baked into an installed payload needs a
            -- key of its own, including when the previous key is hours old.
            ["2026.09.11"] = {
                url    = {
                    GLOBAL = "https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/a30033d3e812c9bf10094f1010374a6b15e192eb/README.adoc",
                    CN     = "https://gitcode.com/mcpp-res/glx-runtime/releases/download/2026.08.08/glx-runtime-2026.08.08.adoc",
                },
                sha256 = "ea68efce197e68413ebb62c51ab4bccfb2309a2fca776d31b49d972f59f3640e",
            },
            ["2026.09.10"] = {
                url    = {
                    GLOBAL = "https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/a30033d3e812c9bf10094f1010374a6b15e192eb/README.adoc",
                    CN     = "https://gitcode.com/mcpp-res/glx-runtime/releases/download/2026.08.08/glx-runtime-2026.08.08.adoc",
                },
                sha256 = "ea68efce197e68413ebb62c51ab4bccfb2309a2fca776d31b49d972f59f3640e",
            },
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

-- WHAT THE FARM'S OWN MEMBERS NEED, AND WHY NOTHING NEW COMES FROM THE HOST.
--
-- The pattern list above decides membership; nothing decided completeness.
-- Measured 2026-09-10 on a host with the proprietary driver: 52 members, and
-- 30 sonames those members need that this directory does not carry --
-- `libX11.so.6`, `libxcb*.so.*`, `libz.so.1`, `libLLVM.so.20.1`,
-- `libnvidia-glcore.so.*` and `libstdc++.so.6` among them. A consumer reaching
-- any of those members through this farm gets a load failure that no closure
-- check can see, because no link edge names it.
--
-- THE HOST SURFACE IS HELD AT WHAT THE PATTERN LIST ALREADY TAKES. Two of the
-- thirty say why: `libstdc++.so.6`, and behind it a host C++ runtime on the
-- RUNPATH of every GL consumer this index has. mcpp links libstdc++ statically,
-- and a second one arriving through a farm is the failure class the libc guard
-- below already exists for. So the rule is:
--
--   * an installed payload provides it  -> link the payload's copy
--   * nothing does                      -> named in UNSERVED with the reason,
--                                          and linked into a directory this
--                                          package never creates
--   * anything else                     -> a warning naming it
--
-- and there is no branch at all that harvests a file from /usr/lib. Measured
-- 2026-09-10 on a host with the proprietary driver: ALL THIRTY come from
-- installed payloads. The four `libnvidia-*` ones come from
-- `xim:nvidia-gl-host-link`, which is where this file already says the driver
-- reaches the subos from; the other twenty-six come from the stack
-- `xim:graphics` pulls in -- `xim:libX11`, `xim:libxcb`, `xim:mesa`,
-- `xim:libllvm`, `xim:gcc-runtime` and the rest. The host surface of this farm
-- is therefore exactly what the pattern list takes, and nothing more.
--
-- The dangling branch is not a workaround. mcpp reads this directory with a
-- three-state rule -- resolved, present-but-dangling (this machine has no such
-- library), absent everywhere (the publisher never carried it) -- and DANGLING
-- IS ONLY EXPRESSIBLE IF THIS PACKAGE MADE A LINK. Leaving the soname out
-- reports "the publisher never considered it" on every machine, including the
-- ones where the truth is "this host has no X11". The link is also
-- self-healing, the shape `xim:libcuda-host-link` already uses: it resolves the
-- moment the machine gains the library.
local never_farm = {
    ["libc.so.6"] = true, ["libm.so.6"] = true, ["libdl.so.2"] = true,
    ["libpthread.so.0"] = true, ["librt.so.1"] = true, ["libresolv.so.2"] = true,
    ["ld-linux-x86-64.so.2"] = true, ["ld-linux-aarch64.so.1"] = true,
    ["libgcc_s.so.1"] = true,
}

local function xim_store_roots()
    local roots = {}
    local home = os.getenv("XLINGS_HOME")
    if home and home ~= "" then roots[#roots + 1] = path.join(home, "data/xpkgs") end
    local pfx = pkginfo.install_dir()
    if pfx then roots[#roots + 1] = path.directory(path.directory(pfx)) end
    return roots
end

-- Every copy, not the last one sorted: a driver payload can ship its own copy
-- of a library another package owns. compat.vulkan-runtime carries the
-- measurement behind this.
local function find_in_store(soname)
    local out, seen = {}, {}
    for _, root in ipairs(xim_store_roots()) do
        local f = io.popen(string.format(
            [[ls -1 "%s"/xim-x-*/*/lib/%s "%s"/xim-x-*/*/lib64/%s 2>/dev/null | sort -V]],
            root, soname, root, soname))
        if f then
            for line in f:lines() do
                local hit = line:gsub("[\r\n]+$", "")
                if hit ~= "" and not seen[hit] then
                    seen[hit] = true
                    out[#out + 1] = hit
                end
            end
            f:close()
        end
    end
    return out
end

-- WHAT A MEMBER NEEDS IS READ FROM THE MEMBER, NOT FROM A LOADER.
--
-- `ldd` answers "can this resolve HERE", and here includes the host's default
-- directories -- so a soname the host happens to carry reads as resolved and is
-- never recorded, while the consumer, whose search path is this farm and not
-- the host, cannot load it. `readelf -d` answers what the FILE says, and
-- membership is decided against this directory alone, which is the question
-- mcpp asks of it.
-- The store first, PATH second. Under xlings a payload's own binutils is the
-- one that matches the objects being read, and a host `readelf` may simply not
-- be installed -- this package runs on machines that were never asked to have a
-- toolchain. compat.opencl-runtime and compat.vulkan-runtime look the same way.
local function find_tool(name)
    for _, root in ipairs(xim_store_roots()) do
        local f = io.popen(string.format(
            [[ls -1 "%s"/xim-x-binutils/*/bin/%s "%s"/xim-x-gcc/*/bin/%s 2>/dev/null | sort -V | tail -1]],
            root, name, root, name))
        if f then
            local hit = (f:read("l") or ""):gsub("[\r\n]+$", "")
            f:close()
            if hit ~= "" then return hit end
        end
    end
    local f = io.popen(string.format([[command -v %s 2>/dev/null]], name))
    if f then
        local hit = (f:read("l") or ""):gsub("[\r\n]+$", "")
        f:close()
        if hit ~= "" then return hit end
    end
    return nil
end

local function unresolved_against_farm(outdir)
    local readelf = find_tool("readelf")
    -- A MISSING TOOL IS NOT AN EMPTY ANSWER.
    --
    -- Returning `{}` here would report "no member needs anything this farm
    -- lacks", which is the reading a fully closed farm produces -- so the one
    -- environment where this pass cannot run would be indistinguishable from
    -- the one where it ran and found nothing. That is the confusion this whole
    -- change exists to remove, one layer down, in the tool lookup.
    if not readelf then
        log.warn("compat.glx-runtime: readelf was not found, so the farm's own members were "
                 .. "not checked. This is NOT the same as finding no gaps: "
                 .. "install xim:binutils, or read HOST-SURFACE.txt with the "
                 .. "knowledge that it is incomplete.")
        return {}
    end
    local have, members = {}, {}
    local lsf = io.popen(string.format([[ls -1 "%s" 2>/dev/null]], outdir))
    if not lsf then return {} end
    for line in lsf:lines() do
        local b = line:gsub("[\r\n]+$", "")
        if b ~= "" then have[b] = true; members[#members + 1] = b end
    end
    lsf:close()
    local out, seen = {}, {}
    for _, base in ipairs(members) do
        local f = io.popen(string.format(
            [[%s -d %s 2>/dev/null | sed -n 's/.*(NEEDED).*\[\(.*\)\]/\1/p']],
            sh_quote(readelf), sh_quote(path.join(outdir, base))))
        if f then
            for line in f:lines() do
                local n = line:gsub("[\r\n]+$", "")
                -- AN ABSOLUTE `DT_NEEDED` NEVER GOES THROUGH A SEARCH PATH.
                --
                -- The loader opens it directly, so this farm can neither serve
                -- it nor honestly record it as unserved -- and treating it as a
                -- soname produces a lookup for a name with slashes in it and,
                -- worse, an `unserved` link whose name is a path. Measured on
                -- this farm: four members -- the glvnd vendor entries
                -- `libEGL_nvidia`, `libGLESv1_CM_nvidia`, `libGLESv2_nvidia`
                -- and `libGLX_nvidia` -- name `/lib/x86_64-linux-gnu/...`
                -- outright. They are a host reach that bypasses everything this
                -- package arranges, which is worth knowing and is not this
                -- pass's to answer.
                if n:sub(1, 1) == "/" then
                    goto continue
                end
                if n ~= "" and not have[n] and not never_farm[n] and not seen[n] then
                    seen[n] = true
                    out[#out + 1] = n
                end
                ::continue::
            end
            f:close()
        end
    end
    return out
end

-- Nothing is here today, and the table exists so that the day something is,
-- somebody has to write down why it cannot be a package. The warning below is
-- what makes leaving it blank impossible to do by accident.
local UNSERVED = {}

local function close_farm(outdir)
    local filled, unserved, undeclared = {}, {}, {}
    local unserved_dir = path.join(path.directory(outdir), "unserved")
    -- ITERATED TO A FIXED POINT, because `readelf -d` reports DIRECT
    -- dependencies only.
    --
    -- The pass this replaced asked `ldd`, whose answer is the whole transitive
    -- closure, so one round was enough and the comment said so. `readelf` is
    -- the right instrument -- it answers what the FILE says instead of what
    -- this machine can resolve -- but it is not transitive, and a library
    -- filled in one round brings needs of its own. Measured on the first real
    -- install of this package: the farm went from 52 members to 77 and was
    -- still nine sonames short, `libLLVM.so.20.1` and `libstdc++.so.6` among
    -- them, every one of them reachable from something the same round had just
    -- added.
    --
    -- The bound is not a guess about depth; it is there so a cycle cannot spin.
    -- A round that adds nothing ends the loop, which is the normal exit.
    local seen = {}
    for _ = 1, 16 do
    local added = 0
    for _, soname in ipairs(unresolved_against_farm(outdir)) do
        if seen[soname] then goto next end
        seen[soname] = true
        added = added + 1
        local candidates = find_in_store(soname)
        local hit = candidates[#candidates]
        if hit then
            os.exec(string.format([[ln -sf "%s" "%s"]], hit, path.join(outdir, soname)))
            filled[#filled + 1] = soname
        else
            -- Inside this package, not at the canonical host path: a link into
            -- /usr/lib resolves on any machine that happens to carry the file,
            -- which is a host harvest wearing a different name.
            os.exec(string.format([[ln -sf "%s" "%s"]],
                                  path.join(unserved_dir, soname),
                                  path.join(outdir, soname)))
            unserved[#unserved + 1] = soname
            if not UNSERVED[soname] then undeclared[#undeclared + 1] = soname end
        end
        ::next::
    end
    if added == 0 then break end
    end
    return filled, unserved, undeclared
end

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

    -- Completeness, before the guards. Neither branch puts a new host library
    -- on a consumer's path, so the guards below still see exactly what the
    -- pattern list matched.
    local filled, unserved, undeclared = close_farm(outdir)
    if #filled > 0 then
        log.info("compat.glx-runtime: %d libraries the farm's members need were "
                 .. "filled from installed payloads", #filled)
    end
    if #unserved > 0 then
        log.info("compat.glx-runtime: %d sonames the farm's members need are "
                 .. "published by no installed payload and are recorded as "
                 .. "unserved", #unserved)
    end
    -- The list has to be written, not discovered.
    for _, soname in ipairs(undeclared) do
        log.warn("compat.glx-runtime: %s is needed by a farmed member, is "
                 .. "published by no installed payload, and is not declared in "
                 .. "UNSERVED. Add the ecosystem package that provides it, or "
                 .. "record why it cannot be one.", soname)
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
