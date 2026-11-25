-- Immutable upstream-aligned mwrap source release (abseil-m mwrap-20250512.1);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it links, compat.abseil (Abseil LTS
-- 20250512.1, the same release compat.protobuf 35.1 and mcpplibs.mwrap.grpc
-- build on, so a program using them links one Abseil), is Apache-2.0 too,
-- linked statically: the package deploys Abseil's README and LICENSE beside
-- programs (runtime.deploy). The repository is abseil-m (upstream's
-- repository is abseil-cpp; the library is Abseil). The wrapper's own CI covers
-- Linux, macOS, Windows and the Web (wasm32-emscripten, tests under node).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "abseil",
    description = "abseil-m: Abseil LTS 20250512.1 (strings, containers, hashing, status, time, synchronization, logging, flags, random) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/abseil-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/abseil-m/releases/download/${tag}/abseil-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["20250512.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/abseil-m/releases/download/mwrap-20250512.1/abseil-m-20250512.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-abseil/releases/download/20250512.1/abseil-m-20250512.1.tar.gz",
                },
                sha256 = "14cdfc1a08576e20f57b5d81a33333c4d6007d5efd141e5d3b5e9333c7ce198e",
            },
        },
        macosx = {
            ["20250512.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/abseil-m/releases/download/mwrap-20250512.1/abseil-m-20250512.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-abseil/releases/download/20250512.1/abseil-m-20250512.1.tar.gz",
                },
                sha256 = "14cdfc1a08576e20f57b5d81a33333c4d6007d5efd141e5d3b5e9333c7ce198e",
            },
        },
        windows = {
            ["20250512.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/abseil-m/releases/download/mwrap-20250512.1/abseil-m-20250512.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-abseil/releases/download/20250512.1/abseil-m-20250512.1.tar.gz",
                },
                sha256 = "14cdfc1a08576e20f57b5d81a33333c4d6007d5efd141e5d3b5e9333c7ce198e",
            },
        },
    },
}
