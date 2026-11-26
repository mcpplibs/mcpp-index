local versions = {
    ["0.1.1"] = {
        url = "https://github.com/HuxerUI/Lib-Archive/archive/refs/tags/v0.1.1.tar.gz",
        sha256 = "0bc89691c19a84b8879453eb50e4e5f05533539f04527e87b5b231e25358ca6a",
    },
}

-- huxerui.archive — HuxerUI archive and stream compression library as a native mcpp module package.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-Archive-0.1.1/mcpp.toml`)
-- and `build.mcpp` (`huxerui.rules`) and exports `import huxerui.archive;`
-- (`modules/archive.cppm`, hand-maintained with `cpp_modules_gen = false`),
-- depending on `huxerui.huxerui = "0.5.5"` and `compat.{libarchive 3.8.7,
-- zlib 1.3.2, zstd 1.5.7}`.
--
-- 0.1.1 uses plain upstream GitHub URLs across all platforms (no CN mcpp-res mirror yet).
package = {
    spec        = "1",
    namespace   = "huxerui",
    name        = "archive",
    description = "Archive and stream compression library (ZIP, TAR, TAR.GZ, TAR.ZST, gzip, Zstandard) for HuxerUI",
    licenses    = {"MIT"},
    repo        = "https://github.com/HuxerUI/Lib-Archive",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/HuxerUI/Lib-Archive/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.1.1"] = versions["0.1.1"],
        },
        macosx = {
            ["0.1.1"] = versions["0.1.1"],
        },
        windows = {
            ["0.1.1"] = versions["0.1.1"],
        },
    },
}
