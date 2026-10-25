-- Immutable upstream-aligned mwrap source release; GLOBAL and CN bytes are identical.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "godot_cpp",
    description = "godot-cpp-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/godot-cpp-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/godot-cpp-m/releases/download/${tag}/godot-cpp-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["10.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/godot-cpp-m/releases/download/mwrap-10.0.0/godot-cpp-m-10.0.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-godot-cpp/releases/download/10.0.0/godot-cpp-m-10.0.0.tar.gz",
                },
                sha256 = "b5f6d13d018f2359913c6e6fba92e24810b1a1585f027547f4b20c5fd27eeec5",
            },
        },
        macosx = {
            ["10.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/godot-cpp-m/releases/download/mwrap-10.0.0/godot-cpp-m-10.0.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-godot-cpp/releases/download/10.0.0/godot-cpp-m-10.0.0.tar.gz",
                },
                sha256 = "b5f6d13d018f2359913c6e6fba92e24810b1a1585f027547f4b20c5fd27eeec5",
            },
        },
        windows = {
            ["10.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/godot-cpp-m/releases/download/mwrap-10.0.0/godot-cpp-m-10.0.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-godot-cpp/releases/download/10.0.0/godot-cpp-m-10.0.0.tar.gz",
                },
                sha256 = "b5f6d13d018f2359913c6e6fba92e24810b1a1585f027547f4b20c5fd27eeec5",
            },
        },
    },
}
