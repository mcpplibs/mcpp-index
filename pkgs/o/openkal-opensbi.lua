-- openkal-opensbi — openkal on the RISC-V Supervisor Binary Interface.
--
-- ⭐ The PORTABLE RISC-V backend, as distinct from a board's own. A board
-- backend writes to a device address, and that address is a board fact: the
-- same binary on a second RISC-V machine writes to something that is not a
-- UART and prints nothing. SBI's console is a call into firmware that already
-- knows the machine, so one image runs under OpenSBI on QEMU's `virt` and on a
-- real board without being rebuilt.
--
-- ⚠️ NO `deps`. The only mcpp dependency is the specification package, declared
-- in this package's own manifest; nothing needs installing.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-opensbi",
    description = "An implementation of openkal on the RISC-V Supervisor Binary Interface, portable across every machine whose firmware provides one",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-opensbi",
    type        = "package",

    xpm = {
        linux = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.2.0/openkal-opensbi-0.2.0.tar.gz",
                },
                sha256 = "e5c4f0112e2a2dd52472932ca2fd0ef3a08880f9c001044bf3e19d0b3f8174bf",
            },
            ["0.1.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.5/openkal-opensbi-0.1.5.tar.gz",
                },
                sha256 = "7bda45b8aca80528bd127a22e2a6ca80cf1e2aa2d421ad6d7a672ae06cf88fd0",
            },
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.4/openkal-opensbi-0.1.4.tar.gz",
                },
                sha256 = "9764ee70712c9f8c97dd490b4e49762d18a7e983cb4c63aa4a5991a0a3f3e034",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.2/openkal-opensbi-0.1.2.tar.gz",
                },
                sha256 = "c5328d282828fd7398b2376f269974a9b51f46f22e8247d9f81d2ece0628416b",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.1/openkal-opensbi-0.1.1.tar.gz",
                },
                sha256 = "5c8cc2479654139c14b9aa3d912aac980fa942fa2ad6abf74e6be7443901e02d",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.0/openkal-opensbi-0.1.0.tar.gz",
                },
                sha256 = "6b5b81be59171f6f0d8e5d2e586a7f502479a2f309efb7fb1ab17c77a7579884",
            },
        },
        macosx = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.2.0/openkal-opensbi-0.2.0.tar.gz",
                },
                sha256 = "e5c4f0112e2a2dd52472932ca2fd0ef3a08880f9c001044bf3e19d0b3f8174bf",
            },
            ["0.1.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.5/openkal-opensbi-0.1.5.tar.gz",
                },
                sha256 = "7bda45b8aca80528bd127a22e2a6ca80cf1e2aa2d421ad6d7a672ae06cf88fd0",
            },
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.4/openkal-opensbi-0.1.4.tar.gz",
                },
                sha256 = "9764ee70712c9f8c97dd490b4e49762d18a7e983cb4c63aa4a5991a0a3f3e034",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.2/openkal-opensbi-0.1.2.tar.gz",
                },
                sha256 = "c5328d282828fd7398b2376f269974a9b51f46f22e8247d9f81d2ece0628416b",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.1/openkal-opensbi-0.1.1.tar.gz",
                },
                sha256 = "5c8cc2479654139c14b9aa3d912aac980fa942fa2ad6abf74e6be7443901e02d",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.0/openkal-opensbi-0.1.0.tar.gz",
                },
                sha256 = "6b5b81be59171f6f0d8e5d2e586a7f502479a2f309efb7fb1ab17c77a7579884",
            },
        },
        windows = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.2.0/openkal-opensbi-0.2.0.tar.gz",
                },
                sha256 = "e5c4f0112e2a2dd52472932ca2fd0ef3a08880f9c001044bf3e19d0b3f8174bf",
            },
            ["0.1.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.5/openkal-opensbi-0.1.5.tar.gz",
                },
                sha256 = "7bda45b8aca80528bd127a22e2a6ca80cf1e2aa2d421ad6d7a672ae06cf88fd0",
            },
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.4/openkal-opensbi-0.1.4.tar.gz",
                },
                sha256 = "9764ee70712c9f8c97dd490b4e49762d18a7e983cb4c63aa4a5991a0a3f3e034",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.2/openkal-opensbi-0.1.2.tar.gz",
                },
                sha256 = "c5328d282828fd7398b2376f269974a9b51f46f22e8247d9f81d2ece0628416b",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.1/openkal-opensbi-0.1.1.tar.gz",
                },
                sha256 = "5c8cc2479654139c14b9aa3d912aac980fa942fa2ad6abf74e6be7443901e02d",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.0/openkal-opensbi-0.1.0.tar.gz",
                },
                sha256 = "6b5b81be59171f6f0d8e5d2e586a7f502479a2f309efb7fb1ab17c77a7579884",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
