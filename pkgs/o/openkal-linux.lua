-- openkal-linux --- the reference implementation.
--
-- No `deps`. The implementation uses the C library of the host, which mcpp
-- already supplies for a hosted target; nothing further is required.
--
-- The package is listed for every platform because a descriptor's platform
-- table describes availability rather than applicability. A project selects
-- this implementation with a conditional dependency on `cfg(os = "linux")`,
-- and a project that selects it elsewhere fails at compile time, which is the
-- correct place for that failure.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-linux",
    description = "The reference implementation of openkal for Linux, maintained as a worked example",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-linux",
    type        = "package",

    xpm = {
        linux = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.2.0/openkal-linux-0.2.0.tar.gz",
                },
                sha256 = "0007231fa59852f13ac3a0048033c9efbe6772c39545bbfb36f230c6ffd8a654",
            },
        },
        macosx = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.2.0/openkal-linux-0.2.0.tar.gz",
                },
                sha256 = "0007231fa59852f13ac3a0048033c9efbe6772c39545bbfb36f230c6ffd8a654",
            },
        },
        windows = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.2.0/openkal-linux-0.2.0.tar.gz",
                },
                sha256 = "0007231fa59852f13ac3a0048033c9efbe6772c39545bbfb36f230c6ffd8a654",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
