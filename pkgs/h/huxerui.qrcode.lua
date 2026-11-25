local versions = {
    ["0.1.1"] = {
        url = "https://github.com/HuxerUI/Lib-QRCode/archive/refs/tags/v0.1.1.tar.gz",
        sha256 = "14fb81089e30cdd7e782cf7e971c52ace42c2da201632665010989fe6d057692",
    },
}

-- huxerui.qrcode — HuxerUI QR code and barcode package as a native mcpp module package.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-QRCode-0.1.1/mcpp.toml`)
-- and `build.mcpp` (vendored ZXing 3.1.1 sources + Version.h generation) and
-- exports `import huxerui.qrcode;` (`modules/qrcode.cppm`), depending on
-- `huxerui.huxerui = "0.5.5"` for transitive SDK and platform dependencies.
--
-- 0.1.1 includes `#include <cstdlib>` in `third_party/zxing/core/src/librscpp/poly.h`
-- for libc++ 23 (`std::abs`) compatibility. Plain upstream GitHub URLs are used
-- across all platforms (no CN mcpp-res mirror yet).
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
