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
                url = "https://github.com/mcpplibs/imgui-m/archive/61b491e16779202d8569ff2ea01c05d1c7e7975f.tar.gz",
                sha256 = "fe0c83397e1787a2a2ff7b41547c9f487325329a67f62e20529ff9482a56b6ff",
            },
        },
        macosx = {
            ["1.92.8"] = {
                url = "https://github.com/mcpplibs/imgui-m/archive/61b491e16779202d8569ff2ea01c05d1c7e7975f.tar.gz",
                sha256 = "fe0c83397e1787a2a2ff7b41547c9f487325329a67f62e20529ff9482a56b6ff",
            },
        },
        windows = {
            ["1.92.8"] = {
                url = "https://github.com/mcpplibs/imgui-m/archive/61b491e16779202d8569ff2ea01c05d1c7e7975f.tar.gz",
                sha256 = "fe0c83397e1787a2a2ff7b41547c9f487325329a67f62e20529ff9482a56b6ff",
            },
        },
    },
}
