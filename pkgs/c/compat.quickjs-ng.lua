local versions = {
    ["0.18.0"] = {
        url = "https://github.com/quickjs-ng/quickjs/archive/refs/tags/v0.18.0.tar.gz",
        sha256 = "28bcd89aa3683fd2a946537e5ce3f11cc46b5cbf3383c7561aaef3df5ff9f1dd",
    },
}

-- compat.quickjs-ng — QuickJS-ng, a small embeddable JavaScript engine.
--
-- Shape A (C-source compat): upstream's library target and nothing else. A
-- consumer writes `#include <quickjs.h>` and links the lib.
--
-- WHAT IS COMPILED. Upstream's `qjs_sources` (CMakeLists.txt:273-278): dtoa.c,
-- libregexp.c, libunicode.c and quickjs.c. quickjs-libc.c is NOT compiled. It
-- is upstream's optional standard library, the `std` / `os` / `bjson` modules
-- (files, environment variables, timers, child processes, signal handlers).
-- Upstream's own library leaves it out by default too: CMake adds it only under
-- QJS_BUILD_LIBC (meson: -Dlibc=true) and otherwise builds it as a separate,
-- uninstalled static library for the qjs and qjsc programs. An embedder that
-- wants the engine without giving scripts access to the host needs it left
-- out. The other .c files at the root are the qjs/qjsc programs, tests and
-- generators.
--
-- LAYOUT. install() (below) moves the release directory `quickjs-<version>/` to be the
-- install dir itself, so no path of this descriptor holds a version and a new release is an
-- appended xpm entry only (extensions.autoupdate). 0.17.0 was published before install()
-- existed and stays installed with its release directory kept; the entries that name
-- `quickjs-0.17.0/` and the `#else` of the forwarder serve exactly that install, and are
-- never extended: a later release is always flat.
--
-- ONE PUBLIC HEADER. Without quickjs-libc, upstream installs quickjs.h alone
-- (CMakeLists.txt:557, meson.build:144-146 and 263), but the tarball keeps it
-- at the root beside the engine's private headers, among them list.h, cutils.h
-- and dtoa.h, names generic enough to shadow a consumer's own. So a one-line
-- forwarder through `generated_files` is the only directory on the include
-- path (the compat.libaio pattern). The engine's own TUs include their headers
-- in quote form next to the .c and need no -I.
--
-- FLAGS, each one as upstream's CMake and meson builds set it:
--   -std=gnu11          C11 with GNU extensions (CMakeLists.txt:9-11,
--                       meson.build:6). The -std on this package's compile
--                       line does not follow `c_standard`: "gnu11" there still
--                       gives -std=c11 (the same observation as compat.libaio),
--                       so the dialect arrives through `cflags`, where the
--                       later -std wins.
--   -funsigned-char     CMakeLists.txt:109, meson.build:42, and /J for MSVC
--                       (meson.build:70). x86_64 and aarch64 Linux disagree on
--                       the sign of plain char, and upstream pins it so the
--                       engine behaves the same on both. A consumer does not
--                       need it: quickjs.h only passes char by pointer.
--   -D_GNU_SOURCE       CMakeLists.txt:285 and meson.build:162, on every
--                       platform.
--   -DQUICKJS_NG_BUILD  CMakeLists.txt:46, meson.build:19. quickjs.h reads it
--                       only for quickjs-libc's Windows export macro
--                       (quickjs.h:82), so it has no effect on Linux today; it
--                       is set so the engine's TUs see the macros upstream's
--                       own build gives them.
-- All four go through `cflags`, so they reach this package's C TUs and never a
-- consumer's TU. NDEBUG is not set, as in most descriptors here, so the engine
-- keeps its assertions and its debug-dump code (quickjs.c:84-86); upstream's
-- default build type (Release) would define it.
--
-- PLATFORMS. Linux (llvm 22.1.8 on x86_64-linux-gnu, and in an openkal graph),
-- macOS and Windows: the same four sources and flags, as upstream's own CI
-- builds them on all three (clang and MSVC-ABI clang on Windows).
--
-- NO CN MIRROR. The url is upstream's tag archive as a plain string, the
-- fallback docs/cn-mirror.md describes for a contributor without mcpp-res write
-- access. A maintainer can turn it into a GLOBAL/CN table later; the sha256
-- does not change.
--
-- LICENSES. The engine is MIT (LICENSE). libunicode-table.h, which libunicode.c
-- compiles in, is generated from the Unicode data files and carries the
-- Unicode License V3 in its header, so a binary built from this package needs
-- both notices.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "quickjs-ng",
    description = "QuickJS-ng, a small embeddable JavaScript engine (engine only, without quickjs-libc)",
    licenses    = {"MIT", "Unicode-3.0"},
    repo        = "https://github.com/quickjs-ng/quickjs",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/quickjs-ng/quickjs/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.17.0"] = {
                url    = "https://github.com/quickjs-ng/quickjs/archive/refs/tags/v0.17.0.tar.gz",
                sha256 = "559bc4c420475e55c7ab4510adbc562f55d7524d75e8e89d79ce4bb02f5687d9",
            },
            ["0.18.0"] = versions["0.18.0"],
        },
        macosx = {
            ["0.17.0"] = {
                url    = "https://github.com/quickjs-ng/quickjs/archive/refs/tags/v0.17.0.tar.gz",
                sha256 = "559bc4c420475e55c7ab4510adbc562f55d7524d75e8e89d79ce4bb02f5687d9",
            },
            ["0.18.0"] = versions["0.18.0"],
        },
        windows = {
            ["0.17.0"] = {
                url    = "https://github.com/quickjs-ng/quickjs/archive/refs/tags/v0.17.0.tar.gz",
                sha256 = "559bc4c420475e55c7ab4510adbc562f55d7524d75e8e89d79ce4bb02f5687d9",
            },
            ["0.18.0"] = versions["0.18.0"],
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "mcpp/include" },
        cflags       = { "-std=gnu11", "-funsigned-char", "-D_GNU_SOURCE", "-DQUICKJS_NG_BUILD" },
        sources      = {
            "dtoa.c",
            "quickjs-0.17.0/dtoa.c",
            "libregexp.c",
            "quickjs-0.17.0/libregexp.c",
            "libunicode.c",
            "quickjs-0.17.0/libunicode.c",
            "quickjs.c",
            "quickjs-0.17.0/quickjs.c",
        },
        generated_files = {
            ["mcpp/include/quickjs.h"] =
[[
#pragma once
/* compat.quickjs-ng: upstream installs quickjs.h alone, but the release
   tarball keeps it beside the engine's private headers (list.h, cutils.h,
   dtoa.h, ...). This forwarder is the only thing on the include path. */
#if __has_include("../../quickjs.h")
#include "../../quickjs.h"
#else
/* 0.17.0 was installed with its release directory kept (quickjs-0.17.0/);
   later releases are moved to the install root by install(). */
#include "../../quickjs-0.17.0/quickjs.h"
#endif
]],
        },
        -- Upstream links `m`, the dl library and the thread library PUBLIC
        -- (CMakeLists.txt:291-311). A consumer with no C++ in it is linked by
        -- the C driver, which adds no libm, and quickjs.c's Math functions then
        -- fail to link. libdl is left out: only quickjs-libc.c calls dlopen.
        linux        = { ldflags = { "-lm", "-lpthread" } },
        -- libSystem carries libm and pthreads: nothing to add on macOS.
        -- Windows: upstream's CMake adds _CRT_SECURE_NO_WARNINGS for MSVC-ABI
        -- builds (CMakeLists.txt, `if(MSVC)`), and quickjs.c's thread-safe
        -- atomics need nothing beyond the CRT.
        windows      = { cflags = { "-D_CRT_SECURE_NO_WARNINGS" } },
        targets      = { ["quickjs-ng"] = { kind = "lib" } },
        deps         = { },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

-- Once a descriptor defines install(), the archive is extracted to a sibling of
-- the install dir rather than into it; moving it is the descriptor's job.
-- The release unpacks to `quickjs-<version>/`. Moving that directory to be the
-- install dir itself leaves no version in any path of the descriptor, so a new
-- release needs no edit here (the wrap name is derived, not listed).
function install()
    local v = pkginfo.version()
    local srcroot
    for _, name in ipairs({ "quickjs-" .. v, "quickjs-ng-" .. v, "quickjs-v" .. v }) do
        if os.isfile(path.join(name, "quickjs.h")) then
            srcroot = name
            break
        end
    end
    if not srcroot then
        log.error("[quickjs-ng] extracted tree not found (looked for quickjs-%s)", v)
        return false
    end
    os.tryrm(pkginfo.install_dir())
    os.mv(srcroot, pkginfo.install_dir())
    if not os.isfile(path.join(pkginfo.install_dir(), "quickjs.h")) then
        log.error("[quickjs-ng] quickjs.h missing from the release tarball")
        return false
    end
    return true
end
