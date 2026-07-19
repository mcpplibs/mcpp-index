-- Form A descriptor: the public ffmpeg module package ships its own
-- mcpp.toml. mcpp's default lookup finds <verdir>/*/mcpp.toml inside
-- the GitHub source tarball wrap.
--
-- The package is the thin C++23 module layer (import ffmpeg.av / per-lib
-- ffmpeg.avcodec, …) over FFmpeg's unchanged C API; the FFmpeg sources
-- themselves arrive through its compat.ffmpeg dependency (full source
-- build, config snapshot — see pkgs/c/compat.ffmpeg.lua). Linux-only for
-- now: compat.ffmpeg carries a linux-x86_64 configure snapshot (macOS
-- blocked on mcpp#229 dependency cfg-conditional sources).
--
package = {
    spec        = "1",
    name        = "ffmpeg",
    namespace   = "",
    description = "C++23 module package for FFmpeg (import ffmpeg.av) — full source build via compat.ffmpeg, C API unchanged",
    licenses    = {"MIT"},   -- module layer; upstream via compat.ffmpeg is LGPL-2.1-or-later
    repo        = "https://github.com/mcpplibs/ffmpeg-m",
    type        = "package",

    xpm = {
        linux = {
            ["0.0.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/ffmpeg-m/archive/refs/tags/v0.0.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/ffmpeg/releases/download/v0.0.3/ffmpeg-m-0.0.3.tar.gz",
                },
                sha256 = "822e59d1674b2ead88d1c8e2806c8f661dc0c628980e1dc23fd22dd51bf55fcc",
            },
        },
        macosx = {
            ["0.0.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/ffmpeg-m/archive/refs/tags/v0.0.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/ffmpeg/releases/download/v0.0.3/ffmpeg-m-0.0.3.tar.gz",
                },
                sha256 = "822e59d1674b2ead88d1c8e2806c8f661dc0c628980e1dc23fd22dd51bf55fcc",
            },
        },
        windows = {
            ["0.0.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/ffmpeg-m/archive/refs/tags/v0.0.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/ffmpeg/releases/download/v0.0.3/ffmpeg-m-0.0.3.tar.gz",
                },
                sha256 = "822e59d1674b2ead88d1c8e2806c8f661dc0c628980e1dc23fd22dd51bf55fcc",
            },
        },
    },

    -- (no `mcpp` field -- default lookup will find <verdir>/*/mcpp.toml)
}
