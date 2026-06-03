package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.xrender",
    description = "X Rendering extension runtime library and public headers",
    licenses    = {"HPND-sell-variant"},
    repo        = "https://gitlab.freedesktop.org/xorg/lib/libxrender",
    type        = "package",

    xpm = {
        linux = {
            ["0.9.12"] = {
                url    = "https://xorg.freedesktop.org/releases/individual/lib/libXrender-0.9.12.tar.gz",
                sha256 = "0fff64125819c02d1102b6236f3d7d861a07b5216d8eea336c3811d31494ecf7",
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
        targets      = { ["Xrender"] = { kind = "shared", soname = "libXrender.so.1" } },
        deps = {
            ["compat.x11"]        = "1.8.13",
            ["compat.xorgproto"] = "2025.1",
        },
    },
}
