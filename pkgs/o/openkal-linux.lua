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
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.3.0/openkal-linux-0.3.0.tar.gz",
                },
                sha256 = "a88f7c60330dd8f6b6778e478574a022a744893db1a2e338e0a42fb4eb949679",
            },
        },
        macosx = {
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.3.0/openkal-linux-0.3.0.tar.gz",
                },
                sha256 = "a88f7c60330dd8f6b6778e478574a022a744893db1a2e338e0a42fb4eb949679",
            },
        },
        windows = {
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.3.0/openkal-linux-0.3.0.tar.gz",
                },
                sha256 = "a88f7c60330dd8f6b6778e478574a022a744893db1a2e338e0a42fb4eb949679",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
