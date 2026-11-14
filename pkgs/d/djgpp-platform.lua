-- djgpp-platform --- 32-bit DOS programs built by DJGPP (mcpp SPEC-013).
--
-- A data package mcpp reads: the row `i586-dos-djgpp' (COFF objects, `.exe',
-- ILP32, the execution system `dos'), its GCC named by the row's GCC target
-- `i586-pc-msdosdjgpp' (the xim package `i586-pc-msdosdjgpp-gcc'), and its
-- runner, dirun with DOSBox Staging's profile. C only: DJGPP's GCC 12.2.0 has
-- no dependency scanning for C++ modules. It stands beside the openkal route
-- to DOS (openkal-platform's `i686-dos-musl'), which is the community default.
-- A project selects it for the row:
--   [target.i586-dos-djgpp] platform = "djgpp-platform@0.1.0"
-- Read by mcpp 2026.11.13.1 and later (the package states the floor).
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "djgpp-platform",
    description = "32-bit DOS programs built by DJGPP: the i586-dos-djgpp row, its GCC payload, and DOSBox Staging as its runner",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/djgpp-platform",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/mcpplibs/djgpp-platform/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/djgpp-platform/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/djgpp-platform/releases/download/0.1.0/djgpp-platform-0.1.0.tar.gz",
                },
                sha256 = "f25356cae01bbd8da40a1e37030365e230b1b1f30fbf2b696203ce663e86dbfa",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/djgpp-platform/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/djgpp-platform/releases/download/0.1.0/djgpp-platform-0.1.0.tar.gz",
                },
                sha256 = "f25356cae01bbd8da40a1e37030365e230b1b1f30fbf2b696203ce663e86dbfa",
            },
        },
        windows = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/djgpp-platform/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/djgpp-platform/releases/download/0.1.0/djgpp-platform-0.1.0.tar.gz",
                },
                sha256 = "f25356cae01bbd8da40a1e37030365e230b1b1f30fbf2b696203ce663e86dbfa",
            },
        },
    },
}
