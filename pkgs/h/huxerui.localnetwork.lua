local versions = {
    ["0.1.0"] = {
        url = "https://github.com/HuxerUI/Lib-LocalNetwork/archive/refs/tags/v0.1.0.tar.gz",
        sha256 = "c8b271e1c48a19dbee914fe43f03ec88ba6a6a9cc2acdd4a2dd7f339268223ad",
    },
}

-- huxerui.localnetwork — HuxerUI local network discovery, pairing, transport, and Wi-Fi package.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-LocalNetwork-0.1.0/mcpp.toml`)
-- and `build.mcpp` (`huxerui.rules`) and exports `import huxerui.localnetwork;`
-- (`modules/localnetwork.cppm`), depending on `huxerui.huxerui = "0.5.5"` and
-- `compat.mbedtls = "3.6.8"`.
--
-- 0.1.0 uses plain upstream GitHub URLs across all platforms (no CN mcpp-res mirror yet).
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
