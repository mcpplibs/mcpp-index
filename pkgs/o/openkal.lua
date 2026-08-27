-- openkal --- the specification package.
--
-- Form A because the package is described by its own mcpp.toml.
--
-- 0.1.0 is replaced rather than retained. It placed the module a consumer
-- imports under the control of the implementation, which contradicts what
-- the specification is for; two incompatible specifications under one name
-- would be worse than the absence of the earlier one, which no project uses.
--
-- No `deps`. This package declares and does not define; it needs neither a
-- toolchain payload nor a target sysroot, and the implementation that supplies
-- the definitions is selected by the consuming project as a conditional
-- dependency rather than by this descriptor.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal",
    description = "openkal: a portable kernel ABI specification, and the C++ modules that declare it",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal",
    type        = "package",

    xpm = {
        linux = {
            ["0.8.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.8.0/openkal-0.8.0.tar.gz",
                },
                sha256 = "c0e758847847baac55763f2056881760834892252f35b2e671bff310d7dd0b34",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.7.0/openkal-0.7.0.tar.gz",
                },
                sha256 = "47909cd3add5a62b668c4e0bcb04fb0ec46b79f4fccef12b19b25f6a76578f22",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.6.0/openkal-0.6.0.tar.gz",
                },
                sha256 = "643a6ec61623f79298610b259c00042ad1f33d059d91ce4613c79ffb8d649371",
            },
            ["0.5.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.5.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.5.2/openkal-0.5.2.tar.gz",
                },
                sha256 = "f0d97398391b77adf1958dc78ff6fcb96fc6bdeb6652a7b7f7d5cb83fb300327",
            },
            ["0.5.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.5.1/openkal-0.5.1.tar.gz",
                },
                sha256 = "cc4bd91fe0ea7c2046307e9bee92b58c9ea29f18056a03ff717f6c8e1e839d20",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.4.0/openkal-0.4.0.tar.gz",
                },
                sha256 = "e0fe3da54c73a237fad8461268a536b498d2366d9f512c888234eddfc7a9142d",
            },
        },
        macosx = {
            ["0.8.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.8.0/openkal-0.8.0.tar.gz",
                },
                sha256 = "c0e758847847baac55763f2056881760834892252f35b2e671bff310d7dd0b34",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.7.0/openkal-0.7.0.tar.gz",
                },
                sha256 = "47909cd3add5a62b668c4e0bcb04fb0ec46b79f4fccef12b19b25f6a76578f22",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.6.0/openkal-0.6.0.tar.gz",
                },
                sha256 = "643a6ec61623f79298610b259c00042ad1f33d059d91ce4613c79ffb8d649371",
            },
            ["0.5.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.5.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.5.2/openkal-0.5.2.tar.gz",
                },
                sha256 = "f0d97398391b77adf1958dc78ff6fcb96fc6bdeb6652a7b7f7d5cb83fb300327",
            },
            ["0.5.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.5.1/openkal-0.5.1.tar.gz",
                },
                sha256 = "cc4bd91fe0ea7c2046307e9bee92b58c9ea29f18056a03ff717f6c8e1e839d20",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.4.0/openkal-0.4.0.tar.gz",
                },
                sha256 = "e0fe3da54c73a237fad8461268a536b498d2366d9f512c888234eddfc7a9142d",
            },
        },
        windows = {
            ["0.8.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.8.0/openkal-0.8.0.tar.gz",
                },
                sha256 = "c0e758847847baac55763f2056881760834892252f35b2e671bff310d7dd0b34",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.7.0/openkal-0.7.0.tar.gz",
                },
                sha256 = "47909cd3add5a62b668c4e0bcb04fb0ec46b79f4fccef12b19b25f6a76578f22",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.6.0/openkal-0.6.0.tar.gz",
                },
                sha256 = "643a6ec61623f79298610b259c00042ad1f33d059d91ce4613c79ffb8d649371",
            },
            ["0.5.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.5.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.5.2/openkal-0.5.2.tar.gz",
                },
                sha256 = "f0d97398391b77adf1958dc78ff6fcb96fc6bdeb6652a7b7f7d5cb83fb300327",
            },
            ["0.5.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.5.1/openkal-0.5.1.tar.gz",
                },
                sha256 = "cc4bd91fe0ea7c2046307e9bee92b58c9ea29f18056a03ff717f6c8e1e839d20",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.4.0/openkal-0.4.0.tar.gz",
                },
                sha256 = "e0fe3da54c73a237fad8461268a536b498d2366d9f512c888234eddfc7a9142d",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
