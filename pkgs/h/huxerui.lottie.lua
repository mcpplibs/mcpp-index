local versions = {
    ["0.1.0"] = {
        url = "https://github.com/HuxerUI/Lib-Lottie/archive/refs/tags/v0.1.0.tar.gz",
        sha256 = "d4c122867e3b002c71012d1d46c84bc1409d571f847d59636bb3808a997457ce",
    },
}

-- huxerui.lottie — Lottie vector animation component backed by ThorVG for HuxerUI.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-Lottie-0.1.0/mcpp.toml`)
-- and `build.mcpp` (`huxerui.rules`) and exports `import huxerui.lottie;`
-- (`modules/lottie.cppm`), depending on `huxerui.huxerui = "0.5.5"` and
-- `compat.thorvg = "1.1.3"`.
--
-- 0.1.0 uses plain upstream GitHub URLs (no CN mcpp-res mirror yet).
package = {
    spec        = "1",
    namespace   = "huxerui",
    name        = "lottie",
    description = "Lottie vector animation component backed by ThorVG for HuxerUI",
    licenses    = {"MIT"},
    repo        = "https://github.com/HuxerUI/Lib-Lottie",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/HuxerUI/Lib-Lottie/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.1.0"] = versions["0.1.0"],
        },
        macosx = {
            ["0.1.0"] = versions["0.1.0"],
        },
        windows = {
            ["0.1.0"] = versions["0.1.0"],
        },
    },
}
