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
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/0d55de134c5c16bc31b5fb1e91c5946236b8b829.tar.gz",
                sha256 = "7c91fbb6f260906ef4bb730cef7cfe1329842d9cd39dbbeeb29b1b9ac8adbff1",
            },
        },
        macosx = {
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/0d55de134c5c16bc31b5fb1e91c5946236b8b829.tar.gz",
                sha256 = "7c91fbb6f260906ef4bb730cef7cfe1329842d9cd39dbbeeb29b1b9ac8adbff1",
            },
        },
        windows = {
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/0d55de134c5c16bc31b5fb1e91c5946236b8b829.tar.gz",
                sha256 = "7c91fbb6f260906ef4bb730cef7cfe1329842d9cd39dbbeeb29b1b9ac8adbff1",
            },
        },
    },
}
