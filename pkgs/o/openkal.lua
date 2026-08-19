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
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.3.0/openkal-0.3.0.tar.gz",
                },
                sha256 = "919a13bb2a012f268c09591586e0c622f7ccab51bfa46cd36206576851d8945f",
            },
        },
        macosx = {
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.3.0/openkal-0.3.0.tar.gz",
                },
                sha256 = "919a13bb2a012f268c09591586e0c622f7ccab51bfa46cd36206576851d8945f",
            },
        },
        windows = {
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/0.3.0/openkal-0.3.0.tar.gz",
                },
                sha256 = "919a13bb2a012f268c09591586e0c622f7ccab51bfa46cd36206576851d8945f",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
