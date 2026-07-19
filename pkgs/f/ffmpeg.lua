-- Form A descriptor: the public ffmpeg module package ships its own
-- mcpp.toml. mcpp's default lookup finds <verdir>/*/mcpp.toml inside
-- the GitHub source tarball wrap.
--
-- The package is the thin C++23 module layer (import ffmpeg.av / per-lib
-- ffmpeg.avcodec, …) over FFmpeg's unchanged C API; the FFmpeg sources
-- themselves arrive through its compat.ffmpeg dependency (full source
-- build, per-OS config snapshot — see pkgs/c/compat.ffmpeg.lua). Linux +
-- macOS: compat.ffmpeg carries per-OS frozen snapshots (linux-x86_64 NASM,
-- macosx-arm64 NEON) and the module layer is platform-neutral. Windows
-- pending mcpp#247 (driver-style link rspfile).
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
            ["0.0.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/ffmpeg-m/archive/refs/tags/v0.0.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/ffmpeg/releases/download/v0.0.2/ffmpeg-m-0.0.2.tar.gz",
                },
                sha256 = "557e885315f16866c2ed2e367bcd6b0af2d79f9a9f36202b23c89f73d81cecea",
            },
        },
        macosx = {
            ["0.0.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/ffmpeg-m/archive/refs/tags/v0.0.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/ffmpeg/releases/download/v0.0.2/ffmpeg-m-0.0.2.tar.gz",
                },
                sha256 = "557e885315f16866c2ed2e367bcd6b0af2d79f9a9f36202b23c89f73d81cecea",
            },
        },
    },

    -- (no `mcpp` field -- default lookup will find <verdir>/*/mcpp.toml)
}
