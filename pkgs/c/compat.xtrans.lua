package = {
    spec        = "1",
    namespace   = "compat",
    name        = "xtrans",
    description = "X.Org transport layer support headers used by Xlib",
    licenses    = {"HPND-sell-variant", "MIT", "MIT-Open-Group"},
    repo        = "https://gitlab.freedesktop.org/xorg/lib/libxtrans",
    type        = "package",

    xpm = {
        linux = {
            ["1.6.0"] = {
                url    = {
                    GLOBAL = "https://xorg.freedesktop.org/releases/individual/lib/xtrans-1.6.0.tar.xz",
                    CN     = "https://gitcode.com/mcpp-res/xtrans/releases/download/1.6.0/xtrans-1.6.0.tar.xz",
                },
                sha256 = "faafea166bf2451a173d9d593352940ec6404145c5d1da5c213423ce4d359e92",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = {"include"},
        generated_files = {
            ["mcpp_generated/xtrans_empty.c"] = "int mcpp_compat_xtrans_headers_anchor(void) { return 0; }\n",
        },
        sources = {"mcpp_generated/xtrans_empty.c"},
        targets = { ["xtrans"] = { kind = "lib" } },
        deps    = {},
    },
}

import("xim.libxpkg.pkginfo")

local xtrans_headers = {
    "Xtrans.h",
    "Xtrans.c",
    "Xtransint.h",
    "Xtranslcl.c",
    "Xtranssock.c",
    "Xtransutil.c",
    "transport.c",
}

function install()
    local srcdir = pkginfo.install_file():replace(".tar.xz", "")
    if not os.isdir(srcdir) then
        srcdir = "xtrans-" .. pkginfo.version()
    end

    os.tryrm(pkginfo.install_dir())
    os.mv(srcdir, pkginfo.install_dir())

    local xtransdir = path.join(pkginfo.install_dir(), "include", "X11", "Xtrans")
    os.mkdir(path.join(pkginfo.install_dir(), "include"))
    os.mkdir(path.join(pkginfo.install_dir(), "include", "X11"))
    os.mkdir(xtransdir)
    for _, header in ipairs(xtrans_headers) do
        os.cp(path.join(pkginfo.install_dir(), header), path.join(xtransdir, header))
    end
    return true
end
