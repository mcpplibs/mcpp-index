-- compat.openssl — OpenSSL 3.5.1 built from source as a portable, static
-- library that provides TLS/crypto for consumers (e.g. chriskohlhoff.asio's
-- `ssl` feature, which wraps asio::ssl::context / asio::ssl::stream).
--
-- OpenSSL builds through its own Perl Configure + GNU Make system, which does
-- not fit mcpp's "list the .c files" model. The xpkg install() hook runs that
-- build and lays the lib + headers under the install dir. GNU Make comes from
-- the `xim:make@latest` build dep on linux; that package has no macOS build,
-- so there resolve_make() falls back to PATH.
--
-- Because that build runs OUTSIDE mcpp's compile rules, it inherits none of
-- the resolved toolchain's flags — it just calls `cc`. Anything the host
-- toolchain needs spelled out (macOS SDK, ranlib) has to be handed to it
-- explicitly; see cc_override() and the install_sw step.
--
-- PERL. `./config` execs `Configure`, which is `#!/usr/bin/env perl` and opens
-- with `use Config; use FindBin;`. So what this build needs is not "a perl
-- binary on PATH" but "a perl whose CORE MODULES are present" — and those are
-- different things on a distro that splits perl into sub-packages or in a
-- trimmed container image. Probing with `command -v perl` accepts such a host
-- and the build then dies fifteen lines into Configure with
-- `Can't locate FindBin.pm in @INC`, which reads like an OpenSSL problem
-- (#140).
--
-- Two changes follow from that. The package now DECLARES `xim:perl@latest` as
-- a build dep on both platforms and puts that perl's bindir at the front of
-- PATH for the build, so it brings its own known-complete interpreter instead
-- of auditing the host's. And the probe now RUNS perl with the modules
-- Configure needs rather than looking it up, so a host perl reached through
-- the fallback path is checked for the property that actually matters.
--
-- (xim:perl ships linux x86_64/aarch64 as fully static musl builds and
-- macosx x86_64/arm64 as relocatable-perl. Unlike xim:make it HAS a macosx
-- entry, so declaring it there resolves — see the macosx block below for what
-- goes wrong when it doesn't.)
--
-- Platforms:
--   * linux/macosx — build a fully static libcrypto.a + libssl.a from source
--     via install() hook (anchor-triggered build, same pattern as compat.openblas).
--   * windows — source build too, through OpenSSL's only x64 windows
--     configuration: `perl Configure VC-WIN64A` + NMAKE. No prebuilt MSVC
--     archive is uploaded anywhere; the same tarball every other platform uses
--     is built in place. Note the HOST requirements this brings (see the
--     windows xpm block and _install_windows_impl): perl, because xim:perl
--     ships no windows build, and a Visual Studio C++ toolset, because
--     VC-WIN64A's build_scheme is VC-common — an NMAKE makefile, which
--     xim:make (GNU make, linux-only anyway) cannot drive. Both are probed
--     with named errors rather than left to fail as an unreadable batch error.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "openssl",
    description = "OpenSSL — TLS/crypto library (static, install()-driven build)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/openssl/openssl",
    type        = "package",

    xpm = {
        linux = {
            deps = { "xim:make@latest", "xim:perl@latest" },
            ["3.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/openssl/openssl/releases/download/openssl-3.5.1/openssl-3.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openssl/releases/download/3.5.1/openssl-3.5.1.tar.gz",
                },
                sha256 = "529043b15cffa5f36077a4d0af83f3de399807181d607441d734196d889b641f",
            },
        },
        macosx = {
            -- NO xim:make here: that package is linux-only
            -- (xim-pkgindex pkgs/m/make.lua declares only an `xpm.linux`
            -- block), so declaring it fails resolution outright with
            -- `E_INVALID_INPUT: package 'xim:make@latest' not found` — before
            -- install() ever runs. compat.openblas declares it on macosx and
            -- is broken the same way; it goes unnoticed because that package
            -- is Windows-only in the test suite, so its macOS path is never
            -- taken. resolve_make() therefore falls back to PATH here.
            --
            -- xim:perl IS declared: it ships a macosx x86_64/arm64 build, so
            -- it resolves here and the platform gets the same
            -- known-complete interpreter linux does.
            deps = { "xim:perl@latest" },
            ["3.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/openssl/openssl/releases/download/openssl-3.5.1/openssl-3.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openssl/releases/download/3.5.1/openssl-3.5.1.tar.gz",
                },
                sha256 = "529043b15cffa5f36077a4d0af83f3de399807181d607441d734196d889b641f",
            },
        },
        windows = {
            -- No build deps here, and that is not an oversight: xim:perl ships
            -- no windows build ("The Windows answer is Strawberry Perl" — see
            -- xim-pkgindex pkgs/p/perl.lua) and xim:make is linux-only, while
            -- OpenSSL's x64 windows path needs NMAKE specifically. Both are
            -- HOST requirements, probed with named errors in install().
            ["3.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/openssl/openssl/releases/download/openssl-3.5.1/openssl-3.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openssl/releases/download/3.5.1/openssl-3.5.1.tar.gz",
                },
                sha256 = "529043b15cffa5f36077a4d0af83f3de399807181d607441d734196d889b641f",
            },
        },
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

        linux = {
            ldflags = {
                "-Llib",
                -- `-l:<archive>` names the file and goes straight to ld, so the
                -- static archive is what gets linked no matter what else is on
                -- the search path. Plain `-lssl` asks the driver to *resolve* a
                -- name, and a resolver prefers a shared object — one stray -L
                -- ahead of ours (a toolchain sysroot, a distro multiarch dir)
                -- and the link silently picks up the host libssl.so.3, giving
                -- the consumer a runtime dependency this package exists to
                -- avoid. ssl precedes crypto: libssl depends on libcrypto.
                "-l:libssl.a",
                "-l:libcrypto.a",
                -- Static libcrypto's own system deps. Configured `no-dso
                -- no-engine` (so no dlopen) and glibc >= 2.34 folds both into
                -- libc, which is why CI links without them — but musl and
                -- older glibc still need them spelled out.
                "-ldl",
                "-lpthread",
            },
        },
        -- macOS: ld64 has no `-l:` spelling. lib/ holds only the .a archives
        -- this package built, so name resolution has nothing else to find, and
        -- libSystem already carries dl/pthread.
        macosx = { ldflags = { "-Llib", "-lssl", "-lcrypto" } },
        -- Windows: `nmake install_sw` on a no-shared build lays down
        -- lib\libssl.lib + lib\libcrypto.lib. Under the MSVC ABI the driver
        -- maps -l<name> to <name>.lib, so the names carry their `lib` prefix
        -- (this is NOT the unix convention where -lssl finds libssl). The
        -- system imports are the set OpenSSL's own VC build links: ws2_32 for
        -- sockets, crypt32 for the certificate store, advapi32/user32 for the
        -- entropy and UI paths, and bcrypt for RtlGenRandom.
        windows = {
            ldflags = {
                "-Llib",
                "-llibssl",
                "-llibcrypto",
                "-lws2_32", "-lcrypt32", "-ladvapi32", "-luser32", "-lbcrypt",
            },
        },
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
    -- No build dep (macOS): prefer a Homebrew `gmake` when present. macOS's
    -- own /usr/bin/make is GNU Make 3.81, frozen in 2006.
    if os.host() == "macosx" and os.isfile("/opt/homebrew/bin/gmake") then
        return "/opt/homebrew/bin/gmake"
    end
    return "make"
end

-- The C compiler OpenSSL's own Makefile should use.
--
-- OpenSSL is configured and built outside mcpp's compile rules, so it does not
-- inherit the resolved toolchain's sysroot flags — it just runs `cc`. On macOS
-- the toolchain in PATH is xim's llvm, which has no macOS SDK wired up, so
-- every compile would fail on <stdio.h>. Pin Apple's own driver, which finds
-- the SDK by itself. Left alone elsewhere: on linux the xim gcc carries its
-- own payload and is the right compiler to use.
local function cc_override()
    if os.host() == "macosx" and os.isfile("/usr/bin/cc") then
        return "CC=/usr/bin/cc "
    end
    return ""
end

-- Does this perl actually RUN, with the core modules Configure opens with?
--
-- `command -v perl` answers a different question, and the difference is the
-- whole of #140: a host can have /usr/bin/perl and no FindBin.pm, and then the
-- failure lands inside OpenSSL's Configure where it reads as an OpenSSL bug.
-- The module list is Configure's own opening lines (Config, FindBin,
-- File::Basename/File::Spec/File::Path), plus POSIX, which the Makefile's
-- perl helpers use.
local function perl_usable(perl)
    return pcall(function()
        os.exec(string.format("bash -c %s",
                sh_quote(sh_quote(perl)
                         .. " -MConfig -MFindBin -MFile::Path -MFile::Spec"
                         .. " -MFile::Basename -MPOSIX -e exit"
                         .. " >/dev/null 2>&1")))
    end)
end

-- Returns the perl to build with and the bindir to put in front of PATH, or
-- nil. The bindir matters as much as the binary: `./config` is a shell script
-- that execs `Configure`, whose shebang is `#!/usr/bin/env perl` — so it takes
-- whatever PATH resolves, not whatever we invoke. Handing it the right PATH is
-- the only way to steer it, and Configure then records that same interpreter
-- as `$config{PERL}` (from `$^X`) for the rest of the build.
local function resolve_perl()
    local p = pkginfo.build_dep("xim:perl") or pkginfo.build_dep("perl")
    if p and p.bin then
        local cand = path.join(p.bin, "perl")
        if os.isfile(cand) and perl_usable(cand) then
            return cand, p.bin
        end
    end
    -- Fallback: whatever PATH already has, but only if it passes the same
    -- check. An engine that cannot resolve the build dep should still build on
    -- a host whose own perl is complete.
    if perl_usable("perl") then return "perl", nil end
    return nil, nil
end

-- Last `n` lines of the build log, or nil if it cannot be read.
local function tail_lines(file, n)
    local ok, content = pcall(io.readfile, file)
    if not ok or not content then return nil end
    local lines = {}
    for line in (tostring(content) .. "\n"):gmatch("(.-)\n") do
        lines[#lines + 1] = line
    end
    if #lines == 0 then return nil end
    return table.concat(lines, "\n", math.max(1, #lines - n + 1), #lines)
end

-- Run one build step, and on failure print the tail of the log with it.
--
-- Everything the build says goes to an on-disk log (xim's interface mode
-- swallows subprocess stdout), and xlings surfaces a failed install() as a
-- bare `E_INTERNAL: [openssl] failed:` — so without this the only signal a CI
-- run gives is that something, somewhere, went wrong. The message is passed as
-- a single pre-formatted argument: log output contains `%` often enough that
-- handing it to a format string is its own failure mode.
local function run(step, logf, cmd)
    local ok, err = pcall(os.exec, string.format("bash -c %s", sh_quote(cmd)))
    if ok then return true end
    local tail = tail_lines(logf, 40) or "<log unreadable at " .. tostring(logf) .. ">"
    log.error("%s", "compat.openssl: " .. step .. " failed (" .. tostring(err)
                 .. ")\n--- last 40 lines of " .. tostring(logf) .. " ---\n" .. tail)
    return false
end

local function _install_impl()
    local perl, perlbin = resolve_perl()
    if not perl then
        log.error("compat.openssl: no usable perl. OpenSSL's ./config execs "
               .. "Configure, which needs a perl WITH its core modules "
               .. "(Config, FindBin, File::Path, POSIX) — a perl binary alone "
               .. "is not enough, and a perl missing them fails inside "
               .. "Configure with `Can't locate FindBin.pm in @INC`. The "
               .. "xim:perl build dep should have supplied one; if it could "
               .. "not be resolved, install a complete perl (e.g. Debian "
               .. "perl-modules, Fedora perl-core) and retry.")
        return false
    end

    -- Put the resolved perl FIRST on PATH for every build step. Configure's
    -- shebang is `#!/usr/bin/env perl`, so this — not the command we type — is
    -- what decides which interpreter runs it. Empty when the fallback picked
    -- up the host's own perl, which is already on PATH by definition.
    local perl_path = ""
    if perlbin then
        perl_path = "export PATH=" .. sh_quote(perlbin) .. ':"$PATH"; '
    end

    -- The fetched tarball unpacks to openssl-<ver>/ beside the archive. Every
    -- command below cd's into srcroot itself, so the process cwd is left alone
    -- (an os.cd here would break the relative-path fallback on the next line).
    local ifile   = pkginfo.install_file()
    local srcroot = ifile and tostring(ifile):replace(".tar.gz", "")
                            or ("openssl-" .. pkginfo.version())
    if not os.isdir(srcroot) then
        srcroot = "openssl-" .. pkginfo.version()
    end

    -- Build in the extracted source directory with --prefix pointing at a
    -- clean install directory. Building in-place (prefix == srcroot) makes
    -- `make install_sw` fail with "cp: source and dest are identical".
    --
    -- The prefix is emptied HERE, before the build, so the build log can live
    -- inside it: a log that a later os.tryrm would delete, or one left in the
    -- transient srcroot, is gone exactly when a failed build needs reading.
    -- xim's interface mode swallows subprocess stdout, so this file is the
    -- only record of what the compiler said.
    local prefix = pkginfo.install_dir()
    os.tryrm(prefix)
    os.mkdir(prefix)
    local logf = path.join(prefix, "mcpp_openssl_build.log")

    -- Static-only build: no shared libs, no DSO, no tests, no apps, no engine.
    -- `./config` auto-detects the target (equivalent to `perl Configure
    -- <detected-target>`).
    --
    -- --libdir=lib is NOT cosmetic. Left unset, OpenSSL derives the install
    -- libdir as "lib$target{multilib}" (Configurations/unix-Makefile.tmpl),
    -- and Configurations/10-main.conf gives linux-x86_64 `multilib => "64"`.
    -- So on the single most common target the archives land in $prefix/lib64
    -- while `-Llib` and the check below look at $prefix/lib. linux-aarch64 and
    -- both darwin64 targets declare no multilib and resolve to plain "lib" —
    -- which is how a source build can pass on an arm64 Mac and still be broken
    -- for everyone on x86_64 Linux.
    local make  = resolve_make()
    local jobs  = (os.default_njob and os.default_njob()) or 4
    local flags = "no-shared no-dso no-tests no-apps no-engine"

    -- Record which make is in play: "3.81 vs 4.x" is the difference between a
    -- build and a wall of Makefile syntax errors, and it is invisible after
    -- the fact otherwise. `command -v perl` is logged under the same PATH the
    -- build will use, so the log says which interpreter Configure got rather
    -- than which one we hoped it would get.
    run("build environment", logf, string.format(
        "%s{ %s --version; echo \"cc: $(command -v cc)\"; cc --version; " ..
        "echo \"perl: $(command -v perl)\"; perl --version; } >> %s 2>&1 || true",
        perl_path, make, sh_quote(logf)))

    local cc = cc_override()
    if not run("./config", logf, string.format(
        "%scd %s && %s./config --prefix=%s --libdir=lib %s >> %s 2>&1",
        perl_path, sh_quote(srcroot), cc, sh_quote(prefix), flags,
        sh_quote(logf))) then
        return false
    end
    if not run("make", logf, string.format(
        "%scd %s && %s -j%d >> %s 2>&1",
        perl_path, sh_quote(srcroot), make, jobs, sh_quote(logf))) then
        return false
    end

    -- macOS only: Configure bakes `RANLIB = ranlib -c` into the Makefile for
    -- darwin targets, and the `ranlib` that PATH resolves to is the
    -- toolchain's llvm-ranlib, which rejects `-c` — install_dev then dies
    -- right after copying libcrypto.a. Point RANLIB at Apple's own, without
    -- the flag. Confined to the platform that needs it: a Linux container
    -- without /usr/bin/ranlib should not fail install_sw for no reason.
    --
    -- It MUST be spelled `make RANLIB=… install_sw` and not
    -- `RANLIB=… make install_sw`. The first is a command-line assignment,
    -- which beats the Makefile's own; the second is merely an environment
    -- variable, which a Makefile assignment overrides (absent `make -e`), so
    -- the override silently does nothing and the build fails exactly as if it
    -- were not there.
    local ranlib = (os.host() == "macosx") and " RANLIB=/usr/bin/ranlib" or ""
    if not run("make install_sw", logf, string.format(
        "%scd %s && %s%s install_sw >> %s 2>&1",
        perl_path, sh_quote(srcroot), make, ranlib, sh_quote(logf))) then
        return false
    end

    -- Verify the build produced the expected archives.
    local libdir   = path.join(prefix, "lib")
    local crypto_a = path.join(libdir, "libcrypto.a")
    local ssl_a    = path.join(libdir, "libssl.a")
    if not os.isfile(crypto_a) or not os.isfile(ssl_a) then
        log.error("compat.openssl: build produced no libcrypto.a / libssl.a "
               .. "under %s (see %s)", libdir, logf)
        return false
    end

    -- Emit the anchor TU mcpp compiles. Its absence after extraction is what
    -- makes mcpp run this install() before the build (same trigger as
    -- compat.openblas / compat.xcb).
    io.writefile(path.join(prefix, "mcpp_openssl_anchor.c"),
                 "int mcpp_compat_openssl_anchor(void) { return 0; }\n")
    return true
end

-- Windows build. OpenSSL's only x64 windows configuration is VC-WIN64A
-- (Configurations/10-main.conf; the clang-cl configs in 50-win-clang-cl.conf
-- are Windows-on-ARM only), and its build_scheme is VC-common — i.e. the
-- generated makefile is for NMAKE, not GNU make. So this path needs two things
-- from the HOST that xim cannot supply: perl, and a Visual Studio developer
-- environment for nmake.
--
-- Everything windows-specific lives in a generated .bat rather than being
-- one-lined through `cmd /c`. Nesting quotes through cmd for a `call
-- vcvars64.bat && perl Configure ... && nmake` chain is its own failure mode,
-- and a script on disk is also what a maintainer can re-run by hand after a
-- failed CI job.
local function _install_windows_impl()
    -- The log is opened FIRST and appended to at every step, before anything
    -- that can fail. xlings swallows an install() hook's log.error on windows —
    -- a failure surfaces only as a bare `E_INTERNAL: [openssl] failed:` — so
    -- this file is the single channel that survives, and CI's "Dump install()
    -- build logs on failure" step is what prints it. Without it a windows
    -- failure is undebuggable from a CI run.
    local prefix = pkginfo.install_dir()
    os.tryrm(prefix)
    os.mkdir(prefix)
    local logf = path.join(prefix, "mcpp_openssl_build.log")
    local bat  = path.join(prefix, "mcpp_openssl_build.bat")
    local inner = path.join(prefix, "mcpp_openssl_inner.bat")

    local function note(msg)
        local fh = io.open(logf, "a")
        if fh then fh:write("[mcpp] " .. tostring(msg) .. "\n"); fh:close() end
    end
    note("windows install() start; prefix=" .. tostring(prefix))

    -- Every call below goes through this. The xlings sandbox exposes a SUBSET
    -- of xmake's Lua API, and calling something outside it kills install()
    -- silently — the first attempt died on os.curdir() with no message at all,
    -- leaving only the line above in the log. `safe` turns that class of
    -- failure into a log line naming the call.
    local function safe(label, fn, fallback)
        local ok, res = pcall(fn)
        if not ok then
            note("call failed: " .. label .. " -> " .. tostring(res))
            return fallback
        end
        return res
    end

    local ifile = safe("pkginfo.install_file()", function() return pkginfo.install_file() end)
    note("install_file=" .. tostring(ifile))
    local srcroot = ifile and tostring(ifile):replace(".tar.gz", "")
                            or ("openssl-" .. pkginfo.version())
    if not os.isdir(srcroot) then
        note("srcroot '" .. tostring(srcroot) .. "' is not a dir; falling back")
        srcroot = "openssl-" .. pkginfo.version()
    end
    if not os.isdir(srcroot) then
        note("FATAL: no source dir found. Entries beside it:")
        local entries = safe("os.filedirs('*')", function() return os.filedirs("*") end, {})
        for _, f in ipairs(entries) do note("   " .. tostring(f)) end
        return false
    end
    -- path.absolute() is NOT in the xlings sandbox (verified: "attempt to call
    -- a nil value"), and it is not needed — pkginfo.install_file() already
    -- returns an absolute path, so srcroot derived from it is absolute too.
    -- cmd wants backslashes; the path arrives with both separators mixed.
    srcroot = tostring(srcroot):gsub("/", "\\")
    note("srcroot=" .. tostring(srcroot))

    -- vswhere is installed with every VS 2017+ at a fixed location, and is the
    -- supported way to find the toolset; hardcoding a VS path breaks on the
    -- next release. `-products *` is required or Build Tools-only machines
    -- (which is what CI images often are) report nothing.
    -- The batch reports through the LOG, not through its exit code: the first
    -- attempt came back ok=true from os.exec while having produced nothing and
    -- written nothing, so that channel cannot be trusted here. Every step
    -- announces itself into the log BEFORE running, and the script always
    -- exits 0 after recording RESULT=<code>, which is what Lua then reads.
    --
    -- CRLF line endings are REQUIRED, and this was established the hard way.
    -- io.writefile writes bytes verbatim (it does not translate \n), and with
    -- an LF-only batch the run got as far as `call "%VCVARS%"` — the log even
    -- shows "[vcvarsall.bat] Environment initialized for: 'x64'" — and then
    -- stopped dead: no further echo, no RESULT, exit 0. cmd reads a batch by
    -- FILE OFFSET and its bookkeeping assumes CRLF, so on returning from a
    -- `call` it resumes at the wrong position and hits EOF. The symptom is a
    -- script that "succeeds" having done nothing after the first call.
    local logw  = tostring(logf):gsub("/", "\\")
    local prefw = tostring(prefix):gsub("/", "\\")
    local innerw = tostring(inner):gsub("/", "\\")
    local envdump = path.join(prefix, "mcpp_vsenv.txt")
    local envw = tostring(envdump):gsub("/", "\\")
    io.writefile(inner, table.concat({
        "@echo off",
        -- vcvars is never `call`ed. Three runs showed the caller vanishing the
        -- moment it finished — even from a child cmd — so instead it runs in a
        -- cmd whose only job is to dump the resulting environment, and those
        -- variables are imported here. This is the standard way build systems
        -- capture a VS environment, and it does not depend on vcvars returning
        -- to anyone. Note `&` rather than `&&`: `set` must run whatever exit
        -- status vcvars leaves behind.
        'echo [bat] capturing VS environment >> "' .. logw .. '" 2>&1',
        'cmd /c ""%MCPP_VCVARS%" & set" > "' .. envw .. '" 2>>"' .. logw .. '"',
        'if not exist "' .. envw .. '" ( echo [bat] no env dump produced >> "' .. logw .. '" & exit /b 13 )',
        'for /f "usebackq tokens=1* delims==" %%a in ("' .. envw .. '") do set "%%a=%%b"',
        'echo [bat] toolset ready >> "' .. logw .. '" 2>&1',
        'cd /d "' .. srcroot .. '"',
        'if errorlevel 1 exit /b 14',
        'where perl >> "' .. logw .. '" 2>&1',
        'where nmake >> "' .. logw .. '" 2>&1',
        'echo [bat] configuring >> "' .. logw .. '" 2>&1',
        'perl Configure VC-WIN64A no-shared no-tests no-apps no-engine no-dso --prefix="' .. prefw .. '" --openssldir="' .. prefw .. '\\ssl" >> "' .. logw .. '" 2>&1',
        'if errorlevel 1 exit /b 20',
        'echo [bat] building >> "' .. logw .. '" 2>&1',
        'nmake >> "' .. logw .. '" 2>&1',
        'if errorlevel 1 exit /b 21',
        'echo [bat] installing >> "' .. logw .. '" 2>&1',
        'nmake install_sw >> "' .. logw .. '" 2>&1',
        'if errorlevel 1 exit /b 22',
        "exit /b 0",
    }, "\r\n") .. "\r\n")

    -- Outer script: find the toolset, then hand the actual build to the inner
    -- script in a CHILD cmd and record its exit code.
    --
    -- The child process is the whole point. Three runs in a row died silently
    -- right after `call "%VCVARS%"` succeeded — the log even showed
    -- "[vcvarsall.bat] Environment initialized for: 'x64'" — and then nothing:
    -- no further echo, no RESULT, exit 0. Visual Studio's developer-prompt
    -- script terminates the batch that calls it. Running it inside `cmd /c
    -- <inner.bat>` means it can only take that child down, and the outer
    -- script still runs to write RESULT. The vcvars path travels by ENVIRONMENT
    -- VARIABLE rather than as an argument, because a child cmd inherits the
    -- environment and that avoids another layer of quoting around a path with
    -- spaces.
    io.writefile(bat, table.concat({
        "@echo off",
        'echo [bat] started >> "' .. logw .. '" 2>&1',
        'set "VSWHERE=%ProgramFiles(x86)%\\Microsoft Visual Studio\\Installer\\vswhere.exe"',
        'echo [bat] vswhere=%VSWHERE% >> "' .. logw .. '" 2>&1',
        'if not exist "%VSWHERE%" ( echo [bat] RESULT=10 vswhere missing >> "' .. logw .. '" & exit /b 0 )',
        'for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSPATH=%%i"',
        'echo [bat] vspath=%VSPATH% >> "' .. logw .. '" 2>&1',
        'if not defined VSPATH ( echo [bat] RESULT=11 no VC toolset >> "' .. logw .. '" & exit /b 0 )',
        'set "MCPP_VCVARS=%VSPATH%\\VC\\Auxiliary\\Build\\vcvars64.bat"',
        'if not exist "%MCPP_VCVARS%" ( echo [bat] RESULT=12 no vcvars64 >> "' .. logw .. '" & exit /b 0 )',
        'echo [bat] handing build to child cmd >> "' .. logw .. '" 2>&1',
        'cmd /c "' .. innerw .. '"',
        'echo [bat] RESULT=%errorlevel% >> "' .. logw .. '" 2>&1',
        "exit /b 0",
    }, "\r\n") .. "\r\n")

    note("wrote " .. bat .. "; running it")
    local batw = tostring(bat):gsub("/", "\\")
    local ok, err = pcall(os.exec, string.format('cmd /c "%s"', batw))
    note("os.exec ok=" .. tostring(ok) .. " err=" .. tostring(err)
         .. " (advisory only -- RESULT= in this log decides)")

    local content = ""
    local rok, rdata = pcall(io.readfile, logf)
    if rok and rdata then content = tostring(rdata) end
    local result = content:match("%[bat%] RESULT=(%d+)")
    note("batch RESULT=" .. tostring(result))
    if result ~= "0" then
        local tail = tail_lines(logf, 40) or "<no log; the failure was before the build started>"
        log.error("%s", "compat.openssl: windows build failed (RESULT=" .. tostring(result) ..
                  ")\nexit 10-13 = no Visual Studio C++ toolset found (vswhere/vcvars64), " ..
                  "20-22 = Configure/nmake failed.\nHOST REQUIREMENTS on windows: perl " ..
                  "(Strawberry Perl -- xim:perl has no windows build) and a Visual Studio " ..
                  "C++ toolset for nmake.\n--- last 40 lines of " .. tostring(logf) ..
                  " ---\n" .. tail)
        return false
    end

    -- no-shared VC builds land libssl.lib / libcrypto.lib in <prefix>\lib.
    local libdir = path.join(prefix, "lib")
    note("checking " .. libdir)
    if os.isdir(libdir) then
        local produced = safe("os.files(lib/*)", function() return os.files(path.join(libdir, "*")) end, {})
        for _, f in ipairs(produced) do note("   lib/ " .. tostring(f)) end
    else
        note("   (no lib/ directory was produced)")
    end
    if not os.isfile(path.join(libdir, "libssl.lib"))
       or not os.isfile(path.join(libdir, "libcrypto.lib")) then
        log.error("compat.openssl: windows build produced no libssl.lib / "
               .. "libcrypto.lib under %s (see %s)", libdir, logf)
        return false
    end

    io.writefile(path.join(prefix, "mcpp_openssl_anchor.c"),
                 "int mcpp_compat_openssl_anchor(void) { return 0; }\n")
    return true
end

function install()
    if os.host() == "windows" then
        local okw, resw = pcall(_install_windows_impl)
        if not okw then
            log.error("compat.openssl install() failed on windows: %s", tostring(resw))
            return false
        end
        if not resw then
            log.error("compat.openssl install() returned false on windows")
            return false
        end
        return true
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
