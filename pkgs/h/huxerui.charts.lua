local versions = {
    ["0.1.1"] = {
        url = "https://github.com/HuxerUI/Lib-Charts/archive/refs/tags/v0.1.1.tar.gz",
        sha256 = "4abc8232a9e029f8028722503db5d40de6f421afd6f0432bdd673aad133c2109",
    },
}

-- huxerui.charts — HuxerUI declarative charts library as a native mcpp module package.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-Charts-0.1.1/mcpp.toml`)
-- and `build.mcpp` (`huxerui.rules`) and exports `import huxerui.charts;`
-- (`modules/charts.cppm`), depending on `huxerui.huxerui = "0.5.5"` which
-- provides the transitive SDK and platform dependencies.
--
-- Upstream already had tag `v0.1.0`; native mcpp/C++23 module support shipped
-- in `v0.1.1`. Plain upstream GitHub URLs are used across all platforms
-- (no CN mcpp-res mirror yet).
package = {
    spec        = "1",
    namespace   = "huxerui",
    name        = "charts",
    description = "Declarative charts library (line, area, bar, scatter, and pie charts) for HuxerUI",
    licenses    = {"MIT"},
    repo        = "https://github.com/HuxerUI/Lib-Charts",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/HuxerUI/Lib-Charts/archive/refs/tags/${tag}.tar.gz",
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
