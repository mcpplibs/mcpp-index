package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.opengl",
    description = "Khronos OpenGL API headers for mcpp packages",
    licenses    = {"MIT"},
    repo        = "https://github.com/KhronosGroup/OpenGL-Registry",
    type        = "package",

    xpm = {
        linux = {
            ["2026.05.31"] = {
                url    = "https://github.com/KhronosGroup/OpenGL-Registry/archive/a30033d3e812c9bf10094f1010374a6b15e192eb.tar.gz",
                sha256 = "3dadc4ccfe4b8d3a798fb405b7067304420ff997505b67041f3edfeecc3228ae",
            },
        },
        macosx = {
            ["2026.05.31"] = {
                url    = "https://github.com/KhronosGroup/OpenGL-Registry/archive/a30033d3e812c9bf10094f1010374a6b15e192eb.tar.gz",
                sha256 = "3dadc4ccfe4b8d3a798fb405b7067304420ff997505b67041f3edfeecc3228ae",
            },
        },
        windows = {
            ["2026.05.31"] = {
                url    = "https://github.com/KhronosGroup/OpenGL-Registry/archive/a30033d3e812c9bf10094f1010374a6b15e192eb.tar.gz",
                sha256 = "3dadc4ccfe4b8d3a798fb405b7067304420ff997505b67041f3edfeecc3228ae",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = {"*/api", "mcpp_generated/include"},
        generated_files = {
            ["mcpp_generated/include/GL/gl.h"] = "#pragma once\n#include <GL/glcorearb.h>\n",
            ["mcpp_generated/opengl_empty.c"] = "int mcpp_compat_opengl_headers_anchor(void) { return 0; }\n",
        },
        sources = {"mcpp_generated/opengl_empty.c"},
        targets = { ["opengl"] = { kind = "lib" } },
        deps    = {},
    },
}
