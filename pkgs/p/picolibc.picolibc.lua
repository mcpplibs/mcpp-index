-- picolibc as a SOURCE package: compiled with the consuming program's own flags.
--
-- THERE IS NO MULTILIB HERE, AND THAT IS WHY IT IS A SOURCE PACKAGE.
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
-- AND THE HEADERS WERE NEVER PER-PROFILE. Measured across those seven
-- builds, the whole include tree — `picolibc.h` and `newlib.h`, which meson
-- GENERATES, included — is byte-identical. The prebuilt ships seven copies of
-- one directory.
--
-- `picocrt` IS DELIBERATELY ABSENT. A startup object decides where execution
-- begins and how it reaches the host — which board is running. Choosing among
-- picolibc's nine variants is a board-support package's job; `cortex-m-rt`
-- supplies its own, including the thread-pointer initialisation without which a
-- `printf` program links cleanly, runs, prints nothing and hangs.
--
-- THE NAMESPACE IS UPSTREAM'S, NOT `mcpplibs`. This package vendors someone
-- else's sources and adds a manifest; the code is theirs and the identity says
-- so. `mcpplibs` is for packages whose CONTENT this organisation wrote.
--
-- The wrapper REPOSITORY can still live under mcpplibs — `ocornut.imgui` is
-- published from `mcpplibs/imgui-m` for exactly this reason. Where the manifest
-- lives and whose code it describes are different questions.
-- THE VERSION IS UPSTREAM'S, AND THE FOURTH SEGMENT IS THE PACKAGING REVISION.
--
-- `1.8.12` is what upstream released and what every one of the 2109 vendored
-- files was compared against, byte for byte. A change to the PACKAGING moves
-- the fourth segment: `1.8.12.1` orders strictly above `1.8.12`, because mcpp
-- compares an arbitrary-length dot list with absent segments as zero, and
-- satisfies every requirement `1.8.12` satisfies, because a bare requirement is
-- a caret. A consumer therefore writes the number upstream released.
--
package = {
    spec        = "1",
    namespace   = "picolibc",
    name        = "picolibc",
    description = "picolibc as a source package: a freestanding C library compiled with the consuming program's own flags, so there is no multilib and no ABI convention to match",
    -- Counted over the files actually shipped, not guessed. picolibc descends
    -- from newlib and the vendored tree carries five identifiers: BSD-3-Clause
    -- (902 files), BSD-3-Clause-Clear (31), MIT (8), BSD-2-Clause-FreeBSD (5),
    -- BSD-2-Clause (4). `LICENSE.picolibc` is upstream's per-file mapping.
    licenses    = {"BSD-3-Clause", "BSD-3-Clause-Clear", "MIT",
                   "BSD-2-Clause-FreeBSD", "BSD-2-Clause"},
    repo        = "https://github.com/mcpplibs/picolibc",
    type        = "package",

    xpm = {
        linux = {
            ["1.8.12.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/picolibc/archive/refs/tags/1.8.12.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/picolibc/releases/download/1.8.12.2/picolibc-1.8.12.2.tar.gz",
                },
                sha256 = "29045a2eed39a421353dec6f7763f3d78eda88d0957f9eec6833143d92b2e2fd",
            },
        },
        macosx = {
            ["1.8.12.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/picolibc/archive/refs/tags/1.8.12.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/picolibc/releases/download/1.8.12.2/picolibc-1.8.12.2.tar.gz",
                },
                sha256 = "29045a2eed39a421353dec6f7763f3d78eda88d0957f9eec6833143d92b2e2fd",
            },
        },
        windows = {
            ["1.8.12.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/picolibc/archive/refs/tags/1.8.12.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/picolibc/releases/download/1.8.12.2/picolibc-1.8.12.2.tar.gz",
                },
                sha256 = "29045a2eed39a421353dec6f7763f3d78eda88d0957f9eec6833143d92b2e2fd",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
