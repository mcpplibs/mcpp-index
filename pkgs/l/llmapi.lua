-- Form A descriptor: the upstream repo ships its own mcpp.toml from
-- v0.2.4 onwards. mcpp's default-look-up walks the GitHub tarball
-- wrap (`llmapi-<tag>/mcpp.toml`) automatically.
package = {
    spec        = "1",
    namespace = "mcpplibs",
    name        = "llmapi",
    description = "Modern C++ LLM API client with openai-compatible support",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/llmapi",
    type        = "package",

    xpm = {
        linux = {
            ["0.2.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/llmapi/archive/refs/tags/0.2.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llmapi/releases/download/0.2.4/llmapi-0.2.4.tar.gz",
                },
                sha256 = "b1d204576ee2d2069abdac1a7e25078e605c8fae5b1cdad6cee200946cfed0f0",
            },
            ["0.2.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/llmapi/archive/refs/tags/0.2.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llmapi/releases/download/0.2.5/llmapi-0.2.5.tar.gz",
                },
                sha256 = "fffa1341beed98ace97e029c0e46f47f55470df6e6a7114374e73e2bfd13699f",
            },
            ["0.2.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/llmapi/archive/refs/tags/0.2.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llmapi/releases/download/0.2.6/llmapi-0.2.6.tar.gz",
                },
                sha256 = "d4aedb04d695c6bbf5685fad79185642aec4a48e8b4211275b752294c3eb43cc",
            },
            ["0.2.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/llmapi/archive/refs/tags/0.2.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llmapi/releases/download/0.2.8/llmapi-0.2.8.tar.gz",
                },
                sha256 = "0f8ccc93d15a4d4eba9d1f2655c15fc394bf13ba2ee918b8de051127f2f1065d",
            },
        },
        macosx = {
            ["0.2.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/llmapi/archive/refs/tags/0.2.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llmapi/releases/download/0.2.4/llmapi-0.2.4.tar.gz",
                },
                sha256 = "b1d204576ee2d2069abdac1a7e25078e605c8fae5b1cdad6cee200946cfed0f0",
            },
            ["0.2.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/llmapi/archive/refs/tags/0.2.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llmapi/releases/download/0.2.5/llmapi-0.2.5.tar.gz",
                },
                sha256 = "fffa1341beed98ace97e029c0e46f47f55470df6e6a7114374e73e2bfd13699f",
            },
            ["0.2.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/llmapi/archive/refs/tags/0.2.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llmapi/releases/download/0.2.6/llmapi-0.2.6.tar.gz",
                },
                sha256 = "d4aedb04d695c6bbf5685fad79185642aec4a48e8b4211275b752294c3eb43cc",
            },
            ["0.2.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/llmapi/archive/refs/tags/0.2.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llmapi/releases/download/0.2.8/llmapi-0.2.8.tar.gz",
                },
                sha256 = "0f8ccc93d15a4d4eba9d1f2655c15fc394bf13ba2ee918b8de051127f2f1065d",
            },
        },
        windows = {
            ["0.2.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/llmapi/archive/refs/tags/0.2.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llmapi/releases/download/0.2.4/llmapi-0.2.4.tar.gz",
                },
                sha256 = "b1d204576ee2d2069abdac1a7e25078e605c8fae5b1cdad6cee200946cfed0f0",
            },
            ["0.2.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/llmapi/archive/refs/tags/0.2.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llmapi/releases/download/0.2.5/llmapi-0.2.5.tar.gz",
                },
                sha256 = "fffa1341beed98ace97e029c0e46f47f55470df6e6a7114374e73e2bfd13699f",
            },
            ["0.2.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/llmapi/archive/refs/tags/0.2.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llmapi/releases/download/0.2.6/llmapi-0.2.6.tar.gz",
                },
                sha256 = "d4aedb04d695c6bbf5685fad79185642aec4a48e8b4211275b752294c3eb43cc",
            },
            ["0.2.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/llmapi/archive/refs/tags/0.2.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llmapi/releases/download/0.2.8/llmapi-0.2.8.tar.gz",
                },
                sha256 = "0f8ccc93d15a4d4eba9d1f2655c15fc394bf13ba2ee918b8de051127f2f1065d",
            },
        },
    },
}
