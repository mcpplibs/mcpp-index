-- djgpp-platform --- 32-bit DOS programs built by DJGPP (mcpp SPEC-013).
--
-- A data package mcpp reads: the row `i586-dos-djgpp' (COFF objects, `.exe',
-- ILP32, the execution system `dos'), its GCC named by the row's GCC target
-- `i586-pc-msdosdjgpp' (the xim package `i586-pc-msdosdjgpp-gcc'), and its
-- runner, dirun with DOSBox Staging's profile. C only: DJGPP's GCC 12.2.0 has
-- no dependency scanning for C++ modules. It stands beside the openkal route
-- to DOS (openkal-platform's `i686-dos-musl'), which is the community default.
-- The entry lists the row it serves (`platform_rows'), so mcpp's platform
-- column selects the package for `--target i586-dos-djgpp'; a project pins a
-- release for the row:
--   [target.i586-dos-djgpp] platform = "djgpp-platform@0.2.0"
-- Read by mcpp 2026.11.13.1 and later (the package states the floor).
--
-- 0.2.0: the runner takes dirun 0.6.0 and dosbox-staging 0.83.0-2, the
-- packages of openkal-platform's DOS row, so the files a run names
-- (`mcpp run --file', `[test] files', mcpp 2026.11.17.1) reach the program;
-- it states `enabled = false', as the other runners that start a machine do
-- (enable it with `[target.i586-dos-djgpp] runner = true').
-- mcpplibs/djgpp-platform#2.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "djgpp-platform",
    description = "32-bit DOS programs built by DJGPP: the i586-dos-djgpp row, its GCC payload, and DOSBox Staging as its runner",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/djgpp-platform",
    type        = "package",

    -- The rows this platform serves, for mcpp's platform column (SPEC-013 §14): derived
    -- from the newest version's manifest by tools/platform_rows.py, never written by hand.
    platform_rows = { "i586-dos-djgpp" },
    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/mcpplibs/djgpp-platform/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/djgpp-platform/archive/refs/tags/0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/djgpp-platform/releases/download/0.2.0/djgpp-platform-0.2.0.tar.gz",
                },
                sha256 = "2b4cafc8510145142fcdc142c3c723a52a18655eb0b155eb3169f204d16e65a6",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/djgpp-platform/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/djgpp-platform/releases/download/0.1.0/djgpp-platform-0.1.0.tar.gz",
                },
                sha256 = "f25356cae01bbd8da40a1e37030365e230b1b1f30fbf2b696203ce663e86dbfa",
            },
        },
        macosx = {
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/djgpp-platform/archive/refs/tags/0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/djgpp-platform/releases/download/0.2.0/djgpp-platform-0.2.0.tar.gz",
                },
                sha256 = "2b4cafc8510145142fcdc142c3c723a52a18655eb0b155eb3169f204d16e65a6",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/djgpp-platform/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/djgpp-platform/releases/download/0.1.0/djgpp-platform-0.1.0.tar.gz",
                },
                sha256 = "f25356cae01bbd8da40a1e37030365e230b1b1f30fbf2b696203ce663e86dbfa",
            },
        },
        windows = {
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/djgpp-platform/archive/refs/tags/0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/djgpp-platform/releases/download/0.2.0/djgpp-platform-0.2.0.tar.gz",
                },
                sha256 = "2b4cafc8510145142fcdc142c3c723a52a18655eb0b155eb3169f204d16e65a6",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/djgpp-platform/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/djgpp-platform/releases/download/0.1.0/djgpp-platform-0.1.0.tar.gz",
                },
                sha256 = "f25356cae01bbd8da40a1e37030365e230b1b1f30fbf2b696203ce663e86dbfa",
            },
        },
    },

    -- The package's own manifest, at the archive root.
    mcpp = "*/mcpp.toml",
}
