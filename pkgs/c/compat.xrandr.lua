package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.xrandr",
    description = "X Resize, Rotate and Reflect extension runtime library and public headers",
    licenses    = {"HPND-sell-variant"},
    repo        = "https://gitlab.freedesktop.org/xorg/lib/libxrandr",
    type        = "package",

    xpm = {
        linux = {
            ["1.5.5"] = {
                url    = "https://xorg.freedesktop.org/releases/individual/lib/libXrandr-1.5.5.tar.gz",
                sha256 = "23faedab4675890ba579b8103399132a139527306b18b500c6fe28e090e2a056",
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
        targets      = { ["Xrandr"] = { kind = "shared", soname = "libXrandr.so.2" } },
        deps = {
            ["compat.x11"]        = "1.8.13",
            ["compat.xext"]       = "1.3.7",
            ["compat.xrender"]    = "0.9.12",
            ["compat.xorgproto"] = "2025.1",
        },
    },
}
