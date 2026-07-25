-- Form B (inline mcpp = { ... }) carries the build info for ALL listed versions.
-- 0.0.2+ ships an upstream `mcpp.toml`, but `mcpp` is a package-level field
-- (not per-version) in xpkg.lua, so to keep 0.0.1 installable we keep the
-- workaround table here. The src/**/*.cppm layout is identical across 0.0.1
-- and 0.0.2, so a single Form B block describes both versions correctly.
-- When 0.0.1 is dropped, this can be replaced with `mcpp = "*/mcpp.toml"`.
--
-- M6.x: Form B paths are globs relative to the verdir (the untouched
-- xlings extract dir). The leading `*/` absorbs the GitHub tarball's
-- `cmdline-<tag>/` wrap layer.
package = {
    spec        = "1",
    namespace = "mcpplibs",
    name        = "cmdline",
    description = "A simple command-line parsing library/framework for modern C++",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/cmdline",
    type        = "package",

    xpm = {
        linux = {
            ["0.0.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cmdline/archive/refs/tags/0.0.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cmdline/releases/download/0.0.1/cmdline-0.0.1.tar.gz",
                },
                sha256 = "3fb2f5495c1a144485b3cbb2e43e27059151633460f702af0f3851cbff387ef0",
            },
            ["0.0.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cmdline/archive/refs/tags/v0.0.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cmdline/releases/download/0.0.2/cmdline-0.0.2.tar.gz",
                },
                sha256 = "4f3e2b8dc4d9f11bdd9a784a9914e889234ac305e1020282ffa03f506b75d52a",
            },
        },
        macosx = {
            ["0.0.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cmdline/archive/refs/tags/0.0.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cmdline/releases/download/0.0.1/cmdline-0.0.1.tar.gz",
                },
                sha256 = "3fb2f5495c1a144485b3cbb2e43e27059151633460f702af0f3851cbff387ef0",
            },
            ["0.0.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cmdline/archive/refs/tags/v0.0.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cmdline/releases/download/0.0.2/cmdline-0.0.2.tar.gz",
                },
                sha256 = "4f3e2b8dc4d9f11bdd9a784a9914e889234ac305e1020282ffa03f506b75d52a",
            },
        },
        windows = {
            ["0.0.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cmdline/archive/refs/tags/0.0.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cmdline/releases/download/0.0.1/cmdline-0.0.1.tar.gz",
                },
                sha256 = "3fb2f5495c1a144485b3cbb2e43e27059151633460f702af0f3851cbff387ef0",
            },
            ["0.0.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cmdline/archive/refs/tags/v0.0.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cmdline/releases/download/0.0.2/cmdline-0.0.2.tar.gz",
                },
                sha256 = "4f3e2b8dc4d9f11bdd9a784a9914e889234ac305e1020282ffa03f506b75d52a",
            },
        },
    },

    mcpp = {
        schema     = "0.1",
        language   = "c++23",
        import_std = true,
        modules    = { "mcpplibs.cmdline" },
        sources    = { "*/src/**/*.cppm" },
        targets    = { ["cmdline"] = { kind = "lib" } },
        deps       = { },
    },
}
