-- compat.box2d — Box2D v3, the 2D rigid-body physics engine for games, MIT.
--
-- Box2D 3.x is a C17 rewrite of the engine (bodies, shapes, joints, contact
-- and sensor events, ray and shape casts, continuous collision, a built-in
-- task scheduler) with no dependencies beyond the C library. Upstream
-- documents it as cross-platform deterministic: the same inputs give the
-- same bits on x86_64 (SSE2 or AVX2) and arm64 (Neon), with any worker
-- count, as long as the floating point is built as upstream builds it. Its
-- own test suite pins that as a hash (test/test_determinism.c, the "falling
-- hinges" scene: sleep step 299, hash 0x465F3DF4 in single precision).
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE BUILD UPSTREAM'S CMAKE MAKES, AND WHY EACH FLAG
--
--   sources       every src/*.c (src/CMakeLists.txt's BOX2D_SOURCE_FILES is
--                 exactly the .c files of src/; the .inl files are included
--                 by contact_solver_w4.c / _w8.c and recording.c).
--   C17, GNU      `C_STANDARD 17`, `C_EXTENSIONS YES`: c_standard "gnu17"
--                 (-std=gnu17, the last -std on the line).
--   -ffp-contract=off
--                 CMakeLists.txt "Deterministic math": contraction of a*b+c
--                 into an FMA is the one value-changing transform compilers
--                 enable by default, and whether it fires depends on the
--                 target (arm64 always has FMA; x86_64 only under AVX2/FMA,
--                 which the AVX2 solver file is). Upstream sets it for every
--                 GCC and Clang, and for clang-cl as /clang:-ffp-contract=off;
--                 this index's Windows toolchain is clang's GNU-style driver
--                 targeting MSVC, which takes the plain flag. Without it the
--                 determinism hash differs between rows.
--   SIMD          upstream's default (BOX2D_DISABLE_SIMD off): src/core.h
--                 picks SSE2 on x86_64 and Neon on arm64 from the compiler's
--                 predefined macros, and on x86_64 additionally compiles
--                 contact_solver_w8.c under `#pragma GCC target("avx2")` /
--                 `clang attribute push(target("avx2"))`, chosen at run time
--                 by cpuid (src/simd.c) — no -mavx2 for the build. The 4-wide
--                 and 8-wide solvers give the same bits (upstream's
--                 SSE2-fallback determinism test).
--   -fvisibility=hidden
--                 `CMAKE_C_VISIBILITY_PRESET hidden`: of a shared object a
--                 consumer links this into, only its own exports are visible;
--                 the B2_API declarations need no attribute in a static
--                 library (BOX2D_EXPORT is empty without box2d_EXPORTS).
--   -fPIC         unix: linked into shared objects by its consumers. Not on
--                 Windows (PE/COFF; clang rejects it for the MSVC target).
--   -lm -lpthread linux: libm for sqrtf/atan2f, pthreads for the built-in
--                 scheduler's workers (src/timer.c). macOS has both in
--                 libSystem; Windows uses CreateThread (kernel32).
--
-- NOT DEFINED, as a FetchContent / installed consumer of upstream gets it:
-- BOX2D_VALIDATE (a top-level-only option; only effective without NDEBUG),
-- B2_ENABLE_ASSERT (RelWithDebInfo only), BOX2D_PROFILE (Tracy),
-- BOX2D_DOUBLE_PRECISION (large worlds; it is PUBLIC upstream because it
-- changes the headers' types, so it would be a separate package, not a
-- consumer define). B2_ASSERT is on when NDEBUG is not defined, upstream's
-- rule (include/box2d/base.h).
--
-- kind = "lib": a static library; consumers `#include <box2d/box2d.h>`.
-- src/ is not on the consumer's include path: the sources include their
-- internal headers in quote form beside themselves.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "box2d",
    description = "Box2D 3.2.0 — the 2D rigid-body physics engine for games (C17, cross-platform deterministic), MIT",
    licenses    = {"MIT"},
    repo        = "https://github.com/erincatto/box2d",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/erincatto/box2d/archive/refs/tags/${tag}.tar.gz",
        },
    },

    -- One source tarball for every platform.
    xpm = {
        linux = {
            ["3.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/erincatto/box2d/archive/refs/tags/v3.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/box2d/releases/download/3.2.0/box2d-3.2.0.tar.gz",
                },
                sha256 = "ffec747b27a2267016f8d0240d658c82d187fb2271fa0f69fcbe53fbc067180d",
            },
        },
        macosx = {
            ["3.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/erincatto/box2d/archive/refs/tags/v3.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/box2d/releases/download/3.2.0/box2d-3.2.0.tar.gz",
                },
                sha256 = "ffec747b27a2267016f8d0240d658c82d187fb2271fa0f69fcbe53fbc067180d",
            },
        },
        windows = {
            ["3.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/erincatto/box2d/archive/refs/tags/v3.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/box2d/releases/download/3.2.0/box2d-3.2.0.tar.gz",
                },
                sha256 = "ffec747b27a2267016f8d0240d658c82d187fb2271fa0f69fcbe53fbc067180d",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "gnu17",

        -- The public headers, included as <box2d/box2d.h>. They declare the
        -- API as `extern "C"` under C++ themselves (B2_API).
        include_dirs = { "*/include" },

        sources = { "*/src/*.c" },
        cflags  = { "-ffp-contract=off" },

        -- The Web: src/core.h maps wasm onto the SSE2 path, whose intrinsics
        -- compile only with wasm SIMD enabled (upstream's CMakeLists.txt sets
        -- exactly these two for EMSCRIPTEN). A program running it needs a
        -- browser or node with wasm SIMD (every current one).
        target_cfg = {
            ["cfg(os = \"emscripten\")"] = {
                cflags = { "-msimd128", "-msse2" },
            },
        },

        linux = {
            cflags  = { "-fPIC", "-fvisibility=hidden" },
            ldflags = { "-lm", "-lpthread" },
        },
        macosx = {
            cflags = { "-fPIC", "-fvisibility=hidden" },
        },

        targets = { box2d = { kind = "lib" } },
        deps    = {},
    },
}
