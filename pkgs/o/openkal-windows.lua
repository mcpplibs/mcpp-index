-- openkal-windows --- an implementation for a system that shares no ancestry
-- with the one openkal was first written on.
--
-- No `deps`. The interfaces it uses are the ones every installation of that
-- system already has, and it names them in the objects it produces rather than
-- on a link line, so a project that selects it needs nothing further.
--
-- The package is listed for every platform because a descriptor's platform
-- table describes availability rather than applicability. A project selects
-- this implementation with a conditional dependency on `cfg(windows)`, and a
-- project that selects it elsewhere fails at compile time, which is the correct
-- place for that failure.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-windows",
    description = "An implementation of openkal for Windows, on the Win32 interfaces and the object manager beneath them, using no C runtime symbol",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-windows",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.1/openkal-windows-0.1.1.tar.gz",
                },
                sha256 = "e4e517c80d030eacd5427e85c4431a425d098a151c263554bf79d277f360d444",
            },
        },
        macosx = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.1/openkal-windows-0.1.1.tar.gz",
                },
                sha256 = "e4e517c80d030eacd5427e85c4431a425d098a151c263554bf79d277f360d444",
            },
        },
        windows = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.1/openkal-windows-0.1.1.tar.gz",
                },
                sha256 = "e4e517c80d030eacd5427e85c4431a425d098a151c263554bf79d277f360d444",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
