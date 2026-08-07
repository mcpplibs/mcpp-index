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
--   * windows — still deferred, but NOT for the reason written here before:
--     a source build was attempted and the blocker is not a missing prebuilt
--     archive. vswhere finds the toolset fine, and then running vcvars in ANY
--     form takes the whole process chain down — plain `call`, a child
--     `cmd /c`, and the standard `cmd /c "vcvars & set"` environment dump all
--     stop dead at that line with no RESULT and no error. See
--     .agents/docs/2026-08-05-openssl-windows-todo.md for the evidence, the
--     two host requirements it brings (perl — xim:perl has no windows build;
--     a VS C++ toolset for nmake, since VC-WIN64A's build_scheme is an NMAKE
--     makefile), and why a manual run on a windows machine should come before
--     the next code attempt.
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
            -- glibc + linux-headers are here for the same reason make and perl
            -- are: this package builds through its own Makefile with a bare
            -- `cc`, so every tool it uses has to be something this descriptor
            -- resolved, not something it hopes to find. See cc_override().
            --
            -- The specs are xim:gcc's own, character for character, and NOT
            -- `@latest`. openssl's objects are linked into projects built by
            -- that gcc, so the C library it compiles against has to be the one
            -- the toolchain uses; `@latest` would be free to resolve a NEWER
            -- glibc than the toolchain's and introduce symbols the final link
            -- cannot satisfy. Matching the ranges means both resolve the same
            -- node -- already on disk wherever gcc is, so this costs a
            -- resolution rather than a download.
            deps = {
                "xim:make@latest", "xim:perl@latest",
                "xim:glibc@>=2.39", "xim:linux-headers@5.11.1",
            },
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
-- the SDK by itself.
--
-- On linux the compiler used to be left to PATH, on the strength of "the xim
-- gcc carries its own payload and is the right compiler to use". The binary is
-- right; the assumption that it is SELF-SUFFICIENT is not. PATH reaches it
-- through its xvm shim, and the shim injects `--sysroot=<subos>` resolved
-- against **the subos the calling process resolved to** (xim-pkgindex
-- pkgs/g/gcc.lua) -- whose own comment states the other half of the contract:
--
--     Consumers that bypass the shim supply their own header flags.
--
-- OpenSSL's Makefile is exactly such a consumer: it calls a bare `cc`. So the
-- flags are this hook's business, the same way `make` and `perl` already are.
--
-- Leaving it ambient breaks whenever the resolved subos is not the one holding
-- the toolchain. This hook runs with its cwd inside the CONSUMING PROJECT's
-- xlings home (<proj>/.mcpp/.xlings/data/runtimedir/openssl-<v>), so the subos
-- resolves to the PROJECT one, which holds only what that project installed --
-- no usr/include, usually no usr/ at all. A `--sysroot` at an empty tree does
-- not fall back to the default search, it SUPPRESSES it, and every compile
-- dies a long way from the cause:
--
--     include/internal/common.h:14:11: fatal error: stdlib.h: No such file
--     .../xim-x-gcc/16.1.0/lib/gcc/.../limits.h:210:15: fatal error: limits.h
--
-- (the second is gcc's own `#include_next`, which reads like a broken compiler
-- and is not).
--
-- So resolve the C library the way make and perl are resolved -- from declared
-- build deps -- and hand openssl the three things the payload gcc needs:
-- headers (-isystem), crt objects (-B) and -lc (-L). `--sysroot` is re-pointed
-- at the glibc payload root, which is NOT FHS-shaped and therefore contributes
-- no search path of its own: it neutralises whatever the shim injected without
-- opening a door to the host's /usr/include. A later --sysroot wins, so this
-- needs no cooperation from the shim.
--
-- This is a local restatement of what mcpp's own link model does
-- (src/build/flags.cppm, "payload-first, --sysroot fallback"). Duplicating a
-- decision is a real cost; the alternative is worse, because openssl builds
-- outside mcpp's compile rules by construction and has no other way to be told.
-- If xim ever hands install() hooks a ready CC/CFLAGS, this should become that.
local function libc_payloads()
    local glibc = pkginfo.build_dep("xim:glibc") or pkginfo.build_dep("glibc")
    local kern  = pkginfo.build_dep("xim:linux-headers")
                  or pkginfo.build_dep("linux-headers")
    local groot = glibc and glibc.path
    local kroot = kern and kern.path
    if not (groot and os.isfile(path.join(groot, "include", "stdlib.h"))) then
        return nil
    end
    return groot, kroot
end

local function cc_override()
    if os.host() == "macosx" and os.isfile("/usr/bin/cc") then
        return "CC=/usr/bin/cc "
    end
    if os.host() ~= "linux" then return "" end

    local groot, kroot = libc_payloads()
    if not groot then
        log.warn("openssl: no xim:glibc payload resolved; leaving CC to PATH"
            .. " (fails if the active subos carries no libc headers)")
        return ""
    end
    local libdir = os.isdir(path.join(groot, "lib64"))
                   and path.join(groot, "lib64") or path.join(groot, "lib")
    local cc = "gcc --sysroot=" .. groot
        .. " -isystem " .. path.join(groot, "include")
    if kroot and os.isdir(path.join(kroot, "include")) then
        cc = cc .. " -isystem " .. path.join(kroot, "include")
    end
    cc = cc .. " -B " .. libdir .. " -L " .. libdir
    return "CC=" .. sh_quote(cc) .. " "
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

function install()
    -- Windows is deferred: there is no windows xpm block, so version
    -- resolution already fails before this point. Kept as a named error in
    -- case a windows entry is added before this hook learns to build there.
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
