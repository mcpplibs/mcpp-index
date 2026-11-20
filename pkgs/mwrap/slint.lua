-- Immutable upstream-aligned mwrap source releases (slint-m mwrap-1.19.0.2, and
-- mwrap-1.19.0.1 with its published bytes);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0. The library it links, compat.slint (Slint 1.19.0,
-- upstream CMake's desktop default features), is Slint's own three-way
-- license (GPL-3.0-only, Royalty-free-2.0 or the Software license, at the
-- user's choice); the package deploys Slint's README, LICENSE.md and the three
-- license texts beside programs (runtime.deploy). Linux x86_64, macOS arm64 and
-- Windows x86_64: compat.slint's payload has no Linux aarch64 row yet.
--
-- The build rule mcpp.mcpplibs.slintgen is the separate package
-- mcpplibs.slintgen (rules/ of the same archive), re-exported from 1.19.0.2 on.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "slint",
    description = "slint-m: Slint (declarative GUI toolkit) as C++23 modules: the runtime API, the interpreter, the platform API and the features as constants",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/slint-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/slint-m/releases/download/${tag}/slint-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.19.0.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.2/slint-m-1.19.0.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.2/slint-m-1.19.0.2.tar.gz",
                },
                sha256 = "95021ff52af53930f2b9306f5612f421e9f79741d7465ec3d586e7eb1948c62d",
            },
            ["1.19.0.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.1/slint-m-1.19.0.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.1/slint-m-1.19.0.1.tar.gz",
                },
                sha256 = "ed0da17d0e0394eba430b0e877c270251710885024f35cbb2ec1e7a71c0b7ee2",
            },
        },
        macosx = {
            ["1.19.0.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.2/slint-m-1.19.0.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.2/slint-m-1.19.0.2.tar.gz",
                },
                sha256 = "95021ff52af53930f2b9306f5612f421e9f79741d7465ec3d586e7eb1948c62d",
            },
            ["1.19.0.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.1/slint-m-1.19.0.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.1/slint-m-1.19.0.1.tar.gz",
                },
                sha256 = "ed0da17d0e0394eba430b0e877c270251710885024f35cbb2ec1e7a71c0b7ee2",
            },
        },
        windows = {
            ["1.19.0.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.2/slint-m-1.19.0.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.2/slint-m-1.19.0.2.tar.gz",
                },
                sha256 = "95021ff52af53930f2b9306f5612f421e9f79741d7465ec3d586e7eb1948c62d",
            },
            ["1.19.0.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.1/slint-m-1.19.0.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.1/slint-m-1.19.0.1.tar.gz",
                },
                sha256 = "ed0da17d0e0394eba430b0e877c270251710885024f35cbb2ec1e7a71c0b7ee2",
            },
        },
    },
}
