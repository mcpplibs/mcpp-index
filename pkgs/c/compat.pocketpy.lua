-- compat.pocketpy — PocketPy 2, a small embeddable Python 3.x interpreter in
-- C11 (MIT).
--
-- Shape A (C-source compat): upstream's library target, built from the tag
-- archive with each source compiled on its own, as upstream's build.sh and
-- run_tests.sh build it. A consumer writes `#include <pocketpy.h>` and links
-- the lib.
--
-- WHAT IS COMPILED. Every src/**/*.c, which is exactly CMake's POCKETPY_SRC
-- (`file(GLOB_RECURSE … src/*.c)`): the compiler, the VM, the public C API
-- (src/public), the built-in types and the bundled modules (math, json,
-- pickle, random, time, os, array2d, vmath …). src/common/_generated.c, the
-- pure-Python part of the standard library as C strings, is checked in, so
-- upstream's prebuild.py does not need to run. Not compiled: src2/ (the
-- `main` REPL program and its tests), 3rd/ (the optional lz4, cute_png,
-- msgpack and periphery modules, each OFF in CMakeOptions.txt), and the
-- pybind11-style C++ layer under include/pybind11 (header-only, not built).
--
-- INCLUDE PATH. `*/include`, upstream's INTERFACE include directory
-- (`target_include_directories(pocketpy INTERFACE include)`): a consumer
-- includes <pocketpy.h>, which defines PK_IS_PUBLIC_INCLUDE and so declares
-- the py_TValue layout. The sources include their private headers as
-- "pocketpy/…" from there, so it cannot be narrower; the private headers are
-- all under pocketpy/, and upstream's pybind11-style C++ layer is under
-- pybind11/, as a CMake consumer sees them.
--
-- CONFIGURATION. The library is built with the PK_ENABLE_* values its own
-- include/pocketpy/config.h gives a consumer that defines none (the values a
-- consumer's <pocketpy.h> reads, and those of upstream's single-file release
-- and of its build.sh / run_tests.sh builds), except for two upstream options
-- that are on here:
--   PK_ENABLE_OS=1          the os module, file import, the debugger
--                           (config.h's default; CMake's too).
--   PK_ENABLE_THREADS=0     config.h's default. CMake turns it on, but only
--                           its unity build compiles that way: src/modules/
--                           time.c calls c11_thrd__yield without including
--                           the header that declares it, which a separate
--                           compilation (GCC 14+) rejects. Off, pkpy has no
--                           ComputeThread and names are interned without a
--                           lock; the same on every platform, the Web included.
--   PK_ENABLE_DLL=0         config.h's default: no import of native modules
--                           from shared libraries (dlopen / LoadLibrary).
--   PK_ENABLE_DETERMINISM=1 and -ffp-contract=off, as CMake builds it: float
--                           operations give the same bits on every platform
--                           (no contraction of a*b+c into an FMA; the math
--                           module is upstream's own dmath either way).
--   PK_ENABLE_WATCHDOG=1    pocketpy.h declares py_watchdog_begin and
--                           py_watchdog_end unconditionally, but they are
--                           defined only with the watchdog on: on, a host can
--                           end a runaway script with a TimeoutError. It costs
--                           one comparison per bytecode while no watchdog runs.
--   PK_ENABLE_CUSTOM_SNAME=0, PK_ENABLE_MIMALLOC=0: off, as everywhere.
-- NDEBUG follows the build profile, as it follows CMake's build type upstream
-- (defined for every type but Debug): the release profile defines it for the
-- library and its consumer alike, which matters because pocketpy.h declares
-- py_callcfunc as a function without NDEBUG and as a macro with it.
--
-- PLATFORMS. Linux (GCC, LLVM), macOS, Windows (clang targeting the MSVC ABI)
-- and wasm32-emscripten, the same sources and flags. Linux links libm for a
-- consumer linked by the C driver. Windows links ws2_32 (CMake, for the
-- debugger's socket) and defines _CRT_SECURE_NO_WARNINGS as CMake does.
--
-- ONE UPSTREAM FIX, applied in install() with a checked match count:
-- pocketpy commit de8351ed (2026-09-06, after the 2.2.0 tag, on main since).
-- An exception keeps up to seven traceback frames, each with a `locals` and a
-- `globals` value that only the debugger fills in; the garbage collector
-- marks both unconditionally, so a collection while an exception object is
-- alive reads uninitialised memory as values, and crashes when it looks like
-- a pointer. Upstream's own tests/901_array2d_extra1.py crashes so, built as
-- build.sh builds it (GCC 16, -O2). The fix sets both to nil when a frame is
-- recorded, as upstream's main does. Nothing else is changed.
--
-- NO CN MIRROR. The url is upstream's tag archive as a plain string, the
-- fallback docs/cn-mirror.md describes for a contributor without mcpp-res
-- write access; a maintainer can add the CN entry later, the sha256 stays.
--
-- LICENSE. MIT (LICENSE, Copyright (c) 2026 blueloveTH).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "pocketpy",
    description = "PocketPy 2.2.0, a small embeddable Python 3.x interpreter in C11 (MIT)",
    licenses    = {"MIT"},
    repo        = "https://github.com/pocketpy/pocketpy",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/pocketpy/pocketpy/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["2.2.0"] = {
                url    = "https://github.com/pocketpy/pocketpy/archive/refs/tags/v2.2.0.tar.gz",
                sha256 = "c67cb6a1422abe26114219d2e58441cbb3625bae6b25901d5b7f6f46b23ae8b3",
            },
        },
        macosx = {
            ["2.2.0"] = {
                url    = "https://github.com/pocketpy/pocketpy/archive/refs/tags/v2.2.0.tar.gz",
                sha256 = "c67cb6a1422abe26114219d2e58441cbb3625bae6b25901d5b7f6f46b23ae8b3",
            },
        },
        windows = {
            ["2.2.0"] = {
                url    = "https://github.com/pocketpy/pocketpy/archive/refs/tags/v2.2.0.tar.gz",
                sha256 = "c67cb6a1422abe26114219d2e58441cbb3625bae6b25901d5b7f6f46b23ae8b3",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "gnu11",
        include_dirs = { "*/include" },
        sources      = { "*/src/**/*.c" },
        cflags       = {
            "-ffp-contract=off",
            "-DPK_ENABLE_OS=1",
            "-DPK_ENABLE_THREADS=0",
            "-DPK_ENABLE_DLL=0",
            "-DPK_ENABLE_DETERMINISM=1",
            "-DPK_ENABLE_WATCHDOG=1",
            "-DPK_ENABLE_CUSTOM_SNAME=0",
            "-DPK_ENABLE_MIMALLOC=0",
        },
        linux = {
            ldflags = { "-lm" },
        },
        windows = {
            cflags  = { "-D_CRT_SECURE_NO_WARNINGS" },
            ldflags = { "-lws2_32" },
        },
        targets = { ["pocketpy"] = { kind = "lib" } },
        deps    = { },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

-- See the header note: upstream's fix for the uninitialised traceback-frame
-- values (de8351ed), then the unpacked tree moved into the install dir as its
-- single wrap level, so the `*/` globs keep matching (compat.libserial does
-- the same).
function install()
    local wrap = "pocketpy-" .. pkginfo.version()
    local source = path.join(wrap, "src/public/PyException.c")
    local content = io.readfile(source)
    if not content then
        log.error("compat.pocketpy: cannot read %s", source)
        return false
    end
    local before = "    BaseExceptionFrame* frame_dump = c11_vector__emplace(&ud->stacktrace);\n"
    local after = before
        .. "    // `locals` and `globals` are only filled in when the debugger is attached, but the GC\n"
        .. "    // walks them unconditionally; nil them out before anything below can allocate\n"
        .. "    py_newnil(&frame_dump->locals);\n"
        .. "    py_newnil(&frame_dump->globals);\n"
    local patched, count = content:gsub(before:gsub("(%W)", "%%%1"), function() return after end)
    if count ~= 1 then
        log.error("compat.pocketpy: expected 1 match in %s, found %d", source, count)
        return false
    end
    io.writefile(source, patched)

    local prefix = pkginfo.install_dir()
    os.tryrm(prefix)
    os.mkdir(prefix)
    os.mv(wrap, path.join(prefix, wrap))
    return true
end
