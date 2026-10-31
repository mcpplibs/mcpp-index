-- openkal-tools --- okrun and okld (openkal SPEC clause 12).
--
-- A member of mcpplibs/openkal-image (one tag, one archive). A project that
-- builds ok images (`<arch>-openkal`) declares it for this machine:
--
--     [build-dependencies]
--     openkal-tools = { version = "0.1.0", tools = ["okld", "okrun"] }
--
-- mcpp finishes each image with okld and runs it with okrun.
--
-- No `deps'. The package names openkal-run and openkal-ld.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-tools",
    description = "okrun and okld: the runner of ok images, and the tool that writes an image's requirements note, checks the convention and signs it",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-image",
    type        = "package",

    xpm = {
        linux = {
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
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.1/openkal-image-0.1.1.tar.gz",
                },
                sha256 = "7b0056d62e1f297b937d63e9f59b5d82ec19f034a1286ec6ec44d6c834d5f0cc",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.0/openkal-image-0.1.0.tar.gz",
                },
                sha256 = "50d79f5a2ba9404e533693527b93a0e2e76f250840939b64bf2ea97a21cb414b",
            },
        },
        macosx = {
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
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.1/openkal-image-0.1.1.tar.gz",
                },
                sha256 = "7b0056d62e1f297b937d63e9f59b5d82ec19f034a1286ec6ec44d6c834d5f0cc",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.0/openkal-image-0.1.0.tar.gz",
                },
                sha256 = "50d79f5a2ba9404e533693527b93a0e2e76f250840939b64bf2ea97a21cb414b",
            },
        },
        windows = {
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
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.1/openkal-image-0.1.1.tar.gz",
                },
                sha256 = "7b0056d62e1f297b937d63e9f59b5d82ec19f034a1286ec6ec44d6c834d5f0cc",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.0/openkal-image-0.1.0.tar.gz",
                },
                sha256 = "50d79f5a2ba9404e533693527b93a0e2e76f250840939b64bf2ea97a21cb414b",
            },
        },
    },

    mcpp = "*/tools/mcpp.toml",
}
