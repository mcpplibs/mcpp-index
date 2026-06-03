package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.xi",
    description = "X Input extension runtime library and public headers",
    licenses    = {"MIT-Open-Group"},
    repo        = "https://gitlab.freedesktop.org/xorg/lib/libxi",
    type        = "package",

    xpm = {
        linux = {
            ["1.8.3"] = {
                url    = "https://xorg.freedesktop.org/releases/individual/lib/libXi-1.8.3.tar.gz",
                sha256 = "6648c44127e4585f4e7842c0802d265008fa6f9741df0ea6ee7934a5267adf63",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        cflags       = {"-D_GNU_SOURCE", "-D_DEFAULT_SOURCE"},
        include_dirs = {"*/include", "*/include/X11/extensions", "*/src"},
        sources = {
            "*/src/*.c",
            "!*/src/XFreeLst.c",
        },
        targets      = { ["Xi"] = { kind = "shared", soname = "libXi.so.6" } },
        deps = {
            ["compat.x11"]       = "1.8.13",
            ["compat.xext"]      = "1.3.7",
            ["compat.xfixes"]    = "6.0.2",
            ["compat.xorgproto"] = "2025.1",
        },
    },
}
