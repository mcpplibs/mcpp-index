-- Immutable upstream-aligned mwrap source release (manifold-m mwrap-3.5.5);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it vendors and links statically,
-- Manifold 3.5.5, is Apache-2.0: the package deploys its README, LICENSE and
-- AUTHORS beside programs (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "manifold",
    description = "manifold-m: Manifold 3.5.5 (booleans, hulls, level sets, slices and extrusions of solids that stay solid) as a C++23 module",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/manifold-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/manifold-m/releases/download/${tag}/manifold-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["3.5.5"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/manifold-m/releases/download/mwrap-3.5.5/manifold-m-3.5.5.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-manifold/releases/download/3.5.5/manifold-m-3.5.5.tar.gz",
                },
                sha256 = "87325649c4f7f653e7fffd929a030d3fdd252bd2cdabae920d6cb88afdfacb85",
            },
        },
        macosx = {
            ["3.5.5"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/manifold-m/releases/download/mwrap-3.5.5/manifold-m-3.5.5.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-manifold/releases/download/3.5.5/manifold-m-3.5.5.tar.gz",
                },
                sha256 = "87325649c4f7f653e7fffd929a030d3fdd252bd2cdabae920d6cb88afdfacb85",
            },
        },
        windows = {
            ["3.5.5"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/manifold-m/releases/download/mwrap-3.5.5/manifold-m-3.5.5.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-manifold/releases/download/3.5.5/manifold-m-3.5.5.tar.gz",
                },
                sha256 = "87325649c4f7f653e7fffd929a030d3fdd252bd2cdabae920d6cb88afdfacb85",
            },
        },
    },
}
