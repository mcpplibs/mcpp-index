-- compat.xxhash — xxHash, an extremely fast non-cryptographic hash.
--
-- Shape A (C-source compat): one translation unit, one public header, no
-- configuration. A consumer writes `#include <xxhash.h>` and links the lib.
--
-- COMPILED, not XXH_INLINE_ALL. Upstream offers a header-only mode by defining
-- XXH_INLINE_ALL before the include, which re-emits the whole implementation in
-- every translation unit that hashes anything. That is the right trade only when
-- exactly one TU uses it; a package cannot know that, and the compiled form is
-- what every distribution ships. A consumer that does want the inline mode still
-- can — the header honours the macro regardless of this lib being linked.
--
-- The xxh_x86dispatch.c dispatcher is deliberately NOT compiled: it exists to
-- select an AVX2/AVX512 path at runtime and requires per-file -mavx2 flags plus
-- XXH_X86DISPATCH at every call site. Without it the SSE2 baseline path is used,
-- which needs no flags and no CPU detection.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "xxhash",
    description = "Extremely fast non-cryptographic hash algorithm (XXH32/XXH64/XXH3)",
    licenses    = {"BSD-2-Clause"},
    repo        = "https://github.com/Cyan4973/xxHash",
    type        = "package",

    xpm = {
        linux = {
            ["0.8.3"] = {
                url = {
                    GLOBAL = "https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xxhash/releases/download/0.8.3/xxhash-0.8.3.tar.gz",
                },
                sha256 = "aae608dfe8213dfd05d909a57718ef82f30722c392344583d3f39050c7f29a80",
            },
        },
        macosx = {
            ["0.8.3"] = {
                url = {
                    GLOBAL = "https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xxhash/releases/download/0.8.3/xxhash-0.8.3.tar.gz",
                },
                sha256 = "aae608dfe8213dfd05d909a57718ef82f30722c392344583d3f39050c7f29a80",
            },
        },
        windows = {
            ["0.8.3"] = {
                url = {
                    GLOBAL = "https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xxhash/releases/download/0.8.3/xxhash-0.8.3.tar.gz",
                },
                sha256 = "aae608dfe8213dfd05d909a57718ef82f30722c392344583d3f39050c7f29a80",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        -- Tarball root: xxhash.h, xxh3.h and xxhash.c all sit there, so a
        -- consumer's `#include <xxhash.h>` resolves against `*/`.
        include_dirs = { "*" },
        sources      = { "*/xxhash.c" },
        targets      = { ["xxhash"] = { kind = "lib" } },
        deps         = { },
    },
}
