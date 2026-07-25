package = {
    spec        = "1",
    namespace   = "compat",
    name        = "lz4",
    description = "LZ4 extremely fast compression",
    licenses    = {"BSD-2-Clause"},
    repo        = "https://github.com/lz4/lz4",
    type        = "package",

    xpm = {
        linux = {
            ["1.10.0"] = {
                url    = {
                    GLOBAL = "https://github.com/lz4/lz4/archive/refs/tags/v1.10.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/lz4/releases/download/1.10.0/lz4-1.10.0.tar.gz",
                },
                sha256 = "537512904744b35e232912055ccf8ec66d768639ff3abe5788d90d792ec5f48b",
            },
        },
        macosx = {
            ["1.10.0"] = {
                url    = {
                    GLOBAL = "https://github.com/lz4/lz4/archive/refs/tags/v1.10.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/lz4/releases/download/1.10.0/lz4-1.10.0.tar.gz",
                },
                sha256 = "537512904744b35e232912055ccf8ec66d768639ff3abe5788d90d792ec5f48b",
            },
        },
        windows = {
            ["1.10.0"] = {
                url    = {
                    GLOBAL = "https://github.com/lz4/lz4/archive/refs/tags/v1.10.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/lz4/releases/download/1.10.0/lz4-1.10.0.tar.gz",
                },
                sha256 = "537512904744b35e232912055ccf8ec66d768639ff3abe5788d90d792ec5f48b",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = {"*/lib"},
        cflags       = { "-D_GNU_SOURCE" },
        sources      = {"*/lib/*.c"},
        targets      = { ["lz4"] = { kind = "lib" } },
        deps         = {},
    },
}
