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
-- ⚠️ `picocrt` IS DELIBERATELY ABSENT. A startup object decides where execution
-- begins and how it reaches the host — which board is running. Choosing among
-- picolibc's nine variants is a board-support package's job; `cortex-m-rt`
-- supplies its own, including the thread-pointer initialisation without which a
-- `printf` program links cleanly, runs, prints nothing and hangs.
--
-- ⚠️ THE NAMESPACE IS UPSTREAM'S, NOT `mcpplibs`. This package vendors someone
-- else's sources and adds a manifest; the code is theirs and the identity says
-- so. `mcpplibs` is for packages whose CONTENT this organisation wrote.
--
-- ⭐ The wrapper REPOSITORY can still live under mcpplibs — `ocornut.imgui` is
-- published from `mcpplibs/imgui-m` for exactly this reason. Where the manifest
-- lives and whose code it describes are different questions.
package = {
    spec        = "1",
    namespace   = "picolibc",
    name        = "picolibc",
    description = "picolibc 1.8.12 as a source package: a freestanding C library compiled with the consuming program's own flags, so there is no multilib and no ABI convention to match",
    licenses    = {"BSD-3-Clause", "BSD-2-Clause"},
    repo        = "https://github.com/mcpplibs/picolibc",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/picolibc/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/picolibc/releases/download/0.1.1/picolibc-0.1.1.tar.gz",
                },
                sha256 = "2265a49e58ed02b2166a4cbef40595a2250c7a0821156f96d4e04ae2086ccf89",
            },
        },
        macosx = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/picolibc/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/picolibc/releases/download/0.1.1/picolibc-0.1.1.tar.gz",
                },
                sha256 = "2265a49e58ed02b2166a4cbef40595a2250c7a0821156f96d4e04ae2086ccf89",
            },
        },
        windows = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/picolibc/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/picolibc/releases/download/0.1.1/picolibc-0.1.1.tar.gz",
                },
                sha256 = "2265a49e58ed02b2166a4cbef40595a2250c7a0821156f96d4e04ae2086ccf89",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
