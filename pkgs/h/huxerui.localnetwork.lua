local versions = {
    ["0.1.1"] = {
        url = "https://github.com/HuxerUI/Lib-LocalNetwork/archive/refs/tags/v0.1.1.tar.gz",
        sha256 = "1258ed16fdc8a2807a7bb8027e918e9df034387c15fd76fcc27d5fdc88d3a213",
    },
}

-- huxerui.localnetwork — HuxerUI local network discovery, pairing, transport, and Wi-Fi package.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-LocalNetwork-0.1.1/mcpp.toml`)
-- and `build.mcpp` (`huxerui.rules`) and exports `import huxerui.localnetwork;`
-- (`modules/localnetwork.cppm`), depending on `huxerui.huxerui = "0.5.5"` and
-- `compat.mbedtls = "3.6.8"`.
--
-- 0.1.1 uses plain upstream GitHub URLs across all platforms (no CN mcpp-res mirror yet).
package = {
    spec        = "1",
    namespace   = "huxerui",
    name        = "localnetwork",
    description = "Local network discovery, pairing, TCP/TLS transport, and Wi-Fi operations for HuxerUI",
    licenses    = {"MIT"},
    repo        = "https://github.com/HuxerUI/Lib-LocalNetwork",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/HuxerUI/Lib-LocalNetwork/archive/refs/tags/${tag}.tar.gz",
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
