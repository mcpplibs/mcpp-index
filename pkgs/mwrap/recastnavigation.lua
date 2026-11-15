-- Immutable upstream-aligned mwrap source releases (recastnavigation-m mwrap-1.6.0, the first release of upstream
-- 1.6.0; mwrap-1.6.0.1, its first revision); GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the libraries it vendors and links statically,
-- Recast & Detour 1.6.0, are zlib: the package deploys their README and
-- License.txt beside programs (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "recastnavigation",
    description = "recastnavigation-m: Recast & Detour 1.6.0 (navigation meshes built from triangles, path finding, crowds, tiled meshes with obstacles) as a C++23 module",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/recastnavigation-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/recastnavigation-m/releases/download/${tag}/recastnavigation-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/recastnavigation-m/releases/download/mwrap-1.6.0/recastnavigation-m-1.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-recastnavigation/releases/download/1.6.0/recastnavigation-m-1.6.0.tar.gz",
                },
                sha256 = "13382f6c751ee5d000987c8e45e3721a4106f928753e004856dc339fbf5daa05",
            },
            ["1.6.0.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/recastnavigation-m/releases/download/mwrap-1.6.0.1/recastnavigation-m-1.6.0.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-recastnavigation/releases/download/1.6.0.1/recastnavigation-m-1.6.0.1.tar.gz",
                },
                sha256 = "5dd92b25792ea35b10b4a40ddfd772915b67ec648ce5296abe21c30d4da8fbc9",
            },
        },
        macosx = {
            ["1.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/recastnavigation-m/releases/download/mwrap-1.6.0/recastnavigation-m-1.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-recastnavigation/releases/download/1.6.0/recastnavigation-m-1.6.0.tar.gz",
                },
                sha256 = "13382f6c751ee5d000987c8e45e3721a4106f928753e004856dc339fbf5daa05",
            },
            ["1.6.0.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/recastnavigation-m/releases/download/mwrap-1.6.0.1/recastnavigation-m-1.6.0.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-recastnavigation/releases/download/1.6.0.1/recastnavigation-m-1.6.0.1.tar.gz",
                },
                sha256 = "5dd92b25792ea35b10b4a40ddfd772915b67ec648ce5296abe21c30d4da8fbc9",
            },
        },
        windows = {
            ["1.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/recastnavigation-m/releases/download/mwrap-1.6.0/recastnavigation-m-1.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-recastnavigation/releases/download/1.6.0/recastnavigation-m-1.6.0.tar.gz",
                },
                sha256 = "13382f6c751ee5d000987c8e45e3721a4106f928753e004856dc339fbf5daa05",
            },
            ["1.6.0.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/recastnavigation-m/releases/download/mwrap-1.6.0.1/recastnavigation-m-1.6.0.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-recastnavigation/releases/download/1.6.0.1/recastnavigation-m-1.6.0.1.tar.gz",
                },
                sha256 = "5dd92b25792ea35b10b4a40ddfd772915b67ec648ce5296abe21c30d4da8fbc9",
            },
        },
    },
}
