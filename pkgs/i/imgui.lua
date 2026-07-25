-- Form A descriptor: the public imgui module package ships its own
-- mcpp.toml. mcpp's default lookup finds <verdir>/*/mcpp.toml inside
-- the GitHub source tarball wrap.
--
package = {
    spec        = "1",
    name        = "imgui",
    namespace   = "mcpplibs",
    description = "C++23 module package for Dear ImGui core and GLFW/OpenGL3 backends",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/imgui-m",
    type        = "package",

    xpm = {
        linux = {
            ["0.0.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.1/imgui-0.0.1.tar.gz",
                },
                sha256 = "168d1f9a2dfc3823d671385654823f7eba25f146d029ceeacfb19a84617af4a0",
            },
            ["0.0.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.2/imgui-0.0.2.tar.gz",
                },
                sha256 = "dd2199c76ea762fc2eb084967fa42953c8b876e076e41b57409f84b322e3161e",
            },
            ["0.0.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.3/imgui-0.0.3.tar.gz",
                },
                sha256 = "55bc5c557f5c803279f923e0335a788a6d6f57289b3c2e1a0dd0cc46414b3524",
            },
            ["0.0.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.4/imgui-0.0.4.tar.gz",
                },
                sha256 = "d10f7794225de45167e0ff88cb37532ae8a4f00d145fcdaa58fe19702467bc44",
            },
            ["0.0.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.5/imgui-0.0.5.tar.gz",
                },
                sha256 = "6b729104166b8dd0db5c6d5018ffcd24c0df6a9fc0e4381f1f8151c22724bed6",
            },
            ["0.0.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.6/imgui-0.0.6.tar.gz",
                },
                sha256 = "25780adb69fb5080b2dbd9a26ff007fc0751301544e0e6fb467d674091bbf071",
            },
        },
        macosx = {
            ["0.0.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.1/imgui-0.0.1.tar.gz",
                },
                sha256 = "168d1f9a2dfc3823d671385654823f7eba25f146d029ceeacfb19a84617af4a0",
            },
            ["0.0.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.2/imgui-0.0.2.tar.gz",
                },
                sha256 = "dd2199c76ea762fc2eb084967fa42953c8b876e076e41b57409f84b322e3161e",
            },
            ["0.0.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.3/imgui-0.0.3.tar.gz",
                },
                sha256 = "55bc5c557f5c803279f923e0335a788a6d6f57289b3c2e1a0dd0cc46414b3524",
            },
            ["0.0.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.4/imgui-0.0.4.tar.gz",
                },
                sha256 = "d10f7794225de45167e0ff88cb37532ae8a4f00d145fcdaa58fe19702467bc44",
            },
            ["0.0.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.5/imgui-0.0.5.tar.gz",
                },
                sha256 = "6b729104166b8dd0db5c6d5018ffcd24c0df6a9fc0e4381f1f8151c22724bed6",
            },
            ["0.0.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.6/imgui-0.0.6.tar.gz",
                },
                sha256 = "25780adb69fb5080b2dbd9a26ff007fc0751301544e0e6fb467d674091bbf071",
            },
        },
        windows = {
            ["0.0.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.1/imgui-0.0.1.tar.gz",
                },
                sha256 = "168d1f9a2dfc3823d671385654823f7eba25f146d029ceeacfb19a84617af4a0",
            },
            ["0.0.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.2/imgui-0.0.2.tar.gz",
                },
                sha256 = "dd2199c76ea762fc2eb084967fa42953c8b876e076e41b57409f84b322e3161e",
            },
            ["0.0.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.3/imgui-0.0.3.tar.gz",
                },
                sha256 = "55bc5c557f5c803279f923e0335a788a6d6f57289b3c2e1a0dd0cc46414b3524",
            },
            ["0.0.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.4/imgui-0.0.4.tar.gz",
                },
                sha256 = "d10f7794225de45167e0ff88cb37532ae8a4f00d145fcdaa58fe19702467bc44",
            },
            ["0.0.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.5/imgui-0.0.5.tar.gz",
                },
                sha256 = "6b729104166b8dd0db5c6d5018ffcd24c0df6a9fc0e4381f1f8151c22724bed6",
            },
            ["0.0.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/imgui-m/archive/refs/tags/0.0.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/0.0.6/imgui-0.0.6.tar.gz",
                },
                sha256 = "25780adb69fb5080b2dbd9a26ff007fc0751301544e0e6fb467d674091bbf071",
            },
        },
    },

    -- (no `mcpp` field -- default lookup will find <verdir>/*/mcpp.toml)
}
