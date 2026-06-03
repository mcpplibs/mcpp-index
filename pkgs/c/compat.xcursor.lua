package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.xcursor",
    description = "X cursor management runtime library and public headers",
    licenses    = {"HPND-sell-variant"},
    repo        = "https://gitlab.freedesktop.org/xorg/lib/libxcursor",
    type        = "package",

    xpm = {
        linux = {
            ["1.2.3"] = {
                url    = "https://xorg.freedesktop.org/releases/individual/lib/libXcursor-1.2.3.tar.gz",
                sha256 = "74e72da27e61cc2cfd2e267c14f500ea47775850048ee0b00362a55c9b60ee9b",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        cflags       = {"-D_GNU_SOURCE", "-D_DEFAULT_SOURCE", "-DHAVE_XFIXES=1"},
        include_dirs = {"*/include", "*/include/X11/Xcursor", "*/include/X11/extensions", "*/src"},
        sources      = {"*/src/*.c"},
        targets      = { ["Xcursor"] = { kind = "shared", soname = "libXcursor.so.1" } },
        deps = {
            ["compat.x11"]        = "1.8.13",
            ["compat.xfixes"]     = "6.0.2",
            ["compat.xrender"]    = "0.9.12",
            ["compat.xorgproto"] = "2025.1",
        },
    },
}
