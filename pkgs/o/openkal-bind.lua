-- openkal-bind --- the build plugin `mcpp.mcpplibs.openkal_bind' (openkal-image
-- docs/bind.md).
--
-- A member of mcpplibs/openkal-image from 0.1.2 (one tag, one archive). A
-- library published as an ok image (`lib<name>.okso') and a C header calls it
-- from its build.mcpp:
--
--     [build-dependencies]
--     openkal-bind = "0.1.2"
--
-- On an openkal target the image is linked as it is; on Linux, macOS and
-- Windows the plugin reads the header with clang, checks the boundary, and
-- generates a binding that calls the image through libokrun (openkal-run).
--
-- No `deps'. The plugin names no package; the library that uses it names
-- openkal-run, and the plugin's own `xim:llvm' payload is declared on request.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-bind",
    description = "A build plugin: a library published as an ok image (.okso) and a C header is called from a program of Linux, macOS or Windows, through a binding generated from the header and libokrun",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-image",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.7/openkal-image-0.1.7.tar.gz",
                },
                sha256 = "cbe4971fd0f3ae4c3dc522d0e9ab361522670ddb90af5b64be46c362ac7ded52",
            },
            ["0.1.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.6/openkal-image-0.1.6.tar.gz",
                },
                sha256 = "0258983a10984f7b4597ed1e7dd08fb5b2dad436113574791bedc0ea2d1b002b",
            },
            ["0.1.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.5/openkal-image-0.1.5.tar.gz",
                },
                sha256 = "5cd28c5bcebf7c4f0b9f69ea01e1e5d8f595ed148d485404ad367631c083aef8",
            },
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.4/openkal-image-0.1.4.tar.gz",
                },
                sha256 = "d9ec0dc0a78c2bdbd20f1420df510805ef3f019545cb5306393ca31765edf5ff",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.3/openkal-image-0.1.3.tar.gz",
                },
                sha256 = "eec70f276f973b1eb64b28773432489723866e38b6261edba24e137387099f23",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.2/openkal-image-0.1.2.tar.gz",
                },
                sha256 = "63768571a800f3acdad420e18c14ee1bc5142f77ef29dcf01841f40d8f1f9a25",
            },
        },
        macosx = {
            ["0.1.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.7/openkal-image-0.1.7.tar.gz",
                },
                sha256 = "cbe4971fd0f3ae4c3dc522d0e9ab361522670ddb90af5b64be46c362ac7ded52",
            },
            ["0.1.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.6/openkal-image-0.1.6.tar.gz",
                },
                sha256 = "0258983a10984f7b4597ed1e7dd08fb5b2dad436113574791bedc0ea2d1b002b",
            },
            ["0.1.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.5/openkal-image-0.1.5.tar.gz",
                },
                sha256 = "5cd28c5bcebf7c4f0b9f69ea01e1e5d8f595ed148d485404ad367631c083aef8",
            },
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.4/openkal-image-0.1.4.tar.gz",
                },
                sha256 = "d9ec0dc0a78c2bdbd20f1420df510805ef3f019545cb5306393ca31765edf5ff",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.3/openkal-image-0.1.3.tar.gz",
                },
                sha256 = "eec70f276f973b1eb64b28773432489723866e38b6261edba24e137387099f23",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.2/openkal-image-0.1.2.tar.gz",
                },
                sha256 = "63768571a800f3acdad420e18c14ee1bc5142f77ef29dcf01841f40d8f1f9a25",
            },
        },
        windows = {
            ["0.1.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.7/openkal-image-0.1.7.tar.gz",
                },
                sha256 = "cbe4971fd0f3ae4c3dc522d0e9ab361522670ddb90af5b64be46c362ac7ded52",
            },
            ["0.1.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.6/openkal-image-0.1.6.tar.gz",
                },
                sha256 = "0258983a10984f7b4597ed1e7dd08fb5b2dad436113574791bedc0ea2d1b002b",
            },
            ["0.1.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.5/openkal-image-0.1.5.tar.gz",
                },
                sha256 = "5cd28c5bcebf7c4f0b9f69ea01e1e5d8f595ed148d485404ad367631c083aef8",
            },
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.4/openkal-image-0.1.4.tar.gz",
                },
                sha256 = "d9ec0dc0a78c2bdbd20f1420df510805ef3f019545cb5306393ca31765edf5ff",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.3/openkal-image-0.1.3.tar.gz",
                },
                sha256 = "eec70f276f973b1eb64b28773432489723866e38b6261edba24e137387099f23",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.2/openkal-image-0.1.2.tar.gz",
                },
                sha256 = "63768571a800f3acdad420e18c14ee1bc5142f77ef29dcf01841f40d8f1f9a25",
            },
        },
    },

    mcpp = "*/bind/mcpp.toml",
}
