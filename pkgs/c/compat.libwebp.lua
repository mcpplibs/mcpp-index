-- compat.libwebp — the WebP image codec, encode + decode, built from upstream
-- source rather than linked against a host libwebp.
--
-- Shape A (C-source compat): a consumer writes `#include <webp/encode.h>` /
-- `<webp/decode.h>` and links one lib.
--
-- WHAT IS IN THE LIB. dec + enc + dsp + utils + sharpyuv, as five directory
-- globs. sharpyuv is inside the SAME archive rather than a package of its own
-- because the encoder's picture_csp_enc.c calls into it directly — upstream's
-- CMake builds it as a separate target only to reuse it elsewhere, and there is
-- nothing else here to reuse it.
--
-- WHAT IS NOT. `src/demux` and `src/mux` (animation and metadata containers:
-- WebPDemux* / WebPMux*) are separate upstream libraries with their own public
-- headers; they belong in a feature, and nothing asks for them yet.
-- `examples/`, `extras/`, `imageio/` and `swig/` are tools and bindings.
--
-- SIMD. Every `src/dsp/*_sse2.c`, `*_sse41.c`, `*_neon.c`, `*_mips*.c`, `*_msa.c`
-- variant is compiled unconditionally and gates ITSELF: src/dsp/cpu.h keys off
-- the compiler's own `__SSE2__` / `__SSE4_1__` / `__aarch64__` built-ins, so a
-- variant that does not match the target compiles to an empty translation unit
-- and the runtime CPU probe falls back to scalar. That is why the glob is safe
-- and why there are no per-file flags here.
--
-- SSE4.1 needs `-msse4.1` per file to actually be emitted, which this package
-- does not add: it would make the artifact require an SSE4.1 CPU. x86-64's
-- baseline SSE2 and aarch64's baseline NEON are both on without any flag.
--
-- INCLUDE ROOTS, both of them. The library's own sources include flat from the
-- archive root (`#include "src/dsp/dsp.h"`, `"sharpyuv/sharpyuv.h"`), while
-- consumers include `<webp/decode.h>` — which lives at `src/webp/decode.h`. Both
-- roots therefore travel to dependents.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libwebp",
    description = "WebP image codec: encode + decode + sharpyuv, built from upstream sources",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/webmproject/libwebp",
    type        = "package",

    xpm = {
        linux = {
            ["1.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/webmproject/libwebp/archive/refs/tags/v1.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libwebp/releases/download/1.5.0/libwebp-1.5.0.tar.gz",
                },
                sha256 = "668c9aba45565e24c27e17f7aaf7060a399f7f31dba6c97a044e1feacb930f37",
            },
        },
        macosx = {
            ["1.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/webmproject/libwebp/archive/refs/tags/v1.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libwebp/releases/download/1.5.0/libwebp-1.5.0.tar.gz",
                },
                sha256 = "668c9aba45565e24c27e17f7aaf7060a399f7f31dba6c97a044e1feacb930f37",
            },
        },
        windows = {
            ["1.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/webmproject/libwebp/archive/refs/tags/v1.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libwebp/releases/download/1.5.0/libwebp-1.5.0.tar.gz",
                },
                sha256 = "668c9aba45565e24c27e17f7aaf7060a399f7f31dba6c97a044e1feacb930f37",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*", "*/src" },
        -- 117 translation units, as five directory globs. Each directory holds
        -- only library code; the tools live in examples/ extras/ imageio/ swig/
        -- and the container libraries in src/demux src/mux, none of which are
        -- matched here.
        sources = {
            "*/src/dec/*.c",
            "*/src/enc/*.c",
            "*/src/dsp/*.c",
            "*/src/utils/*.c",
            "*/sharpyuv/*.c",
        },
        targets = { ["webp"] = { kind = "lib" } },
        deps    = { },

        -- libm for the dsp math, pthread for utils/thread_utils.c's worker pool.
        -- Both are sysroot components, not third-party host libraries. Windows
        -- needs neither: the CRT carries the math and thread_utils uses the Win32
        -- thread API directly.
        linux  = { ldflags = { "-lpthread", "-lm" } },
        macosx = { ldflags = { "-lpthread", "-lm" } },
    },
}
