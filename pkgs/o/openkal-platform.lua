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
            ["0.17.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.1/openkal-platform-0.17.1.tar.gz",
                },
                sha256 = "db006660fff2b34ff39dfa570774afac15b392e30ebcadd34675f88ea6a60b50",
            },
        },
        macosx = {
            ["0.17.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-platform/archive/refs/tags/0.17.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-platform/releases/download/0.17.1/openkal-platform-0.17.1.tar.gz",
                },
                sha256 = "db006660fff2b34ff39dfa570774afac15b392e30ebcadd34675f88ea6a60b50",
            },
        },
        windows = {
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
