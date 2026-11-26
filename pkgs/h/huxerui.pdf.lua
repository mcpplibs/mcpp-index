local versions = {
    ["0.2.1"] = {
        url = "https://github.com/HuxerUI/Lib-PDF/archive/refs/tags/v0.2.1.tar.gz",
        sha256 = "075cf0a73e51ce722f9404255a3fdf9b95db64fae9ac1948cdf799f587ebcece",
    },
}

-- huxerui.pdf — HuxerUI PDF document and declarative view package as a native mcpp module package.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-PDF-0.2.1/mcpp.toml`) and
-- `build.mcpp` (`huxerui.rules`) and exports `import huxerui.pdf;`
-- (`modules/pdf.cppm`), depending on `huxerui.huxerui = "0.5.5"` and
-- `compat.pdfium = "8165"`.
--
-- 0.2.1 uses plain upstream GitHub URLs across all platforms (no CN mcpp-res
-- mirror yet).
package = {
    spec        = "1",
    namespace   = "huxerui",
    name        = "pdf",
    description = "PDF document and declarative view component for HuxerUI, powered by PDFium",
    licenses    = {"MIT"},
    repo        = "https://github.com/HuxerUI/Lib-PDF",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/HuxerUI/Lib-PDF/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.2.1"] = versions["0.2.1"],
        },
        macosx = {
            ["0.2.1"] = versions["0.2.1"],
        },
        windows = {
            ["0.2.1"] = versions["0.2.1"],
        },
    },
}
