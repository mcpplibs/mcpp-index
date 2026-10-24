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
                url = "https://github.com/mcpplibs/imgui-m/archive/eeaa5164ecd801f316c8097ae8e43b03ae457550.tar.gz",
                sha256 = "ccc22557b3d9e9ecae56a17d1ec3d7ef362ae7fcb429a2ec3a91f16f75e7d1a4",
            },
        },
        macosx = {
            ["1.92.8"] = {
                url = "https://github.com/mcpplibs/imgui-m/archive/eeaa5164ecd801f316c8097ae8e43b03ae457550.tar.gz",
                sha256 = "ccc22557b3d9e9ecae56a17d1ec3d7ef362ae7fcb429a2ec3a91f16f75e7d1a4",
            },
        },
        windows = {
            ["1.92.8"] = {
                url = "https://github.com/mcpplibs/imgui-m/archive/eeaa5164ecd801f316c8097ae8e43b03ae457550.tar.gz",
                sha256 = "ccc22557b3d9e9ecae56a17d1ec3d7ef362ae7fcb429a2ec3a91f16f75e7d1a4",
            },
        },
    },
}
