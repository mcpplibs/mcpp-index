local versions = {
    ["0.2.0"] = {
        url = "https://github.com/HuxerUI/Lib-Interaction/archive/refs/tags/v0.2.0.tar.gz",
        sha256 = "9ffff3fa6e8bee09a97a766f84af5b4c7dd61f1db6d321d2256ddcc2b32d968d",
    },
}

-- huxerui.interaction — HuxerUI interactive primitives as a native mcpp module package.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-Interaction-0.2.0/mcpp.toml`)
-- and exports `import huxerui.interaction;` (`modules/interaction.cppm` and
-- `modules/operators.cppm`), depending on `huxerui.huxerui = "0.5.5"` which
-- provides the transitive SDK and platform dependencies.
--
-- 0.2.0 uses plain upstream GitHub URLs (no CN mcpp-res mirror yet).
package = {
    spec        = "1",
    namespace   = "huxerui",
    name        = "interaction",
    description = "Interactive primitives, controllers, feedback modifiers, and visual motion effects for HuxerUI",
    licenses    = {"MIT"},
    repo        = "https://github.com/HuxerUI/Lib-Interaction",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/HuxerUI/Lib-Interaction/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.2.0"] = versions["0.2.0"],
        },
        macosx = {
            ["0.2.0"] = versions["0.2.0"],
        },
        windows = {
            ["0.2.0"] = versions["0.2.0"],
        },
    },
}
