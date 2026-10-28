-- Immutable upstream-aligned mwrap source release (box2d-m mwrap-3.2.0);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it links, compat.box2d (Box2D 3.2.0,
-- single precision, -ffp-contract=off), is MIT, linked statically: the package
-- deploys Box2D's README and LICENSE beside programs (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "box2d",
    description = "box2d-m: Box2D 3.2.0 (the 2D rigid-body physics engine, cross-platform deterministic) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/box2d-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/box2d-m/releases/download/${tag}/box2d-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["3.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/box2d-m/releases/download/mwrap-3.2.0/box2d-m-3.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-box2d/releases/download/3.2.0/box2d-m-3.2.0.tar.gz",
                },
                sha256 = "a7b448ea45e29edfb36059f0a6c6acd1f24655deae61742f64287a71bf197572",
            },
        },
        macosx = {
            ["3.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/box2d-m/releases/download/mwrap-3.2.0/box2d-m-3.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-box2d/releases/download/3.2.0/box2d-m-3.2.0.tar.gz",
                },
                sha256 = "a7b448ea45e29edfb36059f0a6c6acd1f24655deae61742f64287a71bf197572",
            },
        },
        windows = {
            ["3.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/box2d-m/releases/download/mwrap-3.2.0/box2d-m-3.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-box2d/releases/download/3.2.0/box2d-m-3.2.0.tar.gz",
                },
                sha256 = "a7b448ea45e29edfb36059f0a6c6acd1f24655deae61742f64287a71bf197572",
            },
        },
    },
}
