-- sbase --- the suckless base utilities, above openkal-musl.
--
-- The sources are upstream's, unmodified. What this package supplies is a
-- manifest naming one dependency, two build decisions that are about linking
-- rather than about sources, and fifty comparisons against the system's own
-- tools.
--
-- It is listed for every platform, and that is the result rather than a
-- convention: sbase has no Windows port and does not build on macOS as it
-- stands --- three of its tools include a header of the Linux C libraries and
-- four use a field POSIX 2008 specifies that the other system's C library does
-- not have. Neither obstacle is in a kernel.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "sbase",
    description = "The suckless base utilities recompiled above openkal-musl: ninety-seven tools, sources unmodified, on Linux, macOS and Windows",
    licenses    = {"MIT", "Apache-2.0"},
    repo        = "https://github.com/mcpplibs/sbase",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/sbase/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sbase/releases/download/0.1.0/sbase-0.1.0.tar.gz",
                },
                sha256 = "cd8ea89e9b15ae1ef41c0efba58304d39e853d649783b9300c0fab69375e36ff",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/sbase/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sbase/releases/download/0.1.0/sbase-0.1.0.tar.gz",
                },
                sha256 = "cd8ea89e9b15ae1ef41c0efba58304d39e853d649783b9300c0fab69375e36ff",
            },
        },
        windows = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/sbase/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sbase/releases/download/0.1.0/sbase-0.1.0.tar.gz",
                },
                sha256 = "cd8ea89e9b15ae1ef41c0efba58304d39e853d649783b9300c0fab69375e36ff",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
