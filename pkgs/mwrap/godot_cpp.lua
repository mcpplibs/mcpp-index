-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "godot_cpp",
    description = "godot-cpp-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/godot-cpp-m",
    type = "package",
    xpm = {
        linux = {
            ["10.0.0-rc1.1"] = {
                url = "https://github.com/mcpplibs/godot-cpp-m/archive/87dd2d6208e818fdd3f951b512299cf4ea6b2169.tar.gz",
                sha256 = "23bc6517ddaf51945000f2a29e378b259941c98f8a0878edec7fe793f36ced0e",
            },
        },
        macosx = {
            ["10.0.0-rc1.1"] = {
                url = "https://github.com/mcpplibs/godot-cpp-m/archive/87dd2d6208e818fdd3f951b512299cf4ea6b2169.tar.gz",
                sha256 = "23bc6517ddaf51945000f2a29e378b259941c98f8a0878edec7fe793f36ced0e",
            },
        },
        windows = {
            ["10.0.0-rc1.1"] = {
                url = "https://github.com/mcpplibs/godot-cpp-m/archive/87dd2d6208e818fdd3f951b512299cf4ea6b2169.tar.gz",
                sha256 = "23bc6517ddaf51945000f2a29e378b259941c98f8a0878edec7fe793f36ced0e",
            },
        },
    },
}
