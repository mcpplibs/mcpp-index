package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.xext",
    description = "X11 miscellaneous extensions runtime library and public headers",
    licenses    = {"HPND-sell-variant", "ISC", "MIT", "MIT-Open-Group"},
    repo        = "https://gitlab.freedesktop.org/xorg/lib/libxext",
    type        = "package",

    xpm = {
        linux = {
            ["1.3.7"] = {
                url    = "https://xorg.freedesktop.org/releases/individual/lib/libXext-1.3.7.tar.gz",
                sha256 = "6564608dc3b816b0cfddf0c7ddc62bc579055dd70b2f28113a618df2acb64189",
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
        targets      = { ["Xext"] = { kind = "shared", soname = "libXext.so.6" } },
        deps = {
            ["compat.x11"]        = "1.8.13",
            ["compat.xorgproto"] = "2025.1",
        },
    },
}
