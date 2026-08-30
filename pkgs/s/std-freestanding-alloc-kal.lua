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
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.4/std-freestanding-alloc-kal-0.1.4.tar.gz",
                },
                sha256 = "1cd6589b42cf8355b99cc1458c4f48e90b1ae6614b9aefa7e60b9fd6b1863bdd",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.3/std-freestanding-alloc-kal-0.1.3.tar.gz",
                },
                sha256 = "257ff5ff4b3262f1f610266d18e0ddcb8630c6ef5a08f0f0b118eddc89c40fb3",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.2/std-freestanding-alloc-kal-0.1.2.tar.gz",
                },
                sha256 = "c0f9d699d7349cf8cef0bb2d1659ad4d2cadb2d9c8695078c6bed6351a583769",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.1/std-freestanding-alloc-kal-0.1.1.tar.gz",
                },
                sha256 = "a25edb94353e99959d1789836df7368b58277168acadd46e554e2220c47642d7",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.0/std-freestanding-alloc-kal-0.1.0.tar.gz",
                },
                sha256 = "6d3c746e5013655464fd47de54868e06c81a3563046d6bff58c9cb28e689e899",
            },
        },
        macosx = {
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.4/std-freestanding-alloc-kal-0.1.4.tar.gz",
                },
                sha256 = "1cd6589b42cf8355b99cc1458c4f48e90b1ae6614b9aefa7e60b9fd6b1863bdd",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.3/std-freestanding-alloc-kal-0.1.3.tar.gz",
                },
                sha256 = "257ff5ff4b3262f1f610266d18e0ddcb8630c6ef5a08f0f0b118eddc89c40fb3",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.2/std-freestanding-alloc-kal-0.1.2.tar.gz",
                },
                sha256 = "c0f9d699d7349cf8cef0bb2d1659ad4d2cadb2d9c8695078c6bed6351a583769",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.1/std-freestanding-alloc-kal-0.1.1.tar.gz",
                },
                sha256 = "a25edb94353e99959d1789836df7368b58277168acadd46e554e2220c47642d7",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.0/std-freestanding-alloc-kal-0.1.0.tar.gz",
                },
                sha256 = "6d3c746e5013655464fd47de54868e06c81a3563046d6bff58c9cb28e689e899",
            },
        },
        windows = {
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.4/std-freestanding-alloc-kal-0.1.4.tar.gz",
                },
                sha256 = "1cd6589b42cf8355b99cc1458c4f48e90b1ae6614b9aefa7e60b9fd6b1863bdd",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.3/std-freestanding-alloc-kal-0.1.3.tar.gz",
                },
                sha256 = "257ff5ff4b3262f1f610266d18e0ddcb8630c6ef5a08f0f0b118eddc89c40fb3",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.2/std-freestanding-alloc-kal-0.1.2.tar.gz",
                },
                sha256 = "c0f9d699d7349cf8cef0bb2d1659ad4d2cadb2d9c8695078c6bed6351a583769",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-kal/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-kal/releases/download/0.1.1/std-freestanding-alloc-kal-0.1.1.tar.gz",
                },
                sha256 = "a25edb94353e99959d1789836df7368b58277168acadd46e554e2220c47642d7",
            },
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
