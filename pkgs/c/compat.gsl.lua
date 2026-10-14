-- compat.gsl -- GNU Scientific Library 2.8, built from the official
-- autotools release. GSL's configure step generates config.h and libtool
-- assembles two archives, so the install hook is used instead of trying to
-- approximate the upstream source graph with broad globs.
--
-- The package exposes both libgsl and the GSL CBLAS implementation. Windows
-- is intentionally not declared: the official release has no native MSVC
-- build system, and silently using a host or third-party binary would break
-- the index's source-build and ABI guarantees.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "gsl",
    description = "GNU Scientific Library with its CBLAS implementation (static, source-built)",
    licenses    = {"GPL-3.0-or-later"},
    repo        = "https://www.gnu.org/software/gsl/",
    type        = "package",

    xpm = {
        linux = {
            deps = { "xim:make@latest" },
            ["2.8"] = {
                url = "https://ftp.gnu.org/gnu/gsl/gsl-2.8.tar.gz",
                sha256 = "6a99eeed15632c6354895b1dd542ed5a855c0f15d9ad1326c6fe2b2c9e423190",
            },
        },
        macosx = {
            ["2.8"] = {
                url = "https://ftp.gnu.org/gnu/gsl/gsl-2.8.tar.gz",
                sha256 = "6a99eeed15632c6354895b1dd542ed5a855c0f15d9ad1326c6fe2b2c9e423190",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        sources      = { "mcpp_gsl_anchor.c" },
        include_dirs = { "include" },
        targets      = { ["gsl"] = { kind = "lib" } },
        linux = {
            ldflags = { "-Llib", "-lgsl", "-lgslcblas", "-lm" },
        },
        macosx = {
            ldflags = { "-Llib", "-lgsl", "-lgslcblas", "-lm" },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

local function sh_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function resolve_make()
    local dep = pkginfo.build_dep("xim:make") or pkginfo.build_dep("make")
    if dep and dep.bin then
        local candidate = path.join(dep.bin, "make")
        if os.isfile(candidate) then return candidate end
    end
    return "make"
end

local function run(command, logf)
    local ok, result = pcall(os.exec, string.format(
        "bash -c %s", sh_quote(command .. " >> " .. sh_quote(logf) .. " 2>&1")))
    if not ok or not result then
        log.error("compat.gsl: build command failed; see %s", logf)
        return false
    end
    return true
end

local function install_gsl()
    local archive = pkginfo.install_file()
    local source = archive and tostring(archive):replace(".tar.gz", "")
                 or ("gsl-" .. pkginfo.version())
    if not os.isdir(source) then
        source = "gsl-" .. pkginfo.version()
    end

    local prefix = pkginfo.install_dir()
    os.tryrm(prefix)
    os.mv(source, prefix)
    os.cd(prefix)

    local logf = path.join(prefix, "mcpp_gsl_build.log")
    local make = resolve_make()
    local jobs = (os.default_njob and os.default_njob()) or 4
    local configure = string.format(
        "CC=cc CFLAGS='-std=c11' %s --disable-shared --enable-static "
        .. "--disable-dependency-tracking "
        .. "--prefix=%s --libdir=%s",
        "./configure", sh_quote(prefix), sh_quote(path.join(prefix, "lib")))
    if not run(configure, logf) then return false end
    if not run(string.format("%s -j%d", sh_quote(make), jobs), logf) then
        return false
    end
    if not run(string.format("%s install", sh_quote(make)), logf) then
        return false
    end

    local required = {
        path.join(prefix, "include", "gsl", "gsl_math.h"),
        path.join(prefix, "include", "gsl", "gsl_cblas.h"),
        path.join(prefix, "lib", "libgsl.a"),
        path.join(prefix, "lib", "libgslcblas.a"),
    }
    for _, file in ipairs(required) do
        if not os.isfile(file) then
            log.error("compat.gsl: build did not produce %s; see %s", file, logf)
            return false
        end
    end

    io.writefile(path.join(prefix, "mcpp_gsl_anchor.c"),
                 "int mcpp_compat_gsl_anchor(void) { return 0; }\n")
    return true
end

function install()
    if os.host() == "windows" then return true end
    local ok, result = pcall(install_gsl)
    if not ok then
        log.error("compat.gsl install() failed: %s", tostring(result))
        return false
    end
    return result
end
