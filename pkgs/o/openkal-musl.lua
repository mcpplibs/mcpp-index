-- openkal-musl --- musl 1.2.5 above openkal rather than above one kernel.
--
-- The version line continues rather than restarting. This repository was
-- `openkal-libc' up to 0.2.0, and those tags are still in it; a package that
-- restarted at 0.1.0 would give one tag two meanings, which is the one thing a
-- release chain cannot allow. The earlier name keeps its own descriptor so that
-- a project pinned to it continues to resolve, and nothing is added to it.
--
-- No `deps'. The package names the specification it is written against and the
-- implementation of openkal for the target being built, both in its own
-- manifest --- because a C library is the one consumer that knows the program
-- above it carries no other runtime, and that is what selects the
-- implementation's `standalone' feature.
--
-- The consequence for a program is that it names this package and nothing else.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-musl",
    description = "musl 1.2.5 redirected onto openkal: one C library, ported once, above every implementation of the specification rather than above one kernel",
    licenses    = {"Apache-2.0", "MIT"},
    repo        = "https://github.com/mcpplibs/openkal-musl",
    type        = "package",

    xpm = {
        linux = {
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.0/openkal-musl-0.3.0.tar.gz",
                },
                sha256 = "ec96bc1f68c42daf2b8db4815138b8fc548cebb910c13482dbefa4c4a8994f17",
            },
        },
        macosx = {
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.0/openkal-musl-0.3.0.tar.gz",
                },
                sha256 = "ec96bc1f68c42daf2b8db4815138b8fc548cebb910c13482dbefa4c4a8994f17",
            },
        },
        windows = {
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.0/openkal-musl-0.3.0.tar.gz",
                },
                sha256 = "ec96bc1f68c42daf2b8db4815138b8fc548cebb910c13482dbefa4c4a8994f17",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
