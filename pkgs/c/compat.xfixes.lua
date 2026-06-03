package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.xfixes",
    description = "X Fixes extension runtime library and public headers",
    licenses    = {"HPND-sell-variant"},
    repo        = "https://gitlab.freedesktop.org/xorg/lib/libxfixes",
    type        = "package",

    xpm = {
        linux = {
            ["6.0.2"] = {
                url    = "https://xorg.freedesktop.org/releases/individual/lib/libXfixes-6.0.2.tar.gz",
                sha256 = "041331b8e6e36038b3bf836785b6b175ec8515f964c9e4e3316b3bfed0f53ac7",
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
        targets      = { ["Xfixes"] = { kind = "shared", soname = "libXfixes.so.3" } },
        deps = {
            ["compat.x11"]       = "1.8.13",
            ["compat.xext"]      = "1.3.7",
            ["compat.xorgproto"] = "2025.1",
        },
    },
}
