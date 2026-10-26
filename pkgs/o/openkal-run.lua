-- openkal-run --- libokrun, the runner of ok images (openkal SPEC clause 12).
--
-- A member of mcpplibs/openkal-image (one tag, one archive). It maps an image
-- with libokld and binds what the image imports to the implementation of
-- openkal for the system it is built for, which its own manifest names under
-- `[target.<os>.dependencies]`. `okrun` is built from it, and so is a program
-- that carries an image as a section (`mcpp pack --mode self-contained`, M3).
--
-- No `deps'. The package names openkal, openkal-ld and the implementation.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-run",
    description = "libokrun: the runner of ok images over this system's openkal implementation --- it maps an image with libokld and binds the kal_* names it imports to this process's implementation",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-image",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.0/openkal-image-0.1.0.tar.gz",
                },
                sha256 = "50d79f5a2ba9404e533693527b93a0e2e76f250840939b64bf2ea97a21cb414b",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.0/openkal-image-0.1.0.tar.gz",
                },
                sha256 = "50d79f5a2ba9404e533693527b93a0e2e76f250840939b64bf2ea97a21cb414b",
            },
        },
        windows = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-image/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-image/releases/download/0.1.0/openkal-image-0.1.0.tar.gz",
                },
                sha256 = "50d79f5a2ba9404e533693527b93a0e2e76f250840939b64bf2ea97a21cb414b",
            },
        },
    },

    mcpp = "*/run/mcpp.toml",
}
