local versions = {
    ["0.1.0"] = {
        url = "https://github.com/HuxerUI/Lib-QRCode/archive/refs/tags/v0.1.0.tar.gz",
        sha256 = "8cee876321cdcaa44362342d1990036faf2bd57cea069d9e725f3563907f2d40",
    },
}

-- huxerui.qrcode — HuxerUI QR code and barcode package as a native mcpp module package.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-QRCode-0.1.0/mcpp.toml`)
-- and `build.mcpp` (vendored ZXing 3.1.1 sources + Version.h generation) and
-- exports `import huxerui.qrcode;` (`modules/qrcode.cppm`), depending on
-- `huxerui.huxerui = "0.5.5"` for transitive SDK and platform dependencies.
--
-- 0.1.0 uses plain upstream GitHub URLs (no CN mcpp-res mirror yet).
package = {
    spec        = "1",
    namespace   = "huxerui",
    name        = "qrcode",
    description = "QR code and barcode generation, declarative HuxerUI views, and multi-format image decoding",
    licenses    = {"MIT"},
    repo        = "https://github.com/HuxerUI/Lib-QRCode",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/HuxerUI/Lib-QRCode/archive/refs/tags/${tag}.tar.gz",
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
