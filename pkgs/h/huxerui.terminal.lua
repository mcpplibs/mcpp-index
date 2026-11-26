local versions = {
    ["0.1.0"] = {
        url    = "https://github.com/HuxerUI/Lib-Terminal/archive/refs/tags/v0.1.0.tar.gz",
        sha256 = "f9723074d6908ed33a510a0a060f5b98c40e390ad5388488aa4f8c830349a1e7",
    },
}

-- huxerui.terminal — HuxerUI VT100/xterm terminal emulator, PTY shell, and declarative view component.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-Terminal-0.1.0/mcpp.toml`),
-- `build.mcpp` (`huxerui.rules`), and hand-maintained `modules/terminal.cppm`
-- (`export module huxerui.terminal;`) with vendored scrollback-patched `libvterm 0.3.3`,
-- depending on `huxerui.huxerui = "0.5.5"` and `compat.utf8proc = "2.10.0"`.
package = {
    spec        = "1",
    namespace   = "huxerui",
    name        = "terminal",
    description = "Cross-platform terminal emulator, PTY shell, and view component for HuxerUI",
    licenses    = {"MIT"},
    repo        = "https://github.com/HuxerUI/Lib-Terminal",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/HuxerUI/Lib-Terminal/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux   = { ["0.1.0"] = versions["0.1.0"] },
        macosx  = { ["0.1.0"] = versions["0.1.0"] },
        windows = { ["0.1.0"] = versions["0.1.0"] },
    },
}
