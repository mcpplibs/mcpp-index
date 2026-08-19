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
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.4.0/openkal-0.4.0.tar.gz",
                },
                sha256 = "e0fe3da54c73a237fad8461268a536b498d2366d9f512c888234eddfc7a9142d",
            },
        },
        macosx = {
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.4.0/openkal-0.4.0.tar.gz",
                },
                sha256 = "e0fe3da54c73a237fad8461268a536b498d2366d9f512c888234eddfc7a9142d",
            },
        },
        windows = {
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
