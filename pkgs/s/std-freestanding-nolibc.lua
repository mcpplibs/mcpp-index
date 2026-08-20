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
        },
        macosx = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-nolibc/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-nolibc/releases/download/0.1.0/std-freestanding-nolibc-0.1.0.tar.gz",
                },
                sha256 = "280ffe0180e0bd19ef94d4655c564507c4799e5c72ac7624d58722cb8aac363a",
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
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
