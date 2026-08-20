-- openarch — the architecture-mechanism layer.
--
-- Form A because mcpp looks for a package manifest at the package ROOT, and
-- Form B would leave it one level down inside the tarball's wrap directory.
--
-- ⚠️ NO `deps`. This package needs nothing installed: it is C++ modules plus
-- per-architecture assembly, and which assembly is compiled follows the
-- resolved target through the manifest's own `cfg(arch = ...)` sections.
--
-- ⚠️ 0.1.0 IS A PROBE, NOT A LAYER. One architecture and one of the two
-- primitives that decide whether the layer can exist. The gate — that a single
-- interface survives a second, genuinely different machine — has not been
-- passed and cannot be passed by one architecture. Listed so that the probe can
-- be consumed and reproduced, not because the layer is ready to be built upon.
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
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openarch/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openarch/releases/download/0.1.0/openarch-0.1.0.tar.gz",
                },
                sha256 = "9f1799c66eb5b96fe1cfe09c6d534d26b61fed14c985e9fa4ce788cd0ecb0e65",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openarch/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openarch/releases/download/0.1.0/openarch-0.1.0.tar.gz",
                },
                sha256 = "9f1799c66eb5b96fe1cfe09c6d534d26b61fed14c985e9fa4ce788cd0ecb0e65",
            },
        },
        windows = {
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
