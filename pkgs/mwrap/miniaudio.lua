-- Immutable upstream-aligned mwrap source release (miniaudio-m mwrap-0.11.25);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it links, compat.miniaudio (miniaudio
-- 0.11.25, compiled at gnu11 so that the Web Audio backend builds for
-- wasm32-emscripten), is a choice of MIT No Attribution or the Unlicense, linked
-- statically: the package deploys miniaudio's README and LICENSE beside
-- programs (runtime.deploy). The wrapper's own CI covers Linux, macOS, Windows
-- and the Web (wasm32-emscripten, tests under node).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "miniaudio",
    description = "miniaudio-m: miniaudio (audio playback, capture, WAV/FLAC/MP3 decoding, mixing, the engine) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/miniaudio-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/miniaudio-m/releases/download/${tag}/miniaudio-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["0.11.25"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/miniaudio-m/releases/download/mwrap-0.11.25/miniaudio-m-0.11.25.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-miniaudio/releases/download/0.11.25/miniaudio-m-0.11.25.tar.gz",
                },
                sha256 = "81fb7a80252796069581483b5457271b0312f2a5f4b37431e2ced1bac2f97eb2",
            },
        },
        macosx = {
            ["0.11.25"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/miniaudio-m/releases/download/mwrap-0.11.25/miniaudio-m-0.11.25.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-miniaudio/releases/download/0.11.25/miniaudio-m-0.11.25.tar.gz",
                },
                sha256 = "81fb7a80252796069581483b5457271b0312f2a5f4b37431e2ced1bac2f97eb2",
            },
        },
        windows = {
            ["0.11.25"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/miniaudio-m/releases/download/mwrap-0.11.25/miniaudio-m-0.11.25.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-miniaudio/releases/download/0.11.25/miniaudio-m-0.11.25.tar.gz",
                },
                sha256 = "81fb7a80252796069581483b5457271b0312f2a5f4b37431e2ced1bac2f97eb2",
            },
        },
    },
}
