local versions = {
    ["0.1.0"] = {
        url    = "https://github.com/HuxerUI/Lib-Map/archive/refs/tags/v0.1.0.tar.gz",
        sha256 = "1be555500de48775cc768718e3fe1d0a65c0a74ae740cc0fbe9705111527aa9c",
    },
}

-- huxerui.map — Cross-platform declarative map view, types, and overlay validation for HuxerUI.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-Map-0.1.0/mcpp.toml`),
-- `build.mcpp` (`huxerui.rules`), and `modules/map.cppm` (`export module huxerui.map;`),
-- depending on `huxerui.huxerui = "0.5.5"`.
package = {
    spec        = "1",
    namespace   = "huxerui",
    name        = "map",
    description = "Cross-platform declarative map view, types, and overlay validation for HuxerUI",
    licenses    = {"MIT"},
    repo        = "https://github.com/HuxerUI/Lib-Map",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/HuxerUI/Lib-Map/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux   = { ["0.1.0"] = versions["0.1.0"] },
        macosx  = { ["0.1.0"] = versions["0.1.0"] },
        windows = { ["0.1.0"] = versions["0.1.0"] },
    },
}
