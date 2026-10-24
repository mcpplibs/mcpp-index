-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "llamacpp",
    description = "llama.cpp-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/llama.cpp-m",
    type = "package",
    xpm = {
        linux = {
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/70f3735b450b16a079c4eb0123184cfe5fd88185.tar.gz",
                sha256 = "1aa091ee6b84029d2b28a76737a0771182441d9afc665295b6780d1ae99dc499",
            },
        },
        macosx = {
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/70f3735b450b16a079c4eb0123184cfe5fd88185.tar.gz",
                sha256 = "1aa091ee6b84029d2b28a76737a0771182441d9afc665295b6780d1ae99dc499",
            },
        },
        windows = {
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/70f3735b450b16a079c4eb0123184cfe5fd88185.tar.gz",
                sha256 = "1aa091ee6b84029d2b28a76737a0771182441d9afc665295b6780d1ae99dc499",
            },
        },
    },
}
