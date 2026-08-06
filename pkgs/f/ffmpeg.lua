-- ⚠️ 已冻结 —— 本条目不再接收新版本。
--
-- 本包已迁往 `ffmpeg:ffmpeg@8.1.2`(见 pkgs/f/ffmpeg.ffmpeg.lua),理由是命名空间说的是这个库是谁的、
-- 版本说的是你拿到的是哪一版上游;`mcpplibs` 是 mcpp 的默认命名空间,两者都不是它
-- 该表达的东西。规则与全生态迁移表:mcpp-index#163。
--
-- 这里保留而不删除:已经在用 `mcpplibs:ffmpeg` 的消费者继续解析得到它。新版本只在新条目下
-- 发布。迁移方式是把依赖写成限定形式 ——
--
--     [dependencies.ffmpeg]
--     ffmpeg = "8.1.2"
--
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
    namespace   = "mcpplibs",
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
