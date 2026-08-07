package = {
    spec        = "1",
    namespace   = "compat",
    name        = "glx-runtime",
    description = "Host GLVND/GLX/OpenGL runtime adapter for mcpp Linux window applications",
    licenses    = {"MIT"},
    repo        = "https://github.com/KhronosGroup/OpenGL-Registry",
    type        = "package",

    xpm = {
        linux = {
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
        add(dir)
    end
    add("/lib/x86_64-linux-gnu")
    add("/usr/lib/x86_64-linux-gnu")
    add("/lib64")
    add("/usr/lib64")
    add("/usr/lib")
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
    "libnvidia*.so*",
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

-- Is FILE a 64-bit ELF? e_ident[EI_CLASS] == ELFCLASS64.
--
-- Five bytes read directly. `file`/`readelf`/`patchelf` would each answer this
-- and each may be absent when a hook runs, and a probe that answers "cannot
-- tell" by assuming "fine" is the bug below.
local function is_elf64(file)
    local f = io.open(file, "rb")
    if not f then return false end
    local head = f:read(5)
    f:close()
    return head ~= nil and #head == 5
       and head:sub(1, 4) == "\127ELF" and head:byte(5) == 2
end

-- Link the host's GL runtime into one directory, FIRST HIT WINS, 64-bit only.
--
-- openxlings/xlings' mcpp#352: on Fedora 44 this produced
--     libGLX.so.0 -> /usr/lib/libGLX.so.0
-- a 32-bit library, and the application died with
--     libGLX.so.0: wrong ELF class: ELFCLASS32
--
-- TWO BUGS, and the obvious diagnosis ("the candidate order assumes Debian") is
-- not either of them -- `/usr/lib64` is already ahead of `/usr/lib` in the list:
--
--   1. `ln -sf` OVERWRITES. The loop reached /usr/lib64 first and linked the
--      correct file, then reached /usr/lib and replaced it. Last-wins, not
--      first-wins. `libOpenGL.so.0` survived as 64-bit purely because that host's
--      32-bit glvnd does not ship it -- which is why exactly one link in the bug
--      report was right.
--   2. NO ABI CHECK ANYWHERE, including in `required` below, which asserted that
--      libGLX.so.0 and libGL.so.1 EXIST. Both existed. Both were 32-bit.
--
-- There is no directory layout to assume: the FHS biarch clause makes /usr/lib
-- 32-bit (Fedora/RHEL/SUSE), Debian explicitly declined that clause and uses
-- /usr/lib/<triplet> so its /usr/lib is 64-bit, and Arch is a third answer
-- again. So the fix cannot be a better ordering -- it has to be an ABI check,
-- which makes the order stop mattering.
local function link_runtime_libs(outdir)
    os.mkdir(outdir)
    local claimed = {}
    for _, dir in ipairs(candidate_dirs()) do
        for _, pattern in ipairs(host_gl_patterns) do
            -- Enumerate, then decide per file, instead of letting the shell
            -- link them: the decision needs the ELF class and "have I already
            -- taken this name", neither of which a `ln -sf` loop can express.
            local pipe = io.popen("ls -1 " .. sh_quote(dir) .. "/" .. pattern
                                  .. " 2>/dev/null")
            if pipe then
                for line in pipe:lines() do
                    local lib = line:gsub("[\r\n]+$", "")
                    local name = lib:match("[^/]+$")
                    if lib ~= "" and name and not claimed[name]
                       and is_elf64(lib) then
                        claimed[name] = lib
                        os.exec("ln -sf " .. sh_quote(lib) .. " "
                                .. sh_quote(path.join(outdir, name)))
                    end
                end
                pipe:close()
            end
        end
    end

    for name, _ in pairs(required) do
        local link = path.join(outdir, name)
        -- Existence AND ABI. Existence alone passed on the Fedora host with
        -- both links 32-bit, which is how a broken package reported success and
        -- the failure surfaced as a silent exit code 255 from the application.
        if not os.isfile(link) then
            log.error("required host GL runtime library not found: %s", name)
            log.error("  searched: %s", table.concat(candidate_dirs(), " "))
            log.error("  install your distro's GL runtime (mesa / libglvnd)")
            return false
        end
        if not is_elf64(link) then
            log.error("host %s is not 64-bit (%s)", name, claimed[name] or link)
            log.error("  a 32-bit library here fails at dlopen with")
            log.error("  `wrong ELF class: ELFCLASS32` and the application")
            log.error("  exits without output. Install the 64-bit GL runtime.")
            return false
        end
    end
    log.info("glx-runtime: linked %d host GL libraries (64-bit)",
             (function() local n = 0 for _ in pairs(claimed) do n = n + 1 end return n end)())
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
