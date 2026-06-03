package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.xinerama",
    description = "Xinerama extension runtime library and public headers",
    licenses    = {"MIT-Open-Group"},
    repo        = "https://gitlab.freedesktop.org/xorg/lib/libxinerama",
    type        = "package",

    xpm = {
        linux = {
            ["1.1.6"] = {
                url    = "https://xorg.freedesktop.org/releases/individual/lib/libXinerama-1.1.6.tar.gz",
                sha256 = "c74ee3d05e473671bf86285e2dece345485200bb042bea1540b1e30ff3f74bae",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        cflags       = {"-D_GNU_SOURCE", "-D_DEFAULT_SOURCE"},
        include_dirs = {"*/include", "*/include/X11/extensions", "*/src"},
        sources      = {"*/src/*.c"},
        targets      = { ["Xinerama"] = { kind = "shared", soname = "libXinerama.so.1" } },
        deps = {
            ["compat.x11"]        = "1.8.13",
            ["compat.xext"]       = "1.3.7",
            ["compat.xorgproto"] = "2025.1",
        },
    },
}
