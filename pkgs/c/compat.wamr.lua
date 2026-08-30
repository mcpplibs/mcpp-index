-- Form B inline descriptor for WAMR (WebAssembly Micro Runtime) — Bytecode
-- Alliance's small-footprint WebAssembly runtime. Pure-C source build, same
-- shape as compat.mbedtls: compile the interpreter runtime into one lib and
-- expose `wasm_export.h` / `wasm_c_api.h`.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/` absorbs
-- the GitHub tarball's `wasm-micro-runtime-WAMR-2.4.5/` wrap layer.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY A GENERATED CONFIG HEADER AND A GENERATED .S
--
-- WAMR does not select its target from the compiler's own predefined macros.
-- `wasm_runtime_common.c` wraps the whole invoke-native section in
-- `#if defined(BUILD_TARGET_X86_64) || defined(BUILD_TARGET_AARCH64) || …`,
-- so with none of them defined the runtime compiles with no way to call a
-- native function at all — the build succeeds and the link fails. Upstream's
-- CMake sets the right one from `WAMR_BUILD_TARGET`. A descriptor cannot: the
-- schema varies `sources`/`cflags` per OS, not per architecture (`archs` is
-- package-level metadata, not a selector).
--
-- Both halves of that problem are solved by letting the preprocessor read the
-- compiler's architecture macros instead:
--
--   * `mcpp_wamr_config.h` maps `__x86_64__`/`__aarch64__` to the matching
--     `BUILD_TARGET_*`, and arrives on every TU through `-include`. Same
--     mechanism compat.zlib uses for `Z_HAVE_UNISTD_H`.
--   * `mcpp_wamr_invoke_native.S` picks the matching assembly implementation.
--     Upstream's files are `arch/invokeNative_em64.s` and
--     `arch/invokeNative_aarch64.s` — lowercase `.s`, which clang assembles
--     WITHOUT running the preprocessor, so they cannot guard themselves the
--     way libffi's `.S` files do. Naming our own dispatcher `.S` gets it
--     preprocessed, `#include` pulls the chosen file in as text, and the
--     `#ifndef BH_PLATFORM_DARWIN` guard already inside those files then
--     works as upstream intended.
--
-- Verified: both branches assemble and define `invokeNative`
-- (`clang -c` and `clang --target=aarch64-unknown-linux-gnu -c`).
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY -std=gnu11 AND NOT c_standard = "c11"
--
-- `core/shared/platform/linux/platform_internal.h` writes the GS base with a
-- bare `asm volatile`. `-std=c11` defines __STRICT_ANSI__, under which `asm`
-- is not a keyword (only `__asm__` is), and `wasm_memory.c` plus
-- `wasm_interp_fast.c` fail to compile. Upstream builds as a GNU dialect.
-- The alternative — `-DWASM_DISABLE_WRITE_GS_BASE=1`, which is a real upstream
-- knob — also compiles, but turns off a fast-path memory access on x86_64 to
-- work around a language-mode choice, so the dialect flag is the honest fix.
--
-- ─────────────────────────────────────────────────────────────────────────
-- LINUX ONLY, DELIBERATELY
--
-- WAMR itself is portable (there are `platform/darwin` and `platform/windows`
-- trees, and the assembly files carry Darwin guards), but neither was built or
-- run while writing this descriptor, and Windows additionally has to settle
-- whether it takes upstream's MASM `.asm` or the MinGW `.s` variant. Rather
-- than declare platforms on the strength of them looking symmetric, `xpm`
-- carries `linux` only and consumers gate with `[target.'cfg(linux)'…]` —
-- the same shape compat.libaio uses. macOS and Windows sections can be added
-- by someone able to verify them.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHAT THE BASE CONTAINS
--
-- Interpreter runtime only: classic + fast interpreter, bulk memory and
-- reference types (both on in upstream's own default build), no AOT, no JIT,
-- and no libc for the guest. That is the configuration an embedder wants when
-- wasm modules are plugins reached only through host-provided imports.
-- Guest-facing libc comes in through the two features.
--
--   * `libc-builtin` — upstream's built-in libc wrappers (printf, memcpy,
--     malloc … exported to the guest under `env`).
--   * `libc-wasi`    — WASI preview1, which also needs the three POSIX
--     platform files upstream excludes when WASI is off
--     (`posix_file.c`, `posix_clock.c`, `posix_socket.c`) plus `libc-util`.
--
-- Both are safe as features: `core/iwasm/include/wasm_export.h` never branches
-- on `WASM_ENABLE_LIBC_BUILTIN` or `WASM_ENABLE_LIBC_WASI` (both appear zero
-- times outside comments), so a consumer compiled without the define still
-- sees the same types as the library — the ABI hazard that keeps
-- compat.recastnavigation's DT_POLYREF64 out of the feature table does not
-- apply here.
--
-- ─────────────────────────────────────────────────────────────────────────
-- CN MIRROR
--
-- Not created: no `mcpp-res` write access. `url` is the plain-string upstream
-- form, which lint accepts and which makes CN users fall back to GitHub. A
-- maintainer can promote it to the `{ GLOBAL=…, CN=… }` table later.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "wamr",
    description = "WebAssembly Micro Runtime — small-footprint WebAssembly interpreter from the Bytecode Alliance",
    licenses    = {"Apache-2.0 WITH LLVM-exception"},
    repo        = "https://github.com/bytecodealliance/wasm-micro-runtime",
    type        = "package",

    xpm = {
        linux = {
            ["2.4.5"] = {
                url    = "https://github.com/bytecodealliance/wasm-micro-runtime/archive/refs/tags/WAMR-2.4.5.tar.gz",
                sha256 = "1ab09d51099f276ca4a1d6629f6b589aab2bd0caa01445e05031a4bed22c199b",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",

        include_dirs = {
            -- public: wasm_export.h / wasm_c_api.h, and the platform types
            -- wasm_export.h refers to
            "*/core/iwasm/include",
            "*/core/shared/platform/include",
            -- internal: WAMR's TUs include each other by bare filename
            "*/core",
            "*/core/iwasm/common",
            "*/core/iwasm/interpreter",
            "*/core/shared/include",
            "*/core/shared/platform/linux",
            "*/core/shared/mem-alloc",
            "*/core/shared/utils",
            -- reached by the generated dispatcher's #include
            "*/core/iwasm/common/arch",
            -- The two features' header roots. They live here rather than in
            -- the feature entries because a feature can only carry sources,
            -- defines, deps, implies and requires -- there is no include_dirs
            -- in a feature. And they are needed by BASE translation units, not
            -- just the feature's own: with WASM_ENABLE_LIBC_WASI=1,
            -- common/wasm_runtime_common.h itself opens `#include "posix.h"`,
            -- so wasm_loader.c and wasm_runtime.c stop compiling without the
            -- sandboxed-system-primitives roots. Listing them unconditionally
            -- costs nothing when the features are off: they are -I paths into
            -- directories no base source includes from.
            "*/core/iwasm/libraries/libc-builtin",
            "*/core/iwasm/libraries/libc-wasi",
            "*/core/iwasm/libraries/libc-wasi/sandboxed-system-primitives/include",
            "*/core/iwasm/libraries/libc-wasi/sandboxed-system-primitives/src",
            "*/core/shared/platform/common/libc-util",
            "mcpp_generated/include",
        },

        linux = {
            cflags = {
                -- see "WHY -std=gnu11" above; appended after c_standard so it wins
                "-std=gnu11",
                "-D_GNU_SOURCE",
                "-DBH_PLATFORM_LINUX",
                -- upstream's iwasm_common.cmake sets both unconditionally
                "-DBH_MALLOC=wasm_runtime_malloc",
                "-DBH_FREE=wasm_runtime_free",
                "-DWASM_ENABLE_INTERP=1",
                "-DWASM_ENABLE_FAST_INTERP=1",
                "-DWASM_ENABLE_BULK_MEMORY=1",
                "-DWASM_ENABLE_REF_TYPES=1",
                -- glibc/musl both have mremap; upstream probes for it with
                -- check_symbol_exists and falls back to its own allocator when
                -- absent. Linux always has it.
                "-DWASM_HAVE_MREMAP=1",
                "-include", "mcpp_wamr_config.h",
            },
            ldflags = { "-lpthread", "-lm" },
        },

        generated_files = {
            ["mcpp_generated/include/mcpp_wamr_config.h"] =
[==[
#ifndef MCPP_WAMR_CONFIG_H
#define MCPP_WAMR_CONFIG_H
/* WAMR takes its target from BUILD_TARGET_*, which upstream's CMake sets from
   WAMR_BUILD_TARGET. A descriptor has no per-architecture hook, so derive it
   from the compiler's own macros instead. Without one of these defined, the
   invoke-native section of wasm_runtime_common.c compiles to nothing and the
   link fails on `invokeNative`. */
#if defined(__x86_64__) || defined(__amd64__) || defined(_M_X64)
#define BUILD_TARGET_X86_64
#elif defined(__aarch64__) || defined(_M_ARM64)
#define BUILD_TARGET_AARCH64
#else
#error "compat.wamr: no BUILD_TARGET_* for this architecture"
#endif
#endif /* MCPP_WAMR_CONFIG_H */
]==],
            ["mcpp_generated/mcpp_wamr_invoke_native.S"] =
[==[
/* Architecture dispatch for WAMR's invokeNative.

   Upstream ships one hand-written assembly implementation per architecture as
   `arch/invokeNative_<arch>.s`. Lowercase `.s` is assembled without the C
   preprocessor, so those files cannot select themselves and a descriptor
   cannot select between them either. This file is `.S`, so it IS
   preprocessed: the #include below pastes the chosen implementation in, and
   the `#ifndef BH_PLATFORM_DARWIN` guard already inside it is honoured. */
#if defined(__x86_64__) || defined(__amd64__)
#include "invokeNative_em64.s"
#elif defined(__aarch64__)
#include "invokeNative_aarch64.s"
#else
#error "compat.wamr: no invokeNative implementation for this architecture"
#endif
]==],
        },

        sources = {
            -- runtime core
            "*/core/iwasm/common/*.c",
            "mcpp_generated/mcpp_wamr_invoke_native.S",
            -- interpreter: loader + runtime + the fast interpreter.
            -- wasm_mini_loader.c and wasm_interp_classic.c are upstream's
            -- alternatives to these two, not additions — including them would
            -- define the same symbols twice.
            "*/core/iwasm/interpreter/wasm_loader.c",
            "*/core/iwasm/interpreter/wasm_runtime.c",
            "*/core/iwasm/interpreter/wasm_interp_fast.c",
            -- platform layer
            "*/core/shared/platform/linux/*.c",
            -- posix_file.c, posix_clock.c and posix_socket.c are in here.
            -- Upstream's platform_api_posix.cmake drops those three (and
            -- libc-util below) unless LIBC_WASI or the debug interpreter is on,
            -- and the natural translation would be a `!` exclusion in the base
            -- with the libc-wasi feature adding them back. That does not work:
            -- an exclusion glob is global, so the feature's own entry for the
            -- same file is still excluded and the WASI build fails to link
            -- (os_file_get_access_mode, os_closedir, os_is_dir_stream_valid).
            -- They compile cleanly with WASI off — verified file by file — so
            -- the base simply always carries them. The cost is a few KB of
            -- unreferenced objects the linker drops.
            "*/core/shared/platform/common/posix/*.c",
            "*/core/shared/platform/common/libc-util/*.c",
            -- allocator and utils
            "*/core/shared/mem-alloc/mem_alloc.c",
            "*/core/shared/mem-alloc/ems/*.c",
            "*/core/shared/utils/*.c",
        },

        targets = { ["wamr"] = { kind = "lib" } },

        features = {
            -- Built-in libc wrappers exported to the guest under `env`.
            ["libc-builtin"] = {
                sources = { "*/core/iwasm/libraries/libc-builtin/*.c" },
                defines = { "WASM_ENABLE_LIBC_BUILTIN=1" },
            },
            -- WASI preview1. The POSIX support files this needs are already
            -- unconditionally in the base sources; see the note there.
            ["libc-wasi"] = {
                sources = { "*/core/iwasm/libraries/libc-wasi/**/*.c" },
                -- runtime_lib.cmake:97-99 turns MODULE_INST_CONTEXT on
                -- together with LIBC_WASI; without it wasm_native.c calls
                -- wasm_native_{get,set}_context and the context-key helpers
                -- that wasm_native.h only declares under that macro.
                defines = {
                    "WASM_ENABLE_LIBC_WASI=1",
                    "WASM_ENABLE_MODULE_INST_CONTEXT=1",
                },
            },
        },

        deps = { },
    },
}
