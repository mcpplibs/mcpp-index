local versions = {
    ["0.1.1"] = {
        url    = "https://github.com/HuxerUI/Lib-Git/archive/refs/tags/v0.1.1.tar.gz",
        sha256 = "43eb826f58d61f6b6788b50615ef3278a4155e1fa4be7917cab55721d2c23778",
    },
}

-- huxerui.git — HuxerUI asynchronous Git repository inspection and operations package.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-Git-0.1.1/mcpp.toml`),
-- `build.mcpp` (`huxerui.rules`), and `modules/git.cppm` (`export module huxerui.git;`),
-- depending on `huxerui.huxerui = "0.5.5"` and `compat.libgit2 = "1.9.7"`.
package = {
    spec        = "1",
    namespace   = "huxerui",
    name        = "git",
    description = "Repository inspection and Git operations for HuxerUI",
    licenses    = {"MIT"},
    repo        = "https://github.com/HuxerUI/Lib-Git",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/HuxerUI/Lib-Git/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux   = { ["0.1.1"] = versions["0.1.1"] },
        macosx  = { ["0.1.1"] = versions["0.1.1"] },
        windows = { ["0.1.1"] = versions["0.1.1"] },
    },
}
