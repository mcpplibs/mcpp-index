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
                url = "https://github.com/mcpplibs/godot-cpp-m/archive/daf32149f3ca87a6f8e8f1568913491fac7b353a.tar.gz",
                sha256 = "824eff5f63f059525f0d55a750a54c2b544026677f2dffd418c9989e711850a9",
            },
        },
        macosx = {
            ["10.0.0-rc1"] = {
                url = "https://github.com/mcpplibs/godot-cpp-m/archive/daf32149f3ca87a6f8e8f1568913491fac7b353a.tar.gz",
                sha256 = "824eff5f63f059525f0d55a750a54c2b544026677f2dffd418c9989e711850a9",
            },
        },
        windows = {
            ["10.0.0-rc1"] = {
                url = "https://github.com/mcpplibs/godot-cpp-m/archive/daf32149f3ca87a6f8e8f1568913491fac7b353a.tar.gz",
                sha256 = "824eff5f63f059525f0d55a750a54c2b544026677f2dffd418c9989e711850a9",
            },
        },
    },
}
