package = {
    spec        = "1",
    namespace   = "compat",
    name        = "imgui",
    description = "Dear ImGui immediate-mode GUI library core sources",
    licenses    = {"MIT"},
    repo        = "https://github.com/ocornut/imgui",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.8"] = {
                url    = {
                    GLOBAL = "https://github.com/ocornut/imgui/archive/refs/tags/v1.92.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/1.92.8/imgui-1.92.8.tar.gz",
                },
                sha256 = "fecb33d33930e12ff53a34064e9d3a06c8f7c3e04408f14cd36c80e3faac863b",
            },
            ["1.92.8-docking"] = {
                url    = {
                    GLOBAL = "https://github.com/ocornut/imgui/archive/refs/tags/v1.92.8-docking.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/1.92.8-docking/imgui-1.92.8-docking.tar.gz",
                },
                sha256 = "ca0653454ed371b7a87e9b0bc29a5d15c9be7f7c0fbe778042fc48c71df1d3d8",
            },
        },
        macosx = {
            ["1.92.8"] = {
                url    = {
                    GLOBAL = "https://github.com/ocornut/imgui/archive/refs/tags/v1.92.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/1.92.8/imgui-1.92.8.tar.gz",
                },
                sha256 = "fecb33d33930e12ff53a34064e9d3a06c8f7c3e04408f14cd36c80e3faac863b",
            },
            ["1.92.8-docking"] = {
                url    = {
                    GLOBAL = "https://github.com/ocornut/imgui/archive/refs/tags/v1.92.8-docking.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/1.92.8-docking/imgui-1.92.8-docking.tar.gz",
                },
                sha256 = "ca0653454ed371b7a87e9b0bc29a5d15c9be7f7c0fbe778042fc48c71df1d3d8",
            },
        },
        windows = {
            ["1.92.8"] = {
                url    = {
                    GLOBAL = "https://github.com/ocornut/imgui/archive/refs/tags/v1.92.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/1.92.8/imgui-1.92.8.tar.gz",
                },
                sha256 = "fecb33d33930e12ff53a34064e9d3a06c8f7c3e04408f14cd36c80e3faac863b",
            },
            ["1.92.8-docking"] = {
                url    = {
                    GLOBAL = "https://github.com/ocornut/imgui/archive/refs/tags/v1.92.8-docking.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/imgui/releases/download/1.92.8-docking/imgui-1.92.8-docking.tar.gz",
                },
                sha256 = "ca0653454ed371b7a87e9b0bc29a5d15c9be7f7c0fbe778042fc48c71df1d3d8",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        include_dirs = {"*", "*/backends"},
        sources = {
            "*/imgui.cpp",
            "*/imgui_draw.cpp",
            "*/imgui_tables.cpp",
            "*/imgui_widgets.cpp",
        },
        targets = { ["imgui"] = { kind = "lib" } },
        deps    = {},
    },
}
