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
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.2.0/openkal-macos-0.2.0.tar.gz",
                },
                sha256 = "459f9b11b4af0e06f8d49848389263ef6bfc542cc97491e130d3e13c53e99ab6",
            },
        },
        macosx = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.2.0/openkal-macos-0.2.0.tar.gz",
                },
                sha256 = "459f9b11b4af0e06f8d49848389263ef6bfc542cc97491e130d3e13c53e99ab6",
            },
        },
        windows = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.2.0/openkal-macos-0.2.0.tar.gz",
                },
                sha256 = "459f9b11b4af0e06f8d49848389263ef6bfc542cc97491e130d3e13c53e99ab6",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
