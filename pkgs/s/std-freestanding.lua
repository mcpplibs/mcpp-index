-- std-freestanding — the freestanding subset of the C++ standard library.
--
-- Form A because the package ships a `build.mcpp`, which mcpp looks for at the
-- package ROOT: Form B would leave it one level down inside the tarball's wrap
-- directory, unfound, and the package would resolve and compile and then link
-- against nothing.
--
-- ⚠️ NO `deps`, and that is the design. This package needs libc++'s headers
-- and the target's C headers, and it gets both by ASKING mcpp
-- (`mcpp::toolchain_dir()`, and the target's libc which mcpp already puts on
-- the compile line) rather than by declaring who provides them. Declaring
-- pinned it to one standard-library implementation, one C library, one
-- architecture and one version of each — none of which it has any business
-- knowing about.
-- ⚠️ 0.3.0 AND 0.3.1's `alloc-kal` / `alloc-libc` features DO NOT WORK; 0.3.2
-- is the first that does. 0.3.0 named `0.1.x`, which the installer reports as a
-- missing package; 0.3.1 named `0.1`, which resolves and then fails with
-- `install path missing after fetch`. 0.3.2 names `^0.1.0`, measured to fetch.
-- The lesson recorded in the package: "no E_NOT_FOUND" is not "installs", and
-- "installs" is not "builds".
--
-- ⚠️ 0.3.0's `alloc-kal` / `alloc-libc` features DO NOT WORK. Their
-- `[feature-deps]` entries name `0.1.x`, a selector the installer does not
-- have, so the implementation cannot be fetched and the feature is inert.
-- 0.3.1 uses a two-segment prefix instead. 0.3.0 stays listed because a
-- published version is one somebody may have pinned, and its non-allocating
-- half is unaffected.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "std-freestanding",
    description = "The freestanding subset of the C++ standard library as one module — import mcpplibs.std.freestanding",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/std-freestanding",
    type        = "package",

    xpm = {
        linux = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.2.0/std-freestanding-0.2.0.tar.gz",
                },
                sha256 = "c0026e6aa85d207b3dd00c3f2fe2674174c2e25d86a162f64fe70742420efb00",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.3.0/std-freestanding-0.3.0.tar.gz",
                },
                sha256 = "04c02fc42d1fb608a831ff6a1c780a4c12901d8d1d680bd602cb4ff439eedf9a",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.3.1/std-freestanding-0.3.1.tar.gz",
                },
                sha256 = "7e9433c037d05940a6680f0a82ea979345535f902d5ee6a4c7b4b352319527e5",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.3.2/std-freestanding-0.3.2.tar.gz",
                },
                sha256 = "8cd1687b2a02a53729fe8d97319b862f92a9c00ae2fb51985332fdbe0c1332c2",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.4.0/std-freestanding-0.4.0.tar.gz",
                },
                sha256 = "a0306d470f524f7ac32fca2ab46a46435a66dc0eb9b4960ada013a905f66b9a6",
            },
        },
        macosx = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.2.0/std-freestanding-0.2.0.tar.gz",
                },
                sha256 = "c0026e6aa85d207b3dd00c3f2fe2674174c2e25d86a162f64fe70742420efb00",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.3.0/std-freestanding-0.3.0.tar.gz",
                },
                sha256 = "04c02fc42d1fb608a831ff6a1c780a4c12901d8d1d680bd602cb4ff439eedf9a",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.3.1/std-freestanding-0.3.1.tar.gz",
                },
                sha256 = "7e9433c037d05940a6680f0a82ea979345535f902d5ee6a4c7b4b352319527e5",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.3.2/std-freestanding-0.3.2.tar.gz",
                },
                sha256 = "8cd1687b2a02a53729fe8d97319b862f92a9c00ae2fb51985332fdbe0c1332c2",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.4.0/std-freestanding-0.4.0.tar.gz",
                },
                sha256 = "a0306d470f524f7ac32fca2ab46a46435a66dc0eb9b4960ada013a905f66b9a6",
            },
        },
        windows = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.2.0/std-freestanding-0.2.0.tar.gz",
                },
                sha256 = "c0026e6aa85d207b3dd00c3f2fe2674174c2e25d86a162f64fe70742420efb00",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.3.0/std-freestanding-0.3.0.tar.gz",
                },
                sha256 = "04c02fc42d1fb608a831ff6a1c780a4c12901d8d1d680bd602cb4ff439eedf9a",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.3.1/std-freestanding-0.3.1.tar.gz",
                },
                sha256 = "7e9433c037d05940a6680f0a82ea979345535f902d5ee6a4c7b4b352319527e5",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.3.2/std-freestanding-0.3.2.tar.gz",
                },
                sha256 = "8cd1687b2a02a53729fe8d97319b862f92a9c00ae2fb51985332fdbe0c1332c2",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.4.0/std-freestanding-0.4.0.tar.gz",
                },
                sha256 = "a0306d470f524f7ac32fca2ab46a46435a66dc0eb9b4960ada013a905f66b9a6",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
