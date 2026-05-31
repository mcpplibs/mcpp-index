package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.imgui",
    description = "Dear ImGui immediate-mode GUI library core sources",
    licenses    = {"MIT"},
    repo        = "https://github.com/ocornut/imgui",
    type        = "package",

    xpm = {
        linux = {
            ["v1.92.8"] = {
                url    = "https://github.com/ocornut/imgui/archive/refs/tags/v1.92.8.tar.gz",
                sha256 = "fecb33d33930e12ff53a34064e9d3a06c8f7c3e04408f14cd36c80e3faac863b",
            },
        },
        macosx = {
            ["v1.92.8"] = {
                url    = "https://github.com/ocornut/imgui/archive/refs/tags/v1.92.8.tar.gz",
                sha256 = "fecb33d33930e12ff53a34064e9d3a06c8f7c3e04408f14cd36c80e3faac863b",
            },
        },
        windows = {
            ["v1.92.8"] = {
                url    = "https://github.com/ocornut/imgui/archive/refs/tags/v1.92.8.tar.gz",
                sha256 = "fecb33d33930e12ff53a34064e9d3a06c8f7c3e04408f14cd36c80e3faac863b",
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
