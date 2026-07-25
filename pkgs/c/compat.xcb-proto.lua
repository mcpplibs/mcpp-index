package = {
    spec        = "1",
    namespace   = "compat",
    name        = "xcb-proto",
    description = "XCB protocol XML descriptions and xcbgen generator",
    licenses    = {"MIT"},
    repo        = "https://gitlab.freedesktop.org/xorg/proto/xcbproto",
    type        = "package",

    xpm = {
        linux = {
            ["1.17.0"] = {
                url    = {
                    GLOBAL = "https://xorg.freedesktop.org/releases/individual/proto/xcb-proto-1.17.0.tar.xz",
                    CN     = "https://gitcode.com/mcpp-res/xcb-proto/releases/download/1.17.0/xcb-proto-1.17.0.tar.xz",
                },
                sha256 = "2c1bacd2110f4799f74de6ebb714b94cf6f80fb112316b1219480fd22562148c",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = {},
        generated_files = {
            ["mcpp_generated/xcb_proto_empty.c"] = "int mcpp_compat_xcb_proto_anchor(void) { return 0; }\n",
        },
        sources = {"mcpp_generated/xcb_proto_empty.c"},
        targets = { ["xcb_proto"] = { kind = "lib" } },
        deps    = {},
    },
}

import("xim.libxpkg.pkginfo")

function install()
    local srcdir = pkginfo.install_file():replace(".tar.xz", "")
    if not os.isdir(srcdir) then
        srcdir = "xcb-proto-" .. pkginfo.version()
    end
    os.tryrm(pkginfo.install_dir())
    os.mv(srcdir, pkginfo.install_dir())
    return true
end
