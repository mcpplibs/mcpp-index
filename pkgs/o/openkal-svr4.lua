-- openkal-svr4 --- openkal for UNIX System V Release 4 and its descendants on
-- i386, on the kernel's own system-call interface. A project names the target
-- `i686-svr4-musl` with openkal-platform (0.30.0+), which states this
-- implementation as the row's `kernel-abi` layer and runs the program under
-- xim's ibcs-us, an emulation of the interface on Linux x86_64. From 0.3.0 it
-- claims openkal.process and openkal.space, and its CI runs the specification's
-- suite under ibcs-us 4.3-2 and on a System V kernel (AT&T UNIX System V/386
-- Release 4.0 Version 3.0 in QEMU, xim's svr4-disk-image, technical
-- verification only); the package's README states both.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-svr4",
    description = "An implementation of openkal for UNIX System V Release 4 and its descendants on i386, on the kernel's system-call interface",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-svr4",
    type        = "package",

    xpm = {
        linux = {
            ["0.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-svr4/archive/refs/tags/0.3.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-svr4/releases/download/0.3.0/openkal-svr4-0.3.0.tar.gz",
                },
                sha256 = "5b9471b08800d07b38b44e835961810251455c157679f25e1eb7851618bb7e1c",
            },
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-svr4/archive/refs/tags/0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-svr4/releases/download/0.2.0/openkal-svr4-0.2.0.tar.gz",
                },
                sha256 = "1e54b5a8e8fa1dddf078258aa8bfd94b835abb5c6f97065a29ba6a4236165435",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-svr4/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-svr4/releases/download/0.1.0/openkal-svr4-0.1.0.tar.gz",
                },
                sha256 = "44400c3d1e4ffd1635df6fa63a415e3f305240a7414a75ffc0b384844906d72c",
            },
        },
        macosx = {
            ["0.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-svr4/archive/refs/tags/0.3.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-svr4/releases/download/0.3.0/openkal-svr4-0.3.0.tar.gz",
                },
                sha256 = "5b9471b08800d07b38b44e835961810251455c157679f25e1eb7851618bb7e1c",
            },
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-svr4/archive/refs/tags/0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-svr4/releases/download/0.2.0/openkal-svr4-0.2.0.tar.gz",
                },
                sha256 = "1e54b5a8e8fa1dddf078258aa8bfd94b835abb5c6f97065a29ba6a4236165435",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-svr4/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-svr4/releases/download/0.1.0/openkal-svr4-0.1.0.tar.gz",
                },
                sha256 = "44400c3d1e4ffd1635df6fa63a415e3f305240a7414a75ffc0b384844906d72c",
            },
        },
        windows = {
            ["0.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-svr4/archive/refs/tags/0.3.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-svr4/releases/download/0.3.0/openkal-svr4-0.3.0.tar.gz",
                },
                sha256 = "5b9471b08800d07b38b44e835961810251455c157679f25e1eb7851618bb7e1c",
            },
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-svr4/archive/refs/tags/0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-svr4/releases/download/0.2.0/openkal-svr4-0.2.0.tar.gz",
                },
                sha256 = "1e54b5a8e8fa1dddf078258aa8bfd94b835abb5c6f97065a29ba6a4236165435",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-svr4/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-svr4/releases/download/0.1.0/openkal-svr4-0.1.0.tar.gz",
                },
                sha256 = "44400c3d1e4ffd1635df6fa63a415e3f305240a7414a75ffc0b384844906d72c",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
