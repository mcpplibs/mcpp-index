-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "imgui",
    description = "imgui-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/imgui-m",
    type = "package",
    xpm = {
        linux = {
            ["1.92.8"] = {
                url = "https://github.com/mcpplibs/imgui-m/archive/c753c95404f4e7c4b2bd80e5a8a349771bae0c01.tar.gz",
                sha256 = "ed8755746e86601162834bae93148e2536089f11fa238ae6dde4250ba8a73db2",
            },
        },
        macosx = {
            ["1.92.8"] = {
                url = "https://github.com/mcpplibs/imgui-m/archive/c753c95404f4e7c4b2bd80e5a8a349771bae0c01.tar.gz",
                sha256 = "ed8755746e86601162834bae93148e2536089f11fa238ae6dde4250ba8a73db2",
            },
        },
        windows = {
            ["1.92.8"] = {
                url = "https://github.com/mcpplibs/imgui-m/archive/c753c95404f4e7c4b2bd80e5a8a349771bae0c01.tar.gz",
                sha256 = "ed8755746e86601162834bae93148e2536089f11fa238ae6dde4250ba8a73db2",
            },
        },
    },
}
