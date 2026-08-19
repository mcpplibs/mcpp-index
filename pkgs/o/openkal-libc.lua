-- openkal-libc --- a C library above openkal.
--
-- No `deps`. The package needs nothing beyond the specification it is written
-- against; the implementation that supplies the definitions is chosen by the
-- consuming project as a conditional dependency.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-libc",
    description = "A C library above openkal rather than above a kernel, written to test the claim that porting one library suffices",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-libc",
    type        = "package",

    xpm = {
        linux = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-libc/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-libc/releases/download/0.2.0/openkal-libc-0.2.0.tar.gz",
                },
                sha256 = "8521c5eeba5b73cdc9bd0c4113f5112632e7f262485223f6d709bdb27d7d06ef",
            },
        },
        macosx = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-libc/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-libc/releases/download/0.2.0/openkal-libc-0.2.0.tar.gz",
                },
                sha256 = "8521c5eeba5b73cdc9bd0c4113f5112632e7f262485223f6d709bdb27d7d06ef",
            },
        },
        windows = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-libc/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-libc/releases/download/0.2.0/openkal-libc-0.2.0.tar.gz",
                },
                sha256 = "8521c5eeba5b73cdc9bd0c4113f5112632e7f262485223f6d709bdb27d7d06ef",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
