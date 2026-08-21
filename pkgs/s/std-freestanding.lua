-- std-freestanding — the freestanding subset of the C++ standard library.
--
-- Form A because the package ships a `build.mcpp`, which mcpp looks for at the
-- package ROOT: Form B would leave it one level down inside the tarball's wrap
-- directory, unfound, and the package would resolve and compile and then link
-- against nothing.
--
-- ⚠️ `deps` IS EMPTY ON TWO PLATFORMS OF THREE, AND THE EXCEPTION IS INSTRUCTIVE.
--
-- The package needs libc++'s headers and the target's C headers, and it gets
-- both by ASKING mcpp (`mcpp::toolchain_dir()`, and the target's libc which
-- mcpp already puts on the compile line) rather than by declaring who provides
-- them. Declaring pinned it to one standard-library implementation, one C
-- library, one architecture and one version of each — none of which it has any
-- business knowing about.
--
-- ⚠️ That holds as long as the toolchain payload CARRIES the headers, and the
-- Windows payload does not. From 0.5.0 the package looks in a second place —
-- an installed `xim:libcxx-headers` — and the windows block below declares it.
-- The rule survives: the package still does not name a C library or an
-- architecture. It names one missing artifact on the one platform that is
-- missing it.
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
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.5.0/std-freestanding-0.5.0.tar.gz",
                },
                sha256 = "cb7c7fe4f2f6dd60784951262875d317e8a107642af01bad6ea4b3a106fc43f2",
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
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.5.0/std-freestanding-0.5.0.tar.gz",
                },
                sha256 = "cb7c7fe4f2f6dd60784951262875d317e8a107642af01bad6ea4b3a106fc43f2",
            },
        },
        windows = {
            -- ⚠️ THE ONLY PLATFORM WITH A `deps`, AND IT IS A PROPERTY OF THE
            -- TOOLCHAIN PAYLOAD RATHER THAN OF WINDOWS.
            --
            -- This package needs libc++'s headers. On linux and macosx the
            -- llvm payload ships them and `build.mcpp` finds them under
            -- `mcpp::toolchain_dir()`; the Windows payload builds clang
            -- against the MSVC standard library and ships no libc++ at all,
            -- so there the headers have to come from somewhere. They come
            -- from here.
            --
            -- ⚠️ `deps` IS PER-PLATFORM, NOT PER-VERSION, so this also applies
            -- to 0.2.0 through 0.4.0 -- which do not look for the package and
            -- could not build on Windows at all. The cost is one small
            -- download on a configuration that never worked; the alternative
            -- is no mechanism for 0.5.0, which does.
            --
            -- The version is pinned rather than `@latest` for the reason
            -- compat.openssl pins glibc: these headers are read by the SAME
            -- clang the payload ships, and a newer libc++ is free to require
            -- a newer compiler than the one that will read it.
            deps = { "xim:libcxx-headers@22.1.8" },
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
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.5.0/std-freestanding-0.5.0.tar.gz",
                },
                sha256 = "cb7c7fe4f2f6dd60784951262875d317e8a107642af01bad6ea4b3a106fc43f2",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
