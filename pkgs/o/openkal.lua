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
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.2.0/openkal-0.2.0.tar.gz",
                },
                sha256 = "461865b784dbb2eb70f757e11889428e1551e297878877c424d429ff3a55281b",
            },
        },
        macosx = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.2.0/openkal-0.2.0.tar.gz",
                },
                sha256 = "461865b784dbb2eb70f757e11889428e1551e297878877c424d429ff3a55281b",
            },
        },
        windows = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.2.0/openkal-0.2.0.tar.gz",
                },
                sha256 = "461865b784dbb2eb70f757e11889428e1551e297878877c424d429ff3a55281b",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
