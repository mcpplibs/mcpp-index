-- std-freestanding-alloc-kal — one of the allocator implementations the
-- freestanding subset can bind.
--
-- Form A because mcpp looks for a package manifest at the package ROOT, and
-- Form B would leave it one level down inside the tarball's wrap directory.
--
-- ⚠️ NO `deps`. The package depends on `openkal` for the C declarations it is
-- written against, and that is an mcpp dependency declared in its own
-- manifest — not an xim payload. Nothing here needs installing.
--
-- The consumer does not name this package. `std-freestanding`'s `alloc-kal`
-- feature pulls it, because the feature both states the requirement and brings
-- an implementation; see that package's `[feature-deps]`.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "std-freestanding-alloc-kal",
    description = "The replaceable allocation functions for the freestanding subset, forwarded to openkal",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/std-freestanding-alloc-kal",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.0/std-freestanding-alloc-kal-0.1.0.tar.gz",
                },
                sha256 = "6d3c746e5013655464fd47de54868e06c81a3563046d6bff58c9cb28e689e899",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.0/std-freestanding-alloc-kal-0.1.0.tar.gz",
                },
                sha256 = "6d3c746e5013655464fd47de54868e06c81a3563046d6bff58c9cb28e689e899",
            },
        },
        windows = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.0/std-freestanding-alloc-kal-0.1.0.tar.gz",
                },
                sha256 = "6d3c746e5013655464fd47de54868e06c81a3563046d6bff58c9cb28e689e899",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
