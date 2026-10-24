-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "ffmpeg",
    description = "ffmpeg-m upstream-preserving C++23 module wrapper",
    licenses = { "MIT" },
    repo = "https://github.com/mcpplibs/ffmpeg-m",
    type = "package",
    xpm = {
        linux = {
            ["8.1.2"] = {
                url = "https://github.com/mcpplibs/ffmpeg-m/archive/572091c02606f66e47318176d25e7d821baaaae6.tar.gz",
                sha256 = "4167c0501ca9b9cf3bcbc2cd78485fc007bceca07f5aa4bf41097c56d14d148a",
            },
        },
        macosx = {
            ["8.1.2"] = {
                url = "https://github.com/mcpplibs/ffmpeg-m/archive/572091c02606f66e47318176d25e7d821baaaae6.tar.gz",
                sha256 = "4167c0501ca9b9cf3bcbc2cd78485fc007bceca07f5aa4bf41097c56d14d148a",
            },
        },
        windows = {
            ["8.1.2"] = {
                url = "https://github.com/mcpplibs/ffmpeg-m/archive/572091c02606f66e47318176d25e7d821baaaae6.tar.gz",
                sha256 = "4167c0501ca9b9cf3bcbc2cd78485fc007bceca07f5aa4bf41097c56d14d148a",
            },
        },
    },
}
