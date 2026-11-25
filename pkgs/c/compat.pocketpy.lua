-- compat.pocketpy — PocketPy 2, a small embeddable Python 3.x interpreter in
-- C11 (MIT).
--
-- Shape A (C-source compat): upstream's library target, built from the tag
-- archive as upstream's CMake builds it by default. A consumer writes
-- `#include <pocketpy.h>` and links the lib.
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
-- ONE TRANSLATION UNIT, as upstream builds it: CMake's default is a unity
-- build of the whole of POCKETPY_SRC in one group (PK_BUILD_WITH_UNITY,
-- UNITY_BUILD_MODE GROUP), and the release's pocketpy.c is the same sources
-- amalgamated. The generated pocketpy_unity.c below includes the 84 files in
-- CMake's order (GLOB_RECURSE sorts them). The sources rely on it: with
-- NDEBUG, PK_INLINE marks functions the headers declare and other files call
-- (py_retval, py_peek, PyObject__userdata …) `inline`, whose definitions
-- clang does not emit for the MSVC ABI, so compiled one by one they leave
-- undefined symbols on Windows; and calls across files inline as upstream's
-- build inlines them. The file list is 2.2.0's: a new version's must be
-- checked against its src/.
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
--   PK_ENABLE_THREADS=0     config.h's default (CMake's is on). Off, pkpy has
--                           no ComputeThread and names are interned without a
--                           lock: the same on every platform, the Web
--                           included, where a program has no threads unless
--                           built for shared memory (-pthread).
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
-- and wasm32-emscripten, the same translation unit and flags. Linux links libm for a
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
        sources      = { "*/mcpp/pocketpy_unity.c" },
        generated_files = {
            ["pocketpy-2.2.0/mcpp/pocketpy_unity.c"] = [==[
/* compat.pocketpy: upstream's unity build (CMakeLists.txt, PK_BUILD_WITH_UNITY,
   one UNITY_GROUP): every C source under src of 2.2.0, in the order of
   CMake's GLOB_RECURSE. */
#include "../src/bindings/py_array.c"
#include "../src/bindings/py_mappingproxy.c"
#include "../src/bindings/py_method.c"
#include "../src/bindings/py_number.c"
#include "../src/bindings/py_object.c"
#include "../src/bindings/py_property.c"
#include "../src/bindings/py_range.c"
#include "../src/bindings/py_str.c"
#include "../src/common/_generated.c"
#include "../src/common/algorithm.c"
#include "../src/common/chunkedvector.c"
#include "../src/common/dmath.c"
#include "../src/common/memorypool.c"
#include "../src/common/name.c"
#include "../src/common/serialize.c"
#include "../src/common/smallmap.c"
#include "../src/common/socket.c"
#include "../src/common/sourcedata.c"
#include "../src/common/sstream.c"
#include "../src/common/str.c"
#include "../src/common/threads.c"
#include "../src/common/vector.c"
#include "../src/compiler/compiler.c"
#include "../src/compiler/lexer.c"
#include "../src/debugger/core.c"
#include "../src/debugger/dap.c"
#include "../src/interpreter/ceval.c"
#include "../src/interpreter/dll.c"
#include "../src/interpreter/frame.c"
#include "../src/interpreter/generator.c"
#include "../src/interpreter/heap.c"
#include "../src/interpreter/line_profiler.c"
#include "../src/interpreter/objectpool.c"
#include "../src/interpreter/py_compile.c"
#include "../src/interpreter/typeinfo.c"
#include "../src/interpreter/vm.c"
#include "../src/interpreter/vmx.c"
#include "../src/modules/array2d.c"
#include "../src/modules/base64.c"
#include "../src/modules/builtins.c"
#include "../src/modules/colorcvt.c"
#include "../src/modules/conio.c"
#include "../src/modules/dis.c"
#include "../src/modules/easing.c"
#include "../src/modules/enum.c"
#include "../src/modules/gc.c"
#include "../src/modules/importlib.c"
#include "../src/modules/inspect.c"
#include "../src/modules/json.c"
#include "../src/modules/lz4.c"
#include "../src/modules/math.c"
#include "../src/modules/os.c"
#include "../src/modules/pickle.c"
#include "../src/modules/picoterm.c"
#include "../src/modules/pkpy.c"
#include "../src/modules/random.c"
#include "../src/modules/stdc.c"
#include "../src/modules/time.c"
#include "../src/modules/traceback.c"
#include "../src/modules/unicodedata.c"
#include "../src/modules/vmath.c"
#include "../src/objects/bintree.c"
#include "../src/objects/codeobject.c"
#include "../src/objects/codeobject_ser.c"
#include "../src/objects/container.c"
#include "../src/objects/namedict.c"
#include "../src/objects/object.c"
#include "../src/public/Bindings.c"
#include "../src/public/CodeExecution.c"
#include "../src/public/DictSlots.c"
#include "../src/public/FrameOps.c"
#include "../src/public/GlobalSetup.c"
#include "../src/public/Inspection.c"
#include "../src/public/ModuleSystem.c"
#include "../src/public/PyDict.c"
#include "../src/public/PyException.c"
#include "../src/public/PyList.c"
#include "../src/public/PySlice.c"
#include "../src/public/PyTuple.c"
#include "../src/public/PythonOps.c"
#include "../src/public/StackOps.c"
#include "../src/public/TypeSystem.c"
#include "../src/public/ValueCast.c"
#include "../src/public/ValueCreation.c"
]==],
        },
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
