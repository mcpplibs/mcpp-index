-- Immutable upstream-aligned mwrap source release (slint-m mwrap-1.19.0);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0. The library it links, compat.slint (Slint 1.19.0,
-- upstream CMake's desktop default features), is Slint's own three-way
-- license (GPL-3.0-only, Royalty-free-2.0 or the Software license, at the
-- user's choice); the package deploys Slint's README, LICENSE.md and the three
-- license texts beside programs (runtime.deploy). Linux x86_64, macOS arm64 and
-- Windows x86_64: compat.slint's payload has no Linux aarch64 row yet.
--
-- The build rule mcpp.plugins.slint is the separate package mcpplibs.slintgen
-- (rules/ of the same archive).
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
            ["1.19.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0/slint-m-1.19.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0/slint-m-1.19.0.tar.gz",
                },
                sha256 = "f75b8fb3ce6e779a176fe47f4a8e07df8bec8713e2b1bde7f199e1400097ddd9",
            },
        },
        macosx = {
            ["1.19.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0/slint-m-1.19.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0/slint-m-1.19.0.tar.gz",
                },
                sha256 = "f75b8fb3ce6e779a176fe47f4a8e07df8bec8713e2b1bde7f199e1400097ddd9",
            },
        },
        windows = {
            ["1.19.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0/slint-m-1.19.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0/slint-m-1.19.0.tar.gz",
                },
                sha256 = "f75b8fb3ce6e779a176fe47f4a8e07df8bec8713e2b1bde7f199e1400097ddd9",
            },
        },
    },
}
