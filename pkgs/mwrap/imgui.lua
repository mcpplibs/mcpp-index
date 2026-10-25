-- Immutable upstream-aligned mwrap source release; GLOBAL and CN bytes are identical.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "imgui",
    description = "imgui-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/imgui-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/imgui-m/releases/download/${tag}/imgui-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.92.8"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/releases/download/mwrap-1.92.8/imgui-m-1.92.8.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-imgui/releases/download/1.92.8/imgui-m-1.92.8.tar.gz",
                },
                sha256 = "dee8081f791484f5d16cac222f022c0bb62a541d6a62e8ce0a526e3a343adbcd",
            },
        },
        macosx = {
            ["1.92.8"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/releases/download/mwrap-1.92.8/imgui-m-1.92.8.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-imgui/releases/download/1.92.8/imgui-m-1.92.8.tar.gz",
                },
                sha256 = "dee8081f791484f5d16cac222f022c0bb62a541d6a62e8ce0a526e3a343adbcd",
            },
        },
        windows = {
            ["1.92.8"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/releases/download/mwrap-1.92.8/imgui-m-1.92.8.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-imgui/releases/download/1.92.8/imgui-m-1.92.8.tar.gz",
                },
                sha256 = "dee8081f791484f5d16cac222f022c0bb62a541d6a62e8ce0a526e3a343adbcd",
            },
        },
    },
}
