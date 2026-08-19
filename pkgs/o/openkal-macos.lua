-- openkal-macos --- a second implementation.
--
-- Its purpose is as much to test the specification as to be used. A
-- specification satisfied only by the system it was written against has not
-- been shown to be portable, however many programs that system hosts.
--
-- Listed for every platform because a platform table describes availability
-- rather than applicability. A project selects this implementation with a
-- conditional dependency on cfg(os = "macos"); one that selects it elsewhere
-- fails at compile time, which is the correct place for that failure.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-macos",
    description = "An implementation of openkal for macOS, which exists as much to test the specification as to be used",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-macos",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.1.0/openkal-macos-0.1.0.tar.gz",
                },
                sha256 = "b546fd73c074abfb8a55c06c34e8e2184d6ba5bc953ef60e3bd50d08f1b79c1e",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.1.0/openkal-macos-0.1.0.tar.gz",
                },
                sha256 = "b546fd73c074abfb8a55c06c34e8e2184d6ba5bc953ef60e3bd50d08f1b79c1e",
            },
        },
        windows = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.1.0/openkal-macos-0.1.0.tar.gz",
                },
                sha256 = "b546fd73c074abfb8a55c06c34e8e2184d6ba5bc953ef60e3bd50d08f1b79c1e",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
