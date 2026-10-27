-- openkal-ld --- libokld, the ok format's library (openkal SPEC clause 12).
--
-- One of the three packages of mcpplibs/openkal-image, which share one tag
-- and one archive; each descriptor names its member's manifest. Freestanding:
-- the definition of the format, a reader, a checker, a signer and a loader, for
-- a loader (openkal-run), the tools (openkal-tools) and a C library that
-- loads an image beside itself (openkal-musl's dlopen in an ok image).
--
-- No `deps'. The package names nothing beneath it.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-ld",
    description = "libokld: the ok format (openkal image format) --- its definition, a reader of bytes, a checker, a signer, and a loader. Freestanding: no C library, no exceptions",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-image",
    type        = "package",

    xpm = {
        linux = {
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

    mcpp = "*/ld/mcpp.toml",
}
