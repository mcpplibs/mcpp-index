-- openkal-llvm-runtime --- LLVM's runtime libraries, configured for openkal.
--
-- libc++, libc++abi, libunwind and compiler-rt's builtins, built from source
-- against openkal-musl rather than against a host C library. This is the entry
-- point for a program that means to reach several machines from one source: it
-- names this package, and the C library, the platform implementation and the
-- specification follow from the graph beneath it.
--
-- No `deps'. The package names openkal-musl in its own manifest, and that
-- package in turn selects the implementation of openkal for the target being
-- built. A program adds one line and gets the whole stack.
--
-- The tarball carries the LLVM sources this build compiles, which is why it is
-- larger than every other descriptor here by two orders of magnitude. What it
-- does NOT carry is a prebuilt binary for any target: the runtime is compiled
-- for the target being built, by whichever compiler is running, which is the
-- property that makes one source reach four object formats.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-llvm-runtime",
    description = "LLVM's C++ runtime libraries -- libc++, libc++abi and libunwind -- configured for openkal-musl rather than for a host C library",
    licenses    = {"Apache-2.0 WITH LLVM-exception"},
    repo        = "https://github.com/mcpplibs/openkal-llvm-runtime",
    type        = "package",

    xpm = {
        linux = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.2.0/openkal-llvm-runtime-0.2.0.tar.gz",
                },
                sha256 = "6449c86981c01f715dcfc1cfa7048544a1d5ac06288dc41d88a26ce2846969ef",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.3/openkal-llvm-runtime-0.1.3.tar.gz",
                },
                sha256 = "ba3cd92060af48edd6cbf787680f16b43e5dedf91014bb58e5d69fcd11b7d7a7",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.2/openkal-llvm-runtime-0.1.2.tar.gz",
                },
                sha256 = "7defe539b6dfa9fb6187b65b344fd520b67e48839013a9d571a0cf21d5e84a90",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.1/openkal-llvm-runtime-0.1.1.tar.gz",
                },
                sha256 = "d3c460e0c72ed4b2ae604643b0287f5696acc7118a1d2fbd271e9fd2d44206a7",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.0/openkal-llvm-runtime-0.1.0.tar.gz",
                },
                sha256 = "100865877d616b18e9c9bc64e7edd90fe147a544955fb47c19d68d02e35701cb",
            },
        },
        macosx = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.2.0/openkal-llvm-runtime-0.2.0.tar.gz",
                },
                sha256 = "6449c86981c01f715dcfc1cfa7048544a1d5ac06288dc41d88a26ce2846969ef",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.3/openkal-llvm-runtime-0.1.3.tar.gz",
                },
                sha256 = "ba3cd92060af48edd6cbf787680f16b43e5dedf91014bb58e5d69fcd11b7d7a7",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.2/openkal-llvm-runtime-0.1.2.tar.gz",
                },
                sha256 = "7defe539b6dfa9fb6187b65b344fd520b67e48839013a9d571a0cf21d5e84a90",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.1/openkal-llvm-runtime-0.1.1.tar.gz",
                },
                sha256 = "d3c460e0c72ed4b2ae604643b0287f5696acc7118a1d2fbd271e9fd2d44206a7",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.0/openkal-llvm-runtime-0.1.0.tar.gz",
                },
                sha256 = "100865877d616b18e9c9bc64e7edd90fe147a544955fb47c19d68d02e35701cb",
            },
        },
        windows = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.2.0/openkal-llvm-runtime-0.2.0.tar.gz",
                },
                sha256 = "6449c86981c01f715dcfc1cfa7048544a1d5ac06288dc41d88a26ce2846969ef",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.3/openkal-llvm-runtime-0.1.3.tar.gz",
                },
                sha256 = "ba3cd92060af48edd6cbf787680f16b43e5dedf91014bb58e5d69fcd11b7d7a7",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.2/openkal-llvm-runtime-0.1.2.tar.gz",
                },
                sha256 = "7defe539b6dfa9fb6187b65b344fd520b67e48839013a9d571a0cf21d5e84a90",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.1/openkal-llvm-runtime-0.1.1.tar.gz",
                },
                sha256 = "d3c460e0c72ed4b2ae604643b0287f5696acc7118a1d2fbd271e9fd2d44206a7",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.0/openkal-llvm-runtime-0.1.0.tar.gz",
                },
                sha256 = "100865877d616b18e9c9bc64e7edd90fe147a544955fb47c19d68d02e35701cb",
            },
        },
    },
}
