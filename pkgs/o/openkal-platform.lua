-- openkal-platform --- the platform of the ok-image targets (mcpp SPEC-013).
--
-- A data package mcpp reads: the configuration of `x86_64-openkal` and
-- `aarch64-openkal` -- their toolchain, C library, C++ and compiler run-time,
-- tools, compile and link conventions, seal, runner and carrier -- and the
-- version group of the openkal family. mcpp's target table selects it for
-- both targets, so a project for an ok image declares nothing but its
-- sources; a project selects another release with
--   [target.'cfg(os = "openkal")'] platform = "openkal-platform@<version>"
-- Read by mcpp 2026.10.27.1 and later (the package states the floor).
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-platform",
    description = "The platform of ok images (<arch>-openkal): toolchain, C library and C++ run-time, tools, compile and link conventions, seal, runner and carrier, and the openkal family's version group, as one versioned statement mcpp reads",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-platform",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.18.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.18.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.18.0/openkal-platform-0.18.0.tar.gz",
                },
                sha256 = "8a25e101e1a7b15c41756134cb7f83d7f55864eeaa9e24a416e0fd3b0bc2f103",
            },
            ["0.17.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.3/openkal-platform-0.17.3.tar.gz",
                },
                sha256 = "36dcf9aa34cc664e12627176c5844bc64c2d386b576712022955c884577ba4ea",
            },
            ["0.17.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.2/openkal-platform-0.17.2.tar.gz",
                },
                sha256 = "e6f920b1907c1c6927e90b993ea4917620bfa1bec41ebf78b29cb79aec322038",
            },
            ["0.17.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.1/openkal-platform-0.17.1.tar.gz",
                },
                sha256 = "db006660fff2b34ff39dfa570774afac15b392e30ebcadd34675f88ea6a60b50",
            },
        },
        macosx = {
            ["0.18.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.18.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.18.0/openkal-platform-0.18.0.tar.gz",
                },
                sha256 = "8a25e101e1a7b15c41756134cb7f83d7f55864eeaa9e24a416e0fd3b0bc2f103",
            },
            ["0.17.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.3/openkal-platform-0.17.3.tar.gz",
                },
                sha256 = "36dcf9aa34cc664e12627176c5844bc64c2d386b576712022955c884577ba4ea",
            },
            ["0.17.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.2/openkal-platform-0.17.2.tar.gz",
                },
                sha256 = "e6f920b1907c1c6927e90b993ea4917620bfa1bec41ebf78b29cb79aec322038",
            },
            ["0.17.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.1/openkal-platform-0.17.1.tar.gz",
                },
                sha256 = "db006660fff2b34ff39dfa570774afac15b392e30ebcadd34675f88ea6a60b50",
            },
        },
        windows = {
            ["0.18.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.18.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.18.0/openkal-platform-0.18.0.tar.gz",
                },
                sha256 = "8a25e101e1a7b15c41756134cb7f83d7f55864eeaa9e24a416e0fd3b0bc2f103",
            },
            ["0.17.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.3/openkal-platform-0.17.3.tar.gz",
                },
                sha256 = "36dcf9aa34cc664e12627176c5844bc64c2d386b576712022955c884577ba4ea",
            },
            ["0.17.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.2/openkal-platform-0.17.2.tar.gz",
                },
                sha256 = "e6f920b1907c1c6927e90b993ea4917620bfa1bec41ebf78b29cb79aec322038",
            },
            ["0.17.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.1/openkal-platform-0.17.1.tar.gz",
                },
                sha256 = "db006660fff2b34ff39dfa570774afac15b392e30ebcadd34675f88ea6a60b50",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
