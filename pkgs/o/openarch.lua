-- openarch — the architecture-mechanism layer.
--
-- Form A because mcpp looks for a package manifest at the package ROOT, and
-- Form B would leave it one level down inside the tarball's wrap directory.
--
-- ⚠️ NO `deps`. This package needs nothing installed: it is C++ modules plus
-- per-architecture assembly, and which assembly is compiled follows the
-- resolved target through the manifest's own `cfg(arch = ...)` sections.
--
-- ⭐ 0.4.0 PASSES THE GATE ON THREE MACHINES, WHICH IS WHAT MAKES IT AN
-- ABSTRACTION RATHER THAN A FIT.
--
-- riscv64 and aarch64 are both weakly-ordered, fixed-width RISC machines: an
-- interface that suits both may suit them because it is right or because they
-- are alike, and no amount of testing on those two tells the cases apart.
-- x86_64 is neither — variable-length instructions, total store order under
-- which three of the four barriers need no instruction at all, and an interrupt
-- mechanism that is a table of 256 gates. One probe source runs on all three
-- and prints byte-identical output.
--
-- ⚠️ THE TARBALL CARRIES FOUR PACKAGES AND A CONSUMER NAMES ONE. Since 0.4.0
-- the repository root is BOTH the interface package and a workspace; the ABI
-- contract and the three backends are members reached by `path` from inside the
-- same archive. `openarch = "0.4.0"` is the whole of a consumer's manifest, and
-- the backend for its target arrives through the default `backend-auto`
-- feature.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openarch",
    description = "openarch: the architecture-mechanism layer — execution contexts, traps and address spaces, as one interface over several instruction sets",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openarch",
    type        = "package",

    xpm = {
        linux = {
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openarch/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openarch/releases/download/0.4.0/openarch-0.4.0.tar.gz",
                },
                sha256 = "deda18140965c7ebee9f49c90b9545aec38d564fc413daa3a075a02725020106",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openarch/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openarch/releases/download/0.2.0/openarch-0.2.0.tar.gz",
                },
                sha256 = "56d4706f45ee581bcd9d1e122a743daf74b26aeaf68f4675b10e1df5596e6303",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openarch/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openarch/releases/download/0.1.0/openarch-0.1.0.tar.gz",
                },
                sha256 = "9f1799c66eb5b96fe1cfe09c6d534d26b61fed14c985e9fa4ce788cd0ecb0e65",
            },
        },
        macosx = {
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openarch/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openarch/releases/download/0.4.0/openarch-0.4.0.tar.gz",
                },
                sha256 = "deda18140965c7ebee9f49c90b9545aec38d564fc413daa3a075a02725020106",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openarch/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openarch/releases/download/0.2.0/openarch-0.2.0.tar.gz",
                },
                sha256 = "56d4706f45ee581bcd9d1e122a743daf74b26aeaf68f4675b10e1df5596e6303",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openarch/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openarch/releases/download/0.1.0/openarch-0.1.0.tar.gz",
                },
                sha256 = "9f1799c66eb5b96fe1cfe09c6d534d26b61fed14c985e9fa4ce788cd0ecb0e65",
            },
        },
        windows = {
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openarch/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openarch/releases/download/0.4.0/openarch-0.4.0.tar.gz",
                },
                sha256 = "deda18140965c7ebee9f49c90b9545aec38d564fc413daa3a075a02725020106",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openarch/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openarch/releases/download/0.2.0/openarch-0.2.0.tar.gz",
                },
                sha256 = "56d4706f45ee581bcd9d1e122a743daf74b26aeaf68f4675b10e1df5596e6303",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openarch/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openarch/releases/download/0.1.0/openarch-0.1.0.tar.gz",
                },
                sha256 = "9f1799c66eb5b96fe1cfe09c6d534d26b61fed14c985e9fa4ce788cd0ecb0e65",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
