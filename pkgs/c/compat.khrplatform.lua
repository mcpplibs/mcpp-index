package = {
    spec        = "1",
    namespace   = "compat",
    name        = "khrplatform",
    description = "Khronos KHR platform header for OpenGL/EGL compat packages",
    licenses    = {"Khronos"},
    repo        = "https://github.com/KhronosGroup/EGL-Registry",
    type        = "package",

    xpm = {
        linux = {
            ["2026.05.31"] = {
                url    = {
                    GLOBAL = "https://github.com/KhronosGroup/EGL-Registry/archive/3d7796b3721d93976b6bfe536aa97bbc4bce8667.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/khrplatform/releases/download/2026.05.31/khrplatform-2026.05.31.tar.gz",
                },
                sha256 = "f303c6a9248081e73c20a41fe9cc5b97c428bc0716286c5bb33551e65306015e",
            },
        },
        macosx = {
            ["2026.05.31"] = {
                url    = {
                    GLOBAL = "https://github.com/KhronosGroup/EGL-Registry/archive/3d7796b3721d93976b6bfe536aa97bbc4bce8667.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/khrplatform/releases/download/2026.05.31/khrplatform-2026.05.31.tar.gz",
                },
                sha256 = "f303c6a9248081e73c20a41fe9cc5b97c428bc0716286c5bb33551e65306015e",
            },
        },
        windows = {
            ["2026.05.31"] = {
                url    = {
                    GLOBAL = "https://github.com/KhronosGroup/EGL-Registry/archive/3d7796b3721d93976b6bfe536aa97bbc4bce8667.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/khrplatform/releases/download/2026.05.31/khrplatform-2026.05.31.tar.gz",
                },
                sha256 = "f303c6a9248081e73c20a41fe9cc5b97c428bc0716286c5bb33551e65306015e",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = {"*/api"},
        generated_files = {
            ["mcpp_generated/khrplatform_empty.c"] = "int mcpp_compat_khrplatform_headers_anchor(void) { return 0; }\n",
        },
        sources = {"mcpp_generated/khrplatform_empty.c"},
        targets = { ["khrplatform"] = { kind = "lib" } },
        deps    = {},
    },
}
