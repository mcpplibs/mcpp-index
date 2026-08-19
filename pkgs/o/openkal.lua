-- openkal --- the specification package.
--
-- Form A because the package is described by its own mcpp.toml.
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
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.1.0/openkal-0.1.0.tar.gz",
                },
                sha256 = "81952cf4c608cb7ffe4f01c01b0d28a6c606f28ea30b2840de33834917c54f36",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.1.0/openkal-0.1.0.tar.gz",
                },
                sha256 = "81952cf4c608cb7ffe4f01c01b0d28a6c606f28ea30b2840de33834917c54f36",
            },
        },
        windows = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.1.0/openkal-0.1.0.tar.gz",
                },
                sha256 = "81952cf4c608cb7ffe4f01c01b0d28a6c606f28ea30b2840de33834917c54f36",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
