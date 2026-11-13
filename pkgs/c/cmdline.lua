-- Form B (inline mcpp = { ... }) carries the build info for ALL listed versions.
-- 0.0.2+ ships an upstream `mcpp.toml`, but `mcpp` is a package-level field
-- (not per-version) in xpkg.lua, so to keep 0.0.1 installable we keep the
-- workaround table here. The src/**/*.cppm layout is the same across 0.0.1,
-- 0.0.2, 0.0.3 and 0.0.4 (0.0.3 adds src/completions*.cppm, which the glob takes in),
-- so a single Form B block describes every version correctly.
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
            ["0.0.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cmdline/archive/refs/tags/v0.0.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cmdline/releases/download/0.0.3/cmdline-0.0.3.tar.gz",
                },
                sha256 = "a7854898e083f6df203ef7f14ec668812f3a5c28739fdc84d05d9dc39b990ca0",
            },
            ["0.0.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cmdline/archive/refs/tags/v0.0.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cmdline/releases/download/0.0.4/cmdline-0.0.4.tar.gz",
                },
                sha256 = "8428e829bec2f74b2841b33fc2f319cdd1316bdcd7a6c5839bdc641c7e85fd1a",
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
            ["0.0.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cmdline/archive/refs/tags/v0.0.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cmdline/releases/download/0.0.3/cmdline-0.0.3.tar.gz",
                },
                sha256 = "a7854898e083f6df203ef7f14ec668812f3a5c28739fdc84d05d9dc39b990ca0",
            },
            ["0.0.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cmdline/archive/refs/tags/v0.0.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cmdline/releases/download/0.0.4/cmdline-0.0.4.tar.gz",
                },
                sha256 = "8428e829bec2f74b2841b33fc2f319cdd1316bdcd7a6c5839bdc641c7e85fd1a",
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
            ["0.0.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cmdline/archive/refs/tags/v0.0.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cmdline/releases/download/0.0.3/cmdline-0.0.3.tar.gz",
                },
                sha256 = "a7854898e083f6df203ef7f14ec668812f3a5c28739fdc84d05d9dc39b990ca0",
            },
            ["0.0.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cmdline/archive/refs/tags/v0.0.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cmdline/releases/download/0.0.4/cmdline-0.0.4.tar.gz",
                },
                sha256 = "8428e829bec2f74b2841b33fc2f319cdd1316bdcd7a6c5839bdc641c7e85fd1a",
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
