-- Immutable upstream-aligned mwrap source release (jolt-m mwrap-5.6.0, the first release of upstream 5.6.0);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it vendors and links statically,
-- Jolt Physics 5.6.0, is MIT: the package deploys its README and LICENSE
-- beside programs (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "jolt",
    description = "jolt-m: Jolt Physics 5.6.0 (rigid and soft body physics: shapes, constraints, queries, characters, vehicles), cross-platform deterministic, as a C++23 module",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/jolt-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/jolt-m/releases/download/${tag}/jolt-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["5.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/jolt-m/releases/download/mwrap-5.6.0/jolt-m-5.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-jolt/releases/download/5.6.0/jolt-m-5.6.0.tar.gz",
                },
                sha256 = "ea4b7052c13888142594a01966081bda80a2dc8a32e9e093479cfacaba939c49",
            },
        },
        macosx = {
            ["5.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/jolt-m/releases/download/mwrap-5.6.0/jolt-m-5.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-jolt/releases/download/5.6.0/jolt-m-5.6.0.tar.gz",
                },
                sha256 = "ea4b7052c13888142594a01966081bda80a2dc8a32e9e093479cfacaba939c49",
            },
        },
        windows = {
            ["5.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/jolt-m/releases/download/mwrap-5.6.0/jolt-m-5.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-jolt/releases/download/5.6.0/jolt-m-5.6.0.tar.gz",
                },
                sha256 = "ea4b7052c13888142594a01966081bda80a2dc8a32e9e093479cfacaba939c49",
            },
        },
    },
}
