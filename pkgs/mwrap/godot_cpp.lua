-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "godot_cpp",
    description = "godot-cpp-m upstream-preserving C++23 module wrapper",
    licenses = { "MIT" },
    repo = "https://github.com/mcpplibs/godot-cpp-m",
    type = "package",
    xpm = {
        linux = {
            ["10.0.0-rc1"] = {
                url = "https://github.com/mcpplibs/godot-cpp-m/archive/4f6f0628b4df94f940ef7e0bdcde3f5df104b03a.tar.gz",
                sha256 = "0ae5293a74eba9455652d5db1f0b8f3a0029ff0882b83fa01148af163903b25b",
            },
        },
        macosx = {
            ["10.0.0-rc1"] = {
                url = "https://github.com/mcpplibs/godot-cpp-m/archive/4f6f0628b4df94f940ef7e0bdcde3f5df104b03a.tar.gz",
                sha256 = "0ae5293a74eba9455652d5db1f0b8f3a0029ff0882b83fa01148af163903b25b",
            },
        },
        windows = {
            ["10.0.0-rc1"] = {
                url = "https://github.com/mcpplibs/godot-cpp-m/archive/4f6f0628b4df94f940ef7e0bdcde3f5df104b03a.tar.gz",
                sha256 = "0ae5293a74eba9455652d5db1f0b8f3a0029ff0882b83fa01148af163903b25b",
            },
        },
    },
}
