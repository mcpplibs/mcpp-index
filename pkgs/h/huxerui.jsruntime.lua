local versions = {
    ["0.1.1"] = {
        url = "https://github.com/HuxerUI/Lib-JSRuntime/archive/refs/tags/v0.1.1.tar.gz",
        sha256 = "eda639d834d2ce369887851da758ff1281b520f9db04077a06686123463c6f5f",
    },
}

-- huxerui.jsruntime — HuxerUI QuickJS and TSX JavaScript runtime bridge as a
-- native mcpp module package.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-JSRuntime-0.1.1/mcpp.toml`)
-- and `build.mcpp` (`huxerui.rules`) and exports `import huxerui.jsruntime;` and
-- `import huxerui.jsruntime.quickjs;` (`modules/jsruntime.cppm` and
-- `modules/quickjs.cppm`), depending on `huxerui.huxerui = "0.5.5"`.
-- QuickJS C11 engine sources and `js/runtime.js` are bundled/embedded upstream;
-- prebuilt esbuild binaries are decoupled and downloaded/SHA256-verified on
-- demand only by CMake builds that bundle `.tsx` inputs.
--
-- 0.1.1 uses plain upstream GitHub URLs across all platforms (no CN mcpp-res
-- mirror yet).
package = {
    spec        = "1",
    namespace   = "huxerui",
    name        = "jsruntime",
    description = "TSX and QuickJS JavaScript runtime bridge for HuxerUI",
    licenses    = {"MIT", "Unicode-3.0"},
    repo        = "https://github.com/HuxerUI/Lib-JSRuntime",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/HuxerUI/Lib-JSRuntime/archive/refs/tags/${tag}.tar.gz",
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
