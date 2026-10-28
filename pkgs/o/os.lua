-- os --- mcpplibs.os, a C++ operating-system library over openkal.
--
-- Processes, files, the environment, terminals, conventional directories and
-- local IPC, composed from openkal's atoms, with compile-time platform
-- constants for a program built for a system and `host()' answered at load for
-- one built as an ok image (`<arch>-openkal').
--
-- No `deps'. The package names openkal and, for the system it is built for,
-- that system's implementation in its own manifest. From 0.2.1 an ok image's
-- C library, C++ run-time and loader are its platform's (openkal-platform,
-- which mcpp 2026.10.27.1 selects for `<arch>-openkal'), and the package
-- declares none of them.
-- From 0.2.2 it builds for `wasm32-emscripten' over Emscripten's C library and
-- openkal-emscripten 0.6.0, which its manifest names for that target; starting
-- a program there fails at link, naming the openkal symbol.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "os",
    description = "mcpplibs.os: a C++ operating-system library over openkal --- processes, files, environment, terminals, directories and local IPC, with compile-time platform constants and a few platform modules",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/os",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/mcpplibs/os/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.2.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.2/os-0.2.2.tar.gz",
                },
                sha256 = "33c5d946c29de1ba7bacabe40fe6ee2f60bea0b25e62c0359f8c570b0f654e3e",
            },
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.1/os-0.2.1.tar.gz",
                },
                sha256 = "264a3b80ef40fcb760b7c63565e01597549fdd8e5aa0672389b5d9384661218f",
            },
            ["0.2.0"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.0.tar.gz",
                sha256 = "9dc147ad8dca0216549c40dc4dfabaed7394cdf7a7f253c58613ccc226abd04e",
            },
            ["0.1.2"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.2.tar.gz",
                sha256 = "bf6f5cfb1518b045b693e246ee39306746074586434419d4052e648be111ea34",
            },
            ["0.1.1"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.1.tar.gz",
                sha256 = "c5abfb625ded0d5d837b799722c836c302460251d47081fef7a57a2a12e6b2b9",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.1.0/os-0.1.0.tar.gz",
                },
                sha256 = "f7e4117612d721da2ae311cb36afab42625391208e4b0f8e8491534a00b6ab18",
            },
        },
        macosx = {
            ["0.2.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.2/os-0.2.2.tar.gz",
                },
                sha256 = "33c5d946c29de1ba7bacabe40fe6ee2f60bea0b25e62c0359f8c570b0f654e3e",
            },
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.1/os-0.2.1.tar.gz",
                },
                sha256 = "264a3b80ef40fcb760b7c63565e01597549fdd8e5aa0672389b5d9384661218f",
            },
            ["0.2.0"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.0.tar.gz",
                sha256 = "9dc147ad8dca0216549c40dc4dfabaed7394cdf7a7f253c58613ccc226abd04e",
            },
            ["0.1.2"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.2.tar.gz",
                sha256 = "bf6f5cfb1518b045b693e246ee39306746074586434419d4052e648be111ea34",
            },
            ["0.1.1"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.1.tar.gz",
                sha256 = "c5abfb625ded0d5d837b799722c836c302460251d47081fef7a57a2a12e6b2b9",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.1.0/os-0.1.0.tar.gz",
                },
                sha256 = "f7e4117612d721da2ae311cb36afab42625391208e4b0f8e8491534a00b6ab18",
            },
        },
        windows = {
            ["0.2.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.2/os-0.2.2.tar.gz",
                },
                sha256 = "33c5d946c29de1ba7bacabe40fe6ee2f60bea0b25e62c0359f8c570b0f654e3e",
            },
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/os/releases/download/0.2.1/os-0.2.1.tar.gz",
                },
                sha256 = "264a3b80ef40fcb760b7c63565e01597549fdd8e5aa0672389b5d9384661218f",
            },
            ["0.2.0"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.2.0.tar.gz",
                sha256 = "9dc147ad8dca0216549c40dc4dfabaed7394cdf7a7f253c58613ccc226abd04e",
            },
            ["0.1.2"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.2.tar.gz",
                sha256 = "bf6f5cfb1518b045b693e246ee39306746074586434419d4052e648be111ea34",
            },
            ["0.1.1"] = {
                url    = "https://github.com/mcpplibs/os/archive/refs/tags/0.1.1.tar.gz",
                sha256 = "c5abfb625ded0d5d837b799722c836c302460251d47081fef7a57a2a12e6b2b9",
            },
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
