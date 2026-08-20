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
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.0/openkal-opensbi-0.1.0.tar.gz",
                },
                sha256 = "6b5b81be59171f6f0d8e5d2e586a7f502479a2f309efb7fb1ab17c77a7579884",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-opensbi/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-opensbi/releases/download/0.1.0/openkal-opensbi-0.1.0.tar.gz",
                },
                sha256 = "6b5b81be59171f6f0d8e5d2e586a7f502479a2f309efb7fb1ab17c77a7579884",
            },
        },
        windows = {
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
