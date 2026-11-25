local versions = {
    ["0.3.1"] = {
        url = "https://github.com/HuxerUI/Lib-Markdown/archive/refs/tags/v0.3.1.tar.gz",
        sha256 = "0e8be37f40b0377bec57e5354dc3dd1114544db92724eadbb027adf53e1a6f2a",
    },
}

-- huxerui.markdown — HuxerUI Markdown parser and declarative view component as a native mcpp module package.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-Markdown-0.3.1/mcpp.toml`)
-- with vendored `md4c` (C99) and exports `import huxerui.markdown;`
-- (`modules/markdown.cppm` and `modules/macros.cppm`), depending on
-- `huxerui.huxerui = "0.5.5"` for transitive SDK and platform dependencies.
--
-- 0.3.1 uses plain upstream GitHub URLs (no CN mcpp-res mirror yet).
package = {
    spec        = "1",
    namespace   = "huxerui",
    name        = "markdown",
    description = "Native CommonMark and GFM Markdown parser and declarative view component for HuxerUI",
    licenses    = {"MIT"},
    repo        = "https://github.com/HuxerUI/Lib-Markdown",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/HuxerUI/Lib-Markdown/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.3.1"] = versions["0.3.1"],
        },
        macosx = {
            ["0.3.1"] = versions["0.3.1"],
        },
        windows = {
            ["0.3.1"] = versions["0.3.1"],
        },
    },
}
