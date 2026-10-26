-- os --- mcpplibs.os, a C++ operating-system library over openkal.
--
-- Processes, files, the environment, terminals, conventional directories and
-- local IPC, composed from openkal's atoms, with compile-time platform
-- constants for a program built for a system and `host()' answered at load for
-- one built as an ok image (`<arch>-openkal').
--
-- No `deps'. The package names openkal and, for the system it is built for,
-- that system's implementation in its own manifest; a program that builds ok
-- images names the C library and the C++ run-time inside them itself.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "os",
    description = "mcpplibs.os: a C++ operating-system library over openkal --- processes, files, environment, terminals, directories and local IPC, with compile-time platform constants and a few platform modules",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/os",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.1.0/os-0.1.0.tar.gz",
                },
                sha256 = "f7e4117612d721da2ae311cb36afab42625391208e4b0f8e8491534a00b6ab18",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.1.0/os-0.1.0.tar.gz",
                },
                sha256 = "f7e4117612d721da2ae311cb36afab42625391208e4b0f8e8491534a00b6ab18",
            },
        },
        windows = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.1.0/os-0.1.0.tar.gz",
                },
                sha256 = "f7e4117612d721da2ae311cb36afab42625391208e4b0f8e8491534a00b6ab18",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
