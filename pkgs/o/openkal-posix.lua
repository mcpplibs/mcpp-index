-- openkal-posix --- openkal written above a POSIX C library.
--
-- No descriptor-level `deps`: the source manifest names the openkal contract.
-- The implementation calls the system's own C library and states
-- `requires = ["mcpp:c-abi"]`, so it is placed above that C library and never
-- beneath one written above openkal. It provides fifteen of openkal's
-- interfaces; net, datagram, prof and debug are absent.
--
-- The package is listed for every platform because a descriptor's platform
-- table describes availability rather than applicability. A project selects
-- this implementation with a conditional dependency on the systems it serves,
-- and a project that selects it where no POSIX C library exists fails at
-- compile time, which is the correct place for that failure.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-posix",
    description = "An implementation of openkal written above a POSIX C library, for the systems that have no implementation of their own",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-posix",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-posix/archive/refs/tags/0.1.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-posix/releases/download/0.1.1/openkal-posix-0.1.1.tar.gz",
                },
                sha256 = "070963e1682859cbeafab3425bfc9637bf106564918fbd0c5e04539ea63e7081",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-posix/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-posix/releases/download/0.1.0/openkal-posix-0.1.0.tar.gz",
                },
                sha256 = "09878176d163b44675712f0bb285b87f9a8e0f9688b23c0aa4d0ab627f5ebeae",
            },
        },
        macosx = {
            ["0.1.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-posix/archive/refs/tags/0.1.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-posix/releases/download/0.1.1/openkal-posix-0.1.1.tar.gz",
                },
                sha256 = "070963e1682859cbeafab3425bfc9637bf106564918fbd0c5e04539ea63e7081",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-posix/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-posix/releases/download/0.1.0/openkal-posix-0.1.0.tar.gz",
                },
                sha256 = "09878176d163b44675712f0bb285b87f9a8e0f9688b23c0aa4d0ab627f5ebeae",
            },
        },
        windows = {
            ["0.1.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-posix/archive/refs/tags/0.1.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-posix/releases/download/0.1.1/openkal-posix-0.1.1.tar.gz",
                },
                sha256 = "070963e1682859cbeafab3425bfc9637bf106564918fbd0c5e04539ea63e7081",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-posix/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-posix/releases/download/0.1.0/openkal-posix-0.1.0.tar.gz",
                },
                sha256 = "09878176d163b44675712f0bb285b87f9a8e0f9688b23c0aa4d0ab627f5ebeae",
            },
        },
    },
}
