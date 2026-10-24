-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "imgui",
    description = "imgui-m upstream-preserving C++23 module wrapper",
    licenses = { "MIT" },
    repo = "https://github.com/mcpplibs/imgui-m",
    type = "package",
    xpm = {
        linux = {
            ["1.92.8"] = {
                url = "https://github.com/mcpplibs/imgui-m/archive/a0ff50b0ac81afd15072af4b016df5566380b6a6.tar.gz",
                sha256 = "515f5e586d113bb8e05da2565a0fbfe20f468737cba12b3ee321aab556112067",
            },
        },
        macosx = {
            ["1.92.8"] = {
                url = "https://github.com/mcpplibs/imgui-m/archive/a0ff50b0ac81afd15072af4b016df5566380b6a6.tar.gz",
                sha256 = "515f5e586d113bb8e05da2565a0fbfe20f468737cba12b3ee321aab556112067",
            },
        },
        windows = {
            ["1.92.8"] = {
                url = "https://github.com/mcpplibs/imgui-m/archive/a0ff50b0ac81afd15072af4b016df5566380b6a6.tar.gz",
                sha256 = "515f5e586d113bb8e05da2565a0fbfe20f468737cba12b3ee321aab556112067",
            },
        },
    },
}
