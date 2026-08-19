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
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-libc/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-libc/releases/download/0.1.0/openkal-libc-0.1.0.tar.gz",
                },
                sha256 = "721bfa8ef8bbacadb2a17991a14cd6fd1248f8b20b30ab782dafd23f966a2084",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-libc/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-libc/releases/download/0.1.0/openkal-libc-0.1.0.tar.gz",
                },
                sha256 = "721bfa8ef8bbacadb2a17991a14cd6fd1248f8b20b30ab782dafd23f966a2084",
            },
        },
        windows = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-libc/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-libc/releases/download/0.1.0/openkal-libc-0.1.0.tar.gz",
                },
                sha256 = "721bfa8ef8bbacadb2a17991a14cd6fd1248f8b20b30ab782dafd23f966a2084",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
