-- Immutable upstream-aligned mwrap source release (basis-universal-m mwrap-2.50.1);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it vendors and links statically, Basis
-- Universal 2.50's transcoder, is Apache-2.0 (Binomial LLC), and the Zstandard
-- decoder upstream ships beside it is BSD-licensed (Facebook, Inc.): the package
-- deploys upstream's README, LICENSE and NOTICE and Zstandard's LICENSE beside
-- programs (runtime.deploy). It has no dependencies. Wrapper revision 2.50.1
-- builds the larger ASTC table for opaque blocks on every target (upstream
-- turns it off under Emscripten): the same ASTC blocks as WebAssembly as natively.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "basis_universal",
    description = "basis-universal-m: Basis Universal 2.50's transcoder (KTX2 and .basis textures to pixels or to a GPU's own compressed format) as a C++23 module",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/basis-universal-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/basis-universal-m/releases/download/${tag}/basis-universal-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["2.50.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/basis-universal-m/releases/download/mwrap-2.50.1/basis-universal-m-2.50.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-basis-universal/releases/download/2.50.1/basis-universal-m-2.50.1.tar.gz",
                },
                sha256 = "6ee80febbb23b4ae961855328e59e47492b5ea4ed33fdbfa6972dabf39b94f8e",
            },
        },
        macosx = {
            ["2.50.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/basis-universal-m/releases/download/mwrap-2.50.1/basis-universal-m-2.50.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-basis-universal/releases/download/2.50.1/basis-universal-m-2.50.1.tar.gz",
                },
                sha256 = "6ee80febbb23b4ae961855328e59e47492b5ea4ed33fdbfa6972dabf39b94f8e",
            },
        },
        windows = {
            ["2.50.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/basis-universal-m/releases/download/mwrap-2.50.1/basis-universal-m-2.50.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-basis-universal/releases/download/2.50.1/basis-universal-m-2.50.1.tar.gz",
                },
                sha256 = "6ee80febbb23b4ae961855328e59e47492b5ea4ed33fdbfa6972dabf39b94f8e",
            },
        },
    },
}
