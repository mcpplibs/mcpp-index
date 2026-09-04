-- picolibc as a SOURCE package: compiled with the consuming program's own flags.
--
-- ⭐⭐ THERE IS NO MULTILIB HERE, AND THAT IS WHY IT IS A SOURCE PACKAGE.
--
-- A prebuilt C library ships one build per ABI a target table can name — seven
-- for Cortex-M alone — and every consumer then finds the right one through a
-- `libdir` convention that must match the payload byte for byte. That
-- convention is what #481 was filed about, and on ARM it cannot work at all:
-- the key `<march>/<mabi>` does not separate the float ABI, because `mabi`
-- there names the procedure call standard and is `aapcs` either way.
--
-- Measured while building the prebuilt (`xim:picolibc-arm`, which remains
-- published and is NOT the route): the seven profiles collapsed into five
-- directories and the soft-float row received a library carrying
-- `Tag_ABI_HardFP_use`. Nothing failed at build time.
--
-- ⚠️ AND THE HEADERS WERE NEVER PER-PROFILE. Measured across those seven
-- builds, the whole include tree — `picolibc.h` and `newlib.h`, which meson
-- GENERATES, included — is byte-identical. The prebuilt ships seven copies of
-- one directory.
--
-- ⭐ Compiled with the SAME `compile_flags` as the program consuming it, ABI
-- agreement holds by construction rather than by a naming convention, and the
-- version lands in `mcpp.lock` rather than being pinned inside a target table.
--
-- ⚠️ `picocrt` IS DELIBERATELY ABSENT. A startup object decides where execution
-- begins and how it reaches the host — which board is running. Choosing among
-- picolibc's nine variants is a board-support package's job; `cortex-m-rt`
-- supplies its own, including the thread-pointer initialisation without which
-- a `printf` program links cleanly, runs, prints nothing and hangs.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "picolibc",
    description = "picolibc as a source package: a freestanding C library compiled with the consuming program's own flags, so there is no multilib and no ABI convention to match",
    licenses    = {"BSD-3-Clause", "BSD-2-Clause"},
    repo        = "https://github.com/mcpplibs/picolibc",
    type        = "package",

    xpm = {
        linux = {
            ["1.8.12"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/picolibc/archive/refs/tags/1.8.12.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/picolibc/releases/download/1.8.12/picolibc-1.8.12.tar.gz",
                },
                sha256 = "8f3d7a41d9981905d389b321edbfa2fac4946e5acc3a0677617b8184b21d4420",
            },
        },
        macosx = {
            ["1.8.12"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/picolibc/archive/refs/tags/1.8.12.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/picolibc/releases/download/1.8.12/picolibc-1.8.12.tar.gz",
                },
                sha256 = "8f3d7a41d9981905d389b321edbfa2fac4946e5acc3a0677617b8184b21d4420",
            },
        },
        windows = {
            ["1.8.12"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/picolibc/archive/refs/tags/1.8.12.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/picolibc/releases/download/1.8.12/picolibc-1.8.12.tar.gz",
                },
                sha256 = "8f3d7a41d9981905d389b321edbfa2fac4946e5acc3a0677617b8184b21d4420",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
