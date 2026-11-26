local versions = {
    ["0.1.0"] = {
        url    = "https://github.com/HuxerUI/Lib-Git/archive/refs/tags/v0.1.0.tar.gz",
        sha256 = "4e49e70b5e3f88b87a3e3fe7505e79e340a8e968ad8ad827c549416a25889608",
    },
}

-- huxerui.git — HuxerUI asynchronous Git repository inspection and operations package.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-Git-0.1.0/mcpp.toml`),
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
        linux   = { ["0.1.0"] = versions["0.1.0"] },
        macosx  = { ["0.1.0"] = versions["0.1.0"] },
        windows = { ["0.1.0"] = versions["0.1.0"] },
    },
}
