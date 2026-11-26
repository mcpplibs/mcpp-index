local versions = {
    ["0.1.0"] = {
        url = "https://github.com/HuxerUI/Lib-DataTable/archive/refs/tags/v0.1.0.tar.gz",
        sha256 = "592214822fd848af181cc076c07cae16634f8e5483fa3bdafef5443cab311351",
    },
}

-- huxerui.datatable — HuxerUI virtualized data table component as a native mcpp module package.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-DataTable-0.1.0/mcpp.toml`)
-- and `build.mcpp` (`huxerui.rules`) and exports `import huxerui.datatable;`
-- (`modules/datatable.cppm`), depending on `huxerui.huxerui = "0.5.5"` which
-- provides the transitive SDK and platform dependencies.
--
-- 0.1.0 uses plain upstream GitHub URLs (no CN mcpp-res mirror yet).
package = {
    spec        = "1",
    namespace   = "huxerui",
    name        = "datatable",
    description = "Virtualized data table component with sorting, selection, and inline editing for HuxerUI",
    licenses    = {"MIT"},
    repo        = "https://github.com/HuxerUI/Lib-DataTable",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/HuxerUI/Lib-DataTable/archive/refs/tags/${tag}.tar.gz",
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
