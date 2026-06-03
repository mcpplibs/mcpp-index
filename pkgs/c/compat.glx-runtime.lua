package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.glx-runtime",
    description = "Host GLVND/GLX/OpenGL runtime adapter for mcpp Linux window applications",
    licenses    = {"MIT"},
    repo        = "https://github.com/KhronosGroup/OpenGL-Registry",
    type        = "package",

    xpm = {
        linux = {
            ["2026.06.03"] = {
                url    = "https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/a30033d3e812c9bf10094f1010374a6b15e192eb/README.adoc",
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
            log.error("required host GL runtime library not found: %s", name)
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
