package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.xcb",
    description = "X C Binding core library built from upstream sources",
    licenses    = {"MIT"},
    repo        = "https://gitlab.freedesktop.org/xorg/lib/libxcb",
    type        = "package",

    xpm = {
        linux = {
            deps = {
                "xim:python@latest",
            },
            ["1.17.0"] = {
                url    = "https://xorg.freedesktop.org/releases/individual/lib/libxcb-1.17.0.tar.xz",
                sha256 = "599ebf9996710fea71622e6e184f3a8ad5b43d0e5fa8c4e407123c88a59a6d55",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = {"src", "include"},
        cflags = {
            "-D_GNU_SOURCE",
            "-D_DEFAULT_SOURCE",
            "-DHAVE_CONFIG_H",
        },
        sources = {
            "src/xcb_conn.c",
            "src/xcb_out.c",
            "src/xcb_in.c",
            "src/xcb_ext.c",
            "src/xcb_xid.c",
            "src/xcb_list.c",
            "src/xcb_util.c",
            "src/xcb_auth.c",
            "src/xproto.c",
            "src/bigreq.c",
            "src/xc_misc.c",
        },
        targets = { ["xcb"] = { kind = "shared", soname = "libxcb.so.1" } },
        deps = {
            ["compat.xau"]       = "1.0.12",
            ["compat.xcb-proto"] = "1.17.0",
            ["compat.xdmcp"]     = "1.1.5",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

local generated_headers = {
    "xcb.h",
    "xcbext.h",
    "xcb_windefs.h",
    "xproto.h",
    "bigreq.h",
    "xc_misc.h",
}

local function write_config_header(srcdir)
    io.writefile(path.join(srcdir, "config.h"), [[#ifndef MCPP_COMPAT_XCB_CONFIG_H
#define MCPP_COMPAT_XCB_CONFIG_H

#define HAVE_SENDMSG 1
#define HAVE_ABSTRACT_SOCKETS 1
#define HAVE_GETADDRINFO 1
#define XCB_QUEUE_BUFFER_SIZE 16384

#endif
]])
end

local function copy_public_headers(srcdir, installdir)
    local incdir = path.join(installdir, "include", "xcb")
    os.mkdir(path.join(installdir, "include"))
    os.mkdir(incdir)
    for _, header in ipairs(generated_headers) do
        os.cp(path.join(srcdir, header), path.join(incdir, header))
    end
end

local function sh_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function resolve_python()
    local python = pkginfo.build_dep("xim:python") or pkginfo.build_dep("python")
    if not python or not python.bin or not os.isdir(python.bin) then
        log.error("python build dependency not found")
        return nil
    end

    for _, name in ipairs({ "python3", "python" }) do
        local candidate = path.join(python.bin, name)
        if os.isfile(candidate) then
            return candidate
        end
    end

    local matches = os.files(path.join(python.bin, "python3.*")) or {}
    table.sort(matches)
    if #matches > 0 then
        return matches[#matches]
    end

    log.error("python executable not found under %s", python.bin)
    return nil
end

function install()
    local srcroot = pkginfo.install_file():replace(".tar.xz", "")
    if not os.isdir(srcroot) then
        srcroot = "libxcb-" .. pkginfo.version()
    end

    os.tryrm(pkginfo.install_dir())
    os.mv(srcroot, pkginfo.install_dir())

    local proto_dir = pkginfo.install_dir("compat:compat.xcb-proto", "1.17.0")
        or pkginfo.install_dir("compat.xcb-proto", "1.17.0")
    if not proto_dir or not os.isdir(proto_dir) then
        log.error("compat.xcb-proto@1.17.0 install dir not found")
        return false
    end

    local srcdir = path.join(pkginfo.install_dir(), "src")
    write_config_header(srcdir)

    local python = resolve_python()
    if not python then
        return false
    end

    os.cd(srcdir)
    for _, name in ipairs({ "xproto", "bigreq", "xc_misc" }) do
        local cmd = string.format(
            "%s c_client.py -c %s -l %s -s 3 -p %s %s",
            sh_quote(python),
            sh_quote("libxcb " .. pkginfo.version()),
            sh_quote("X Version 11"),
            sh_quote(proto_dir),
            sh_quote(path.join(proto_dir, "src", name .. ".xml"))
        )
        os.exec(cmd)
    end

    copy_public_headers(srcdir, pkginfo.install_dir())
    return true
end
