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
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/3a8ea85219463e1c02c6d1484d75e1edf27d574c.tar.gz",
                sha256 = "1f1acaff030ffd1dc25b276dc5af0d38499ee4eea0107df5ae3600188eb4bf52",
            },
        },
        macosx = {
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/3a8ea85219463e1c02c6d1484d75e1edf27d574c.tar.gz",
                sha256 = "1f1acaff030ffd1dc25b276dc5af0d38499ee4eea0107df5ae3600188eb4bf52",
            },
        },
        windows = {
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/3a8ea85219463e1c02c6d1484d75e1edf27d574c.tar.gz",
                sha256 = "1f1acaff030ffd1dc25b276dc5af0d38499ee4eea0107df5ae3600188eb4bf52",
            },
        },
    },
}
