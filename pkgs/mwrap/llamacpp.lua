-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "llamacpp",
    description = "llama.cpp-m upstream-preserving C++23 module wrapper",
    licenses = { "MIT" },
    repo = "https://github.com/mcpplibs/llama.cpp-m",
    type = "package",
    xpm = {
        linux = {
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/40815555a0189959802069529d9994317555c765.tar.gz",
                sha256 = "32db3e899ba09cb20db839b39038c73f82393b7bc2ea5383bf4dd19c5c50a6ef",
            },
        },
        macosx = {
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/40815555a0189959802069529d9994317555c765.tar.gz",
                sha256 = "32db3e899ba09cb20db839b39038c73f82393b7bc2ea5383bf4dd19c5c50a6ef",
            },
        },
        windows = {
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/40815555a0189959802069529d9994317555c765.tar.gz",
                sha256 = "32db3e899ba09cb20db839b39038c73f82393b7bc2ea5383bf4dd19c5c50a6ef",
            },
        },
    },
}
