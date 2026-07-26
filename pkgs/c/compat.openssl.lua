-- compat.openssl — OpenSSL 3.5.1 built from source as a portable, static
-- library that provides TLS/crypto for consumers (e.g. chriskohlhoff.asio's
-- `ssl` feature, which wraps asio::ssl::context / asio::ssl::stream).
--
-- OpenSSL builds through its own Perl Configure + GNU Make system, which does
-- not fit mcpp's "list the .c files" model. The xpkg install() hook runs that
-- build (build-dep `xim:make@latest`) and lays the lib + headers under the
-- install dir.
--
-- Platforms:
--   * linux/macosx — build a fully static libcrypto.a + libssl.a from source
--     via install() hook (anchor-triggered build, same pattern as compat.openblas).
--   * windows — deferred (requires prebuilt MSVC libs uploaded to xlings-res).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.openssl",
    description = "OpenSSL — TLS/crypto library (static, install()-driven build)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/openssl/openssl",
    type        = "package",

    xpm = {
        linux = {
            deps = { "xim:make@latest" },
            ["3.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/openssl/openssl/releases/download/openssl-3.5.1/openssl-3.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openssl/releases/download/3.5.1/openssl-3.5.1.tar.gz",
                },
                sha256 = "529043b15cffa5f36077a4d0af83f3de399807181d607441d734196d889b641f",
            },
        },
        macosx = {
            -- No xim:make dep: macOS ships GNU Make at /usr/bin/make;
            -- resolve_make() falls back to PATH when the build dep is absent.
            ["3.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/openssl/openssl/releases/download/openssl-3.5.1/openssl-3.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openssl/releases/download/3.5.1/openssl-3.5.1.tar.gz",
                },
                sha256 = "529043b15cffa5f36077a4d0af83f3de399807181d607441d734196d889b641f",
            },
        },
        -- windows deferred (prebuilt zip not yet prepared)
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        -- Anchor TU is NOT a generated_files entry on linux/macosx: it is emitted
        -- by install() so mcpp must run install() (which also builds the lib)
        -- before it can compile this source. include/ + lib/ are produced by
        -- `make install_sw`.
        sources      = { "mcpp_openssl_anchor.c" },
        targets      = { ["openssl"] = { kind = "lib" } },
        include_dirs = { "include" },
        deps         = { },

        -- -lssl must precede -lcrypto (libssl depends on libcrypto).
        linux  = { ldflags = { "-Llib", "-lssl", "-lcrypto" } },
        macosx = { ldflags = { "-Llib", "-lssl", "-lcrypto" } },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

local function sh_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function resolve_make()
    local mk = pkginfo.build_dep("xim:make") or pkginfo.build_dep("make")
    if mk and mk.bin then
        local cand = path.join(mk.bin, "make")
        if os.isfile(cand) then return cand end
    end
    return "make"
end

local function _install_impl()
    -- The fetched tarball unpacks to openssl-<ver>/ beside the archive.
    local ifile   = pkginfo.install_file()
    local srcroot = ifile and tostring(ifile):replace(".tar.gz", "")
                            or ("openssl-" .. pkginfo.version())
    if not os.isdir(srcroot) then
        srcroot = "openssl-" .. pkginfo.version()
    end

    local prefix = pkginfo.install_dir()
    local logf   = path.join(srcroot, "mcpp_openssl_build.log")

    -- Build in the extracted source directory (srcroot) with --prefix
    -- pointing to the clean install directory (prefix).  This avoids the
    -- in-source "cp: source and dest are identical" failure that happens
    -- when prefix == srcroot.
    os.cd(srcroot)

    -- Static-only build: no shared libs, no DSO, no tests, no apps, no engine.
    -- `./config` auto-detects the target platform (equivalent to
    -- `perl Configure <auto-detected-target>`).
    local make  = resolve_make()
    local jobs  = (os.default_njob and os.default_njob()) or 4
    local flags = "no-shared no-dso no-tests no-apps no-engine"
    os.exec(string.format("bash -c %s", sh_quote(string.format(
        "cd %s && ./config --prefix=%s %s >> %s 2>&1",
        sh_quote(srcroot), sh_quote(prefix), flags, sh_quote(logf)))))
    os.exec(string.format("bash -c %s", sh_quote(string.format(
        "cd %s && %s -j%d >> %s 2>&1",
        sh_quote(srcroot), make, jobs, sh_quote(logf)))))

    -- Install to the clean prefix directory.
    -- Override RANLIB to use the system ranlib (which supports the macOS
    -- `-c` flag).  LLVM's llvm-ranlib (injected into PATH by the toolchain)
    -- rejects `-c`, which causes install_dev to fail.
    os.tryrm(prefix)
    os.exec(string.format("bash -c %s", sh_quote(string.format(
        "cd %s && %s RANLIB=/usr/bin/ranlib install_sw >> %s 2>&1",
        sh_quote(srcroot), make, sh_quote(logf)))))

    -- Verify the build produced the expected archives.
    local libdir   = path.join(prefix, "lib")
    local crypto_a = path.join(libdir, "libcrypto.a")
    local ssl_a    = path.join(libdir, "libssl.a")
    if not os.isfile(crypto_a) or not os.isfile(ssl_a) then
        log.error("compat.openssl: build produced no libcrypto.a / libssl.a "
               .. "(see %s)", logf)
        return false
    end

    -- Emit the anchor TU mcpp compiles. Its absence after extraction is what
    -- makes mcpp run this install() before the build (same trigger as
    -- compat.openblas / compat.xcb).
    io.writefile(path.join(prefix, "mcpp_openssl_anchor.c"),
                 "int mcpp_compat_openssl_anchor(void) { return 0; }\n")
    return true
end

function install()
    -- Windows is deferred.
    if os.host() == "windows" then
        log.error("compat.openssl: windows is not yet supported")
        return false
    end
    local ok, result = pcall(_install_impl)
    if not ok then
        log.error("compat.openssl install() failed: %s", tostring(result))
        return false
    end
    if not result then
        log.error("compat.openssl install() returned false")
        return false
    end
    return true
end
