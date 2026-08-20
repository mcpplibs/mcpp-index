-- std-freestanding-nolibc — the five C functions a freestanding C++
-- translation unit still reaches for, for targets that have declined one.
--
-- ⚠️ FOR THE ZERO-LIBC TIER ONLY. mcpp contributes a dependency package's
-- object files to the consumer's link unconditionally, so a project whose
-- board package links `-lc` would get two definitions of `memcpy`. The
-- intended consumer sets `[target.<triple>].sysroot = ""`.
--
-- Four of the five are an obligation rather than a convenience: a freestanding
-- implementation provides memcpy, memmove, memset and memcmp because the
-- compiler lowers structure assignment and array initialisation onto them.
--
-- ⚠️ 0.1.1 corrects a claim, not code. 0.1.0 predicted that using this package
-- alongside a C library would fail with a duplicate definition. Measured: it
-- does not. A C library is an ARCHIVE, and an archive member is pulled only
-- while the symbol is still undefined, so this package's object files define
-- `memcpy` first and the C library's member is never pulled. The build
-- succeeds, silently substituting byte-at-a-time implementations for the C
-- library's optimised ones — which is worse than the error that was predicted.
-- 0.1.0 stays listed because a published version is one somebody may have
-- pinned.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "std-freestanding-nolibc",
    description = "memcpy, memmove, memset, memcmp and strlen for targets with no C library",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/std-freestanding-nolibc",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-nolibc/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-nolibc/releases/download/0.1.0/std-freestanding-nolibc-0.1.0.tar.gz",
                },
                sha256 = "280ffe0180e0bd19ef94d4655c564507c4799e5c72ac7624d58722cb8aac363a",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-nolibc/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-nolibc/releases/download/0.1.1/std-freestanding-nolibc-0.1.1.tar.gz",
                },
                sha256 = "8999ec9db31699569e14a9c5f0fa24f4736961b1d8aec143c4d0cc7e5a978ec0",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-nolibc/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-nolibc/releases/download/0.2.0/std-freestanding-nolibc-0.2.0.tar.gz",
                },
                sha256 = "8e3509752d0a13411b5eabf64c3b9420cf904bbc7bba9e1ab0bd8f16b69e7afd",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-nolibc/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-nolibc/releases/download/0.1.0/std-freestanding-nolibc-0.1.0.tar.gz",
                },
                sha256 = "280ffe0180e0bd19ef94d4655c564507c4799e5c72ac7624d58722cb8aac363a",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-nolibc/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-nolibc/releases/download/0.1.1/std-freestanding-nolibc-0.1.1.tar.gz",
                },
                sha256 = "8999ec9db31699569e14a9c5f0fa24f4736961b1d8aec143c4d0cc7e5a978ec0",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-nolibc/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-nolibc/releases/download/0.2.0/std-freestanding-nolibc-0.2.0.tar.gz",
                },
                sha256 = "8e3509752d0a13411b5eabf64c3b9420cf904bbc7bba9e1ab0bd8f16b69e7afd",
            },
        },
        windows = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-nolibc/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-nolibc/releases/download/0.1.0/std-freestanding-nolibc-0.1.0.tar.gz",
                },
                sha256 = "280ffe0180e0bd19ef94d4655c564507c4799e5c72ac7624d58722cb8aac363a",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-nolibc/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-nolibc/releases/download/0.1.1/std-freestanding-nolibc-0.1.1.tar.gz",
                },
                sha256 = "8999ec9db31699569e14a9c5f0fa24f4736961b1d8aec143c4d0cc7e5a978ec0",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-nolibc/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-nolibc/releases/download/0.2.0/std-freestanding-nolibc-0.2.0.tar.gz",
                },
                sha256 = "8e3509752d0a13411b5eabf64c3b9420cf904bbc7bba9e1ab0bd8f16b69e7afd",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
